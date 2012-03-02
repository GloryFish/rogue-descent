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
  assert(position ~= nil, 'Door initilized without room')
  
  self.rectangle = Rectangle(position, vector(40, 40))
  self.room = room
  self.destination = destination
  self.locked = true
  
  Notifier:listenForMessage('mouse_up', self)
end

function Door:receiveMessage(message, position)
  if message == 'mouse_up' then
    if self.rectangle:contains(position) then
      if self.locked then
        self.locked = false
      else
        Notifier:postMessage('location_selected', self.destination)
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
  
  love.graphics.drawq(spritesheet.texture,
                      spritesheet.quads[frame], 
                      math.floor(self.position.x), 
                      math.floor(self.position.y),
                      0,
                      2,
                      2,
                      0,
                      0)
end