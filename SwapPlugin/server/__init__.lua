require "common/timer"

local function Broadcast(msg)
    Console.Execute("Kyber.Broadcast " .. msg)
end

-- Sends a message every 10 minutes to remind players
SetInterval(function()
    Broadcast("Type !swap to switch teams")
end, 600.0) -- 10 minutes

EventManager.Listen("ServerPlayer:SendMessage", function(player, message)
    if message == "!swap" then
        if player.team == 1 then
            player:SetTeam(2)
        elseif player.team == 2 then
            player:SetTeam(1)
        end
    end
end)

--[[
You can also do it as a function then call it in ServerPlayer:SendMessage

local function Swap(player)
    if player.team == 1 then
        player:SetTeam(2)
    elseif player.team == 2 then
        player:SetTeam(1)  
    end
end

EventManager.Listen("ServerPlayer:SendMessage", function(player, message)
    if message == "!swap" then Swap(player) end
end)
]]