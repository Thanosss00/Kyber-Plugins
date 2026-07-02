require "common/sdk"
require "admins"

local ROUND_DURATION = 600 -- 10 minutes
local MIN_PLAYERS = 1 -- for testing, change it to 2
local HERO_KILL_TARGET = 50
local HUNTER_KILL_TARGET = 1
local heroPlayer = nil
local roundEnded = false
local heroKills = 0
local hunterKills = 0
local heroTimeAlive = 0
local timeElapsed = 0
local currentMapName = nil
local heroTeam = nil
local hunterTeam = nil

local Maps = {
    -- Light side heroes
    ["Endor_01"] = 1,
    -- ["Endor_02"] = 1, crashes, will probably remove
    ["Hoth_01"] = 1,
    ["Jakku_01"] = 1,
    ["Tatooine_01"] = 1,
    ["Naboo_01"] = 1,
    ["Naboo_02"] = 1,
    ["Yavin4_01"] = 1,
    ["Crait_01"] = 1,
    ["Takodana_01"] = 1,
    ["Kashyyyk_01"] = 1,

    -- Dark side heroes
    ["DeathStar02_01"] = 2,
    ["Geonosis_01"] = 2,
    ["Kamino_01"] = 2,
    ["StarKiller_01"] = 2,
    ["CloudCity_01"] = 2,
    ["Kessel_01"] = 2,
    ["JabbasPalace_01"] = 2,
}

local function Broadcast(msg)
    Console.Execute("Kyber.Broadcast " .. msg)
end

local function ExtractMapName(levelPath)
    return levelPath:match("([^/]+)$") or levelPath
end

local function CountHumans()
    local c = 0
    for _, p in pairs(PlayerManager.GetPlayers()) do
        if not p.isBot then c = c + 1 end
    end
    return c
end

local function BroadcastHeroStats()
    if heroPlayer == nil then return end
    local timeStr = string.format("%d:%02d", math.floor(heroTimeAlive / 60), math.floor(heroTimeAlive % 60))
    Broadcast("**HeroHunt:** Hero stats: " .. heroPlayer.name .. " | Kills: " .. heroKills .. " | Time alive: " .. timeStr)
end

