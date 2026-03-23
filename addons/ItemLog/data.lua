local M = {};

-- State
M.poolItems = {};
M.drops = {};
M.invCount = 0;
M.invMax = 0;
M.settings = nil;

function M.Initialize(settings)
    M.poolItems = {};
    M.drops = {};
    M.settings = settings;
end

function M.Cleanup()
    M.poolItems = {};
    M.drops = {};
    M.settings = nil;
end

function M.UpdateInventory()
    local inventory = AshitaCore:GetMemoryManager():GetInventory();
    if inventory then
        M.invCount = inventory:GetContainerCount(0);
        M.invMax = inventory:GetContainerCountMax(0);
    end
end

function M.ReadPoolFromMemory()
    local inventory = AshitaCore:GetMemoryManager():GetInventory();
    if not inventory then return; end

    local newPool = {};
    for slot = 0, 9 do
        local item = inventory:GetTreasurePoolItem(slot);
        if item and item.ItemId > 0 and item.ItemId ~= 65535 then
            local resItem = AshitaCore:GetResourceManager():GetItemById(item.ItemId);
            table.insert(newPool, {
                slot = slot,
                id = item.ItemId,
                name = resItem and resItem.Name[1] or "Unknown Item",
                bidder = item.WinningEntityName or "",
                bid = item.WinningLot or 0,
                myLot = item.Lot or 0
            });
        end
    end
    M.poolItems = newPool;
end

function M.AddDrop(msg)
    table.insert(M.drops, msg);
    local max = M.settings and M.settings.log and M.settings.log.maxDrops or 20;
    while #M.drops > max do
        table.remove(M.drops, 1);
    end
end

function M.GetPoolItems() return M.poolItems; end
function M.GetDrops() return M.drops; end
function M.ClearDrops() M.drops = {}; end

return M;
