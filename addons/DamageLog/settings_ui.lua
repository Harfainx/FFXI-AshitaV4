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
    
    -- Styles
    if winSettings.bgColor then
        imgui.PushStyleColor(ImGuiCol_WindowBg or 2, winSettings.bgColor);
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
        if ImGuiCol_FrameBg then imgui.PushStyleColor(ImGuiCol_FrameBg, {0.1, 0.1, 0.1, 0.5}); popCount = popCount + 1; end
        if ImGuiCol_FrameBgHovered then imgui.PushStyleColor(ImGuiCol_FrameBgHovered, {0.2, 0.2, 0.2, 0.5}); popCount = popCount + 1; end
        if ImGuiCol_FrameBgActive then imgui.PushStyleColor(ImGuiCol_FrameBgActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_ResizeGrip then imgui.PushStyleColor(ImGuiCol_ResizeGrip, tCol); popCount = popCount + 1; end
        if ImGuiCol_ResizeGripHovered then imgui.PushStyleColor(ImGuiCol_ResizeGripHovered, hoverCol); popCount = popCount + 1; end
        if ImGuiCol_ResizeGripActive then imgui.PushStyleColor(ImGuiCol_ResizeGripActive, tCol); popCount = popCount + 1; end

        -- Legacy Index Surgical Strikes (Indices likely to be the "Old Red" culprits)
        -- Surgical strikes for indices (7=FrameBg, 25-27=ResizeGrip, 28-32=Tabs, etc.)
        local indices = { 7, 8, 9, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 36, 42, 43, 44, 55, 56, 57, 58, 59 };
        for _, idx in ipairs(indices) do
            imgui.PushStyleColor(idx, tCol);
            popCount = popCount + 1;
        end
        if ImGuiStyleVar_TabBarBorderSize then
            imgui.PushStyleVar(ImGuiStyleVar_TabBarBorderSize, 0.0);
            varCount = varCount + 1;
        end
    end
    if winSettings.accentColor then
        imgui.PushStyleColor(ImGuiCol_CheckMark or 18, winSettings.accentColor);
        imgui.PushStyleColor(ImGuiCol_SliderGrab or 19, winSettings.accentColor);
        popCount = popCount + 2;
    end
    if winSettings.systemTextColor then
        imgui.PushStyleColor(ImGuiCol_Text or 0, winSettings.systemTextColor);
        popCount = popCount + 1;
    end

    imgui.SetNextWindowSize({ 400, 450 }, ImGuiCond_FirstUseEver);
    if imgui.Begin("DamageLog Settings", M.isOpen, 32) then -- NoCollapse
        if imgui.BeginTabBar("SettingsTabs") then
            
            -- Tab: Appearance
            if imgui.BeginTabItem("Appearance") then
                imgui.Text("Transparency");
                local titleOpacity = { winSettings.titleBarColor[4] };
                if imgui.SliderFloat("Title Bar##Alpha", titleOpacity, 0.0, 1.0) then winSettings.titleBarColor[4] = titleOpacity[1]; end
                local accentOpacity = { winSettings.accentColor[4] };
                if imgui.SliderFloat("Accent##Alpha", accentOpacity, 0.0, 1.0) then winSettings.accentColor[4] = accentOpacity[1]; end
                local bgOpacity = { winSettings.bgColor[4] };
                if imgui.SliderFloat("Window##Alpha", bgOpacity, 0.0, 1.0) then winSettings.bgColor[4] = bgOpacity[1]; end
                local innerOpacity = { winSettings.innerColor[4] };
                if imgui.SliderFloat("Inner##Alpha", innerOpacity, 0.0, 1.0) then winSettings.innerColor[4] = innerOpacity[1]; end
                local systemOpacity = { winSettings.systemTextColor[4] };
                if imgui.SliderFloat("System Text##Alpha", systemOpacity, 0.0, 1.0) then winSettings.systemTextColor[4] = systemOpacity[1]; end

                imgui.Separator();
                imgui.Text("Colors");
                if imgui.ColorEdit4("Title Bar##Color", winSettings.titleBarColor) then end
                if imgui.ColorEdit4("Accent##Color", winSettings.accentColor) then end
                if imgui.ColorEdit4("Window##Color", winSettings.bgColor) then end
                if imgui.ColorEdit4("Inner##Color", winSettings.innerColor) then end
                if imgui.ColorEdit4("System Text##Color", winSettings.systemTextColor) then end

                imgui.Separator();
                if imgui.SetWindowFontScale then
                    local fScale = { winSettings.fontScale };
                    if imgui.SliderFloat("Font Scale", fScale, 0.5, 2.0) then winSettings.fontScale = fScale[1]; end
                end
                imgui.EndTabItem();
            end

            -- Tab: Filters (Damage Stats)
            if imgui.BeginTabItem("Filters") then
                local p = settings.parser;
                local showParty = { p.showPartyDamage };
                if imgui.Checkbox("Track Party Damage", showParty) then p.showPartyDamage = showParty[1]; end
                imgui.Separator();
                
                local showTotal = { p.showTotal };
                if imgui.Checkbox("Show Total Damage", showTotal) then p.showTotal = showTotal[1]; end
                local showNormal = { p.showNormal };
                if imgui.Checkbox("Show Normal Melee", showNormal) then p.showNormal = showNormal[1]; end
                local showCrit = { p.showCrit };
                if imgui.Checkbox("Show Critical Hits", showCrit) then p.showCrit = showCrit[1]; end
                local showMiss = { p.showMiss };
                if imgui.Checkbox("Show Misses", showMiss) then p.showMiss = showMiss[1]; end
                local showHPR = { p.showHPR };
                if imgui.Checkbox("Show Hits Per Round", showHPR) then p.showHPR = showHPR[1]; end
                
                imgui.Separator();
                local showWS = { p.showWS };
                if imgui.Checkbox("Track Weaponskills", showWS) then p.showWS = showWS[1]; end
                local showJA = { p.showAbilities };
                if imgui.Checkbox("Track Job Abilities", showJA) then p.showAbilities = showJA[1]; end
                local showSpells = { p.showSpells };
                if imgui.Checkbox("Track Spells", showSpells) then p.showSpells = showSpells[1]; end

                imgui.EndTabItem();
            end

            imgui.EndTabBar();
        end
        
        if imgui.Button("Save Settings") then require('config').SaveSettings(); end
        imgui.End();
    end

    if popCount > 0 then imgui.PopStyleColor(popCount); end
    if varCount > 0 then imgui.PopStyleVar(varCount); end
end

return M;
