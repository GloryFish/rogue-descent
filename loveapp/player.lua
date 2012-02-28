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
  self.position = vector(0, 0)
end

function Player:receiveMessage(message, data)
end

function Player:update(dt)
end

function Player:draw()
  colors.white:set()
  love.graphics.circle('fill', self.position.x, self.position.y, 50, 40)
end