--[[
MIT License
Copyright (c) 2022 Vítor Ribeiro
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
--]]


Radar = {}
Radar.__index = Radar
Radar.instances = {}

local screenW,screenH = guiGetScreenSize()
local devScreenX, devScreenY = 1600,900
local x,y = (screenW/devScreenX), (screenH/devScreenY)

function Radar.new(posx, posy, width, height)
    local self = setmetatable({}, Radar)
    local me = localPlayer:getPosition()

    showPlayerHudComponent("radar", false)

    -- Setting mini map proportions
    self.x = posx
    self.y = posy
    self.width = width
    self.height = height
    self.zoom = 10

    -- Setting blip config
    self.blipSize = 20
    self.blips = {}

    -- Shaders config
    self.hudMask = DxShader("fx/hud_mask.fx")
    self.circleMask = DxTexture("assets/circle_mask.png", "dxt5")    
    self.world= DxTexture("assets/world.png", "dxt5")

    for i=0, 2 do   
        self.blips[i] = DxTexture("assets/blips/"..tostring(i)..".png", "dxt3")
    end

    if self.hudMask and self.circleMask and self.world then 
        self.hudMask:setValue("sPicTexture", self.world)
        self.hudMask:setValue("sMaskTexture", self.circleMask)
    end

    if (#Radar.instances == 0) then 
        addEventHandler("onClientRender", getRootElement(), Radar.state)
    end

    table.insert(Radar.instances, self)
    return self
end

function Radar.state()
    for i,v in ipairs(Radar.instances) do 
        if v.isVisible then 
            return v:design()
        end
    end
end

function Radar:setVisibility(state)
    self.isVisible = state
    return true
end

function Radar:isVisible()
    return self.isVisible
end

function Radar:blipSize(int)
    self.blipSize = int
    return true
end

function Radar:design()
    local vehicle = localPlayer:getOccupiedVehicle()
    local me = localPlayer:getPosition()

    if not vehicle then return nil end

    px = ( me.x ) / 6000
    py = ( me.y ) / -6000
  
    local zoom = 8
    local worldSize = 3000 / (200/15/self.zoom)
    local camera_rot = getCamera():getRotation().z
    local player_rot = vehicle:getRotation().z
    local speed = getElementSpeed(vehicle)

    -- Zoom out after 120kp/h
    if speed >= 120 then 
        self.zoom = math.max(self.zoom - 0.007, 7)
    else
        self.zoom = math.min(self.zoom + 0.01, 10) 
    end

    -- Setting up updated shader values --
    self.hudMask:setValue("gUVRotAngle", math.rad(-camera_rot))
    self.hudMask:setValue("gUVScale", 1/self.zoom, 1/self.zoom)
    self.hudMask:setValue("gUVPosition", px, py)

    -- Draw Radar World Base --
    dxDrawImage( self.x, self.y, self.width, self.height, self.hudMask, 0,0,0, tocolor(255,255,255,230))

    -- Draw blips --
    for i, b in ipairs (getElementsByType('blip')) do 
        if b:getDimension() == localPlayer:getDimension() and b:getInterior() == localPlayer:getInterior() then
            local elementAttached =  b:getAttachedTo()        
            if elementAttached ~= localPlayer then
                local blipPos = b:getPosition()
                local bf = b:getVisibleDistance()
                local blipIcon = b:getIcon()
                local blipX, blipY = getMathInBoundRadar(blipPos.x, blipPos.y, self.x, self.y, self.width, self.height, x*worldSize)

                if getDistanceBetweenPoints2D(me.x, me.y, blipPos.x, blipPos.y) < self.width + 60 then
                    dxDrawImage(blipX-x*self.blipSize/2, blipY-y*self.blipSize/2, x*self.blipSize, y*self.blipSize, self.blips[blipIcon], 0,0,0,tocolor(255,255,255,255))
                end       
            end
        end
    end

    dxDrawImage( self.x, self.y, self.width, self.height, "assets/circle_vignette.png", 0,0,0, tocolor(255,255,255,230) )
    dxDrawImage((self.x) + x*92, (self.y) + y*91, x*20, y*20, "assets/blips/65.png", camera_rot-player_rot,0,0, tocolor(255,255,255,230) )
end


function getElementSpeed(element)
	speedx, speedy, speedz = getElementVelocity (element)
	actualspeed = (speedx^2 + speedy^2 + speedz^2)^(0.5) 
	kmh = actualspeed * 180
	return math.floor(kmh)
end

function findRotation(x1, y1, x2, y2)
    local t = -math.deg(math.atan2(x2-x1,y2-y1))
    if t < 0 then t = t + 360 end
    return t
end

function getPointAway(x, y, angle, dist)
    local a = -math.rad(angle)
    dist = dist / 57.295779513082
    return x + (dist * math.deg(math.sin(a))), y + (dist * math.deg(math.cos(a)))
end

function getMathInBoundRadar(bx, by, x, y, w, h, scaledMapSize)
	local RadarX, RadarY = x + w/2, y + h/2
	local RadarD = getDistanceBetweenPoints2D(RadarX, RadarY, x, y)
	local px, py = getElementPosition(localPlayer)
	local _, _, crz = getElementRotation(getCamera())
	local dist = getDistanceBetweenPoints2D(px, py, bx, by)
	if dist > RadarD * 6000/scaledMapSize then
		dist = RadarD * 6000/scaledMapSize
	end

	local rot = 180 - findRotation(px, py, bx, by) + crz
	local ax, ay = getPointAway(RadarX, RadarY, rot, dist * scaledMapSize/6000)
	return ax, ay
end
