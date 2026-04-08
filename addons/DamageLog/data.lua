local M = {};
local lsbMapping = require('lsb_mapping');

-- Stats structure:
-- M.stats[id] = { name, total, melee = { dmg, hits, misses, crits }, ws = {}, ja = {}, spells = {} }
M.stats = {};

function M.Initialize()
    M.stats = {};
end

function M.Clear()
    M.stats = {};
end

-- Unified bit-unpacking helper (Little Endian)
-- Matches FFXI/Ashita native byte/bit order
function M.UnpackBits(data, bitOffset, bits)
    local value = 0;
    for i = 0, bits - 1 do
        local absBit = bitOffset + i;
        local byteIdx = math.floor(absBit / 8) + 1;
        if byteIdx <= #data then
            local byte = string.byte(data, byteIdx);
            if bit.band(byte, bit.lshift(1, absBit % 8)) ~= 0 then
                value = value + math.pow(2, i);
            end
        end
    end
    return value;
end

-- Alias for legacy calls if any remain
M.UnpackBitsLE = M.UnpackBits;

function M.GetOrCreateInfo(id)
    if not M.stats[id] then
        local name = "Unknown";
        -- Attempt to get name from entity manager
        local entity = AshitaCore:GetMemoryManager():GetEntity();
        if entity then
             -- We need to find the entity index for this ID
             for i = 0, 2303 do
                 if entity:GetServerId(i) == id then
                     name = entity:GetName(i);
                     break;
                 end
             end
        end
        
        M.stats[id] = {
            name = name,
            total = 0,
            startTime = 0,
            lastTime = 0,
            melee = { dmg = 0, hits = 0, misses = 0, crits = 0, rounds = 0 },
            ws = {},
            ja = {},
            spells = {}
        };
    end
    return M.stats[id];
end

function M.AddMeleeRound(actorId)
    local info = M.GetOrCreateInfo(actorId);
    info.melee.rounds = info.melee.rounds + 1;
    info.lastTime = os.time();
end

function M.AddDamage(actorId, category, actionId, value, isCrit, isMiss)
    local info = M.GetOrCreateInfo(actorId); if not info then return end;
    
    if info.startTime == 0 then info.startTime = os.time(); end
    info.lastTime = os.time();
    
    if isMiss then
        if category == 1 or category == 11 then -- Melee
            info.melee.misses = info.melee.misses + 1;
        end
        return;
    end

    info.total = info.total + value;
    
    if category == 1 or category == 11 then -- Melee
        info.melee.dmg = info.melee.dmg + value;
        info.melee.hits = info.melee.hits + 1;
        if isCrit then
            info.melee.crits = info.melee.crits + 1;
        end
    elseif category == 3 then -- Weaponskills
        if not info.ws[actionId] then
            local rm = AshitaCore:GetResourceManager();
            local res = nil;
            if rm.GetWeaponSkill then res = rm:GetWeaponSkill(actionId); end
            if not res and rm.GetWeaponSkillById then res = rm:GetWeaponSkillById(actionId); end
            
            -- LSB Fallback
            local name = res and res.Name[1] or lsbMapping.weaponskills[actionId];
            info.ws[actionId] = { name = name or ("WS #" .. actionId), total = 0, last = 0 };
        end
        info.ws[actionId].total = info.ws[actionId].total + value;
        info.ws[actionId].last = value;
    elseif category == 4 or category == 8 then -- Spells
        if not info.spells[actionId] then
            local rm = AshitaCore:GetResourceManager();
            local res = nil;
            if rm.GetSpell then res = rm:GetSpell(actionId); end
            if not res and rm.GetSpellById then res = rm:GetSpellById(actionId); end
            
            local name = res and res.Name[1] or lsbMapping.spells[actionId];
            info.spells[actionId] = { name = name or ("Spell #" .. actionId), total = 0, last = 0 };
        end
        info.spells[actionId].total = info.spells[actionId].total + value;
        info.spells[actionId].last = value;
    elseif category == 6 or category == 14 or category == 15 then -- Job Abilities
        if not info.ja[actionId] then
            local rm = AshitaCore:GetResourceManager();
            local res = nil;
            if rm.GetAbility then res = rm:GetAbility(actionId); end
            if not res and rm.GetAbilityById then res = rm:GetAbilityById(actionId); end
            
            local name = res and res.Name[1] or lsbMapping.abilities[actionId];
            info.ja[actionId] = { name = name or ("Ability #" .. actionId), total = 0, last = 0 };
        end
        info.ja[actionId].total = info.ja[actionId].total + value;
        info.ja[actionId].last = value;
    end
end

return M;
