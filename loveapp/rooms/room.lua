--
--  room.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-07-31.
--  Copyright 2012 Jay Roberts. All rights reserved.
--

require 'middleclass'
require 'vector'
require 'rectangle'
require 'colors'
require 'destination'
require 'notifier'
require 'door'

Room = class('Room')

function Room:initialize(destination, position, size)
  assert(instanceOf(Destination, destination), 'destination must be a Destination object')
  assert(position ~= nil, 'Room intialized without position')
  assert(size ~= nil, 'Room intialized without size')

  self.destination = destination
  self.level = self.destination.level
  self.index = self.destination.index
  self.position = position
  self.size     = size
  self.center = position + size / 2
  self.visible = false

  self:generate()
end

-- Base room generation. Creates 4 doors and sets the first room to visible.
function Room:generate()

  -- doors
  self.doors = {}

  -- ul
  if self.destination.index > 1 and self.destination.level > 1 then
    local pos = vector(self.position.x + 32 * 5, self.position.y)
    table.insert(self.doors, Door(pos, self, Destination(self.destination.level - 1, self.destination.index - 1)))

  end

  -- ur
  if self.destination.index < self.destination.level and self.destination.level > 1 then
    local pos = vector(self.position.x + self.size.x - 32 * 6, self.position.y)
    table.insert(self.doors, Door(pos, self, Destination(self.destination.level - 1, self.destination.index)))
  end

  -- ll
  local pos = vector(self.position.x + 32 * 4, self.position.y + self.size.y - 32)
  table.insert(self.doors, Door(pos, self, Destination(self.destination.level + 1, self.destination.index)))

  -- lr
  pos = vector(self.position.x + self.size.x - 32 * 5, self.position.y + self.size.y - 32)
  table.insert(self.doors, Door(pos, self, Destination(self.destination.level + 1, self.destination.index + 1)))

  -- Set visibility
  if self.level == 1 then
    self.visible = true
  end
end

-- Returns true if the room contains the provided world point
function Room:containsPoint(point)
  assert(vector.isvector(point), 'point must be a vector')

  return point.x >= self.position.x and
         point.x <= self.position.x + self.size.x and
         point.y >= self.position.y and
         point.y <= self.position.y + self.size.y

end

-- Returns a table of vectors() between two world points within
-- the room. The Room version just returns the two points.
function Room:pathBetweenPoints(pointA, pointB)
  assert(self:containsPoint(pointA), 'pointA must be within this room')
  assert(self:containsPoint(pointB), 'pointB must be within this room')

  return {pointA, pointB}
end


function Room:__tostring()
  return "Room ("..tonumber(self.destination.level)..","..tonumber(self.destination.index)..","..tonumber(self.destination.id)..") ("..tonumber(self.position.x)..","..tonumber(self.position.y)..")"
end

function Room:update(dt)
end

function Room:getDoors()
  return self.doors
end

function Room:getDoorTo(destination)
  for i, door in ipairs(self.doors) do
    if door.destination == destination then
      return door
    end
  end
  return nil
end

function Room:unlockDoorTo(destination)
  assert(instanceOf(Destination, destination), 'destination must be a Destination object')

  local door = self:getDoorTo(destination)
  if door == nil then
    return
  end

  if door.locked then
    door.locked = false
    Notifier:postMessage('door_unlocked', door)
  end
end

function Room:positionIsWalkable(point)
  return self:containsPoint(point)
end


function Room:draw()
  if not self.visible then
    return
  end

  colors.gray:set()
  love.graphics.rectangle('fill', self.position.x, self.position.y, self.size.x, self.size.y)

  colors.lightgray:set()
  love.graphics.rectangle('fill', self.position.x + 32, self.position.y + 32, self.size.x - 64, self.size.y - 64)

  for i, door in ipairs(self.doors) do
    door:draw()
  end
end