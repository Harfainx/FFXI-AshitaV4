local M = {};

function M.HandleIncomingText(e, settings, dataModule)
    if e.injected then return end;
    if not e.message then return end;

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

    -- Mode 127: [Name] obtains a [item].
    if baseMode == 127 then
        local name, item = msg:match('^(.-) obtains an? (.-)%.$');
        if name and item then
            local party = AshitaCore:GetMemoryManager():GetParty();
            if not party then return end;
            local playerName = party:GetMemberName(0);
            local isSelf = (name == 'You' or name == playerName);

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

            -- Block in game log if enabled
            if settings.log.blockMode127 then
                e.blocked = true;
            end
        end
    end
end

return M;
