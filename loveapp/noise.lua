--
--  noise.lua
--
--  Created by Jay Roberts on 9-4-2012.
--  Copyright 2011 GloryFish.org. All rights reserved.
--

require 'middleclass'

local NoiseClass = class('Noise')

-- Linear interpolation: Faster, but uglier
local function lerp(a, b, amount)
  return a + (b - a) * amount
end

-- Cosine interpolation: Slower, but prettier
local function cerp(a, b, amount)
  local f = (1 - math.cos(amount * math.pi)) * 0.5
  return a * (1 - f) + b * f
end

function NoiseClass:initialize()
  self.noise = {}
  for i = 1, 1000 do
    self.noise[i] = math.random()
  end
end

function NoiseClass:noise1(x)
  n = x * 57
  n = bxor((n * 2^13), n);
  return ( 1.0 - ( (n * (n * n * 15731 + 789221) + 1376312589) % 2147483648) / 1073741824.0)
end

function NoiseClass:perlin(n, seed, octaves)
  local random = twister(seed)

  octaves = octaves or {2, 8, 32}

  local noise = {}

  for octave_index, octave in ipairs(octaves) do
    -- Generate a set of random values for the current octave
    local values = {}
    for i = 1, n / octave + octave + 1 do
      values[i] = random:random() - 0.5
    end

    for i = 1, n do
      local x = values[math.floor(i / octave) + 1]
      local y = values[math.floor(i / octave) + 2]
      local t = (i % octave) / octave

      noise[i] = (noise[i] or 0) * ((octaves[octave_index - 1] or 1) / octave) + cerp(x,y,t)
    end
  end

  return noise
end

Noise = NoiseClass()

