--
--  roomtiled.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-02-23.
--  Copyright 2012 Jay Roberts. All rights reserved.
--

require 'middleclass'
require 'room'
require 'vector'
require 'rectangle'
require 'colors'
require 'destination'
require 'door'
require 'monster'
require 'astar'

RoomTiled = class('RoomTiled', Room)

function RoomTiled:initialize(destination, position, size)
  assert(instanceOf(Destination, destination), 'destination must be a Destination object')
  assert(position ~= nil, 'Room intialized without position')
  assert(size ~= nil, 'Room intialized without size')

  self.destination = destination
  self.level = self.destination.level
  self.index = self.destination.index
  self.position = position
  self.size     = size
  self.center = position + size / 2
  self.visible = false

  -- RoomTiled specific initialization
  self.spritesheet = sprites.main

  self.objects = {}

  self.tileSize = 16
  self.scale = 2

  self.astar = AStar(self)

  self:generate()
end

-- Generate a random room
function RoomTiled:generate()
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
        self.tiles[x][y] = 'wall_dirt'
        self.walkable[x][y] = false -- Outside wall is not walkable
      else
          self.tiles[x][y] = 'background_steel' -- Most of the background is not walkable
        self.walkable[x][y] = false
      end

      self.scenery[x][y] = 'empty'

    end
  end

  -- Make bottom row of tiles walkable
  for x = 2, width - 1 do
    self.walkable[x][height -1] = true
  end

  -- doors
  self.doors = {}

  -- ul
  if self.destination.index > 1 and self.destination.level > 1 then
    local pos = vector(self.position.x + 32 * 5, self.position.y)
    table.insert(self.doors, Door(pos, self, Destination(self.destination.level - 1, self.destination.index - 1)))

    -- Add ladder
    for y = 2, height - 1 do
      self.scenery[6][y] = 'ladder_1'
      self.walkable[6][y] = true
    end
  end

  -- ur
  if self.destination.index < self.destination.level and self.destination.level > 1 then
    local pos = vector(self.position.x + self.size.x - 32 * 6, self.position.y)
    table.insert(self.doors, Door(pos, self, Destination(self.destination.level - 1, self.destination.index)))

    -- Add ladder
    for y = 2, height - 1 do
      self.scenery[15][y] = 'ladder_1'
      self.walkable[15][y] = true
    end

  end

  -- ll
  local pos = vector(self.position.x + 32 * 4, self.position.y + self.size.y - 32)
  table.insert(self.doors, Door(pos, self, Destination(self.destination.level + 1, self.destination.index)))

  -- lr
  pos = vector(self.position.x + self.size.x - 32 * 5, self.position.y + self.size.y - 32)
  table.insert(self.doors, Door(pos, self, Destination(self.destination.level + 1, self.destination.index + 1)))

  -- Add monsters
  if self.level ~= 1 then -- First room has no monsters
    for i = 1, 3 do
      local monster = Monster(self.destination.level)
      table.insert(self.objects, monster)
    end
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

  -- Set visibility
  if self.level == 1 then
    self.visible = true
  end
end

function RoomTiled:toWorldCoords(point)
  local world = vector(
    (point.x - 1) * self.tileSize * self.scale,
    (point.y - 1) * self.tileSize * self.scale
  )

  return world
end

function RoomTiled:toWorldCoordsCenter(point)
  local world = vector(
    (point.x - 1) * self.tileSize * self.scale,
    (point.y - 1) * self.tileSize * self.scale
  )

  world = world + vector(self.tileSize * self.scale / 2, self.tileSize * self.scale / 2) + self.position

  return world
end

-- Returns a table of vectors() between two world points within
-- the room. Uses AStar pathfinding to search for walkable paths.
function RoomTiled:pathBetweenPoints(pointA, pointB)
  assert(self:containsPoint(pointA), 'pointA must be within this room')
  assert(self:containsPoint(pointB), 'pointB must be within this room')

  local tileA = self:toTileCoords(pointA)
  local tileB = self:toTileCoords(pointB)

  local nodePath = self.astar:findPath(tileA, tileB)
  if nodePath == nil then
    return nil
  end

  local path = {}

  for i, node in ipairs(nodePath:getNodes()) do
    local worldPoint = self:toWorldCoordsCenter(node.location)
    table.insert(path, worldPoint)
  end

  return path
