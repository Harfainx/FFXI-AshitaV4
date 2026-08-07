local M = {};

function M.HandleIncomingText(e, settings, dataModule)
    if e.injected then return end;

    local baseMode = e.mode % 256;
    local msg = e.message:strip_colors():strip_translate(true);

    -- Mode 121: You find a [item] on the [enemy]. (Pool entry)
    if baseMode == 121 then
        if msg:contains('You find a') or msg:contains('You find an') then
            if settings.log.blockMode121 then
                e.blocked = true;
            end
        end
    end

    -- Mode 127 / 131: [Name] obtain(s) a [item] / [Name] obtain(s) [amount] gil.
    if baseMode == 127 or baseMode == 131 then
        local msgClean = msg:gsub('^%s*(.-)%s*$', '%1');
        local name, rawItem = msgClean:match('^(.-) obtains? (.-)[%.!]?$');
        if name and rawItem then
            local party = AshitaCore:GetMemoryManager():GetParty();
            if not party then return end;
            local playerName = party:GetMemberName(0);
            local isSelf = (name == 'You' or name == playerName);

            local item = rawItem:gsub('^an? ', '');
            local isGil = item:lower():contains('gil');

            if isGil then
                local showGil = (settings.log.showGil == nil) or settings.log.showGil;
                if showGil and (isSelf or settings.log.showOtherDrops) then
                    if settings.window.showDrops then
                        local titleGil = item:lower():gsub("(%a)([%w']*)", function(a,b) return string.upper(a)..b end);
                        local formatted = titleGil;
                        if not isSelf then
                            formatted = string.format("%s - %s", titleGil, name);
                        end
                        dataModule.AddDrop(formatted);
                    end
                end
            else
                if isSelf or settings.log.showOtherDrops then
                    if settings.window.showDrops then
                        -- Title case the item name for consistency with pool
                        local titleItem = item:lower():gsub("(%a)([%w']*)", function(a,b) return string.upper(a)..b end);
                        
                        local formatted = titleItem;
                        if not isSelf then
                            formatted = string.format("%s - %s", titleItem, name);
                        end
                        dataModule.AddDrop(formatted);
                    end
                end
            end

            -- Block in game log if enabled
            if settings.log.blockMode127 then
                e.blocked = true;
            end
        end
    end
end

return M;
