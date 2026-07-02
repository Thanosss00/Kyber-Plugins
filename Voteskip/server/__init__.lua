require "common/sdk"

local skipVotes = {}
local function CountHumans()
    local c = 0
    for _, p in ipairs(PlayerManager.GetPlayers()) do
        if not p.isBot then c = c + 1 end
    end
    return c
end

local function CountVotes()
    local count = 0
    for _ in pairs(skipVotes) do
        count = count + 1
    end
    return count
end

local function ResetVotes()
    skipVotes = {}
end

local function Broadcast(msg)
    Console.Execute("Kyber.Broadcast " .. msg)
end

EventManager.Listen("Level:Loaded", function(level, mode)
    ResetVotes()
    SetTimeout(function()
        Broadcast("Type !skip to vote to skip the current map.")
    end, 20.0)
end)

EventManager.Listen("ServerPlayer:Disconnect", function(player)
    skipVotes[player.playerId] = nil
end)

EventManager.Listen("ServerPlayer:SendMessage", function(player, message)
    if message:len() < 2 then return end
    local messageSplit = string.split(message)

    if #messageSplit <= 0 then return end
    if messageSplit[1]:len() < 3 then return end
    if messageSplit[1]:sub(1, 1) ~= '!' then return end

    local command = messageSplit[1]:lower():sub(2)
    EventManager.SetCancelled(true)

    if command == "skip" then
        if skipVotes[player.playerId] then
            print(player.name .. " already voted.")
            return
        end

        skipVotes[player.playerId] = true
        local votes = CountVotes()
        local humans = CountHumans()
        local needed = math.floor(humans / 2) + 1
        Broadcast(player.name .. " voted to skip (" .. votes .. "/" .. needed .. ")")

        if votes >= needed then
            Broadcast("Vote passed, skipping map.")
            ResetVotes()
            Console.Execute("Kyber.endofround")
        end
    else
        print("Invalid command: " .. command)
    end
end)