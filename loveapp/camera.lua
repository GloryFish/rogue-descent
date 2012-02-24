--
--  camera.lua
--  redditgamejam-05
--
--  Created by Jay Roberts on 2011-01-06.
--  Copyright 2011 GloryFish.org. All rights reserved.
--

require 'middleclass'
require 'vector'

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
  
  self.zoom = 1
end


function Camera:update(dt)
  -- Move the camera if we are outside the deadzone
  if self.position:dist(self.focus) > self.deadzone then
    self.position = self.position - (self.position - self.focus) * dt
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
end

function Camera:apply()
  love.graphics.push()

  -- love.graphics.translate(-love.graphics.getWidth() / 2 * self.zoom, -love.graphics.getHeight() / 2 * self.zoom)
  -- love.graphics.scale(self.zoom)
  -- love.graphics.translate(love.graphics.getWidth() / 2 * self.zoom, love.graphics.getHeight() / 2 * self.zoom)
  -- 
  love.graphics.translate(-self.offset.x, -self.offset.y)

  -- 
  -- love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
  
end

function Camera:unapply()
  love.graphics.pop()
end