local function PickRandomHero()
    local humans = {}
    for _, p in pairs(PlayerManager.GetPlayers()) do
        if not p.isBot then
            table.insert(humans, p)
        end
    end
    if #humans == 0 then return end
    local picked = humans[math.random(1, #humans)]
    heroPlayer = picked
    heroPlayer:SetTeam(heroTeam)
    Broadcast("**HeroHunt:** " .. heroPlayer.name .. " is the Hero!")
    print("Hero selected: " .. heroPlayer.name)
end

local function Reset()
    heroPlayer = nil
    roundEnded = false
    heroKills = 0
    hunterKills = 0
    heroTimeAlive = 0
    timeElapsed = 0
    currentMapName = nil
    heroTeam = nil
    hunterTeam = nil
end

local function StartRound()
    if CountHumans() < MIN_PLAYERS then
        print("Not enough players")
        return
    end

    for _, p in pairs(PlayerManager.GetPlayers()) do
        if not p.isBot then
            p:SetTeam(hunterTeam)
        end
    end

    Broadcast("**HeroHunt:** Welcome to Hero Hunt! Choosing a hero randomly...")

    SetTimeout(function()
        PickRandomHero()
    end, 5)

    SetTimeout(function()
        Console.Execute("Kyber.startgame")
    end, 10)
end

local function EndRound()
    if roundEnded then return end
    roundEnded = true
    SetTimeout(function()
        Console.Execute("Kyber.endofround")
    end, 3)
end

EventManager.Listen("Level:Loaded", function(level, mode)
    Reset()
    currentMapName = ExtractMapName(level)
    local heroSide = Maps[currentMapName]

    if heroSide == nil then
        print("Map not in list: " .. currentMapName)
        return
    end

    heroTeam = heroSide
    hunterTeam = heroSide == 1 and 2 or 1
    print("Map: " .. currentMapName .. " | Hero team: " .. heroTeam .. " | Hunter team: " .. hunterTeam)

    SetTimeout(function()
        StartRound()
    end, 10)
end)

-- Setting teams in both just incase
EventManager.Listen("ServerPlayer:Joined", function(player)
    if roundEnded then return end
    if hunterTeam == nil then return end
    player:SetTeam(hunterTeam)
end)

EventManager.Listen("ServerPlayer:Spawned", function(player)
    if roundEnded then return end
    if heroPlayer ~= nil and player.playerId == heroPlayer.playerId then
        player:SetTeam(heroTeam)
    elseif hunterTeam ~= nil then
        player:SetTeam(hunterTeam)
    end
end)

EventManager.Listen("ServerPlayer:Killed", function(victim, killer, weaponName)
    if roundEnded then return end
    if victim == nil then return end
    if heroPlayer ~= nil and victim.playerId == heroPlayer.playerId then
        hunterKills = hunterKills + 1

        if hunterKills >= HUNTER_KILL_TARGET then
            Broadcast("**HeroHunt:** Hunters win!")
            BroadcastHeroStats()
            print("Hunters win, reached the kill target")
            EndRound()
        end
        return
    end

    if heroPlayer ~= nil and killer ~= nil and killer.playerId == heroPlayer.playerId then
        heroKills = heroKills + 1

        if heroKills >= HERO_KILL_TARGET then
            Broadcast("**HeroHunt:** Hero wins!")
            BroadcastHeroStats()
            EndRound()
        end
    end
end)

EventManager.Listen("Server:UpdatePre", function(delta)
    if roundEnded then return end
    if heroPlayer == nil then return end

    timeElapsed = timeElapsed + delta
    heroTimeAlive = heroTimeAlive + delta

    local remaining = ROUND_DURATION - timeElapsed
    if remaining <= 0 then
        BroadcastHeroStats()
        Broadcast("**HeroHunt:** Hunters survived long enough and won!.")
        print("Hunters win, timer ended")
        EndRound()
        return
    end

    if math.floor(remaining) == 60 then
        Broadcast("**HeroHunt:** 1 minute remaining! Hero has " .. heroKills .. " kills.")
    end
end)

EventManager.Listen("Level:Complete", function()
    Reset()
end)

EventManager.Listen("ServerPlayer:SendMessage", function(player, message)
    if not table.contains(Admins, player.playerId) then return end
    if message:len() < 2 then return end
    local messageSplit = string.split(message)

    if #messageSplit <= 0 then return end
    if messageSplit[1]:len() < 2 then return end
    if messageSplit[1]:sub(1, 1) ~= '/' then return end

    local command = messageSplit[1]:lower():sub(2)
    EventManager.SetCancelled(true)

    if command == "sethero" then
        if #messageSplit < 2 then return end
        local target = PlayerManager.GetPlayer(messageSplit[2])
        if target == nil then return end
        heroPlayer = target
        heroPlayer:SetTeam(heroTeam)
        Broadcast("**HeroHunt:** " .. heroPlayer.name .. " is the Hero!")

    elseif command == "endround" then
        EndRound()

    elseif command == "stats" then
        local timeStr = string.format("%d:%02d", math.floor(heroTimeAlive / 60), math.floor(heroTimeAlive % 60))
        print("Hero: " .. (heroPlayer ~= nil and heroPlayer.name or "none"))
        print("Hero kills: " .. heroKills .. "/" .. HERO_KILL_TARGET)
        print("Hero time alive: " .. timeStr)
        print("Round time: " .. math.floor(timeElapsed) .. "s elapsed")
    else
        print("Invalid command: " .. command)
    end
end)

-- FOR THE FUTURE: Multiple heroes per round in a new branch, 
-- if there's ever an option to force respawn/kill/to the character menu
-- Allow 3 heroes instead of 1 in a new branch so both options are available