--
--  textbutton.lua
--  desert
--
--  Created by Jay Roberts on 2011-03-18.
--  Copyright 2011 GloryFish.org. All rights reserved.
--

require 'middleclass'
require 'vector'
require 'colors'

TextButton = class('TextButton')

function TextButton:initialize(text)
  self.icon = love.graphics.newImage('resources/images/menuicon.png')
  self.icon:setFilter('nearest', 'nearest')

  self.position = vector(0, 0)
  self.text = text
  self.color = colors.lightest
  self.font = fonts.button
  self.fontSelected = fonts.buttonSelected

  self.width = self.font:getWidth(self.text)
  self.height = self.font:getHeight(self.text)

  self.selected = false

  self.action = nil
end

function TextButton:mousepressed(pos)
  self.mousePos = pos
  if self:containsPosition(pos) then
    self.selected = true
  end
end

function TextButton:mousereleased(pos)
  self.mousePos = pos
  self.selected = false

  if self:containsPosition(pos) then
    self:runAction()
  end
end

function TextButton:runAction()
  if self.action ~= nil then
    if soundOn then
      love.audio.play(sounds.menuselect)
    end
    self:action()
  end
end

function TextButton:containsPosition(pos)
  local lineWidth = self.font:getWidth(self.text)
  local halfWidth = lineWidth / 2


  if pos.x >= self.position.x - halfWidth and
     pos.x <= self.position.x + halfWidth and
     pos.y >= self.position.y and
     pos.y <= self.position.y + self.height then
    return true
  else
    return false
  end
end


function TextButton:draw()
  local font = self.font
  if self.selected then
    font = self.fontSelected
  end

  love.graphics.setFont(font)
  local lineWidth = font:getWidth(self.text)

  colors.darkest:set()
  love.graphics.print(self.text,
                      (self.position.x - lineWidth / 2) + 1,
                      self.position.y + 1)

  self.color:set()

  love.graphics.print(self.text,
                      self.position.x - lineWidth / 2,
                      self.position.y)

  if self.selected then
    love.graphics.draw(self.icon, self.position.x - (lineWidth / 2) - 34, self.position.y, 0, 2, 2)
  end
end