local imgui = require('imgui');
local data = require('data');

local M = {};

function M.Initialize(settings)
    -- Initialization logic if needed
end

function M.DrawWindow(settings, messages)
    local winSettings = settings.window;
    
    local popCount = 0;
    local varCount = 0;
    
    -- Backgrounds
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
        local tCol = winSettings.titleBarColor;
        local hoverCol = { math.min(1.0, tCol[1] * 1.2), math.min(1.0, tCol[2] * 1.2), math.min(1.0, tCol[3] * 1.2), tCol[4] };
        local sepCol = { 0.4, 0.4, 0.4, 0.4 };

        -- Traditional Named Pushes
        if ImGuiCol_TitleBg then imgui.PushStyleColor(ImGuiCol_TitleBg, tCol); popCount = popCount + 1; end
        if ImGuiCol_TitleBgActive then imgui.PushStyleColor(ImGuiCol_TitleBgActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_TitleBgCollapsed then imgui.PushStyleColor(ImGuiCol_TitleBgCollapsed, tCol); popCount = popCount + 1; end
        if ImGuiCol_Header then imgui.PushStyleColor(ImGuiCol_Header, tCol); popCount = popCount + 1; end
        if ImGuiCol_HeaderActive then imgui.PushStyleColor(ImGuiCol_HeaderActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_HeaderHovered then imgui.PushStyleColor(ImGuiCol_HeaderHovered, hoverCol); popCount = popCount + 1; end
        if ImGuiCol_Tab then imgui.PushStyleColor(ImGuiCol_Tab, tCol); popCount = popCount + 1; end
        if ImGuiCol_TabActive then imgui.PushStyleColor(ImGuiCol_TabActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_TabUnfocused then imgui.PushStyleColor(ImGuiCol_TabUnfocused, tCol); popCount = popCount + 1; end
        if ImGuiCol_TabUnfocusedActive then imgui.PushStyleColor(ImGuiCol_TabUnfocusedActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_Button then imgui.PushStyleColor(ImGuiCol_Button, tCol); popCount = popCount + 1; end
        if ImGuiCol_ButtonHovered then imgui.PushStyleColor(ImGuiCol_ButtonHovered, hoverCol); popCount = popCount + 1; end
        if ImGuiCol_ButtonActive then imgui.PushStyleColor(ImGuiCol_ButtonActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_FrameBgActive then imgui.PushStyleColor(ImGuiCol_FrameBgActive, tCol); popCount = popCount + 1; end
        if ImGuiCol_Separator then imgui.PushStyleColor(ImGuiCol_Separator, sepCol); popCount = popCount + 1; end

        -- Manual Indices for absolute coverage
        imgui.PushStyleColor(36, tCol); -- TabUnfocused
        imgui.PushStyleColor(16, hoverCol); -- ScrollbarHover (using Accent logic later)
        popCount = popCount + 2;

        if ImGuiStyleVar_TabBarBorderSize then imgui.PushStyleVar(ImGuiStyleVar_TabBarBorderSize, 0.0); varCount = varCount + 1; end
    end

    -- Accent Color
    if winSettings.accentColor then
        local aCol = winSettings.accentColor;
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
    
    -- System Colors
    if winSettings.systemTextColor then
        imgui.PushStyleColor(0, winSettings.systemTextColor);
        popCount = popCount + 1;
    end
    if winSettings.titleBarColor then
        imgui.PushStyleColor(5, { 0.1, 0.1, 0.1, 0.5 }); -- Border (Grey)
        imgui.PushStyleColor(30, winSettings.titleBarColor); -- Resize Grip
        imgui.PushStyleColor(31, winSettings.accentColor or {1, 1, 1, 1}); -- Resize Hover
        popCount = popCount + 3;
    end

    -- Flags
    local sFlags = 0;
    if ImGuiWindowFlags_NoSavedSettings then sFlags = bit.bor(sFlags, ImGuiWindowFlags_NoSavedSettings); end
    if ImGuiWindowFlags_NoFocusOnAppearing then sFlags = bit.bor(sFlags, ImGuiWindowFlags_NoFocusOnAppearing); end
    if ImGuiWindowFlags_NoNav then sFlags = bit.bor(sFlags, ImGuiWindowFlags_NoNav); end
    if ImGuiWindowFlags_NoCollapse then sFlags = bit.bor(sFlags, ImGuiWindowFlags_NoCollapse); end

    -- Draw Main Window
    imgui.SetNextWindowPos({winSettings.x, winSettings.y}, ImGuiCond_FirstUseEver);
    imgui.SetNextWindowSize({winSettings.width, winSettings.height}, ImGuiCond_FirstUseEver);
    
    if imgui.Begin("ChatLog", true, sFlags) then
        if imgui.SetWindowFontScale then imgui.SetWindowFontScale(winSettings.fontScale); end
        
        -- Sync Position/Size
        local pos = {imgui.GetWindowPos()};
        local size = {imgui.GetWindowSize()};
        if pos[1] ~= winSettings.x or pos[2] ~= winSettings.y or size[1] ~= winSettings.width or size[2] ~= winSettings.height then
            winSettings.x, winSettings.y = pos[1], pos[2];
            winSettings.width, winSettings.height = size[1], size[2];
            settings.saveRequired = true;
        end
        
        -- Right-Click Menu
        if imgui.BeginPopupContextWindow("ChatLogSettings", 1) then
            if imgui.MenuItem("Settings...") then require('settings_ui').Open(); end
            imgui.Separator();
            imgui.Text("Channel Toggles");
            imgui.Separator();
            
            local cfg = settings.chat.enabledModes;
            local function ModeToggle(label, modes)
                local st = { cfg[modes[1]] or false };
                if imgui.Checkbox(label .. "##toggle", st) then
                    for _, m in ipairs(modes) do cfg[m] = st[1]; end
                    settings.saveRequired = true;
                end
            end
            
            ModeToggle("Say", {1, 9}); ModeToggle("Party", {5, 13}); ModeToggle("Linkshell", {6, 14});
            ModeToggle("LS2", {213, 214}); ModeToggle("Tell", {4, 12}); ModeToggle("Shout", {10});
            ModeToggle("Yell", {3, 11}); ModeToggle("Emotes", {15, 7}); ModeToggle("System", {123});
            ModeToggle("Secondary System", {121});
            imgui.Separator();
            local stPos = { winSettings.showPosition };
            if imgui.Checkbox("Display Position", stPos) then
                winSettings.showPosition = stPos[1];
                settings.saveRequired = true;
            end
            local stInv = { winSettings.showInventory };
            if imgui.Checkbox("Display Inventory", stInv) then
                winSettings.showInventory = stInv[1];
                settings.saveRequired = true;
            end
            local stEXP = { winSettings.showEXP };
            if imgui.Checkbox("Display EXP", stEXP) then
                winSettings.showEXP = stEXP[1];
                settings.saveRequired = true;
            end
            local stJP = { winSettings.showJP };
            if imgui.Checkbox("Display Job Points", stJP) then
                winSettings.showJP = stJP[1];
                settings.saveRequired = true;
            end
            local stMP = { winSettings.showMerits };
            if imgui.Checkbox("Display Merit Points", stMP) then
                winSettings.showMerits = stMP[1];
                settings.saveRequired = true;
            end
            
            imgui.EndPopup();
        end

        -- Status Bar Rows
        local row1 = {};
        local row2 = {};

        -- Position (Row 1)
        if winSettings.showPosition then
            local ent = AshitaCore:GetMemoryManager():GetEntity();
            local part = AshitaCore:GetMemoryManager():GetParty();
            if ent and part then
                local idx = part:GetMemberTargetIndex(0);
                if idx ~= 0 then
                    table.insert(row1, { color = winSettings.posColor, text = string.format("Pos: %.2f %.2f %.2f", ent:GetLocalPositionX(idx), ent:GetLocalPositionY(idx), ent:GetLocalPositionZ(idx)) });
                end
            end
        end

        -- Inventory (Row 1)
        if winSettings.showInventory then
            local inv = AshitaCore:GetMemoryManager():GetInventory();
            if inv then
                local c, m = inv:GetContainerCount(0), inv:GetContainerCountMax(0);
                local perc = (m > 0) and (c/m*100) or 0;
                local ic = winSettings.invTextColor;
                if winSettings.showInvThresholds then
                    ic = {0.1, 1, 0.1, 1}; -- Green
                    if perc >= (winSettings.invRedThreshold or 85) then ic = {1, 0.1, 0.1, 1};
                    elseif perc >= (winSettings.invYellowThreshold or 65) then ic = {1, 1, 0.1, 1}; end
                end
                table.insert(row1, { labelColor = winSettings.invTextColor, label = "Inv: ", color = ic, text = string.format("%d/%d", c, m) });
            end
        end

        -- Row 2 Items
        if winSettings.showEXP then
            local player = AshitaCore:GetMemoryManager():GetPlayer();
            if player then
                local expCur = player:GetExpCurrent();
                local expNeed = player:GetExpNeeded();
                table.insert(row2, { color = winSettings.expColor, text = string.format("EXP: %d/%d", expCur, expCur + expNeed) });
            end
        end
        if winSettings.showJP then
            local player = AshitaCore:GetMemoryManager():GetPlayer();
            if player then
                table.insert(row2, { color = winSettings.jpColor, text = string.format("JP: %d", player:GetJobPoints(player:GetMainJob())) });
            end
        end
        if winSettings.showMerits then
            local player = AshitaCore:GetMemoryManager():GetPlayer();
            if player then
                table.insert(row2, { color = winSettings.meritColor, text = string.format("Merits: %d", player:GetMeritPoints()) });
            end
        end

        -- Render Rows
        local function renderRow(items)
            if #items == 0 then return false; end
            for i, item in ipairs(items) do
                if i > 1 then
                    imgui.SameLine();
                    imgui.Text(" | ");
                    imgui.SameLine();
                end
                if item.label then
                    imgui.TextColored(item.labelColor, item.label or "");
                    imgui.SameLine(0, 0);
                end
                imgui.TextColored(item.color, (item.text or ""):gsub("%%", "%%%%"));
            end
            return true;
        end

        if renderRow(row1) then imgui.Separator(); end
        if renderRow(row2) then imgui.Separator(); end

        -- Messages region
        imgui.BeginChild("ChatMessagesRegion");
        for _, msg in ipairs(messages) do
            imgui.PushStyleColor(ImGuiCol_Text, msg.color or {1, 1, 1, 1});
            imgui.TextWrapped(msg.text:gsub("%%", "%%%%"));
            imgui.PopStyleColor(1);
        end
        if data.newMessage then imgui.SetScrollHereY(1.0); data.newMessage = false; end
        imgui.EndChild();

        imgui.End();
    end -- Added missing end for imgui.Begin
    
    -- Restore style (ALWAYS call this to avoid leaks)
    if popCount > 0 then imgui.PopStyleColor(popCount); end
    if varCount > 0 then imgui.PopStyleVar(varCount); end
    
    -- Save settings dynamically if changed
    if settings.saveRequired then
        settings.saveRequired = false;
        require('config').SaveSettings();
    end

    -- Draw Settings GUI
    require('settings_ui').Draw(settings);
end

function M.Cleanup()
    -- Any cleanup for display
end

return M;
