--
--  dungeon.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-02-24.
--  Copyright 2012 GloryFish.org. All rights reserved.
--

require 'middleclass'
require 'vector'
require 'roomfactory'
require 'astar'
require 'notifier'
require 'random'

Dungeon = class('Dungeon')

function Dungeon:initialize()
  self.astar = AStar(self)

  local seed = 0

  self.random = twister(seed)

  self:reset()

  Notifier:listenForMessage('player_moved', self)
  Notifier:listenForMessage('player_entered_room', self)
end

function Dungeon:reset()
  self.rooms = {}
  self.roomSize = vector(640, 320)
  self.roomFactory = RoomFactory('random', self.random)

  local startingRoom = self.roomFactory:buildRoom(Destination(1, 1), vector(0, 0), self.roomSize)

  self.rooms[startingRoom.destination.id] = startingRoom
  self.currentRoom = startingRoom

  -- This is a vector which indicates where an observer is currently looking, may not be the player's position
  -- Used for determining which rooms in the dungeon to render and update
  self.focus = startingRoom.position
end

function Dungeon:receiveMessage(message, data)
  if message == 'player_moved' then
    local positions = data
    local prevDest = self:destinationForPosition(positions.previous)
    local currDest = self:destinationForPosition(positions.current)

    if prevDest ~= currDest then
      Notifier:postMessage('player_left_room', self:roomAt(prevDest))
      Notifier:postMessage('player_entered_room', self:roomAt(currDest))
    end
  end

  if message == 'player_entered_room' then
    local room = data

    local descendants = self:getDestinationDescendants(room.destination, 2)

    for i, dest in ipairs(descendants) do
      self:roomAt(dest)
    end
  end
end

function Dungeon:idForLevelAndIndex(level, index)
  return ((level - 1) * level / 2) + index
end

function Dungeon:destinationForPosition(position)
  assert(vector.isvector(position), 'position must be a vector')

  local level = math.floor(position.y / self.roomSize.y) + 1

  local x = position.x + (self.roomSize.x * level / 2) - (self.roomSize.x / 2)
  local index = math.floor(x / self.roomSize.x) + 1

  if level < 1 then
    return nil
  end

  if index < 1 then
    return nil
  end

  if index > level then
    return nil
  end

  return Destination(level, index)
end

function Dungeon:positionIsWalkable(position)
  assert(vector.isvector(position), 'position must be a vector')

  local destination = self:destinationForPosition(position)

  if destination == nil then
    return false
  end

  local room = self.rooms[destination.id]
  if room == nil then
    return false
  end

  return room:positionIsWalkable(position)
end

function Dungeon:positionForRoomAtDestination(destination)
  assert(instanceOf(Destination, destination), 'destination must be a Destination object')
  local level = destination.level
  local index = destination.index

  return vector((-level * self.roomSize.x / 2) + (self.roomSize.x / 2) + (self.roomSize.x * index) - self.roomSize.x,
                level * self.roomSize.y - self.roomSize.y)
end

