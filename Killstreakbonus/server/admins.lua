require "common/sdk"

Admins = {
    1009965413328 -- "The_Negotiator1"
}

EventManager.Listen("ServerPlayer:SendMessage", function(player, message)
    if not table.contains(Admins, player.playerId) then return end

    if message:len() < 2 then return end
    local messageSplit = string.split(message)

    if #messageSplit <= 0 then return end
    if messageSplit[1]:len() < 3 then return end
    if messageSplit[1]:sub(1, 1) ~= '/' then return end

    local command = messageSplit[1]:lower():sub(2)

    EventManager.SetCancelled(true)

    if command == "exec" or command == "cmd" then
        if #messageSplit <= 1 then
            return
        end

        local executeCmd = table.concat(messageSplit, " ", 2)
        print("Admin " .. player.name .. " executed command: " .. executeCmd)
        Console.Execute(executeCmd)
    end
end)