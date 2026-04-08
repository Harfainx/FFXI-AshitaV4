local imgui = require('imgui');

local M = {
    isOpen = { false }
};

function M.Open()
    M.isOpen[1] = true;
end

function M.DrawSettings(settings)
    if not M.isOpen[1] then return end;

    local winSettings = settings.window;
    local logSettings = settings.log;
    local popCount = 0;
    local varCount = 0;

    -- Styling (Same as ChatLog for consistency)
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

        local tCol = { winSettings.titleBarColor[1], winSettings.titleBarColor[2], winSettings.titleBarColor[3], winSettings.titleBarColor[4] };
        local hoverCol = { math.min(1.0, tCol[1] * 1.2), math.min(1.0, tCol[2] * 1.2), math.min(1.0, tCol[3] * 1.2), tCol[4] };

        if ImGuiCol_Header then imgui.PushStyleColor(ImGuiCol_Header, tCol); popCount = popCount + 1; end
        if ImGuiCol_HeaderHovered then imgui.PushStyleColor(ImGuiCol_HeaderHovered, hoverCol); popCount = popCount + 1; end
        if ImGuiCol_Tab then imgui.PushStyleColor(ImGuiCol_Tab, tCol); popCount = popCount + 1; end
        if ImGuiCol_TabHovered then imgui.PushStyleColor(ImGuiCol_TabHovered, hoverCol); popCount = popCount + 1; end
        if ImGuiCol_TabActive then imgui.PushStyleColor(ImGuiCol_TabActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_TabUnfocused then imgui.PushStyleColor(ImGuiCol_TabUnfocused, tCol); popCount = popCount + 1; end
        if ImGuiCol_TabUnfocusedActive then imgui.PushStyleColor(ImGuiCol_TabUnfocusedActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_Button then imgui.PushStyleColor(ImGuiCol_Button, tCol); popCount = popCount + 1; end
        if ImGuiCol_ButtonHovered then imgui.PushStyleColor(ImGuiCol_ButtonHovered, hoverCol); popCount = popCount + 1; end
        if ImGuiCol_ButtonActive then imgui.PushStyleColor(ImGuiCol_ButtonActive, tCol); popCount = popCount + 1; end
        
        -- Surgical strikes for indices (7=FrameBg, 25-27=ResizeGrip, 28-32=Tabs, etc.)
        local indices = { 7, 8, 9, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 36, 42, 43, 44, 55, 56, 57, 58, 59 };
        for _, idx in ipairs(indices) do
            imgui.PushStyleColor(idx, tCol);
            popCount = popCount + 1;
        end
    end
    if winSettings.accentColor then
        local aCol = { winSettings.accentColor[1], winSettings.accentColor[2], winSettings.accentColor[3], winSettings.accentColor[4] };
        local aHover = { math.min(1.0, aCol[1] * 1.2), math.min(1.0, aCol[2] * 1.2), math.min(1.0, aCol[3] * 1.2), aCol[4] };
        if ImGuiCol_SliderGrab then imgui.PushStyleColor(ImGuiCol_SliderGrab, aCol); popCount = popCount + 1; end
        if ImGuiCol_SliderGrabActive then imgui.PushStyleColor(ImGuiCol_SliderGrabActive, aHover); popCount = popCount + 1; end
        if ImGuiCol_CheckMark then imgui.PushStyleColor(ImGuiCol_CheckMark, aCol); popCount = popCount + 1; end
        if ImGuiCol_ScrollbarGrab then imgui.PushStyleColor(ImGuiCol_ScrollbarGrab, aCol); popCount = popCount + 1; end
        if ImGuiCol_ScrollbarGrabHovered then imgui.PushStyleColor(ImGuiCol_ScrollbarGrabHovered, aHover); popCount = popCount + 1; end
        if ImGuiCol_ScrollbarGrabActive then imgui.PushStyleColor(ImGuiCol_ScrollbarGrabActive, aCol); popCount = popCount + 1; end
        imgui.PushStyleColor(14, {0,0,0,0}); -- Transparent scrollbar BG
        popCount = popCount + 1;
    end
    -- Global Text Color (System Text)
    if winSettings.systemTextColor then
        imgui.PushStyleColor(ImGuiCol_Text or 0, winSettings.systemTextColor);
        popCount = popCount + 1;
    end

    local sFlags = 32; -- ImGuiWindowFlags_NoCollapse
    imgui.SetNextWindowSize({ 420, 500 }, ImGuiCond_FirstUseEver);
    if imgui.Begin("ItemLog Settings", M.isOpen, sFlags) then
        if imgui.BeginTabBar("ItemLogTabs") then
            -- Tab: Appearance
            if imgui.BeginTabItem("Appearance") then
                -- 1. Transparency Section
                imgui.Text("Transparency");
                imgui.Separator();
                local function TransSlider(label, color)
                    local alpha = { color[4] };
                    if imgui.SliderFloat(label, alpha, 0.0, 1.0) then color[4] = alpha[1]; end
                end
                TransSlider("Title Bar##Alpha", winSettings.titleBarColor);
                TransSlider("Accent##Alpha", winSettings.accentColor);
                TransSlider("Window##Alpha", winSettings.windowColor);
                TransSlider("Inner##Alpha", winSettings.innerColor);
                TransSlider("System Text##Alpha", winSettings.systemTextColor);

                imgui.Spacing();
                -- 2. Colors Section
                imgui.Text("Colors");
                imgui.Separator();
                imgui.ColorEdit4("Title Bar##Color", winSettings.titleBarColor);
                imgui.ColorEdit4("Accent##Color", winSettings.accentColor);
                imgui.ColorEdit4("Window##Color", winSettings.windowColor);
                imgui.ColorEdit4("Inner##Color", winSettings.innerColor);
                imgui.ColorEdit4("System Text##Color", winSettings.systemTextColor);

                imgui.Spacing();
                -- 3. Drop Display Section
                imgui.Text("Drop Display");
                imgui.Separator();
                local showOthers = { logSettings.showOtherDrops };
                if imgui.Checkbox("Show Others' Drops", showOthers) then logSettings.showOtherDrops = showOthers[1]; end
                
                imgui.Text("Max Drop History");
                local maxDrops = { logSettings.maxDrops };
                if imgui.SliderInt("##MaxDropHistory", maxDrops, 1, 50) then logSettings.maxDrops = maxDrops[1]; end

                imgui.Spacing();
                -- 4. Alert Thresholds Section
                imgui.Text("Alert Thresholds");
                imgui.Separator();
                local showThresh = { winSettings.showInvThresholds };
                if imgui.Checkbox("Use Alert Thresholds", showThresh) then winSettings.showInvThresholds = showThresh[1]; end
                
                local yellowT = { winSettings.invYellowThreshold };
                if imgui.SliderInt("Yellow %", yellowT, 1, 99) then 
                    winSettings.invYellowThreshold = yellowT[1];
                    if winSettings.invYellowThreshold >= winSettings.invRedThreshold then
                        winSettings.invRedThreshold = math.min(100, winSettings.invYellowThreshold + 1);
                    end
                end
                
                local redT = { winSettings.invRedThreshold };
                if imgui.SliderInt("Red %", redT, 1, 100) then 
                    winSettings.invRedThreshold = redT[1];
                    if winSettings.invRedThreshold <= winSettings.invYellowThreshold then
                        winSettings.invYellowThreshold = math.max(0, winSettings.invRedThreshold - 1);
                    end
                end

                imgui.EndTabItem();
            end

            -- Tab: Log Blocking
            if imgui.BeginTabItem("Log Blocking") then
                imgui.TextWrapped("Block item messages from the original game log window.");
                imgui.Separator();
                
                local b121 = { logSettings.blockMode121 };
                if imgui.Checkbox("Block Item Drops (Mode 121 - Pool)", b121) then logSettings.blockMode121 = b121[1]; end
                
                local b127 = { logSettings.blockMode127 };
                if imgui.Checkbox("Block Items Obtained (Mode 127 - Inv)", b127) then logSettings.blockMode127 = b127[1]; end

                imgui.EndTabItem();
            end
            imgui.EndTabBar();
        end
        
        imgui.Separator();
        if imgui.Button("Save Settings") then
            local config = require('config');
            config.save();
        end
        imgui.End();
    end

    if popCount > 0 then imgui.PopStyleColor(popCount); end
    if varCount > 0 then imgui.PopStyleVar(varCount); end
end

return M;