function Dungeon:pathBetweenPoints(pointA, pointB)
  assert(vector.isvector(pointA), 'pointA must be a vector')
  assert(vector.isvector(pointB), 'pointB must be a vector')

  -- No path if start and destination are not walkable
  if not self:positionIsWalkable(pointA) or not self:positionIsWalkable(pointB) then
    return nil
  end

  local destA = self:destinationForPosition(pointA)
  local destB = self:destinationForPosition(pointB)

  -- if start and end destinations are the same, skip broadphase
  if destA.id == destB.id then
    return self.rooms[destA.id]:pathBetweenPoints(pointA, pointB)
  end

  local nodePath = self.astar:findPath(destA, destB)
  if nodePath == nil then
   return nil
  end

  local broadpath = {}

  for i, node in ipairs(nodePath:getNodes()) do
   -- local worldPoint = self:toWorldCoordsCenter(node.location)
   table.insert(broadpath, node.location)
  end

  if isDebug then
    print('found dungeon path with '..tostring(#broadpath)..' nodes')
    for i, destination in ipairs(broadpath) do
     print(destination)
    end
  end

  -- Perform narrowphase pathfinding between each room in the broadpath
  local narrowpath = {}

  local startPosition = pointA

  for i, node in ipairs(broadpath) do
    local currentRoom = self.rooms[node.id]

    local nextNode = broadpath[i + 1]
    if nextNode ~= nil then
      -- If there is a next room
      local nextRoom = self.rooms[nextNode.id]
      local currentDoor = currentRoom:getDoorTo(nextRoom.destination)

      if currentDoor == nil then
        print('currentDoor is nil at 142')
        return nil
      end

      -- Find path from start position to the position of the door to the next room
      local path = currentRoom:pathBetweenPoints(startPosition, currentDoor.center)

      if path == nil then
        print('path is nil at 143')
        return nil
      end

      -- Add the newly found path nodes
      for i, item in ipairs(path) do
        table.insert(narrowpath, item)
      end

      local nextDoor = nextRoom:getDoorTo(currentRoom.destination)

      startPosition = nextDoor.center
    else
      -- Else
        -- Find a path from start position to end position
        local path = currentRoom:pathBetweenPoints(startPosition, pointB)

        if path == nil then
          print('path is nil at 161')
          return nil
        end

        -- Add the newly found path nodes
        for i, item in ipairs(path) do
          table.insert(narrowpath, item)
        end
    end
  end

  return narrowpath

end

function Dungeon:setCurrentRoom(destination)
  assert(instanceOf(Destination, destination), 'destination must be a Destination object')


  if self.currentRoom.destination ~= destination then
    local room = self:roomAt(destination)
    assert(instanceOf(Room, room), 'couldn\'t make a valid room')

    self.currentRoom:setIsCurrent(false)
    room:setIsCurrent(true)

    self.currentRoom = room
  end
end

function Dungeon:roomAt(destination)
  assert(instanceOf(Destination, destination), 'destination must be a Destination object')

  local room = self.rooms[destination.id]
  if room == nil then
    local position = self:positionForRoomAtDestination(destination)
    room = self.roomFactory:buildRoom(destination, position, self.roomSize)
    self.rooms[destination.id] = room
  end

  return room
end

function Dungeon:update(dt)
  local focusDestination = self:destinationForPosition(self.focus)
  if not focusDestination then
    print('invalid focus destination for: ' .. tostring(self.focus))
    return
  end

  for index, destination in ipairs(self:getNeighborhood(focusDestination)) do
    self.rooms[destination.id]:update(dt)
  end
end

-- Gives a set of destinations (that actually have rooms) in an area around a given destination
function Dungeon:getNeighborhood(destination, spread)
 if spread == nil then
   spread = 3
 end

 local neighborhood = {}

 for level = destination.level - spread, destination.level + spread do
   for index = destination.index - spread, destination.index + spread do
     if level > 0 and index > 0 and index <= level then
       local dest = Destination(level, index)
       if self.rooms[dest.id] ~= nil then
         table.insert(neighborhood, dest)
       end
     end
   end
 end
 return neighborhood
end

-- Gives a set of destinations (which may or may not have rooms) which are direct descendants of a given destination
function Dungeon:getDestinationDescendants(destination, depth)
  assert(instanceOf(Destination, destination), 'destination must be a Destination object')

  if depth == nil then
    depth = 1
  end
  assert(depth > 0, 'depth must be greater than 0')

  local destinations = {}

  for level = destination.level + 1, destination.level + depth do
    for index = destination.index, destination.index + level - destination.level do
      local destination = Destination(level, index)
      table.insert(destinations, destination)
    end
  end

  return destinations
end

function Dungeon:draw(mode)
  local focusDestination = self:destinationForPosition(self.focus)
  if not focusDestination then
    print('invalid focus destination for: ' .. tostring(self.focus))
    return
  end

  for index, destination in ipairs(self:getNeighborhood(focusDestination, 2)) do
    self.rooms[destination.id]:draw(mode)
  end
end

-- AStar MapHandler

-- Location should be a point in tile coordinates
function Dungeon:getNode(destination)
  assert(instanceOf(Destination, destination), 'destination must be a Destination object')

  if self.rooms[destination.id] == nil then
    return nil
  end

  return Node(destination, 10, destination.id)
end


function Dungeon:getAdjacentNodes(curnode, dest)
  local result = {}

  -- Process rooms accordign to door connections
  local currentRoom = self.rooms[curnode.location.id]

  for i, door in ipairs(currentRoom:getDoors()) do
    if not door.locked then
      local neighbor = door.destination
      n = self:_handleNode(neighbor.level, neighbor.index, curnode, dest.level, dest.index)
      if n then
        table.insert(result, n)
      end
    end
  end

  return result
end

function Dungeon:locationsAreEqual(a, b)
  return a.id == b.id
end

function Dungeon:_handleNode(level, index, fromnode, destlevel, destindex)
  -- Fetch a Node for the given location and set its parameters
  local dest = Destination(level, index)

  local n = self:getNode(dest)

  if n ~= nil then
    local dlevel = math.max(level, destlevel) - math.min(level, destlevel)
    local dindex = math.max(index, destindex) - math.min(index, destindex)
    local emCost = dlevel + dindex

    n.mCost = n.mCost + fromnode.mCost
    n.score = n.mCost + emCost
    n.parent = fromnode

    return n
  end

  return nil
end
