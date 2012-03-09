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
require 'spritesheets'

Door = class('Door')

function Door:initialize(position, room, destination)
  assert(position ~= nil, 'Door initilized without position')
  assert(instanceOf(Room, room), 'Door initilized with invalid room')
  assert(instanceOf(Destination, destination), 'Door initilized with invalid destination')
  
  self.rectangle = Rectangle(position, vector(40, 40))
  self.room = room
  self.destination = destination
  self.locked = true
  self.center = self.rectangle.position + vector(16, 16)
  Notifier:listenForMessage('mouse_up', self)
end

function Door:receiveMessage(message, position)
  if message == 'mouse_up' then
    if self.rectangle:contains(position) then
      if self.locked then
        self.locked = false
      else
        print(string.format('posted door_selected dest: %s', tostring(self.destination)))
        
        Notifier:postMessage('door_selected', self)
      end
    end
  end
end

function Door:update(dt)
end

function Door:draw()
  colors.white:set()
  local frame = 'door_open'
  if self.locked then
    frame = 'door_closed'
  end
  
  spritesheet.batch:addq(spritesheet.quads[frame], 
                         math.floor(self.rectangle.position.x), 
                         math.floor(self.rectangle.position.y),
                         0,
                         2,
                         2)
end