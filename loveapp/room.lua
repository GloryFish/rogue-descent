--
--  room.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-02-23.
--  Copyright 2012 Jay Roberts. All rights reserved.
--

require 'middleclass'
require 'vector'
require 'rectangle'
require 'colors'

Room = class('Room')

function Room:initialize()
  self.position = vector(50, 20)
  self.size = vector(400, 200)
end


function Room:update(dt)
end


function Room:draw()
  colors.white:set()
  love.graphics.rectangle('line', self.position.x, self.position.y, self.size.x, self.size.y)
end