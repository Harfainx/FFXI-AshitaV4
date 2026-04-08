local M = {};

local messages = {};
local maxLimit = 100;

function M.Initialize(settings)
    if settings and settings.chat and settings.chat.maxMessages then
        maxLimit = settings.chat.maxMessages;
    end
    -- note: we purposely do NOT clear messages on initialize/zone load
    -- to persist across zone changes, per user instructions.
end

function M.AddMessage(mode, text, color)
    table.insert(messages, {
        mode = mode,
        text = text,
        color = color,
        time = os.time()
    });
    
    -- Prune oldest messages if over limit
    while #messages > maxLimit do
        table.remove(messages, 1);
    end
    
    M.newMessage = true; -- Flag to let UI know a new message arrived for auto-scroll
end

function M.GetMessages()
    return messages;
end

function M.Clear()
    messages = {};
end

function M.Cleanup()
    -- Clear data on logout/shutdown
    M.Clear();
end

M.metrics = {
    exp = { total = 0, start = 0 },
    cp = { total = 0, start = 0 }
};

function M.AddExp(amount)
    if M.metrics.exp.start == 0 then M.metrics.exp.start = os.time(); end
    M.metrics.exp.total = M.metrics.exp.total + amount;
end

function M.AddCp(amount)
    if M.metrics.cp.start == 0 then M.metrics.cp.start = os.time(); end
    M.metrics.cp.total = M.metrics.cp.total + amount;
end

function M.ResetMetrics()
    M.metrics.exp = { total = 0, start = 0 };
    M.metrics.cp = { total = 0, start = 0 };
end

return M;
