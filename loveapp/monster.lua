--
--  monster.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-03-09.
--  Copyright 2012 GloryFish.org. All rights reserved.
--

require 'middleclass'
require 'vector'
require 'spritesheets'

Monster = class('Monster')

local monster_names = {
  'goblin',
  'golem',
  'mushroom',
  'flaming_skull',
}

function Monster:initialize(level)
  self.level = level
  self.position = vector(0, 0)
  self.name = monster_names[math.random(#monster_names)]
  self.scale = 2

  local x, y, w, h = spritesheet.quads[self.name]:getViewport()
  self.size = vector(w, h) * self.scale
  self.offset = vector(w / 2, h) * self.scale
end

function Monster:draw()
  spritesheet.batch:addq(spritesheet.quads[self.name], 
                         math.floor(self.position.x) - self.offset.x, 
                         math.floor(self.position.y) - self.offset.y,
                         0,
                         self.scale,
                         self.scale)
end