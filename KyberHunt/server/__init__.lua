require "common/sdk"
require "admins"

local roundDuration = 600 -- 10 minutes
local timeElapsed = 0
local holderPlayer = nil
local anchor = 1 
local lastAnnounced = -1 

local function Broadcast(msg)
    Console.Execute("Kyber.Broadcast " .. msg)
end

local function EnableFriendlyFire(player)
    local syncedGame = Console.GetSettings("SyncedGame")
    if syncedGame == nil then return end
    syncedGame.enableFriendlyFire = true
    player:SendSyncedSettings()
end

local function GetRandomPlayer()
    local humans = {}
    for _, p in pairs(PlayerManager.GetPlayers()) do
        if not p.isBot then
            table.insert(humans, p)
        end
    end
    if #humans == 0 then return nil end
    return humans[math.random(1, #humans)]
end

local function SetHolder(player)
    holderPlayer = player
    Broadcast("**Kyber Hunt:** " .. player.name .. " is now holding the Kyber Crystal!")
end

EventManager.Listen("Level:Loaded", function(level, mode)
    timeElapsed = 0
    holderPlayer = nil
    lastAnnounced = -1
    anchor = math.random(1, 2)

    SetTimeout(function()
        for _, p in pairs(PlayerManager.GetPlayers()) do
            if not p.isBot then
                p:SetTeam(anchor)
                EnableFriendlyFire(p)
            end
        end

        Broadcast("**Kyber Hunt:** Welcome to Kyber Hunt! Hold the Kyber Crystal until the end to win!")

        local startHolder = GetRandomPlayer()
        if startHolder ~= nil then
            SetHolder(startHolder)
        end

        SetTimeout(function()
            Console.Execute("Kyber.startgame")
        end, 5)
    end, 15)
end)

-- Setting the team and friendly fire in both just incase one of them fails
EventManager.Listen("ServerPlayer:Joined", function(player)
    if holderPlayer == nil then return end
    player:SetTeam(anchor)
    EnableFriendlyFire(player)
end)

EventManager.Listen("ServerPlayer:Spawned", function(player)
    if holderPlayer == nil then return end
    player:SetTeam(anchor)
    EnableFriendlyFire(player)
end)

EventManager.Listen("ServerPlayer:Killed", function(victim, killer, weaponName)
    if holderPlayer == nil then return end
    if killer == nil then return end
    if victim == nil then return end

    if victim.playerId == holderPlayer.playerId then
        SetHolder(killer)
    end
end)

EventManager.Listen("Server:UpdatePre", function(delta)
    if holderPlayer == nil then return end

    timeElapsed = timeElapsed + delta

    local remaining = roundDuration - timeElapsed
    if remaining <= 0 then
        Broadcast("**Kyber Hunt:** Time is up! " .. holderPlayer.name .. " wins!")
        holderPlayer = nil 
        SetTimeout(function()
            Console.Execute("Kyber.endofround")
        end, 5)
        return
    end

    local remainingInt = math.floor(remaining)
    if remainingInt ~= lastAnnounced then
        lastAnnounced = remainingInt
        if remainingInt == 300 then
            Broadcast("**Kyber Hunt:** 5 minutes remaining! " .. holderPlayer.name .. " is holding the crystal!")
        elseif remainingInt == 120 then
            Broadcast("**Kyber Hunt:** 2 minutes remaining! " .. holderPlayer.name .. " is holding the crystal!")
        elseif remainingInt == 60 then
            Broadcast("**Kyber Hunt:** 1 minute remaining! " .. holderPlayer.name .. " is holding the crystal!")
        elseif remainingInt == 30 then
            Broadcast("**Kyber Hunt:** 30 seconds remaining! " .. holderPlayer.name .. " is holding the crystal!")
        end
    end
end)

-- Just for testing
EventManager.Listen("ServerPlayer:SendMessage", function(player, message)
    if not table.contains(Admins, player.playerId) then return end
    if message:len() < 2 then return end
    local messageSplit = string.split(message)

    if #messageSplit <= 0 then return end
    if messageSplit[1]:len() < 3 then return end
    if messageSplit[1]:sub(1, 1) ~= '/' then return end

    local command = messageSplit[1]:lower():sub(2)
    EventManager.SetCancelled(true)

    if command == "settime" then
        if #messageSplit < 2 then return end
        local t = tonumber(messageSplit[2])
        if t == nil then return end
        timeElapsed = roundDuration - t
        print("[KyberHunt] Time remaining set to " .. t .. " seconds")

    elseif command == "skiptoend" then
        timeElapsed = roundDuration - 35
        print("[KyberHunt] Skipped to end")

    elseif command == "setholder" then
        if #messageSplit < 2 then return end
        local target = PlayerManager.GetPlayer(messageSplit[2])
        if target == nil then return end
        SetHolder(target)

    elseif command == "forceholder" then
        SetHolder(player)

    elseif command == "resetround" then
        timeElapsed = 0
        holderPlayer = nil
        lastAnnounced = -1
        anchor = math.random(1, 2)
         
    else
        print("Invalid command: " .. command)
    end
end)

--[[ TODO: Add some bonus reward for killstreaks when holding the crystal or for holding the crystal. 
Maybe make a mod that adds a real crystal and you have to pick it up.
Maybe make it as a team based gamemode instead of ffa in an new branch so both playstyles are an option.
]]