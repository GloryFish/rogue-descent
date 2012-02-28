--
--  notifier.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-02-27.
--  Copyright 2012 GloryFish.org. All rights reserved.
--

require 'middleclass'
require 'utility'

local NotifierClass = class('NotifierClass')

function NotifierClass:initialize()
  self.listeners = {}
end

function NotifierClass:listenForMessage(message, listener)
  if self.listeners[message] == nil then
    self.listeners[message] = {}
  end

  if not in_table(listener, self.listeners[message]) then
    table.insert(self.listeners[message], listener)
  end
end

function NotifierClass:stopListeningForMessage(message, listener)
  if self.listeners[message] == nil then
    return
  end
  for index, l in ipairs(listener) do
    if l == listener then
      table.remove(self.listeners, index)
      return
    end
  end
end


function NotifierClass:postMessage(message, data)
  if self.listeners[message] == nil then
    self.listeners[message] = {}
  end
  
  for index, listener in ipairs(self.listeners[message]) do
    listener:receiveMessage(message, data)
  end
end
  
Notifier = NotifierClass()
  