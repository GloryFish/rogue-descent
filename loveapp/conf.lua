--
--  conf.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-04-24.
--  Copyright 2012 GloryFish.org. All rights reserved.
--

function love.conf(config)
  config.title = 'Rogue Descent'                     -- The title of the window the game is in (string)
  config.author = 'Jay Roberts and Paul Bredenberg'  -- The author of the game (string)
  config.identity = 'rogue-descent'                  -- The name of the save directory (string)
  config.version = '0.8.0'                           -- The LÖVE version this game was made for (string)
  config.console = false                             -- Attach a console (boolean, Windows only)
  config.release = false           -- Enable release mode (boolean)
  config.screen.width = 1024       -- The window width (number)
  config.screen.height = 768       -- The window height (number)
  config.screen.fullscreen = false -- Enable fullscreen (boolean)
  config.screen.vsync = true       -- Enable vertical sync (boolean)
  config.screen.fsaa = 0           -- The number of FSAA-buffers (number)
  config.modules.joystick = true   -- Enable the joystick module (boolean)
  config.modules.audio = true      -- Enable the audio module (boolean)
  config.modules.keyboard = true   -- Enable the keyboard module (boolean)
  config.modules.event = true      -- Enable the event module (boolean)
  config.modules.image = true      -- Enable the image module (boolean)
  config.modules.graphics = true   -- Enable the graphics module (boolean)
  config.modules.timer = true      -- Enable the timer module (boolean)
  config.modules.mouse = true      -- Enable the mouse module (boolean)
  config.modules.sound = true      -- Enable the sound module (boolean)
  config.modules.physics = false   -- Enable the physics module (boolean)
end