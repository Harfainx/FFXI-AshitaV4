local imgui = require('imgui');
local data = require('data');

local M = {};

function M.Initialize(settings)
    -- Initialization logic if needed
end

function M.DrawWindow(settings, messages)
    local winSettings = settings.window;
    
    -- Prepare window flags
    local windowFlags = bit.bor(
        ImGuiWindowFlags_NoSavedSettings,
        ImGuiWindowFlags_NoFocusOnAppearing,
        ImGuiWindowFlags_NoNav
    );
    
    -- Set window background color if specified
    local popCount = 0;
    if winSettings.bgColor then
        imgui.PushStyleColor(ImGuiCol_WindowBg, winSettings.bgColor);
        popCount = popCount + 1;
    end
    if winSettings.innerBgColor then
        imgui.PushStyleColor(ImGuiCol_ChildBg, winSettings.innerBgColor);
        popCount = popCount + 1;
    end
    
    -- Set initial position/size before Begin
    imgui.SetNextWindowPos({winSettings.x, winSettings.y}, ImGuiCond_FirstUseEver);
    imgui.SetNextWindowSize({winSettings.width, winSettings.height}, ImGuiCond_FirstUseEver);
    
    -- Note: the user requested a collapse button. ImGui window automatically provides a collapse button on the title bar
    -- if we pass a name and don't omit title bar.
    -- To keep it similar to XIUI but standard ImGui:
    if imgui.Begin("ChatLog", true, windowFlags) then
        -- Check if user moved or resized the window
        local pos = {imgui.GetWindowPos()};
        local size = {imgui.GetWindowSize()};
        
        if pos[1] ~= winSettings.x or pos[2] ~= winSettings.y or size[1] ~= winSettings.width or size[2] ~= winSettings.height then
            winSettings.x = pos[1];
            winSettings.y = pos[2];
            winSettings.width = size[1];
            winSettings.height = size[2];
            settings.window = winSettings;
            settings.saveRequired = true; -- Signal to save
        end
        
        -- Check collapsed state
        local isCollapsed = imgui.IsWindowCollapsed();
        if isCollapsed ~= winSettings.collapsed then
            winSettings.collapsed = isCollapsed;
            settings.saveRequired = true;
        end
        
        -- Draw messages if not collapsed
        if not isCollapsed then
            -- Context Menu for toggling channels
            if imgui.BeginPopupContextWindow("ChatLogSettings", 1) then
                imgui.Text("Channel Filters");
                imgui.Separator();
                
                local cfg = require('config').GetSettings().chat.enabledModes;
                local function DrawToggle(label, modes)
                    local state = { cfg[modes[1]] or false };
                    if imgui.Checkbox(label, state) then
                        for _, m in ipairs(modes) do
                            cfg[m] = state[1];
                        end
                    end
                end
                
                DrawToggle("Say", {1, 9});
                DrawToggle("Party", {5, 13});
                DrawToggle("Linkshell", {6, 14});
                DrawToggle("Linkshell 2", {213, 214});
                DrawToggle("Tell", {4, 12});
                DrawToggle("Shout", {10});
                DrawToggle("Yell", {3, 11});
                DrawToggle("Emotes", {15});
                DrawToggle("System", {123, 121});
                
                imgui.EndPopup();
            end

            -- Create a child region for scrolling
            imgui.BeginChild("ChatMessagesRegion");
            
            for i, msg in ipairs(messages) do
                -- Render message
                -- We can optionally set text colors based on mode here
                -- Mode 9 = Say (White), 10 = Shout (Yellow), 13 = Party (Cyan), 14 = Linkshell (Green)
                local color = msg.color or {1.0, 1.0, 1.0, 1.0};
                imgui.PushStyleColor(ImGuiCol_Text, color);
                imgui.TextWrapped(msg.text);
                imgui.PopStyleColor(1);
            end
            
            -- Auto-scroll if new message
            if data.newMessage then
                imgui.SetScrollHereY(1.0);
                data.newMessage = false;
            end
            
            imgui.EndChild();
        end
    end
    imgui.End();
    
    if popCount > 0 then
        imgui.PopStyleColor(popCount);
    end
    
    -- Save settings dynamically if changed
    if settings.saveRequired then
        settings.saveRequired = false;
        require('config').SaveSettings();
    end
end

function M.Cleanup()
    -- Any cleanup for display
end

return M;
