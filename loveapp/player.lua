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
end

function Player:receiveMessage(message, data)
end

function Player:update(dt)
end

function Player:draw()
  spritesheet.batch:addq(spritesheet.quads['player'], 
                         math.floor(self.position.x), 
                         math.floor(self.position.y),
                         0,
                         2,
                         2)
end