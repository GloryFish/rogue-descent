--
--  menu.lua
--  desert
--
--  Created by Jay Roberts on 2011-03-18.
--  Copyright 2011 GloryFish.org. All rights reserved.
--

require 'colors'

Menu = class('Menu')

function Menu:initialize(pos)
  self.position = pos
  self.buttons = {}
  self.visible = true
  self.padding = 35
  self.selectedIndex = 1
end

function Menu:mousepressed(pos)
  return
  -- These menus will be keyboard controlled
  -- if self.visible then
  --   for i, button in ipairs(self.buttons) do
  --     button:mousepressed(pos)
  --   end
  -- end
end

function Menu:mousereleased(pos)
  return
  -- These menus will be keyboard controlled
  -- if self.visible then
  --   for i, button in ipairs(self.buttons) do
  --     button:mousereleased(pos)
  --   end
  -- end
end

function Menu:keypressed(key, unicode)

end

function Menu:update(dt)
  if input.state.buttons.newpress.up then
    self.selectedIndex = self.selectedIndex - 1
    if self.selectedIndex == 0 then
      self.selectedIndex = #self.buttons
    end
    if soundOn then
      love.audio.play(sounds.menumove)
    end
  end

  if input.state.buttons.newpress.down then
    self.selectedIndex = self.selectedIndex + 1
    if self.selectedIndex > #self.buttons then
      self.selectedIndex = 1
    end

    if soundOn then
      love.audio.play(sounds.menumove)
    end
  end

  if input.state.buttons.newpress.select then
    self.buttons[self.selectedIndex]:runAction()
  end
end

function Menu:addButton(button)
  table.insert(self.buttons, button)
  self:layoutButtons()
end

function Menu:layoutButtons()
  local y = self.position.y
  for i, button in ipairs(self.buttons) do
    button.position = vector(self.position.x, y)
    y = y + self.padding
  end
end

function Menu:draw()
  if self.visible then
    for i, button in ipairs(self.buttons) do
      if i == self.selectedIndex then
        button.selected = true
      else
        button.selected = false
      end
      button:draw()
    end
  end
end
