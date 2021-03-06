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
require 'notifier'
require 'rectangle'
require 'notifier'

Door = class('Door')

function Door:initialize(position, room, destination)
  assert(position ~= nil, 'Door initilized without position')
  assert(instanceOf(Room, room), 'Door initilized with invalid room')
  assert(instanceOf(Destination, destination), 'Door initilized with invalid destination')
  assert(room ~= nil, 'A door must exist within a room')

  self.spritesheet = sprites.main

  self.rectangle = Rectangle(position, vector(40, 40))
  self.room = room
  self.destination = destination
  self.locked = true
  self.center = self.rectangle.position + vector(16, 16)

  -- Uncomment this to allow doors to be clicked open
  -- Notifier:listenForMessage('world_click', self)
end

function Door:receiveMessage(message, position)
  if message == 'world_click' then
    if self.rectangle:contains(position) then
      if self.locked then
        self.room:unlockDoorTo(self.destination)
      else
        self.room:lockDoorTo(self.destination)
      end
    end
  end
end

function Door:update(dt)
end

function Door:draw()
  colors.white:set()
  local frame = 'green_door_open'
  if self.locked then
    frame = 'green_door_closed'
  end

  self.spritesheet.batch:addq(self.spritesheet.quads[frame],
                              math.floor(self.rectangle.position.x),
                              math.floor(self.rectangle.position.y),
                              0,
                              2,
                              2)
end