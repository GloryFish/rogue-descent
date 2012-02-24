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
require 'door'

RoomBuilderClass = class('RoomBuilderClass')

function RoomBuilderClass:initialize()
  self.totalRooms = 0
  self.roomSize = vector(600, 250)
  self.roomPadding = 10
end

function RoomBuilderClass:roomWithLevel(level)
  assert(type(level) == 'number', string.format('roomWithLevel expects a number, got: %s', type(level)))

  local room = Room()
  room.id = self.totalRooms
  self.totalRooms = self.totalRooms + 1
  
  room.size = self.roomSize
  room.level = level
  room.color = room.color:random()
  
  return room
end

function RoomBuilderClass:startingRoom()
  return self:roomWithLevel(0)
end

RoomBuilder = RoomBuilderClass()

Room = class('Room')

function Room:initialize()
  self.position = vector(0, 0)
  self.size = vector(0, 0)

  self.parent = nil
  self.children = {
    left = nil,
    right = nil,
  }
  
  self.level = 1
  
  self.color = colors.white
end

function Room:addChild(loc)
  local location = loc or 'left'
  
  local room = RoomBuilder:roomWithLevel(self.level + 1)
  room.parent = self
  
  local pos = self.position:clone()
  pos.y = pos.y + self.size.y + RoomBuilder.roomPadding
  
  if location == 'left' then
    pos.x = pos.x - room.size.x / 2
    self.children.left = room
  else -- right
    pos.x = pos.x + room.size.x / 2
    self.children.right = room
  end
  
  room.position = pos
  
  return room
  
end


function Room:update(dt)
end


function Room:draw()
  self.color:set()
  love.graphics.rectangle('line', self.position.x, self.position.y, self.size.x, self.size.y)
  
  if debug then
    love.graphics.print(string.format('id: %s level: %s', self.id, self.level), 
                        self.position.x + 10, 
                        self.position.y + 10);
  end
end

