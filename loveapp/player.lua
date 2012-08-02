--
--  player.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-02-27.
--  Copyright 2012 GloryFish.org. All rights reserved.
--

require 'middleclass'
require 'vector'
require 'colors'
require 'notifier'

Player = class('Player')

function Player:initialize()
  self.spritesheet = sprites.main

  self.position = vector(0, 0)
  self.offset = vector(-8, -16)
  self.scale = 2
  self.path = {}
  self.speed = 200
  self.flip = 1
end

function Player:receiveMessage(message, data)
end

-- Receives a table of vectors(), travels at a constant
-- speed to each position in the table, in order
function Player:followPath(path)
  assert(path ~= nil, 'path must not be nil')
  self.path = path
end

function Player:addPathNode(vec)
  assert(vector.isvector(vec), 'PathNode must be a vector')

  table.insert(self.path, vec)
end

function Player:update(dt)

  -- Follow path
  if self.path ~= nil and #self.path > 0 then
    local target = self.path[1]
    local movement = target - self.position

    if movement.x < 0 then
      self.flip = -1
    end

    if movement.x > 0 then
      self.flip = 1
    end

    if movement:len() ~= 0 then
      self.position = self.position + (movement:normalized() * self.speed * dt)
      Notifier:postMessage('player_moved', self.position)
    end

    local distance = target - self.position
    distance = distance:len()
    if distance < 5 then -- we've reached a node in the path
      table.remove(self.path, 1)
    end
  end

  -- Update offset
  local size = self:getCurrentSize()
  self.offset = vector(size.x / 2, 10) -- 10 is just right
end

-- Returns a vector representing the current size, besed on the active quad
function Player:getCurrentSize()
  local quad = self.spritesheet.quads['player_man_standing']
  local x, y, w, h = quad:getViewport()
  return vector(w, h)
end

function Player:draw()
  self.spritesheet.batch:addq(self.spritesheet.quads['player_man_standing'],
                              math.floor(self.position.x),
                              math.floor(self.position.y),
                              0,
                              self.scale * self.flip,
                              self.scale,
                              self.offset.x,
                              self.offset.y)
end