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
require 'spritesheets'

Player = class('Player')

function Player:initialize()
  self.position = vector(0, 0)
  self.offset = vector(-8, -16)
  self.path = {}
  self.speed = 200
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

    if movement:len() ~= 0 then
      self.position = self.position + (movement:normalized() * self.speed * dt)
    end

    local distance = target - self.position
    distance = distance:len()
    if distance < 5 then -- we've reached a node in the path
      table.remove(self.path, 1)
    end
  end
  
end

function Player:draw()
  spritesheet.batch:addq(spritesheet.quads['player'], 
                         math.floor(self.position.x) + self.offset.x, 
                         math.floor(self.position.y) + self.offset.y,
                         0,
                         2,
                         2)
  if debug then
     -- Draw path
     for i, location in ipairs(self.path) do
       local a = self.position
       if i > 1 then
         a = self.path[i - 1]
       end
       
       local b = self.path[i]
       colors.red:set()
       love.graphics.line(a.x, a.y, b.x, b.y)
       colors.white:set()
     end
  end
end