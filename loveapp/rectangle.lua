--
--  rectangle.lua
--  dungeon-gen
--
--  Created by Jay Roberts on 2011-08-03.
--  Copyright 2011 GloryFish.org. All rights reserved.
--

require 'middleclass'
require 'vector'

Rectangle = class('Rectangle')
function Rectangle:initialize(position, size)
  assert(vector.isvector(position), 'position must be a vector')
  assert(vector.isvector(size), 'size must be a vector')

  self.position = position
  self.size = size
end

function Rectangle:contains(point)
  return point.x >= self.position.x and
         point.y >= self.position.y and
         point.x <= self.position.x + self.size.x and
         point.y <= self.position.y + self.size.y

end

function Rectangle:intersects(rect)
  return not (rect.position.x > self.position.x + self.size.x or
              rect.position.x + rect.size.x < self.position.x or
              rect.position.y > self.position.y + self.size.y or
              rect.position.y + rect.size.y < self.position.y)
end

function Rectangle:center()
  return vector(self.position.x + self.size.x / 2, self.position.y + self.size.y / 2)
end


-- This is mainly for debugging
function Rectangle:draw(offset)
  if offset == nil then
    offset = vector(0, 0)
  end

  love.graphics.rectangle('line', self.position.x + offset.x, self.position.y + offset.y, self.size.x, self.size.y)
end




