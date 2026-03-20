--[[
* ChatLog Addon for Ashita v4
]]--

addon.name      = 'ChatLog';
addon.author    = 'Harfainx';
addon.version   = '1.1.0';
addon.desc      = 'Secondary chat window for important channels';
addon.link      = '';

require('common');
local imgui = require('imgui');
local chat  = require('chat');

local config        = require('config');
local data          = require('data');
local texthandlers  = require('texthandlers');
local display       = require('display');

-- Module state
local M = {
    initialized = false
};

ashita.events.register('load', 'load_cb', function ()
    config.Initialize();
    data.Initialize(config.GetSettings());
    display.Initialize(config.GetSettings());
    M.initialized = true;
end);

ashita.events.register('unload', 'unload_cb', function ()
    if not M.initialized then return end;
    
    config.SaveSettings();
    display.Cleanup();
    data.Cleanup();
end);

ashita.events.register('d3d_present', 'd3d_present_cb', function ()
    if not M.initialized then return end;
    display.DrawWindow(config.GetSettings(), data.GetMessages());
end);

ashita.events.register('text_in', 'text_in_cb', function (e)
    if not M.initialized then return end;
    texthandlers.HandleIncomingText(e, config.GetSettings(), data, config);
end);

ashita.events.register('command', 'command_cb', function (e)
    local args = e.command:args();
    if (#args == 0 or args[1]:lower() ~= '/chatlog') then
        return;
    end
    
    e.blocked = true;
    if (#args >= 2) then
        local cmd = args[2]:lower();
        if (cmd == 'clear') then
            data.Clear();
            print(chat.header(addon.name) .. chat.message('Chat history cleared.'));
        elseif (cmd == 'debug') then
            config.debugMode = not config.debugMode;
            print(chat.header(addon.name) .. chat.message('Debug mode: ' .. tostring(config.debugMode)));
        else
            print(chat.header(addon.name) .. chat.message('Available commands:'));
            print(chat.header(addon.name) .. chat.message('  /chatlog clear  - Clears current chat history'));
            print(chat.header(addon.name) .. chat.message('  /chatlog debug  - Toggles debug mode to show chat modes'));
        end
    else
        print(chat.header(addon.name) .. chat.message('Available commands:'));
        print(chat.header(addon.name) .. chat.message('  /chatlog clear  - Clears current chat history'));
        print(chat.header(addon.name) .. chat.message('  /chatlog debug  - Toggles debug mode to show chat modes'));
    end
end);
