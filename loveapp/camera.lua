--
--  camera.lua
--  redditgamejam-05
--
--  Created by Jay Roberts on 2011-01-06.
--  Copyright 2011 GloryFish.org. All rights reserved.
--

require 'middleclass'
require 'vector'
require 'noise'

Camera = class('Camera')

function Camera:initialize()
  self.bounds = {
    top = 0,
    right = love.graphics.getWidth(),
    bottom = love.graphics.getHeight(),
    left = 0
  }
  self.useBounds = false
  self.position = vector(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
  self.offset = self.position
  self.focus = vector(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
  self.deadzone = 100

  self.smoothMovement = true

  self.handheld = true
  self.handheldAmount = vector(0, 0)
  self.handheldNoise = {
    horizontal = Noise:perlin(1000, 1),
    vertical   = Noise:perlin(1000, 2),
  }
  self.handheldMax = vector(15, 15)

  self.shakeDuration = 0
  self.shakeTime = 0
  self.shakeAmount = vector(0, 0)
  self.shakeMax = vector(20, 20)
  self.shakeIntensity = 1

  self.speed = 1.5 -- 1 is normal speed

  self.zoom = 1

  self.elapsed = 0

end

function Camera:worldToScreen(position)
  return position - self.offset
end

function Camera:screenToWorld(position)
  return position + self.offset
end

function Camera:update(dt)
  self.elapsed = self.elapsed + dt

  -- Move the camera if we are outside the deadzone
  if self.smoothMovement then
    if self.position:dist(self.focus) > self.deadzone then
      self.position = self.position - (self.position - self.focus) * dt * self.speed
    end
  else
    self.position = self.focus
  end

  -- Clamp camera to bounds
  if self.useBounds then
    local halfWidth = love.graphics.getWidth() / 2
    local halfHeight = love.graphics.getHeight() / 2

    if self.position.x - halfWidth < self.bounds.left then
      self.position.x = self.bounds.left + halfWidth
    end

    if self.position.x + halfWidth > self.bounds.right then
      self.position.x = self.bounds.right - halfWidth
    end

    if self.position.y - halfHeight < self.bounds.top then
      self.position.y = self.bounds.top + halfHeight
    end

    if self.position.y + halfHeight > self.bounds.bottom then
      self.position.y = self.bounds.bottom - halfHeight
    end
  end

  -- Update the offset
  self.offset = vector(math.floor(self.position.x - love.graphics.getWidth() / 2),
                       math.floor(self.position.y - love.graphics.getHeight() / 2))

  if self.shakeDuration > 0 then
    self.shakeAmount = vector(math.random() * self.shakeMax.x, math.random() * self.shakeMax.y) * (self.shakeDuration / self.shakeTime)

    self.shakeDuration = self.shakeDuration - dt
  end

  if self.handheld then
    -- Sample horizontal and vertical perturbation amounts
    local index = math.ceil((0.1 * self.elapsed * 60) % 1000) -- 1000 samples at 10 samples per second gives us 100 seconds of unique movement

    self.handheldAmount = vector(math.floor(self.handheldNoise.horizontal[index] * self.handheldMax.x), math.floor(self.handheldNoise.vertical[index] * self.handheldMax.y))
  else
    self.handheldAmount = vector(0 , 0)
  end

end

function Camera:shake(duration, intesity)
  self.shakeDuration = duration
  self.shakeTime = duration
  self.shakeIntensity = intesity
  if self.shakeIntensity > 1 then
    self.shakeIntensity = 1
  end
end


function Camera:apply()
  love.graphics.push()

  local camPos = self.offset + self.shakeAmount + self.handheldAmount
  -- love.graphics.translate(-love.graphics.getWidth() / 2 * self.zoom, -love.graphics.getHeight() / 2 * self.zoom)
  -- love.graphics.scale(self.zoom)
  -- love.graphics.translate(love.graphics.getWidth() / 2 * self.zoom, love.graphics.getHeight() / 2 * self.zoom)
  --
  love.graphics.translate(-camPos.x, -camPos.y)

  --
  -- love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

end

function Camera:unapply()
  love.graphics.pop()
end