--
--  notifytest.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-02-27.
--  Copyright 2012 GloryFish.org. All rights reserved.
--

require 'logger'
require 'vector'
require 'colors'
require 'notifier'

scenes.notifytest = Gamestate.new()

local scene = scenes.notifytest

function scene:enter(pre)
  Notifier:listenForMessage('myCustomMessage', scene)
  local myData = {
    name = 'my custom data',
  }
  
  print('here')
  
  Notifier:postMessage('myCustomMessage', myData)
  Notifier:postMessage('differentMessage', myData)
end

function scene:keypressed(key, unicode)
  if key == 'escape' then
    self:quit()
  end

  if key == 'l' then
    Notifier:listenForMessage('spacebar', self)
  end
  
  if key == ' ' then
    Notifier:postMessage('spacebar', myData)
  end
end

function scene:receiveMessage(message, data)
  print('receive')
  if message == 'myCustomMessage' then
    print(string.format('Received message: %s with data: %s', message, data.name))
  else
    print(string.format('Unknown message: %s', message))
  end
end

function scene:mousepressed(x, y, button)
end

function scene:mousereleased(x, y, button)
end

function scene:update(dt)
  if love.mouse.isDown('l') then
  end
end

function scene:draw()
end

function scene:quit()
  love.event.push('q')
end

function scene:leave()
end
