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
  self.isCurrent = false

  Notifier:listenForMessage('player_left_room', self)
  Notifier:listenForMessage('player_entered_room', self)

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

-- Returns true if the point is within the inner bounds of the room. This means the point is considered to be
-- past any doorways or other obstacles. Used primarily to determine when a player has committed to entering the room.
function Room:innerBoundsContainsPoint(point)
  if point.x > self.position.x + 32 and
    point.y > self.position.y + 33 and   -- Ensure that player moves past upper doors
    point.x < self.position.x + self.size.x - 32 and
    point.y < self.position.y + self.size.y - 32 then
    return true
  end
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

function Room:setIsCurrent(current)
  if self.isCurrent == current then
    return
  end

  self.isCurrent = current

  if self.isCurrent then
    Notifier:listenForMessage('player_moved', self)
  else
    Notifier:stopListeningForMessage('player_moved', self)
  end
end

function Room:receiveMessage(message, data)
  if message == 'player_entered_room' then
    print('self: '..tostring(self.destination))
    print('data: '..tostring(data.destination))

    if self.destination == data.destination then
      print('room received own message: player_entered_room')
      self:lockUpperDoors()
      self:unlockLowerDoors()
    end
  end

  if message == 'player_left_room' then
    print('self: '..tostring(self.destination))
    print('data: '..tostring(data.destination))

    if self.destination == data.destination then
      self:lockLowerDoors()
    end
  end
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

function Room:lockDoorTo(destination)
  assert(instanceOf(Destination, destination), 'destination must be a Destination object')

  local door = self:getDoorTo(destination)
  if door == nil then
    return
  end

  if not door.locked then
    door.locked = true
    Notifier:postMessage('door_locked', door)
  end
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

function Room:lockUpperDoors()
  if self.destination.index > 1 and self.destination.level > 1 then
    local dest = Destination(self.destination.level - 1, self.destination.index - 1)
    self:lockDoorTo(dest)
  end

  -- ur
  if self.destination.index < self.destination.level and self.destination.level > 1 then
    local dest = Destination(self.destination.level - 1, self.destination.index)
    self:lockDoorTo(dest)
  end
end

function Room:lockLowerDoors()
  -- ll
  self:lockDoorTo(Destination(self.destination.level + 1, self.destination.index))

  -- lr
  self:lockDoorTo(Destination(self.destination.level + 1, self.destination.index + 1))
end

function Room:unlockLowerDoors()
  -- ll
  self:unlockDoorTo(Destination(self.destination.level + 1, self.destination.index))

  -- lr
  self:unlockDoorTo(Destination(self.destination.level + 1, self.destination.index + 1))
end

function Room:positionIsWalkable(point)
  if point.x > self.position.x + 32 and
     point.y > self.position.y + 32 and
     point.x < self.position.x + self.size.x - 32 and
     point.y < self.position.y + self.size.y - 32 then
     return true
  end

  for i, door in ipairs(self.doors) do
    if not door.locked and door.rectangle:contains(point) then
      return true
    end
  end

  return false
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
