EventManager.Listen("ServerPlayer:Joined", function(player)
    local players = PlayerManager.GetPlayers()
    local light = 0
    local dark = 0

    for _, p in pairs(players) do
        if p.team == 1 then
            light = light + 1
        elseif p.team == 2 then
            dark = dark + 1
        end
    end

    if light > dark then
        player:SetTeam(2)
    else
        player:SetTeam(1)
    end
end)