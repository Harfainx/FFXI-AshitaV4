local dataModule = require('data');
local config = require('config');

local M = {};

function M.HandleIncomingPacket(e, settings)
    if e.id == 0x28 then
        local data = e.data;
        local bitOffset = 40; -- Skip header (5 bytes)
        
        local actorId = dataModule.UnpackBits(data, bitOffset, 32); bitOffset = bitOffset + 32;
        local targetCount = dataModule.UnpackBits(data, bitOffset, 6); bitOffset = bitOffset + 6;
        
        -- Check if we should track this actor
        local partyMgr = AshitaCore:GetMemoryManager():GetParty();
        if not partyMgr then return end;

        local isSelf = (actorId == partyMgr:GetMemberServerId(0));
        local isParty = false;
        for i = 1, 5 do
            if actorId == partyMgr:GetMemberServerId(i) then
                isParty = true;
                break;
            end
        end

        local s = config.GetSettings();
        if not s then return end;
        local trackParty = s.parser.showPartyDamage;
        if not isSelf and not (trackParty and isParty) then return end;

        local res_sum = dataModule.UnpackBits(data, bitOffset, 4); bitOffset = bitOffset + 4;
        local category = dataModule.UnpackBits(data, bitOffset, 4); bitOffset = bitOffset + 4;
        local actionId = dataModule.UnpackBits(data, bitOffset, 32); bitOffset = bitOffset + 32;
        local info = dataModule.UnpackBits(data, bitOffset, 32); bitOffset = bitOffset + 32;
        
        -- Track Melee Rounds
        if category == 1 or category == 11 then
            dataModule.AddMeleeRound(actorId);
        end

        -- Damage Message Whitelist (Strictly engagement only)
        local damageMessages = { 
            [1]=true,   -- Melee Hit
            [67]=true,  -- Melee Crit
            [185]=true, -- WS Hit
            [186]=true, -- WS Hit
            [187]=true, -- WS Hit
            [2]=true,   -- Spell Damage
            [252]=true, -- Spell Damage
            [264]=true, -- Spell Damage
            [225]=true, -- Pet WS
            [226]=true, -- Pet WS
            [302]=true, -- Additional Effect
        };

        for t = 1, targetCount do
            local targetId = dataModule.UnpackBits(data, bitOffset, 32); bitOffset = bitOffset + 32;
            local resultCount = dataModule.UnpackBits(data, bitOffset, 4); bitOffset = bitOffset + 4;
            
            -- Only track damage to units NOT in our party (monsters)
            local isTargetInParty = false;
            for i = 0, 5 do
                if partyMgr:GetMemberServerId(i) == targetId then
                    isTargetInParty = true;
                    break;
                end
            end

            for r = 1, resultCount do
                local resolution = dataModule.UnpackBits(data, bitOffset, 3); bitOffset = bitOffset + 3;
                local kind = dataModule.UnpackBits(data, bitOffset, 2); bitOffset = bitOffset + 2;
                local animation = dataModule.UnpackBits(data, bitOffset, 12); bitOffset = bitOffset + 12;
                local res_info = dataModule.UnpackBits(data, bitOffset, 5); bitOffset = bitOffset + 5;
                local res_scale = dataModule.UnpackBits(data, bitOffset, 5); bitOffset = bitOffset + 5;
                local param = dataModule.UnpackBits(data, bitOffset, 17); bitOffset = bitOffset + 17;
                local message = dataModule.UnpackBits(data, bitOffset, 10); bitOffset = bitOffset + 10;
                local unknown = dataModule.UnpackBits(data, bitOffset, 31); bitOffset = bitOffset + 31;
                
                if not isTargetInParty then
                    local isMiss = (resolution == 1 or resolution == 2 or resolution == 3);
                    local isPhysical = (category == 1 or category == 2 or category == 3 or category == 11 or category == 12);

                    if damageMessages[message] then
                        dataModule.AddDamage(actorId, category, actionId, param, (message == 67), false);
                    elseif isMiss and isPhysical then
                        dataModule.AddDamage(actorId, category, actionId, 0, false, true);
                    end
                end
                
                -- Additional Effect
                local hasAdditional = dataModule.UnpackBits(data, bitOffset, 1); bitOffset = bitOffset + 1;
                if hasAdditional == 1 then
                    local pKind = dataModule.UnpackBits(data, bitOffset, 6); bitOffset = bitOffset + 6;
                    local pInfo = dataModule.UnpackBits(data, bitOffset, 4); bitOffset = bitOffset + 4;
                    local pVal = dataModule.UnpackBits(data, bitOffset, 17); bitOffset = bitOffset + 17;
                    local pMsg = dataModule.UnpackBits(data, bitOffset, 10); bitOffset = bitOffset + 10;
                    if not isTargetInParty and damageMessages[pMsg] then
                        dataModule.AddDamage(actorId, category, actionId, pVal, false, false);
                    end
                end
                
                -- Reaction/Spikes
                local hasSpikes = dataModule.UnpackBits(data, bitOffset, 1); bitOffset = bitOffset + 1;
                if hasSpikes == 1 then
                    bitOffset = bitOffset + 34; -- Skip spikes data (6+4+14+10 bits)
                end
            end
        end
    end
end

return M;
