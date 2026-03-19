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

return M;
