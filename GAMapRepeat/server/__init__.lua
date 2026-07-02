-- Warning: Add each map only 1 time to the rotation, otherwise it will mess up the flow of the plugin

require "common/timer"

local currentRound = 1
local currentLevel = nil
local currentMode = nil
local savedTeams = {}
local isReloading = false -- blocks the Level:Loaded fired during map transition
local hasAnnouncedRound2 = false -- prevents duplicate SetTimeout when Level:Loaded fires multiple times for round 2

local function Broadcast(msg)
    Console.Execute("Kyber.Broadcast " .. msg)
end

local function IsGA(mode)
    return mode == "PlanetaryBattles"
end

local function SaveTeams()
    savedTeams = {}
    local count = 0
    for _, p in pairs(PlayerManager.GetPlayers()) do
        if not p.isBot then
            savedTeams[p.playerId] = p.team
            count = count + 1
        end
    end
end

local function ApplySavedTeamsSwapped()
    local count = 0
    for _, p in pairs(PlayerManager.GetPlayers()) do
        if not p.isBot and savedTeams[p.playerId] ~= nil then
            local flipped = (math.fmod(savedTeams[p.playerId], 2)) + 1
            p:SetTeam(flipped)
            count = count + 1
        end
    end
end

-- Disables shuffle so the plugin can be used alongside Bot Balancer
EventManager.Listen("Server:Init", function()
    local kyberSettings = Console.GetSettings("Kyber")
    if kyberSettings ~= nil then
        kyberSettings.enableShuffleTeams = false
        print("Disabled team shuffling")
    end
end)

-- Same thing here just incase
EventManager.Listen("Level:Loaded", function(level, mode)
    local kyberSettings = Console.GetSettings("Kyber")
    if kyberSettings ~= nil then
        kyberSettings.enableShuffleTeams = false
        print("Disabled team shuffling")
    end

    if not IsGA(mode) then
        currentRound = 1
        currentLevel = nil
        currentMode = nil
        savedTeams = {}
        isReloading = false
        hasAnnouncedRound2 = false
        return
    end

    if isReloading then
        isReloading = false
        return
    end

    currentLevel = level
    currentMode = mode

    if currentRound == 2 and not hasAnnouncedRound2 then
        hasAnnouncedRound2 = true
        SetTimeout(function()
            ApplySavedTeamsSwapped()
            Broadcast("**GAMapRepeat:** Round 2! Same map, sides switched!")
        end, 8)
    end
end)

EventManager.Listen("Level:Complete", function()
    if currentLevel == nil then return end
    if not IsGA(currentMode) then return end
    if currentRound == 1 then
        SaveTeams()
        currentRound = 2
        isReloading = true
        Broadcast("**GAMapRepeat:** Round 1 complete! Moving to Round 2, sides will be switched!")
        Console.Execute("Kyber.LoadLevel " .. currentLevel .. " " .. currentMode)
    elseif currentRound == 2 then
        currentRound = 1
        currentLevel = nil
        currentMode = nil
        savedTeams = {}
        isReloading = false
        hasAnnouncedRound2 = false
        Broadcast("**GAMapRepeat:** Both rounds complete! Moving to the next map.")
    end
end)