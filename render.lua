local screenW,screenH = guiGetScreenSize()
local devScreenX, devScreenY = 1600,900
local x,y = (screenW/devScreenX), (screenH/devScreenY)

addEventHandler("onClientResourceStart", resourceRoot, function () 
    Radar.new(x*20, y*675, x*200, y*200)
    Radar:setVisibility(true)
end)