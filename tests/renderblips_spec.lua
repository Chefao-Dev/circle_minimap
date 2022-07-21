bindKey("z", "down", function ()
    local pos = localPlayer:getPosition()
    createBlip(pos.x, pos.y, pos.z, math.random(0,2), 0, 0, 0, 255)
end)