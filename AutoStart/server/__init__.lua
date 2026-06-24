local function CountHumans()
    local c = 0
    for _, p in ipairs(PlayerManager.GetPlayers()) do
        if not p.isBot then c = c + 1 end
    end
    return c
end

if CountHumans >= 1 then
    Console.Execute("startgame")
else 
    print("Not enough players")
end

--[[
You can also do it with a delay
if CountHumans >= 1 then
    Console.Execute("Kyber.Broadcast Starting in 10 seconds")
    SetTimeout(function)
        Console.Execute("startgame")
    end, 10.0) -- 10 seconds
else 
    print("Not enough players")
end
]]