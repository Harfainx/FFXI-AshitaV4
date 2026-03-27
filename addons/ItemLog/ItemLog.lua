--[[
* ItemLog Addon
* Standalone addon for tracking treasure pools and item drops
]]--

addon.name      = 'ItemLog';
addon.author    = 'Harfainx';
addon.version   = '1.1.0';
addon.desc      = 'Tracks treasure pools and recent item drops';
addon.link      = '';

require('common');
local config        = require('config');
local data          = require('data');
local texthandlers  = require('texthandlers');
local display       = require('display');

-- Module state
local M = {
    initialized = false,
    lastUpdate = 0,
    settings = nil
};

ashita.events.register('load', 'load_cb', function ()
    M.settings = config.load();
    data.Initialize(M.settings);
    display.Initialize(M.settings);
    M.initialized = true;
end);

ashita.events.register('unload', 'unload_cb', function ()
    if not M.initialized then return end;
    config.save();
end);

ashita.events.register('d3d_present', 'd3d_present_cb', function ()
    if not M.initialized then return end;
    
    -- Throttled updates for memory-heavy calls
    local now = os.clock();
    if (now - M.lastUpdate) > 0.5 then
        data.UpdateInventory();
        data.ReadPoolFromMemory();
        M.lastUpdate = now;
    end

    display.DrawWindow(M.settings, data);
end);

ashita.events.register('text_in', 'text_in_cb', function (e)
    if not M.initialized then return end;
    texthandlers.HandleIncomingText(e, M.settings, data);
end);

return M;
