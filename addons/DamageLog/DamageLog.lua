require('common');
local chat = require('chat');
local config = require('config');
local data = require('data');
local texthandlers = require('texthandlers');
local display = nil; -- Loaded later to avoid circular dependencies

addon.name    = 'DamageLog';
addon.author  = 'Harfainx';
addon.version = '1.1.0';
addon.desc    = 'Tracks damage dealt by the player and party with DPS calculations';
addon.link    = '';

-- Module state
local M = {
    initialized = false
};

ashita.events.register('load', 'load_cb', function ()
    config.Initialize();
    data.Initialize();

    -- Load display modules after initialization
    display = require('display');
    display.Initialize(config.GetSettings());
    M.initialized = true;
end);

ashita.events.register('unload', 'unload_cb', function ()
    if not M.initialized then return end;
    config.SaveSettings();
end);

ashita.events.register('command', 'command_cb', function (e)
    if not M.initialized then return end;
    local args = e.command:args();
    if (#args > 0 and (args[1]:lower() == '/damagelog' or args[1]:lower() == '/dml')) then
        e.blocked = true;
        if #args > 1 and args[2]:lower() == 'clear' then
            data.Clear();
            print(chat.header(addon.name) .. chat.message('Damage data cleared.'));
        elseif #args > 1 and args[2]:lower() == 'settings' then
            require('settings_ui').Open();
        else
            print(chat.header(addon.name) .. chat.message('Available commands:'));
            print(chat.header(addon.name) .. chat.message('  /damagelog clear    - Clears damage data'));
            print(chat.header(addon.name) .. chat.message('  /damagelog settings - Opens settings window'));
        end
    end
end);

ashita.events.register('packet_in', 'packet_in_cb', function (e)
    if not M.initialized then return end;
    texthandlers.HandleIncomingPacket(e, config.GetSettings());
end);

ashita.events.register('d3d_present', 'd3d_present_cb', function ()
    if not M.initialized then return end;
    display.DrawWindow(config.GetSettings(), data);
end);
