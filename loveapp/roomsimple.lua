--
--  roomsimple.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-07-30.
--  Copyright 2012 Jay Roberts. All rights reserved.
--

require 'middleclass'
require 'room'

RoomSimple = class('RoomSimple', Room)

function RoomSimple:initialize(destination, position, size)
  Room.initialize(self, destination, position, size)
end


function RoomSimple:draw()
  if not self.visible then
    return
  end

  local tiles = self.tiles
  for x = 1, #tiles do
    for y = 1, #tiles[x] do
      local quad_bg = self.spritesheet.quads[tiles[x][y]]

      if quad_bg == nil then
        print('missing quad: ' .. tiles[x][y])
      else
        self.spritesheet.batch:addq(quad_bg,
                                    self.position.x + ((x - 1) * self.tileSize * self.scale),
                                    self.position.y + ((y - 1) * self.tileSize * self.scale),
                                    0,
                                    self.scale,
                                    self.scale)
      end

      local scenery_id = self.scenery[x][y]
      if scenery_id ~= 'empty' then
        local quad_scenery = self.spritesheet.quads[scenery_id]

        if quad_scenery == nil then
          print('missing quad: ' .. scenery_id)
        else
          self.spritesheet.batch:addq(quad_scenery,
                                      self.position.x + ((x - 1) * self.tileSize * self.scale),
                                      self.position.y + ((y - 1) * self.tileSize * self.scale),
                                      0,
                                      self.scale,
                                      self.scale)
        end
      end
    end
  end

  for i, door in ipairs(self.doors) do
    door:draw()
  end

  for index, object in ipairs(self.objects) do
    object:draw()
  end

  if vars.showpaths then
    for x = 1, #self.tiles do
      for y = 1, #self.tiles[x] do
        if not self.walkable[x][y] then
          self.spritesheet.batch:addq(self.spritesheet.quads['half_red'],
                                  self.position.x + ((x - 1) * self.tileSize * self.scale),
                                  self.position.y + ((y - 1) * self.tileSize * self.scale),
                                  0,
                                  self.scale,
                                  self.scale)
        end
      end
    end
  end

  colors.white:set()
  love.graphics.print('SimpleRoom', self.position.x + 20, self.position.y + 20)

end