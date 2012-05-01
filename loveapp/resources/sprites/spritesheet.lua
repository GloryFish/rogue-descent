module(...)

-- This file is for use with Love2d and was generated by Zwoptex (http://zwoptexapp.com/)
--
-- The function getSpriteSheetData() returns a table suitable for importing using sprite.newSpriteSheetFromData()
--
-- Usage example:
--			local zwoptexData = require "ThisFile.lua"
-- 			local data = zwoptexData.getSpriteSheetData()
--			local spriteSheet = sprite.newSpriteSheetFromData( "Untitled.png", data )
--
-- For more details, see http://developer.anscamobile.com/content/game-edition-sprite-sheets

function getFrames()
	local frames = {
		
			{
				name = "background_steel",
				rect = { x = 56, y = 102, width = 16, height = 16 }, 
			},
		
			{
				name = "chest",
				rect = { x = 38, y = 121, width = 16, height = 16 }, 
			},
		
			{
				name = "door_closed",
				rect = { x = 106, y = 38, width = 16, height = 16 }, 
			},
		
			{
				name = "door_open",
				rect = { x = 104, y = 56, width = 16, height = 16 }, 
			},
		
			{
				name = "empty",
				rect = { x = 74, y = 100, width = 16, height = 16 }, 
			},
		
			{
				name = "flaming_skull",
				rect = { x = 34, y = 2, width = 16, height = 21 }, 
			},
		
			{
				name = "goblin",
				rect = { x = 38, y = 65, width = 16, height = 18 }, 
			},
		
			{
				name = "golem",
				rect = { x = 2, y = 2, width = 30, height = 32 }, 
			},
		
			{
				name = "green_door_closed",
				rect = { x = 38, y = 85, width = 16, height = 16 }, 
			},
		
			{
				name = "green_door_open",
				rect = { x = 20, y = 92, width = 16, height = 16 }, 
			},
		
			{
				name = "half_blue",
				rect = { x = 88, y = 38, width = 16, height = 16 }, 
			},
		
			{
				name = "half_red",
				rect = { x = 74, y = 82, width = 16, height = 16 }, 
			},
		
			{
				name = "ladder_1",
				rect = { x = 20, y = 128, width = 14, height = 16 }, 
			},
		
			{
				name = "mushroom",
				rect = { x = 106, y = 2, width = 16, height = 16 }, 
			},
		
			{
				name = "player_man_standing",
				rect = { x = 56, y = 82, width = 16, height = 18 }, 
			},
		
			{
				name = "player_man_walk_1",
				rect = { x = 68, y = 62, width = 16, height = 18 }, 
			},
		
			{
				name = "player_man_walk_2",
				rect = { x = 50, y = 45, width = 16, height = 18 }, 
			},
		
			{
				name = "player_man_walk_3",
				rect = { x = 2, y = 36, width = 16, height = 18 }, 
			},
		
			{
				name = "player_man_walk_4",
				rect = { x = 52, y = 22, width = 16, height = 18 }, 
			},
		
			{
				name = "player_man_walk_5",
				rect = { x = 2, y = 56, width = 16, height = 18 }, 
			},
		
			{
				name = "player_man_walk_6",
				rect = { x = 70, y = 2, width = 16, height = 18 }, 
			},
		
			{
				name = "player_old",
				rect = { x = 20, y = 36, width = 10, height = 16 }, 
			},
		
			{
				name = "player_woman_forward",
				rect = { x = 52, y = 2, width = 16, height = 18 }, 
			},
		
			{
				name = "player_woman_standing",
				rect = { x = 20, y = 72, width = 16, height = 18 }, 
			},
		
			{
				name = "player_woman_walk_1",
				rect = { x = 32, y = 45, width = 16, height = 18 }, 
			},
		
			{
				name = "player_woman_walk_2",
				rect = { x = 34, y = 25, width = 16, height = 18 }, 
			},
		
			{
				name = "player_woman_walk_3",
				rect = { x = 2, y = 96, width = 16, height = 18 }, 
			},
		
			{
				name = "player_woman_walk_4",
				rect = { x = 70, y = 22, width = 16, height = 18 }, 
			},
		
			{
				name = "player_woman_walk_5",
				rect = { x = 2, y = 76, width = 16, height = 18 }, 
			},
		
			{
				name = "player_woman_walk_6",
				rect = { x = 68, y = 42, width = 16, height = 18 }, 
			},
		
			{
				name = "slime_blue_1",
				rect = { x = 92, y = 92, width = 16, height = 16 }, 
			},
		
			{
				name = "slime_blue_2",
				rect = { x = 20, y = 110, width = 16, height = 16 }, 
			},
		
			{
				name = "slime_blue_3",
				rect = { x = 88, y = 2, width = 16, height = 16 }, 
			},
		
			{
				name = "slime_green_1",
				rect = { x = 2, y = 116, width = 16, height = 16 }, 
			},
		
			{
				name = "slime_green_2",
				rect = { x = 106, y = 20, width = 16, height = 16 }, 
			},
		
			{
				name = "slime_green_3",
				rect = { x = 86, y = 56, width = 16, height = 16 }, 
			},
		
			{
				name = "slime_red_1",
				rect = { x = 2, y = 134, width = 16, height = 16 }, 
			},
		
			{
				name = "slime_red_2",
				rect = { x = 38, y = 103, width = 16, height = 16 }, 
			},
		
			{
				name = "slime_red_3",
				rect = { x = 92, y = 74, width = 16, height = 16 }, 
			},
		
			{
				name = "wall_dirt",
				rect = { x = 88, y = 20, width = 16, height = 16 }, 
			},
		
			{
				name = "wall_steel",
				rect = { x = 92, y = 110, width = 16, height = 16 }, 
			},
		
	}

	return frames
end