local M = {};
local atData = require('at_data');

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
                    
                    -- Fallback to showing IDs if not in dictionary
                    return string.format(' {?%02X%02X%02X} ', b1, b2, b3);
                end
                return ' {?} ';
            elseif type == 0x07 then -- Item Link
                if #d >= 5 then
                    local b1, b2, b3, b4 = string.byte(d, 2, 5); -- Offset 2-5
                    local id = bit.bor(bit.lshift(b1, 24), bit.lshift(b2, 16), bit.lshift(b3, 8), b4);
                    local item = AshitaCore:GetResourceManager():GetItemById(id);
                    if item then
                        return ' [' .. item.Name[1] .. '] ';
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

        -- Remove Item Links (0x1F ... 0x1F) - Old style or fallback
        cleanMsg = cleanMsg:gsub(string.char(0x1F) .. '.-' .. string.char(0x1F), '')
        
        -- Remove Color Tags (0x1E + 1 byte)
        cleanMsg = cleanMsg:gsub(string.char(0x1E) .. '[%z\1-\255]', '')
        
        -- Remove special FFXI glyphs/control codes (0xEF + 1 byte)
        cleanMsg = cleanMsg:gsub(string.char(0xEF) .. '[%z\1-\255]', '')
        
        -- Remove Shift-JIS / Non-ASCII residuals (be careful not to wipe UTF-8 if we ever support it)
        -- For now, keep it simple and only strip proven problematic bytes
        cleanMsg = cleanMsg:gsub('\x81[%z\1-\255]', '') -- Shift-JIS punctuation
        cleanMsg = cleanMsg:gsub('\x7F[%z\1-\255]', '') -- ASCII block
        
        dataModule.AddMessage(baseMode, cleanMsg, settings.chat.customColors[baseMode]);
    end
end

return M;
