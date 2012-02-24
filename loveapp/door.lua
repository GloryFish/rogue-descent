--
--  door.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-02-23.
--  Copyright 2012 Jay Roberts. All rights reserved.
--

require 'middleclass'
require 'vector'
require 'rectangle'
require 'colors'
require 'utility'

Door = class('Door')

doortypes = {
  RED = 1,
  GREEN = 2,
  BLUE = 3,
}

function Door:initialize(doortype)
  assert(in_table(doortype, doortypes), string.format('Invalid doortype: %s', doortype))
  
  self.position = vector(0, 0)
  self.type = doortype
end


function Door:update(dt)
end


function Door:draw()
  colors.white:set()
  love.graphics.rectangle('line', self.position.x, self.position.y, self.size.x, self.size.y)
end