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


scenes = {}
require 'scenes/game'
require 'scenes/roomviewer'
require 'scenes/notifytest'

function love.load()
  profiler = newProfiler()
  profiler:start()
  
  isDebug = true

  love.graphics.setCaption('Rogue Descent')
  love.filesystem.setIdentity('rogue-descent')

  -- Seed random
  local seed = os.time()
  math.randomseed(seed);
  math.random(); math.random(); math.random()

  fonts = {
    default        = love.graphics.newFont('resources/fonts/silkscreen.ttf', 24),
    small          = love.graphics.newFont('resources/fonts/silkscreen.ttf', 20),
  }

  input = Input()

  soundOn = true
  love.audio.setVolume(1)

  Gamestate.registerEvents()
  Gamestate.switch(scenes.game)
end

function love.update(dt)
end

function love.quit()
  profiler:stop()

  local outfile = io.open('profile.txt', 'w+')
  profiler:report(outfile)
  outfile:close()
end
