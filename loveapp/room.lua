--
--  room.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-02-23.
--  Copyright 2012 Jay Roberts. All rights reserved.
--

require 'middleclass'
require 'vector'
require 'rectangle'
require 'colors'
require 'spritesheets'
require 'destination'
require 'door'
require 'monster'

Room = class('Room')

function Room:initialize(destination, position, size)
  assert(instanceOf(Destination, destination), 'destination must be a Destination object')
  assert(position ~= nil, 'Room intialized without position')
  assert(size ~= nil, 'Room intialized without size')
  
  self.destination = destination
  self.level = self.destination.level
  self.index = self.destination.index
  self.position = position
  self.size     = size
  self.center = position + size / 2
  self.platforms = {}
  self.objects = {}
  
  self.tileSize = 16
  self.scale = 2
  
  self:generate()
end

-- Returns the nearest platform in a room to a supplied position
-- If none are available, returns the room's center
function Room:nearestPlatform(position)
  local nearest = nil
  local shortestDistance = 100000
  
  for index, platform in ipairs(self.platforms) do
    local vec = position - platform
    local dist = vec:len()
    if dist < shortestDistance then
      shortestDistance = dist
      nearest = platform
    end
  end
  
  if nearest ~= nil then
    return nearest
  else
    return self.center
  end
end

-- Generate a random room
function Room:generate()
  -- background and walls and collision
  self.tiles = {}
  self.walkable = {}
  self.scenery = {}
  
  local width = self.size.x / 32
  local height = self.size.y / 32

  for x = 1, width, 1 do 
    self.tiles[x] = {}
    self.walkable[x] = {}
    self.scenery[x] = {}

    for y = 1, height, 1 do 
      if y == 1 or y == height or x == 1 or x == width then
        self.tiles[x][y] = 'wall_1' 
        self.walkable[x][y] = false
      else
        self.tiles[x][y] = 'background_1' 
        self.walkable[x][y] = true
      end
      
      self.scenery[x][y] = 'empty'
      
    end
  end
  
  -- doors
  self.doors = {}
  
  -- ul
  if self.destination.index > 1 and self.destination.level > 1 then
    local pos = vector(self.position.x + 32 * 5, self.position.y)
    self.doors.ul = Door(pos, self, Destination(self.destination.level - 1, self.destination.index - 1))
  else
    self.doors.ul = nil
  end
    
  -- ur
  if self.destination.index < self.destination.level and self.destination.level > 1 then
    local pos = vector(self.position.x + self.size.x - 32 * 6, self.position.y)
    self.doors.ur = Door(pos, self, Destination(self.destination.level - 1, self.destination.index))
  else
    self.doors.ur = nil
  end
  
  -- ll
  local pos = vector(self.position.x + 32 * 4, self.position.y + self.size.y - 32)
  self.doors.ll = Door(pos, self, Destination(self.destination.level + 1, self.destination.index))
  
  -- lr
  pos = vector(self.position.x + self.size.x - 32 * 5, self.position.y + self.size.y - 32)
  self.doors.lr = Door(pos, self, Destination(self.destination.level + 1, self.destination.index + 1))

  -- Add ladders
  if self.doors.ul ~= nil then
    for y = 2, height - 1 do
      self.scenery[6][y] = 'ladder_1'
    end
  end
  if self.doors.ur ~= nil then
    for y = 2, height - 1 do
      self.scenery[15][y] = 'ladder_1'
    end
  end
  
  -- Add platforms
  table.insert(self.platforms, vector(self.position.x + 16 + 32 * 5, self.position.y + self.size.y - 32))
  table.insert(self.platforms, vector(self.position.x + self.size.x - (32 * 5) + 16, self.position.y + self.size.y - 32))
  
  -- Add monsters
  for i = 1, 3 do
    local monster = Monster(self.destination.level)
    table.insert(self.objects, monster)    
  end
  
  -- Add items

  
  -- Position objects
  local padding = 10
  width = 0
  for index, object in pairs(self.objects) do
    width = width + object.size.x
  end
  width = width + (padding * (#self.objects - 1))
  
  local x = self.center.x - width / 2
  for index, object in pairs(self.objects) do
    object.position = vector(x + (object.size.x / 2), self.position.y + 285)
    x = x + object.size.x + padding
  end
end

function Room:toWorldCoords(point)
  local world = vector(
    (point.x - 1) * self.tileSize * self.scale,
    (point.y - 1) * self.tileSize * self.scale
  )
  
  return world
end

function Room:toWorldCoordsCenter(point)
  local world = vector(
    point.x * self.tileSize * self.scale,
    point.y * self.tileSize * self.scale
  )
  
  world = world + vector(self.tileSize * self.scale / 2, self.tileSize * self.scale / 2)
  
  return world
end

function Room:toTileCoords(point)
  local world = point - self.position
  local coords = vector(math.floor(point.x / (self.tileSize * self.scale)) + 1,
                        math.floor(point.y / (self.tileSize * self.scale)) + 1)
  return coords
end

function Room:tilePointIsWalkable(tile)
  assert(vector.isvector(tile), 'tile must be a vector')
  
  if self.walkable[tile.x] ~= nil then
    return self.walkable[tile.x][tile.y]
  else
    return false
  end
end

function Room:__tostring()
	return "Room ("..tonumber(self.destination.level)..","..tonumber(self.destination.index)..","..tonumber(self.destination.id)..") ("..tonumber(self.position.x)..","..tonumber(self.position.y)..")"
end

function Room:update(dt)
end

function Room:unlockDoorTo(destination)
  for key, door in pairs(self.doors) do
    if door.destination == destination then
      door.locked = false
      
      local coords = self:toTileCoords(door.center)
      self.walkable[coords.x][coords.y] = true
    end
  end
end

function Room:draw()
  for x = 1, #self.tiles do
    for y = 1, #self.tiles[x] do
      local quad_bg = spritesheet.quads[self.tiles[x][y]]
      local quad_scenery = spritesheet.quads[self.scenery[x][y]]

      spritesheet.batch:addq(quad_bg, 
                              self.position.x + ((x - 1) * self.tileSize * self.scale), 
                              self.position.y + ((y - 1) * self.tileSize * self.scale),
                              0,
                              self.scale,
                              self.scale)
                              
      spritesheet.batch:addq(quad_scenery, 
                              self.position.x + ((x - 1) * self.tileSize * self.scale), 
                              self.position.y + ((y - 1) * self.tileSize * self.scale),
                              0,
                              self.scale,
                              self.scale)
    end
  end
  
  for name, door in pairs(self.doors) do
    door:draw()
  end

  for index, object in ipairs(self.objects) do
    object:draw()
  end
  
  if debug then
    for x = 1, #self.tiles do
      for y = 1, #self.tiles[x] do
        if not self.walkable[x][y] then
          spritesheet.batch:addq(spritesheet.quads['half_red'], 
                                  self.position.x + ((x - 1) * self.tileSize * self.scale), 
                                  self.position.y + ((y - 1) * self.tileSize * self.scale),
                                  0,
                                  self.scale,
                                  self.scale)
        end
      end
    end
  end
  
end

