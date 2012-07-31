--
--  roomfactory.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-03-31.
--  Copyright 2012 GloryFish.org. All rights reserved.
--

require 'middleclass'
require 'rooms/room'
require 'rooms/roomtiled'

RoomFactory = class('RoomFactory')

function RoomFactory:initialize()
end

function RoomFactory:buildRoom(destination, position, size)
  if vars.roomfactype == 'random' then
    -- Choose a random room type
    if math.random() > 0.5 then
      return RoomTiled(destination, position, size)
    else
      return Room(destination, position, size)
    end

  elseif  vars.roomfactype == 'base' then
    return Room(destination, position, size)

  elseif vars.roomfactype == 'tiled' then
    return RoomTiled(destination, position, size)
  end
end