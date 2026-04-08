local settings = require('settings');

local M = {};

-- Default settings
local default_settings = {
    window = {
        x = 400,
        y = 200,
        width = 300,
        height = 300,
        collapsed = false,
        bgColor = { 0, 0, 0, 0.7 },
        innerColor = { 0, 0, 0, 0.5 },
        titleBarColor = { 0.1, 0.4, 0.7, 1.0 },
        accentColor = { 0.2, 0.6, 1.0, 1.0 },
        systemTextColor = { 1.0, 1.0, 1.0, 1.0 },
        fontScale = 1.0
    },
    parser = {
        showPartyDamage = true,
        showTotal = true,
        showNormal = true,
        showCrit = true,
        showMiss = true,
        showHPR = true,
        showWS = true,
        showAbilities = true,
        showSpells = true
    }
};

local current_settings = nil;

function M.Initialize()
    current_settings = settings.load(default_settings);
end

function M.GetSettings()
    return current_settings;
end

function M.SaveSettings()
    if current_settings then
        settings.save();
    end
end

return M;
