--
--  scenes.lua
--  rogue-descent
--
--  Load all of the scenes in the "scenes" folder (except the base scene) and return a
--  table containing them, indexed by name.
--
--  Created by Jay Roberts on 2012-04-26.
--

local scenes = {}

local scenelist = love.filesystem.enumerate('scenes')

for i, filename in ipairs(scenelist) do
  local name = filename:sub(1, -5)
  if name ~= 'base' then
    scenes[name] = require('scenes/'..name)
  end
end

return scenes