--
--  roomviewer.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-02-23.
--  Copyright 2012 Jay Roberts. All rights reserved.
--

require 'logger'
require 'vector'
require 'colors'
require 'room'
require 'camera'

scenes.roomviewer = Gamestate.new()

local scene = scenes.roomviewer

function scene.enter(self, pre)
	self.room = RoomBuilder:startingRoom()
	
	self.camera = Camera()
	self.camera.deadzone = 0
	
  self.currentLevel = self.room.level
end

function scene.keypressed(self, key, unicode)
  if key == 'escape' then
    self:quit()
  end

  if key == 'c' then
    RoomBuilder.totalRooms = 0
    self.room = RoomBuilder:startingRoom()
  end

  if key == 'l' then
    self:addRoom('left')
  end
  
  if key == 'r' then
    self:addRoom('right')
  end

  if key == 'kp7' then
    if self.room.parents['left'] ~= nil then
      self.room = self.room.parents['left']
    end
  end

  if key == 'kp9' then
    if self.room.parents['right'] ~= nil then
      self.room = self.room.parents['right']
    end
  end
  
  if key == 'kp1' and self.room.children['left'] ~= nil then
    self.room = self.room.children['left']
  end

  if key == 'kp3' and self.room.children['right'] ~= nil then
    self.room = self.room.children['right']
  end
  
end

function scene.mousepressed(self, x, y, button)
end

function scene.mousereleased(self, x, y, button)
end

function scene.addRoom(self, location)
  self.room = self.room:addChild(location)
end

function scene.update(self, dt)
  if love.mouse.isDown('l') then
  end

  self.room:update(dt)
  
  self.camera.focus = vector(self.room.position.x + self.room.size.x / 2, self.room.position.y + self.room.size.y / 2)

  self.camera:update(dt)
end

function scene.draw(self)
  self.camera:apply()
  
  self.drawnRooms = nil
  self:drawRooms(self.room, self.room.level)
  self.camera:unapply()
end

function scene:drawRooms(room, level)
  if room == nil then
    return
  end
  
  if self.drawnRooms == nil then
    self.drawnRooms = {}
  end

  local levelThreshhold = 3 -- don't draw more than 5 above or below current level

  if room.level < level - levelThreshhold or room.level > level + levelThreshhold then
    return
  end
  
  if in_table(room, self.drawnRooms) then
    return
  end
  
  -- draw room
  room:draw()
  
  -- add to drawn
  table.insert(self.drawnRooms, room)

  -- draw children
  self:drawRooms(room.children['left'], level)
  self:drawRooms(room.children['right'], level)
  
  -- draw parent
  self:drawRooms(room.parents['left'], level)
  self:drawRooms(room.parents['right'], level)
end

function scene.quit(self)
end

function scene.leave(self)
end
