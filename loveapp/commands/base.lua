--
--  base.lua
--  rogue-descent
--
--  An example of commands that can be invoked by the console. To add new commands create a new file in the commands folder.
--  That file should return a table of commands. Keys are command names and values are functions that recieve a variable 
--  number of arguments.
--  
--  The first argument will always be the console's delegate. In general, this should be the main game scene. It may also
--  be nil.
--
--  The function should return a boolean success variable and a message string. It may also return a table of strings
--  or nothign at all. Yeah, I'm awesome.
--
--  of text to be added to the console window.
--
--  Created by Jay Roberts on 2012-04-27.
--  Copyright 2012 GloryFish.org. All rights reserved.
--

local commands = {
  echo = function(...)
    local delegate = arg[1]
    local text = arg[2]
    print(delegate)
    print(text)
    
    return true, {text}
  end,
  
  fail = function(...)
    return false, {'This command failed intentionally'}
  end,
  
  quit = function(...)
    love.event.push('quit')
    return true
  end,
  
}

return commands