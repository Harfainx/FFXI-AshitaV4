local imgui = require('imgui');

local M = {};

function M.Initialize(settings)
end

function M.DrawWindow(settings, dataModule)
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
    end
    if winSettings.accentColor then
        imgui.PushStyleColor(ImGuiCol_CheckMark or 18, winSettings.accentColor);
        imgui.PushStyleColor(ImGuiCol_SliderGrab or 19, winSettings.accentColor);
        imgui.PushStyleColor(15, winSettings.accentColor); -- Scrollbar Grab
        imgui.PushStyleColor(16, winSettings.accentColor); -- Scrollbar Grab Hovered
        imgui.PushStyleColor(17, winSettings.accentColor); -- Scrollbar Grab Active
        popCount = popCount + 5;
    end
    if winSettings.systemTextColor then
        imgui.PushStyleColor(ImGuiCol_Text or 0, winSettings.systemTextColor);
        popCount = popCount + 1;
    end
    if winSettings.titleBarColor then
        local tCol = { winSettings.titleBarColor[1], winSettings.titleBarColor[2], winSettings.titleBarColor[3], winSettings.titleBarColor[4] };
        local hoverCol = { math.min(1.0, tCol[1] * 1.2), math.min(1.0, tCol[2] * 1.2), math.min(1.0, tCol[3] * 1.2), tCol[4] };
        
        -- Traditional Named Pushes
        if ImGuiCol_Header then imgui.PushStyleColor(ImGuiCol_Header, tCol); popCount = popCount + 1; end
        if ImGuiCol_HeaderHovered then imgui.PushStyleColor(ImGuiCol_HeaderHovered, hoverCol); popCount = popCount + 1; end
        if ImGuiCol_HeaderActive then imgui.PushStyleColor(ImGuiCol_HeaderActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_Button then imgui.PushStyleColor(ImGuiCol_Button, tCol); popCount = popCount + 1; end
        if ImGuiCol_ButtonHovered then imgui.PushStyleColor(ImGuiCol_ButtonHovered, hoverCol); popCount = popCount + 1; end
        if ImGuiCol_ButtonActive then imgui.PushStyleColor(ImGuiCol_ButtonActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_FrameBgActive then imgui.PushStyleColor(ImGuiCol_FrameBgActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_ResizeGrip then imgui.PushStyleColor(ImGuiCol_ResizeGrip, tCol); popCount = popCount + 1; end
        if ImGuiCol_ResizeGripHovered then imgui.PushStyleColor(ImGuiCol_ResizeGripHovered, hoverCol); popCount = popCount + 1; end
        if ImGuiCol_ResizeGripActive then imgui.PushStyleColor(ImGuiCol_ResizeGripActive, tCol); popCount = popCount + 1; end

        -- Legacy Index Surgical Strikes (Indices likely to be the "Old Red" culprits)
        local indices = { 21, 22, 23, 26, 36, 42, 43, 44, 55, 56, 57, 58, 59 };
        for _, idx in ipairs(indices) do
            imgui.PushStyleColor(idx, tCol);
            popCount = popCount + 1;
        end
    end

    imgui.SetNextWindowSizeConstraints({ 200, 100 }, { 1000, 1000 });
    imgui.SetNextWindowPos({winSettings.x, winSettings.y}, ImGuiCond_FirstUseEver);
    imgui.SetNextWindowSize({winSettings.width, winSettings.height}, ImGuiCond_FirstUseEver);

    local flags = 32; -- NoCollapse
    if imgui.Begin("DamageLog", true, flags) then
        if imgui.SetWindowFontScale then imgui.SetWindowFontScale(winSettings.fontScale); end

        -- Sync Position/Size back to settings so window position persists across reloads
        local pos = {imgui.GetWindowPos()};
        local size = {imgui.GetWindowSize()};
        if pos[1] ~= winSettings.x or pos[2] ~= winSettings.y or size[1] ~= winSettings.width or size[2] ~= winSettings.height then
            winSettings.x, winSettings.y = pos[1], pos[2];
            winSettings.width, winSettings.height = size[1], size[2];
            settings.saveRequired = true;
        end

        -- Right-click popup
        if imgui.BeginPopupContextWindow() then
            if imgui.MenuItem("Settings...") then require('settings_ui').Open(); end
            if imgui.MenuItem("Clear Data") then dataModule.Clear(); end
            imgui.EndPopup();
        end

        local p = settings.parser;
        if imgui.Button("Clear") then dataModule.Clear(); end
        imgui.Separator();

        -- Render Stats Table
        local stats = dataModule.stats;
        for id, info in pairs(stats) do
            -- Filter: Only show actors with actual engagement (fixes Monberaux issue)
            if info.total > 0 or info.melee.misses > 0 then
                local dur = (info.startTime > 0) and (os.time() - info.startTime) or 0;
                local dps = (dur > 0) and math.floor(info.total / dur) or 0;
                local label = string.format("%s##%s", info.name, id);

                if imgui.TreeNode(label) then
                    imgui.TextColored({1, 1, 0.5, 1}, "Total Damage: " .. info.total);
                    imgui.SameLine();
                    imgui.TextColored({0.7, 0.9, 1.0, 1}, "[DPS: " .. dps .. "]");
                    
                    if p.showNormal or p.showCrit or p.showMiss then
                        imgui.Separator();
                        if imgui.TreeNode("Melee##" .. id) then
                            if p.showNormal then imgui.Text("  Normal: " .. info.melee.dmg .. " (" .. info.melee.hits .. " hits)"); end
                            if p.showCrit then 
                                local critRate = (info.melee.hits > 0) and (info.melee.crits / info.melee.hits * 100) or 0;
                                imgui.Text(string.format("  Crits: %d (%.0f%%)", info.melee.crits, critRate)); 
                            end
                            if p.showMiss then 
                                local missRate = (info.melee.hits + info.melee.misses > 0) and (info.melee.misses / (info.melee.hits + info.melee.misses) * 100) or 0;
                                imgui.Text(string.format("  Misses: %d (%.0f%%)", info.melee.misses, missRate)); 
                            end
                            if p.showHPR then 
                                local hpr = (info.melee.rounds > 0) and (info.melee.hits / info.melee.rounds) or 0;
                                imgui.Text(string.format("  HPR: %.2f", hpr)); 
                            end
                            imgui.TreePop();
                        end
                    end

                    if (p.showWS and next(info.ws)) then
                        imgui.Separator();
                        if imgui.TreeNode("Weaponskills##" .. id) then
                            for wsId, ws in pairs(info.ws) do
                                imgui.Text(string.format("%s: %d (Last: %d)", ws.name, ws.total, ws.last));
                            end
                            imgui.TreePop();
                        end
                    end

                    if (p.showAbilities and next(info.ja)) then
                        imgui.Separator();
                        if imgui.TreeNode("Abilities##" .. id) then
                            for jaId, ja in pairs(info.ja) do
                                imgui.Text(string.format("%s: %d (Last: %d)", ja.name, ja.total, ja.last));
                            end
                            imgui.TreePop();
                        end
                    end

                    if (p.showSpells and next(info.spells)) then
                        imgui.Separator();
                        if imgui.TreeNode("Spells##" .. id) then
                            for sId, spell in pairs(info.spells) do
                                imgui.Text(string.format("%s: %d (Last: %d)", spell.name, spell.total, spell.last));
                            end
                            imgui.TreePop();
                        end
                    end

                    imgui.TreePop();
                end
            end
        end

        imgui.End();
    end

    if popCount > 0 then imgui.PopStyleColor(popCount); end
    if varCount > 0 then imgui.PopStyleVar(varCount); end

    -- Auto-save if window was moved/resized
    if settings.saveRequired then
        settings.saveRequired = false;
        require('config').SaveSettings();
    end

    -- Draw Settings GUI
    require('settings_ui').Draw(settings);
end

return M;