end


-- Converts a world point to local tile coordinates
function RoomTiled:toTileCoords(point)
  local loc = point - self.position

  local coords = vector(math.floor(loc.x / (self.tileSize * self.scale)) + 1,
                        math.floor(loc.y / (self.tileSize * self.scale)) + 1)
  return coords
end

function RoomTiled:positionIsWalkable(point)
  local tile = self:toTileCoords(point)
  return self:tilePointIsWalkable(tile)
end

function RoomTiled:tilePointIsWalkable(tile)
  assert(vector.isvector(tile), 'tile must be a vector')

  if tile.x < 1 or
     tile.y < 1 or
     tile.x > #self.walkable or
     tile.y > #self.walkable[1] then
     return false
  end

  if self.walkable[tile.x] ~= nil then
    return self.walkable[tile.x][tile.y]
  else
    return false
  end
end

function RoomTiled:__tostring()
	return "RoomTiled ("..tonumber(self.destination.level)..","..tonumber(self.destination.index)..","..tonumber(self.destination.id)..") ("..tonumber(self.position.x)..","..tonumber(self.position.y)..")"
end

function RoomTiled:update(dt)
end

function RoomTiled:unlockDoorTo(destination)
  assert(instanceOf(Destination, destination), 'destination must be a Destination object')

  local door = self:getDoorTo(destination)
  if door == nil then
    return
  end

  if door.locked then
    door.locked = false
    Notifier:postMessage('door_unlocked', door)
  end

  -- RoomTiled needs to set the door tile as walkable area it is unlocked
  local coords = self:toTileCoords(door.center)
  self.walkable[coords.x][coords.y] = true
end

function RoomTiled:draw()
  if not self.visible then
    return
  end

  -- Darw background and scenery tile layers
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

  -- Draw doors
  for i, door in ipairs(self.doors) do
    door:draw()
  end

  -- Draw objects
  for index, object in ipairs(self.objects) do
    object:draw()
  end

  -- Draw pathfinding information
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
end


-- AStar MapHandler

-- Location should be a point in tile coordinates
function RoomTiled:getNode(location)
  assert(vector.isvector(location), 'location must be a vector')

  if not self:tilePointIsWalkable(location) then
    return nil;
  end

  return Node(location, 10, location.y * #self.tiles + location.x)
end


function RoomTiled:getAdjacentNodes(curnode, dest)
  -- Given a node, return a table containing all adjacent nodes
  -- The code here works for a 2d tile-based game but could be modified
  -- for other types of node graphs
  local result = {}
  local cl = curnode.location
  local dl = dest

  local n = false

  n = self:_handleNode(cl.x + 1, cl.y, curnode, dl.x, dl.y)
  if n then
    table.insert(result, n)
  end

  n = self:_handleNode(cl.x - 1, cl.y, curnode, dl.x, dl.y)
  if n then
    table.insert(result, n)
  end

  n = self:_handleNode(cl.x, cl.y + 1, curnode, dl.x, dl.y)
  if n then
    table.insert(result, n)
  end

  n = self:_handleNode(cl.x, cl.y - 1, curnode, dl.x, dl.y)
  if n then
    table.insert(result, n)
  end

  return result
end

function RoomTiled:locationsAreEqual(a, b)
  return a.x == b.x and a.y == b.y
end

function RoomTiled:_handleNode(x, y, fromnode, destx, desty)
  -- Fetch a Node for the given location and set its parameters
  local loc = vector(x, y)

  local n = self:getNode(loc)

  if n ~= nil then
    local dx = math.max(x, destx) - math.min(x, destx)
    local dy = math.max(y, desty) - math.min(y, desty)
    local emCost = dx + dy

    n.mCost = n.mCost + fromnode.mCost
    n.score = n.mCost + emCost
    n.parent = fromnode

    return n
  end

  return nil
end
