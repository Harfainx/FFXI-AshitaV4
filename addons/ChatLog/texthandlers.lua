local M = {};

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

    if configModule.debugMode then
        print(string.format("[ChatLog Debug] Mode: %d | Msg: %s", e.mode, e.message:gsub(string.char(0x1E), "<C>"):gsub(string.char(0x1F), "</C>")));
    end

    local allowedModes = settings.chat.enabledModes;
    
    -- Check if the current message mode is allowed
    -- Some text_in modes can be e.mode % 256 for basic FFXI channels
    local baseMode = e.mode;
    
    if allowedModes[baseMode] then
        -- Clean the string for ImGui rendering by stripping FFXI control characters
        local cleanMsg = e.message
        
        -- Remove Item Links (0x1F ... 0x1F)
        cleanMsg = cleanMsg:gsub(string.char(0x1F) .. '.-' .. string.char(0x1F), '')
        
        -- Remove Color Tags (0x1E + 1 byte)
        cleanMsg = cleanMsg:gsub(string.char(0x1E) .. '[%z\1-\255]', '')
        
        -- Remove Auto-Translate / Special FFXI Glyphs (0xEF + 1 byte)
        cleanMsg = cleanMsg:gsub(string.char(0xEF) .. '[%z\1-\255]', '')
        
        -- Remove Shift-JIS Punctuation/Brackets used in JP client / Linkshell names (0x81 + 1 byte)
        cleanMsg = cleanMsg:gsub(string.char(0x81) .. '[%z\1-\255]', '')
        
        -- Remove standard ASCII block characters like 0x7F
        cleanMsg = cleanMsg:gsub(string.char(0x7F) .. '[%z\1-\255]', '')
        
        dataModule.AddMessage(baseMode, cleanMsg, settings.chat.customColors[baseMode]);
    end
end

return M;
