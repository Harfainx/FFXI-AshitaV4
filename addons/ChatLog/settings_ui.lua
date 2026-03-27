local imgui = require('imgui');

local M = {
    isOpen = { false }
};

function M.Open()
    M.isOpen[1] = true;
end

function M.Draw(settings)
    if not M.isOpen[1] then return end;

    local winSettings = settings.window;
    local popCount = 0;
    local varCount = 0;
    
    -- Backgrounds (Individual pushes for absolute safety)
    if winSettings.bgColor then
        imgui.PushStyleColor(ImGuiCol_WindowBg or 2, winSettings.bgColor);
        popCount = popCount + 1;
    end
    if winSettings.innerBgColor then
        imgui.PushStyleColor(ImGuiCol_ChildBg or 3, winSettings.innerBgColor);
        imgui.PushStyleColor(ImGuiCol_PopupBg or 4, winSettings.innerBgColor);
        popCount = popCount + 2;
    end
    
    if winSettings.titleBarColor then
        imgui.PushStyleColor(ImGuiCol_TitleBg or 10, winSettings.titleBarColor);
        imgui.PushStyleColor(ImGuiCol_TitleBgActive or 11, winSettings.titleBarColor);
        imgui.PushStyleColor(ImGuiCol_TitleBgCollapsed or 12, winSettings.titleBarColor);
        popCount = popCount + 3;

        -- Primary Interactive Fixes (Manual surgical strike for red tabs)
        local tCol = { winSettings.titleBarColor[1], winSettings.titleBarColor[2], winSettings.titleBarColor[3], winSettings.titleBarColor[4] };
        local hoverCol = { math.min(1.0, tCol[1] * 1.2), math.min(1.0, tCol[2] * 1.2), math.min(1.0, tCol[3] * 1.2), tCol[4] };

        -- Traditional Named Pushes
        if ImGuiCol_Header then imgui.PushStyleColor(ImGuiCol_Header, tCol); popCount = popCount + 1; end
        if ImGuiCol_HeaderHovered then imgui.PushStyleColor(ImGuiCol_HeaderHovered, hoverCol); popCount = popCount + 1; end
        if ImGuiCol_HeaderActive then imgui.PushStyleColor(ImGuiCol_HeaderActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_Tab then imgui.PushStyleColor(ImGuiCol_Tab, tCol); popCount = popCount + 1; end
        if ImGuiCol_TabHovered then imgui.PushStyleColor(ImGuiCol_TabHovered, hoverCol); popCount = popCount + 1; end
        if ImGuiCol_TabActive then imgui.PushStyleColor(ImGuiCol_TabActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_TabUnfocused then imgui.PushStyleColor(ImGuiCol_TabUnfocused, tCol); popCount = popCount + 1; end
        if ImGuiCol_TabUnfocusedActive then imgui.PushStyleColor(ImGuiCol_TabUnfocusedActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_Button then imgui.PushStyleColor(ImGuiCol_Button, tCol); popCount = popCount + 1; end
        if ImGuiCol_ButtonHovered then imgui.PushStyleColor(ImGuiCol_ButtonHovered, hoverCol); popCount = popCount + 1; end
        if ImGuiCol_ButtonActive then imgui.PushStyleColor(ImGuiCol_ButtonActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_FrameBgActive then imgui.PushStyleColor(ImGuiCol_FrameBgActive, tCol); popCount = popCount + 1; end

        -- Legacy Index Surgical Strikes (Indices likely to be the "Old Red" culprits)
        -- 36=TabUnfocused, 16=ScrollbarHover
        local indices = { 21, 22, 23, 26, 36, 42, 43, 44, 55, 56, 57, 58, 59 };
        for _, idx in ipairs(indices) do
            imgui.PushStyleColor(idx, tCol);
            popCount = popCount + 1;
        end
        imgui.PushStyleColor(16, hoverCol); -- ScrollbarHover Index (Accent)
        popCount = popCount + 1;
        if ImGuiStyleVar_TabBarBorderSize then
            imgui.PushStyleVar(ImGuiStyleVar_TabBarBorderSize, 0.0);
            varCount = varCount + 1;
        end
    end
    -- Accent Color (Sliders & Scrollbars)
    if winSettings.accentColor then
        local aCol = { winSettings.accentColor[1], winSettings.accentColor[2], winSettings.accentColor[3], winSettings.accentColor[4] };
        local aHover = { math.min(1.0, aCol[1] * 1.2), math.min(1.0, aCol[2] * 1.2), math.min(1.0, aCol[3] * 1.2), aCol[4] };

        if ImGuiCol_SliderGrab then imgui.PushStyleColor(ImGuiCol_SliderGrab, aCol); popCount = popCount + 1; end
        if ImGuiCol_SliderGrabActive then imgui.PushStyleColor(ImGuiCol_SliderGrabActive, aHover); popCount = popCount + 1; end
        if ImGuiCol_ScrollbarGrab then imgui.PushStyleColor(ImGuiCol_ScrollbarGrab, aCol); popCount = popCount + 1; end
        if ImGuiCol_ScrollbarGrabHovered then imgui.PushStyleColor(ImGuiCol_ScrollbarGrabHovered, aHover); popCount = popCount + 1; end
        if ImGuiCol_ScrollbarGrabActive then imgui.PushStyleColor(ImGuiCol_ScrollbarGrabActive, aCol); popCount = popCount + 1; end
        if ImGuiCol_CheckMark then imgui.PushStyleColor(ImGuiCol_CheckMark, aCol); popCount = popCount + 1; end
        
        -- Manual Scrollbar Indices (14=Bg, 15=Grab, 16=GrabHovered, 17=GrabActive)
        imgui.PushStyleColor(14, {0,0,0,0}); -- Transparent BG
        imgui.PushStyleColor(15, aCol);
        imgui.PushStyleColor(16, aHover);
        imgui.PushStyleColor(17, aCol);
        popCount = popCount + 4;
    end
    
    -- Text Color (Index 0)
-- ... (skipping some logic for context but keeping the structure)
    imgui.SetNextWindowSize({ 420, 500 }, ImGuiCond_FirstUseEver);
    if imgui.Begin("ChatLog Settings", M.isOpen, sFlags) then
        if imgui.BeginTabBar("SettingsTabs") then
            -- Tab: Appearance
            if imgui.BeginTabItem("Appearance") then
                imgui.Text("Transparency");
                local bgOpacity = { settings.window.bgColor[4] };
                if imgui.SliderFloat("Window##Opacity", bgOpacity, 0.0, 1.0) then
                    settings.window.bgColor[4] = bgOpacity[1];
                    settings.saveRequired = true;
                end
                local innerOpacity = { settings.window.innerBgColor[4] };
                if imgui.SliderFloat("Inner##Opacity", innerOpacity, 0.0, 1.0) then
                    settings.window.innerBgColor[4] = innerOpacity[1];
                    settings.saveRequired = true;
                end
                local titleOpacity = { settings.window.titleBarColor[4] };
                if imgui.SliderFloat("Title Bar##Opacity", titleOpacity, 0.0, 1.0) then
                    settings.window.titleBarColor[4] = titleOpacity[1];
                    settings.saveRequired = true;
                end
                local accentOpacity = { settings.window.accentColor[4] };
                if imgui.SliderFloat("Accent##Opacity", accentOpacity, 0.0, 1.0) then
                    settings.window.accentColor[4] = accentOpacity[1];
                    settings.saveRequired = true;
                end

                imgui.Separator();
                imgui.Text("Colors");
                if imgui.ColorEdit4("Title Bar##Color", settings.window.titleBarColor) then settings.saveRequired = true; end
                if imgui.ColorEdit4("Accent##Color", settings.window.accentColor) then settings.saveRequired = true; end
                if imgui.ColorEdit4("System Text##Color", settings.window.systemTextColor) then settings.saveRequired = true; end
                if imgui.ColorEdit4("Window##Color", settings.window.bgColor) then settings.saveRequired = true; end
                if imgui.ColorEdit4("Inner##Color", settings.window.innerBgColor) then settings.saveRequired = true; end
                if imgui.ColorEdit4("Position##Color", settings.window.posColor) then settings.saveRequired = true; end
                if imgui.ColorEdit4("Inventory##Color", settings.window.invTextColor) then settings.saveRequired = true; end

                imgui.Separator();
                imgui.Text("Points");
                local se = { settings.window.showEXP };
                if imgui.Checkbox("Show Experience Points", se) then settings.window.showEXP = se[1]; settings.saveRequired = true; end
                if imgui.ColorEdit4("EXP Color", settings.window.expColor) then settings.saveRequired = true; end
                local sj = { settings.window.showJP };
                if imgui.Checkbox("Show Job Points", sj) then settings.window.showJP = sj[1]; settings.saveRequired = true; end
                if imgui.ColorEdit4("JP Color", settings.window.jpColor) then settings.saveRequired = true; end
                local sm = { settings.window.showMerits };
                if imgui.Checkbox("Show Merit Points", sm) then settings.window.showMerits = sm[1]; settings.saveRequired = true; end
                if imgui.ColorEdit4("Merit Color", settings.window.meritColor) then settings.saveRequired = true; end

                imgui.Separator();
                imgui.Text("Chat");
                local st = { settings.chat.showTimestamps };
                if imgui.Checkbox("Display Timestamps", st) then 
                    settings.chat.showTimestamps = st[1]; 
                    settings.saveRequired = true; 
                end

                imgui.Separator();
                imgui.Text("Alert Thresholds");
                local showThresh = { settings.window.showInvThresholds };
                if imgui.Checkbox("Use Alert Thresholds", showThresh) then settings.window.showInvThresholds = showThresh[1]; settings.saveRequired = true; end
                local yellowT = { settings.window.invYellowThreshold };
                if imgui.SliderInt("Yellow %", yellowT, 1, 99) then
                    settings.window.invYellowThreshold = yellowT[1];
                    if settings.window.invRedThreshold <= settings.window.invYellowThreshold then settings.window.invRedThreshold = math.min(100, settings.window.invYellowThreshold + 1); end
                    settings.saveRequired = true;
                end
                local redT = { settings.window.invRedThreshold };
                if imgui.SliderInt("Red %", redT, 2, 100) then
                    settings.window.invRedThreshold = redT[1];
                    if settings.window.invYellowThreshold >= settings.window.invRedThreshold then settings.window.invYellowThreshold = math.max(1, settings.window.invRedThreshold - 1); end
                    settings.saveRequired = true;
                end

                imgui.Separator();
                if imgui.SetWindowFontScale then
                    local fScale = { settings.window.fontScale };
                    if imgui.SliderFloat("Font Scale", fScale, 0.5, 2.0) then settings.window.fontScale = fScale[1]; settings.saveRequired = true; end
                end
                imgui.EndTabItem();
            end

            -- Tab: Chat Colors
            if imgui.BeginTabItem("Chat Colors") then
                local function ColorWidget(label, mode, syncMode)
                    if imgui.ColorEdit4(label, settings.chat.customColors[mode]) then
                        if syncMode then
                            settings.chat.customColors[syncMode] = {
                                settings.chat.customColors[mode][1], settings.chat.customColors[mode][2],
                                settings.chat.customColors[mode][3], settings.chat.customColors[mode][4]
                            };
                        end
                        settings.saveRequired = true;
                    end
                end
                if imgui.BeginChild("ChatColorsScroll", { 0, 0 }, 1) then
                    ColorWidget("Say", 9, 1);
                    ColorWidget("Party", 13, 5);
                    ColorWidget("Linkshell", 14, 6);
                    ColorWidget("Linkshell 2", 214, 213);
                    ColorWidget("Tell", 12, 4);
                    ColorWidget("Shout", 10);
                    ColorWidget("Yell", 11, 3);
                    ColorWidget("Emotes", 15, 7);
                    ColorWidget("System", 123);
                    ColorWidget("Secondary System", 121);
                    imgui.EndChild();
                end
                imgui.EndTabItem();
            end

            -- Tab: Log Blocking
            if imgui.BeginTabItem("Log Blocking") then
                imgui.TextWrapped("Block messages from the original game log window.");
                imgui.Separator();
                if imgui.BeginChild("BlockingScroll", { 0, 0 }, 1) then
                    local function BlockToggle(label, mode, syncMode)
                        local blk = { settings.chat.blockedModes[mode] };
                        if imgui.Checkbox(label, blk) then
                            settings.chat.blockedModes[mode] = blk[1];
                            if syncMode then settings.chat.blockedModes[syncMode] = blk[1]; end
                            settings.saveRequired = true;
                        end
                    end
                    local function PatternToggle(label, key)
                        local blk = { settings.chat.blockPatterns[key] };
                        if imgui.Checkbox(label, blk) then
                            settings.chat.blockPatterns[key] = blk[1];
                            settings.saveRequired = true;
                        end
                    end

                    imgui.Text("Channel Blocks");
                    imgui.Separator();
                    BlockToggle("Block Say", 9, 1);
                    BlockToggle("Block Party", 13, 5);
                    BlockToggle("Block Linkshell", 14, 6);
                    BlockToggle("Block Linkshell 2", 214, 213);
                    BlockToggle("Block Tell", 12, 4);
                    BlockToggle("Block Shout", 10);
                    BlockToggle("Block Yell", 11, 3);
                    BlockToggle("Block Emotes", 15, 7);
                    BlockToggle("Block System", 123);
                    BlockToggle("Block Secondary System", 121);
                    
                    imgui.Spacing();
                    imgui.Text("Activity Blocks (Mode 131)");
                    imgui.Separator();
                    PatternToggle("Block LP Gains", "lp");
                    PatternToggle("Block EXP Gains", "exp");
                    PatternToggle("Block CP Gains", "cp");
                    PatternToggle("Block Gil Obtained", "gil");
                    PatternToggle("Block Merit Gains", "merit");
                    PatternToggle("Block JP Gains", "jp");
                    PatternToggle("Block EXP/CP/LP Chains", "chains");

                    imgui.Spacing();
                    imgui.Text("System Blocks");
                    imgui.Separator();
                    local roe = { settings.chat.blockRoE };
                    if imgui.Checkbox("Block all RoE Messages (Mode 127)", roe) then
                        settings.chat.blockRoE = roe[1];
                        settings.saveRequired = true;
                    end
                    PatternToggle("Block Sparks Messages", "sparks");
                    imgui.EndChild();
                end
                imgui.EndTabItem();
            end

            imgui.EndTabBar();
        end
        imgui.End();
    end
    
    -- Restore style
    if popCount > 0 then imgui.PopStyleColor(popCount); end
    if varCount > 0 then imgui.PopStyleVar(varCount); end
end

return M;
