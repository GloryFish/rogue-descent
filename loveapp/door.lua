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
      
      self.locked = false
      print('got message mouse_up')
      Notifier:postMessage('location_selected', self.destination)
    end
  end
end

function Door:update(dt)
end

function Door:draw()
  colors.white:set()
  local mode = 'line'
  if self.locked then
    mode = 'fill'
  end
  love.graphics.rectangle(mode, self.rectangle.position.x, self.rectangle.position.y, self.rectangle.size.x, self.rectangle.size.y)
end