--
--  main.lua
--  xenofarm
--
--  Created by Jay Roberts on 2011-01-20.
--  Copyright 2011 GloryFish.org. All rights reserved.
--

require 'middleclass'
require 'middleclass-extras'

require 'gamestate'
require 'input'
require 'logger'
require 'profiler'

scenes = require 'scenes'

function love.load()
  profiler = newProfiler()
  profiler:start()
  
  isDebug = true

  love.graphics.setCaption('Rogue Descent')
  love.filesystem.setIdentity('rogue-descent')

  soundOn = true
  love.audio.setVolume(1)
  
  input = Input()

  Gamestate.registerEvents()
  Gamestate.switch(scenes.loading)
end

function love.update(dt)
end

function love.quit()
  profiler:stop()

  local outfile = io.open('profile.txt', 'w+')
  profiler:report(outfile)
  outfile:close()
end
