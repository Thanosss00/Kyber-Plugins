require "common/timer"

local mvpStats = {}
local lastMVP = nil
 
local function GetOrCreate(player)
    if not mvpStats[player.playerId] then
        mvpStats[player.playerId] = {
            name = player.name,
            kills = 0,
            assists = 0,
            deaths = 0,
            score = 0
        }
    end
    return mvpStats[player.playerId]
end
 
local function CalcMVPScore(stats)
    return (stats.kills * 3) + (stats.assists * 1) + (stats.score * 0.01)
end
 
local function GetKD(stats)
    if stats.deaths == 0 then
        return stats.kills
    end
    return math.floor((stats.kills / stats.deaths) * 100) / 100
end
 
local function SyncStats(player)
    if player.isBot then return end
    local stats = GetOrCreate(player)
    stats.name = player.name
    stats.kills = player.kills
    stats.assists = player.assists
    stats.deaths = player.deaths
    stats.score = player.score
end
 
EventManager.Listen("ServerPlayer:Killed", function(victim, inflictor, weaponName)
    if victim ~= nil and not victim.isBot then
        SyncStats(victim)
    end
    if inflictor ~= nil and not inflictor.isBot then
        if inflictor.playerId ~= victim.playerId then
            SyncStats(inflictor)
        end
    end
end)
 
EventManager.Listen("ServerPlayer:Spawned", function(player)
    SyncStats(player)
end)
 
EventManager.Listen("ServerPlayer:Disconnect", function(player)
    mvpStats[player.playerId] = nil
end)
 
EventManager.Listen("Level:Complete", function()
    local mvp = nil
    local topScore = -1
 
    for _, stats in pairs(mvpStats) do
        local s = CalcMVPScore(stats)
        if s > topScore then
            topScore = s
            mvp = stats
        end
    end
 
    if mvp == nil then
        print("[No stats recorded this round.")
        lastMVP = nil
    else
        lastMVP = mvp
        -- only prints here because you can't see the broadcast at this point
        print("[MVP] " .. mvp.name ..
              " | K: " .. mvp.kills ..
              " | D: " .. mvp.deaths ..
              " | A: " .. mvp.assists ..
              " | KD: " .. GetKD(mvp) ..
              " | Score: " .. mvp.score)
    end
 
    mvpStats = {}
end)
 
EventManager.Listen("Level:Loaded", function(level, mode)
    if lastMVP == nil then return end
 
    local mvp = lastMVP
    local msg = "Last round MVP: " .. mvp.name ..
                " | K: " .. mvp.kills ..
                " | D: " .. mvp.deaths ..
                " | A: " .. mvp.assists ..
                " | KD: " .. GetKD(mvp) ..
                " | Score: " .. mvp.score

    -- broadcasts the message at the start of the next round
    SetTimeout(function()
        Console.Execute("Kyber.Broadcast " .. msg)
    end, 20.0)
    lastMVP = nil
end)