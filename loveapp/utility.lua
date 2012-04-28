--
--  utility.lua
--  redditgamejam-05
--
--  Created by Jay Roberts on 2011-01-04.
--  Copyright 2011 GloryFish.org. All rights reserved.
--

-- Make a deep copy of a lua table
function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function in_table(needle, haystack)
  for _, v in pairs(haystack) do
    if v == needle then
      return true
    end
  end
  return false
end

-- http://www.wellho.net/resources/ex.php4?item=u108/split
function string:split(delimiter)
  local result = { }
  local from  = 1
  local delim_from, delim_to = string.find( self, delimiter, from  )
  while delim_from do
    table.insert( result, string.sub( self, from , delim_from-1 ) )
    from  = delim_to + 1
    delim_from, delim_to = string.find( self, delimiter, from  )
  end
  table.insert( result, string.sub( self, from  ) )
  return result
end