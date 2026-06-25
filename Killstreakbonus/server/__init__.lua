require "admins"
require "common/sdk"

local streaks = {}
local MILESTONES = {
    [5]  = 50,
    [10] = 100,
    [15] = 250,
    [20] = 500,
    [25] = 750,
    [30] = 900,
    [40] = 1000,
    [50] = 1050,
    [60] = 1100,
    [70] = 1250,
    [80] = 1500,
    [90] = 1750,
    [100] = 2000,
}
 
local function GetStreak(player)
    if not streaks[player.playerId] then
        streaks[player.playerId] = 0
    end
    return streaks[player.playerId]
end
 
local function ResetStreak(player)
    streaks[player.playerId] = 0
end
 
EventManager.Listen("ServerPlayer:Killed", function(victim, inflictor, weaponName)
    if victim ~= nil and not victim.isBot then
        ResetStreak(victim)
    end

    if inflictor == nil or inflictor.isBot then return end
    if victim ~= nil and inflictor.playerId == victim.playerId then return end -- ignore suicides
 
    local streak = GetStreak(inflictor) + 1
    streaks[inflictor.playerId] = streak
 
    local bonus = MILESTONES[streak]
    if bonus ~= nil then
        inflictor:GiveBattlepoints(bonus)
        print("[KillStreak] " .. inflictor.name .. " hit a " .. streak .. " kill streak! +" .. bonus .. " BP")
    end
end)
 
EventManager.Listen("ServerPlayer:Disconnect", function(player)
    streaks[player.playerId] = nil
end)
 
-- Reset all streaks on new round
EventManager.Listen("Level:Loaded", function(level, mode)
    streaks = {}
end)

-- This is just for testing
EventManager.Listen("ServerPlayer:SendMessage", function(player, message)
    if not table.contains(Admins, player.playerId) then return end
    if message:len() < 2 then return end
    local messageSplit = string.split(message)

    if #messageSplit <= 0 then return end
    if messageSplit[1]:len() < 3 then return end
    if messageSplit[1]:sub(1, 1) ~= '/' then return end

    local command = messageSplit[1]:lower():sub(2)
    EventManager.SetCancelled(true)

    if command == "killstreak" then
        local amount = tonumber(messageSplit[2])

        if amount == nil then
            return
        end

        streaks[player.playerId] = amount
        print(player.name .. " killstreak set to " .. amount)
    else
        print("Invalid command: " .. command)
    end
end)