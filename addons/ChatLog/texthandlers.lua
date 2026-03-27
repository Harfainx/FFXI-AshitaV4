local M = {};
local atData = require('at_data');
local kiData = require('ki_data');

-- Helper to convert FFXI chat colors
local function GetColorFromMode(mode)
    -- This relies on the global table or standard mapping if desired,
    -- but usually ImGui will let us render colored text.
    -- For now, Ashita gives us e.mode, e.message.
    -- The e.message itself may contain color tags (\x1E\x01 etc).
    return nil;
end

function M.HandleIncomingText(e, settings, dataModule, configModule)
    -- Prevent infinite loops where Ashita 'print' generates a text_in event,
    -- which triggers another print(), crashing the game instantly via stack overflow.
    if e.injected then return end;
    if string.find(e.message, '%[ChatLog Debug%]') then return end;

    if configModule.debugMode == true then
        local hexMsg = e.message:gsub('[^%z\32-\126]', function(c)
            return string.format('<%02X>', string.byte(c))
        end)
        print(string.format("[ChatLog Debug] Mode: %d | Msg: %s", e.mode, hexMsg));
    end

    local allowedModes = settings.chat.enabledModes;
    
    -- Check if the current message mode is allowed
    -- Basic FFXI channels are e.mode % 256. Some modes might have high bits set.
    local baseMode = e.mode % 256;
    
    if allowedModes[baseMode] then
        -- Clean the string for ImGui rendering
        local cleanMsg = e.message
        
        -- Handle FFXI FD Tokens (FD [type] [data] FD)
        -- Reference: FD 02 = Auto-Translate, FD 07 = Item
        cleanMsg = cleanMsg:gsub('\xFD(.)(.-)\xFD', function(t, d)
            local type = string.byte(t);
            if type == 0x02 then -- Auto-Translate
                if #d >= 3 then
                    local b1, b2, b3 = string.byte(d, 1, 3);
                    
                    local phrase = (atData[b2] and atData[b2][b3]);
                    if phrase then
                        return ' {' .. phrase .. '} ';
                    end
                    
                    return string.format(' {?%02X%02X%02X} ', b1, b2, b3);
                end
                return '';
            elseif type == 0x07 or type == 0x09 or type == 0x0A then -- Item
                local id = 0;
                if #d >= 5 then -- Full Link
                    local b1, b2, b3, b4 = string.byte(d, 2, 5);
                    id = bit.bor(bit.lshift(b1, 24), bit.lshift(b2, 16), bit.lshift(b3, 8), b4);
                elseif #d >= 3 then -- Auto-Translate Item
                    local b2, b3 = string.byte(d, 2, 3);
                    if type == 0x09 then b2 = 0; end
                    if type == 0x0A then b3 = 0; end
                    id = (b2 * 256) + b3;
                end
                
                if id > 0 then
                    local item = AshitaCore:GetResourceManager():GetItemById(id);
                    if item then
                        local name = item.Name[1];
                        if (not name or name == '' or name == '.') then
                            name = item.LogNameSingular[1];
                        end
                        if (not name or name == '' or name == '.') then
                            name = 'Item #' .. id;
                        end
                        return ' [' .. name .. '] ';
                    end
                end
            elseif type == 0x13 or type == 0x15 or type == 0x16 then -- Key Item
                if #d >= 3 then
                    local b2, b3 = string.byte(d, 2, 3);
                    if type == 0x15 then b2 = 0; end
                    if type == 0x16 then b3 = 0; end
                    local id = (b2 * 256) + b3;
                    local name = AshitaCore:GetResourceManager():GetString('keyitems', id);
                    if (not name or name == '') then
                        name = kiData[id];
                    end
                    if name then
                        return ' [' .. name .. '] ';
                    end
                end
            end
            -- For other FD tokens or failures, just return a marker or empty
            return '';
        end);

        -- Also handle the EF 27/28 markers just in case some packets still use them
        cleanMsg = cleanMsg:gsub('\xEF\x27(....)\xEF\x28', function(c)
            local b1, b2, b3, b4 = string.byte(c, 1, 4);
            local id = bit.bor(bit.lshift(b1, 24), bit.lshift(b2, 16), bit.lshift(b3, 8), b4);
            local phrase = AshitaCore:GetResourceManager():GetString('autotran', id);
            return ' {' .. (phrase or '???') .. '} ';
        end);

        -- Remove Item Links/Formatting (0x1F + 1 byte or 0x1F ... 0x1F)
        cleanMsg = cleanMsg:gsub('\x1F[\x01-\xFF]', '');
        cleanMsg = cleanMsg:gsub('\x1F', '');
        
        -- Remove Color Tags (0x1E + 1 byte)
        cleanMsg = cleanMsg:gsub('\x1E[\x01-\xFF]', '')
        
        -- Remove special FFXI glyphs/control codes
        cleanMsg = cleanMsg:gsub('\xEF[\x01-\xFF]', '')
        cleanMsg = cleanMsg:gsub('\x07', ' ') -- Replace break markers with space
        
        -- Remove Shift-JIS / Non-ASCII residuals
        cleanMsg = cleanMsg:gsub('\x81[\x01-\xFF]', '') -- Shift-JIS punctuation
        cleanMsg = cleanMsg:gsub('\x87[\x01-\xFF]', '') -- Custom glyphs (e.g. 87 B2)
        cleanMsg = cleanMsg:gsub('\x7F[\x01-\xFF]', '') -- ASCII block/terminator
        cleanMsg = cleanMsg:gsub('\x7F', '')
        
        if settings.chat.showTimestamps then
            local t = os.date('%H:%M:%S');
            cleanMsg = string.format('[%s] %s', t, cleanMsg);
        end
        
        dataModule.AddMessage(baseMode, cleanMsg, settings.chat.customColors[baseMode]);
    end

    -- Handle Chat Blocking (cancelling the game's text event)
    local baseMode = e.mode % 256;
    if settings.chat.blockedModes and settings.chat.blockedModes[baseMode] then
        e.blocked = true;
    end

    -- Handle Advanced Blocking (Patterns)
    if baseMode == 127 and settings.chat.blockRoE then
        e.blocked = true;
    elseif baseMode == 131 or baseMode == 121 then
        local msg = e.message:strip_colors():strip_translate(true):lower();
        local p = settings.chat.blockPatterns;
        if p.exp and msg:contains('gains') and msg:contains('experience points') then e.blocked = true; end
        if p.lp and msg:contains('gains') and msg:contains('limit points') then e.blocked = true; end
        if p.cp and msg:contains('gains') and (msg:contains('capacity points') or msg:contains('capacity point')) then e.blocked = true; end
        if p.gil and msg:contains('obtains') and msg:contains('gil') then e.blocked = true; end
        if p.merit and msg:contains('earns a merit point') then e.blocked = true; end
        if p.jp and msg:contains('earns a job point') then e.blocked = true; end
        if p.chains and msg:contains('chain #') then e.blocked = true; end
        if p.sparks and msg:contains('sparks of eminence') then e.blocked = true; end
    end
end

return M;
