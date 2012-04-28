--
--  base.lua
--  rogue-descent
--
--  An example of commands that can be invoked by the console. To add new commands create a new file in the commands folder.
--  That file should return a table of commands. Keys are command names and values are functions that recieve a delegate and a
--  variable number of arguments.
--  
--  In general, the delgate should be the main game scene. It may also be nil.
--
--  The function should return a message string or a table of strings or nil. Yeah, I'm awesome.
--
--  of text to be added to the console window.
--
--  Created by Jay Roberts on 2012-04-27.
--  Copyright 2012 GloryFish.org. All rights reserved.
--

local commands = {
  quit = {
    description = 'Exit the game',
    callback = function(delegate, ...)
      love.event.push('quit')
      return
    end,
  },

  exit = {
    description = 'Exit the game',
    callback = function(delegate, ...)
      love.event.push('quit')
      return
    end,
  },
}

return commands