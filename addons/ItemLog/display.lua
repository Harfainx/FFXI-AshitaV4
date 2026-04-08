local imgui = require('imgui');
local settingsUI = require('settings_ui');

local M = {};

function M.Initialize(settings)
end

function M.DrawWindow(settings, dataModule)
    local winSettings = settings.window;
    local popCount = 0;
    local varCount = 0;

    -- Styles
    if winSettings.windowColor then
        imgui.PushStyleColor(ImGuiCol_WindowBg or 2, winSettings.windowColor);
        popCount = popCount + 1;
    end
    if winSettings.innerColor then
        imgui.PushStyleColor(ImGuiCol_ChildBg or 3, winSettings.innerColor);
        imgui.PushStyleColor(ImGuiCol_PopupBg or 4, winSettings.innerColor);
        popCount = popCount + 2;
    end
    if winSettings.titleBarColor then
        imgui.PushStyleColor(ImGuiCol_TitleBg or 10, winSettings.titleBarColor);
        imgui.PushStyleColor(ImGuiCol_TitleBgActive or 11, winSettings.titleBarColor);
        imgui.PushStyleColor(ImGuiCol_TitleBgCollapsed or 12, winSettings.titleBarColor);
        popCount = popCount + 3;

        -- Red-bias fixes (Surgical strikes)
        local tCol = { winSettings.titleBarColor[1], winSettings.titleBarColor[2], winSettings.titleBarColor[3], winSettings.titleBarColor[4] };
        local hoverCol = { math.min(1.0, tCol[1] * 1.2), math.min(1.0, tCol[2] * 1.2), math.min(1.0, tCol[3] * 1.2), tCol[4] };

        if ImGuiCol_Header then imgui.PushStyleColor(ImGuiCol_Header, tCol); popCount = popCount + 1; end
        if ImGuiCol_HeaderHovered then imgui.PushStyleColor(ImGuiCol_HeaderHovered, hoverCol); popCount = popCount + 1; end
        if ImGuiCol_HeaderActive then imgui.PushStyleColor(ImGuiCol_HeaderActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_Button then imgui.PushStyleColor(ImGuiCol_Button, tCol); popCount = popCount + 1; end
        if ImGuiCol_ButtonHovered then imgui.PushStyleColor(ImGuiCol_ButtonHovered, hoverCol); popCount = popCount + 1; end
        if ImGuiCol_ButtonActive then imgui.PushStyleColor(ImGuiCol_ButtonActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_ResizeGrip then imgui.PushStyleColor(ImGuiCol_ResizeGrip, tCol); popCount = popCount + 1; end
        if ImGuiCol_ResizeGripHovered then imgui.PushStyleColor(ImGuiCol_ResizeGripHovered, hoverCol); popCount = popCount + 1; end
        if ImGuiCol_ResizeGripActive then imgui.PushStyleColor(ImGuiCol_ResizeGripActive, tCol); popCount = popCount + 1; end
        
        -- Legacy Index Surgical Strikes (36=TabUnfocused, 26=ResizeGripActive, etc.)
        local indices = { 21, 22, 23, 24, 25, 26, 36, 42, 43, 44 };
        for _, idx in ipairs(indices) do
            imgui.PushStyleColor(idx, tCol);
            popCount = popCount + 1;
        end
    end
    if winSettings.accentColor then
        local aCol = { winSettings.accentColor[1], winSettings.accentColor[2], winSettings.accentColor[3], winSettings.accentColor[4] };
        local aHover = { math.min(1.0, aCol[1] * 1.2), math.min(1.0, aCol[2] * 1.2), math.min(1.0, aCol[3] * 1.2), aCol[4] };
        
        if ImGuiCol_CheckMark or 18 then imgui.PushStyleColor(ImGuiCol_CheckMark or 18, aCol); popCount = popCount + 1; end
        if ImGuiCol_SliderGrab or 19 then imgui.PushStyleColor(ImGuiCol_SliderGrab or 19, aCol); popCount = popCount + 1; end
        if ImGuiCol_ScrollbarGrab then imgui.PushStyleColor(ImGuiCol_ScrollbarGrab, aCol); popCount = popCount + 1; end
        if ImGuiCol_ScrollbarGrabHovered then imgui.PushStyleColor(ImGuiCol_ScrollbarGrabHovered, aHover); popCount = popCount + 1; end
        
        imgui.PushStyleColor(14, {0,0,0,0}); -- Transparent scrollbar BG
        imgui.PushStyleColor(15, aCol);      -- Scrollbar Grab Index
        imgui.PushStyleColor(16, aHover);    -- Scrollbar Hover Index
        popCount = popCount + 3;
    end
    if winSettings.systemTextColor then
        imgui.PushStyleColor(ImGuiCol_Text or 0, winSettings.systemTextColor);
        popCount = popCount + 1;
    end

    -- Window Constraints to prevent crash on tiny size
    imgui.SetNextWindowSizeConstraints({ 150, 100 }, { 1000, 1000 });
    imgui.SetNextWindowPos({winSettings.x, winSettings.y}, ImGuiCond_FirstUseEver);
    imgui.SetNextWindowSize({winSettings.width, winSettings.height}, ImGuiCond_FirstUseEver);

    local mainFlags = 32; -- ImGuiWindowFlags_NoCollapse
    if imgui.Begin("ItemLog", true, mainFlags) then
        -- Sync Position/Size back to settings so window position persists across reloads
        local pos = {imgui.GetWindowPos()};
        local size = {imgui.GetWindowSize()};
        if pos[1] ~= winSettings.x or pos[2] ~= winSettings.y or size[1] ~= winSettings.width or size[2] ~= winSettings.height then
            winSettings.x, winSettings.y = pos[1], pos[2];
            winSettings.width, winSettings.height = size[1], size[2];
            settings.saveRequired = true;
        end

        -- Right-Click Menu
        if imgui.BeginPopupContextWindow() then
            if imgui.MenuItem("Settings...") then settingsUI.Open(); end
            imgui.Separator();
            
            local si = { winSettings.showInventory };
            if imgui.Checkbox("Display Inventory", si) then winSettings.showInventory = si[1]; end
            local sp = { winSettings.showPool };
            if imgui.Checkbox("Display Pool", sp) then winSettings.showPool = sp[1]; end
            local sd = { winSettings.showDrops };
            if imgui.Checkbox("Display Drops", sd) then winSettings.showDrops = sd[1]; end
            imgui.EndPopup();
        end

        -- 1. Inventory Counter (Top)
        if winSettings.showInventory then
            local c, m = dataModule.invCount, dataModule.invMax;
            local color = winSettings.inventoryColor or { 1, 1, 1, 1 };
            
            if winSettings.showInvThresholds and m > 0 then
                color = { 0.1, 1.0, 0.1, 1.0 }; -- Default Green
                local pct = (c / m) * 100;
                if pct >= (winSettings.invRedThreshold or 85) then 
                    color = { 1.0, 0.1, 0.1, 1.0 };
                elseif pct >= (winSettings.invYellowThreshold or 65) then 
                    color = { 1.0, 1.0, 0.1, 1.0 }; 
                end
            end
            
            imgui.TextColored(winSettings.inventoryColor or { 1, 1, 1, 1 }, "Inv: ");
            imgui.SameLine();
            imgui.TextColored(color, string.format("%d/%d", c, m));
            imgui.Separator();
        end

        -- 2. Pool
        local poolItems = dataModule.GetPoolItems();
        if winSettings.showPool and #poolItems > 0 then
            imgui.Text("Pool");
            imgui.Separator();
            
            local lineHeight = imgui.GetTextLineHeightWithSpacing();
            local calcHeight = (#poolItems * lineHeight) + 8; 

            if imgui.BeginChild("PoolChild", { 0, calcHeight }, 1, 8) then
                for _, item in ipairs(poolItems) do
                    imgui.Text(string.format("%s | %s - %d", item.name, item.bidder ~= "" and item.bidder or "(None)", item.bid));
                end
                imgui.EndChild();
            end
            imgui.Spacing();
        end

        -- 3. Drops
        if winSettings.showDrops then
            local drops = dataModule.GetDrops();
            if #drops > 0 then
                imgui.Text("Drops");
                imgui.Separator();
                if imgui.BeginChild("DropsChild", { 0, 0 }, 1) then
                    for _, msg in ipairs(drops) do
                        imgui.TextWrapped(msg:gsub("%%", "%%%%"));
                    end
                    imgui.EndChild();
                end
            end
        end

        imgui.End();
    end

    -- Settings Window
    settingsUI.DrawSettings(settings);

    if popCount > 0 then imgui.PopStyleColor(popCount); end

    -- Auto-save if window was moved/resized
    if settings.saveRequired then
        settings.saveRequired = false;
        require('config').save();
    end
end

return M;
