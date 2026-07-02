require "common/sdk"
require "admins"

local function Broadcast(msg)
    Console.Execute("Kyber.Broadcast " .. msg)
end

EventManager.Listen("ServerPlayer:SendMessage", function(player, message)
    if not table.contains(Admins, player.playerId) then return end
    if message:len() < 2 then return end
    local messageSplit = string.split(message)

    if #messageSplit <= 0 then return end
    if messageSplit[1]:len() < 3 then return end
    if messageSplit[1]:sub(1, 1) ~= '/' then return end

    local command = messageSplit[1]:lower():sub(2)
    EventManager.SetCancelled(true)

    if command == "kick" then
        if #messageSplit < 2 then return end
        local target = PlayerManager.GetPlayer(messageSplit[2])
        if target == nil then return end
        target:Kick("Kicked by an admin")

    elseif command == "setteam" or command == "st" then
        if #messageSplit < 3 then return end
        local target = PlayerManager.GetPlayer(messageSplit[2])
        if target == nil then return end
        local team = tonumber(messageSplit[3])
        if team ~= 1 and team ~= 2 then return end
        target:SetTeam(team)

    elseif command == "swap" then
        if #messageSplit < 2 then return end
        local target = PlayerManager.GetPlayer(messageSplit[2])
        if target == nil then return end
        target:SetTeam((math.fmod(target.team, 2)) + 1)

    elseif command == "fullteamswap" or command == "fts" then
        Console.Execute("Kyber.FullTeamSwap")

    elseif command == "givebp" then
        if #messageSplit < 3 then return end
        local target = PlayerManager.GetPlayer(messageSplit[2])
        if target == nil then return end
        local amount = tonumber(messageSplit[3])
        if amount == nil then return end
        target:GiveBattlepoints(amount)

    elseif command == "setbp" then
        if #messageSplit < 3 then return end
        local target = PlayerManager.GetPlayer(messageSplit[2])
        if target == nil then return end
        local amount = tonumber(messageSplit[3])
        if amount == nil then return end
        target:SetBattlepoints(amount)

    elseif command == "sethealth" then
        if #messageSplit < 3 then return end
        local target = PlayerManager.GetPlayer(messageSplit[2])
        if target == nil then return end
        local amount = tonumber(messageSplit[3])
        if amount == nil then return end
        target:SetHealth(amount)

    elseif command == "invisible" then
        if #messageSplit < 3 then return end
        local target = PlayerManager.GetPlayer(messageSplit[2])
        if target == nil then return end
        local val = messageSplit[3] == "true"
        target:SetInvisible(val)

    elseif command == "endofround" or command == "endround" or command == "eor" then
        Console.Execute("Kyber.endofround")

    elseif command == "endgameteam1" or command == "endteam1" or command == "egt1" then
        Console.Execute("Kyber.endgameteam1")

    elseif command == "endgameteam2" or command == "endteam2" or command == "egt2" then
        Console.Execute("Kyber.endgameteam2")

    elseif command == "loadlevel" or command == "loadmap" then
        if #messageSplit < 3 then return end
        Console.Execute("Kyber.LoadLevel " .. messageSplit[2] .. " " .. messageSplit[3])

    elseif command == "broadcast" or command == "bc" then
        if #messageSplit < 2 then return end
        local msg = table.concat(messageSplit, " ", 2)
        Broadcast(msg)

    elseif command == "listplayers" or command == "lp" then
        for _, p in pairs(PlayerManager.GetPlayers()) do
            print(p.name .. " | Team: " .. p.team .. " | ID: " .. tostring(p.playerId) .. " | Bot: " .. tostring(p.isBot))
        end

    elseif command == "crashgame" or command == "crash" then
        Console.Execute("Kyber.CrashGame")

    elseif command == "shuffleteams" or command == "shuffle" then
        Console.Execute("Kyber.ShuffleTeams")

    elseif command == "hotreloadlua" or command == "hotreload" or command == "reload" or command == "hrl" or command == "rl" then
        Console.Execute("Kyber.HotReloadLua")

    elseif command == "startgame" or command == "start" or command == "sg" then
        Console.Execute("Kyber.startgame")

    elseif command == "teleport" or command == "tp" then
        if #messageSplit < 5 then return end
        local target = PlayerManager.GetPlayer(messageSplit[2])
        if target == nil then return end
        Console.Execute("Kyber.Teleport " .. messageSplit[2] .. " " .. messageSplit[3] .. " " .. messageSplit[4] .. " " .. messageSplit[5])

    --[[ These will work when feat/squads gets merged
    elseif command == "setimmortal" or command == "si" then
        if #messageSplit < 3 then return end
        local target = PlayerManager.GetPlayer(messageSplit[2])
        if target == nil then return end
        local val = messageSplit[3] == "true"
        target:SetImmortal(val)

    elseif command == "setfakeimmortal" or command == "sfi" then
        if #messageSplit < 3 then return end
        local target = PlayerManager.GetPlayer(messageSplit[2])
        if target == nil then return end
        local val = messageSplit[3] == "true"
        target:SetFakeImmortal(val)

    elseif command == "setexplosionmodifier" or command == "sem" then
        if #messageSplit < 3 then return end
        local target = PlayerManager.GetPlayer(messageSplit[2])
        if target == nil then return end
        local val = tonumber(messageSplit[3])
        if val == nil then return end
        target:SetExplosionDamageModifier(val)

    elseif command == "setspeed" or command == "ss" then
        if #messageSplit < 3 then return end
        local target = PlayerManager.GetPlayer(messageSplit[2])
        if target == nil then return end
        local val = tonumber(messageSplit[3])
        if val == nil then return end
        target:SetMoveSpeedMultiplier(val)

    elseif command == "setcooldown" or command == "sc" then
        if #messageSplit < 3 then return end
        local target = PlayerManager.GetPlayer(messageSplit[2])
        if target == nil then return end
        local val = tonumber(messageSplit[3])
        if val == nil then return end
        target:SetCooldownModifier(val)
    ]]

    else
        print("Invalid command: " .. command)
    end
end)