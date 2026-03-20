local settings = require('settings');

local M = {};

-- Default settings
local default_settings = {
    window = {
        x = 200,
        y = 200,
        width = 400,
        height = 300,
        collapsed = false,
        bgColor = { 0, 0, 0, 0.7 },
        innerBgColor = { 0, 0, 0, 0.5 },
        fontScale = 1.0,
        showPosition = true
    },
    chat = {
        maxMessages = 100,
        -- Chat modes config
        -- 9=Say, 10=Shout, 11=Tell(incoming?), 12=Tell(outgoing?), 13=Party, 14=Linkshell, 26=Yell, 214=Linkshell2 (Mode might vary, user can edit these if needed)
        enabledModes = {
            [1] = true,   -- Say (Out)
            [9] = true,   -- Say (In)
            [5] = true,   -- Party (Out)
            [13] = true,  -- Party (In)
            [6] = true,   -- Linkshell (Out)
            [14] = true,  -- Linkshell (In)
            [10] = true,  -- Shout/Server
            [4] = true,   -- Tell (Out)
            [12] = true,  -- Tell (In)
            [3] = true,   -- Yell (Out)
            [11] = true,  -- Yell (In)
            [213] = true, -- Linkshell2 (Out)
            [214] = true, -- Linkshell2 (In)
            [123] = true, -- Console/Party System
            [121] = true, -- Additional System messages (e.g. 16505 % 256)
            [15] = true   -- Emotes
        },
        -- Fallback colors for specific modes if needed, otherwise uses the text_in mode color
        customColors = {
            [1] = { 1.0, 1.0, 1.0, 1.0 },       [9] = { 1.0, 1.0, 1.0, 1.0 },
            [5] = { 0.67, 0.84, 0.9, 1.0 },     [13] = { 0.67, 0.84, 0.9, 1.0 },
            [6] = { 0.1, 0.8, 0.1, 1.0 },       [14] = { 0.1, 0.8, 0.1, 1.0 },
            [213] = { 0.1, 0.6, 0.4, 1.0 },     [214] = { 0.1, 0.6, 0.4, 1.0 },
            [4] = { 0.9, 0.5, 0.9, 1.0 },       [12] = { 0.9, 0.5, 0.9, 1.0 },
            [10] = { 1.0, 0.5, 0.0, 1.0 },
            [3] = { 1.0, 0.7, 0.0, 1.0 },       [11] = { 1.0, 0.7, 0.0, 1.0 },
            [123] = { 0.7, 0.7, 0.7, 1.0 },     [121] = { 0.7, 0.7, 0.7, 1.0 },
            [15] = { 0.7, 0.5, 0.7, 1.0 }
        }
    }
};

local current_settings = nil;

function M.Initialize()
    current_settings = settings.load(default_settings);
end

M.debugMode = false;

function M.GetSettings()
    return current_settings;
end

function M.SaveSettings()
    if current_settings then
        settings.save();
    end
end

return M;
