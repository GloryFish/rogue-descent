--
--  game.lua
--  rogue-descent
--
--  Created by Jay Roberts on 2012-02-27.
--  Copyright 2012 GloryFish.org. All rights reserved.
--

require 'middleclass'
require 'notifier'
require 'vector'

GestureRecognizer = class('GestureRecognizer')

function GestureRecognizer:initialize()
  self.state = {
    isDown = false,
    isDragging = false,
    position = vector(love.mouse.getX(), love.mouse.getY())
  }

  self.previousState = {
    isDown = false,
    isDragging = false,
    position = vector(love.mouse.getX(), love.mouse.getY())
  }
end

function GestureRecognizer:update(dt)
  self.previousState = self.state

  self.state = {
    isDown = love.mouse.isDown('l'),
    isDragging = self.previousState.isDragging,
    position = vector(love.mouse.getX(), love.mouse.getY())
  }

  -- New button Down
  if self.state.isDown == true and self.previousState.isDown == false then
    Notifier:postMessage('mouse_down', self.state.position)
  end

  -- Button is down and moved
  if self.state.isDown == true and self.state.position:dist(self.previousState.position) > 0.5 then
    self.state.isDragging = true
    Notifier:postMessage('mouse_drag', self.state.position - self.previousState.position)
  end

  -- New button up
  if self.state.isDown == false and self.previousState.isDown == true then
    self.state.isDragging = false

    -- Did we stop dragging?
    if self.previousState.isDragging then
      Notifier:postMessage('mouse_up', self.state.position)
    else
      Notifier:postMessage('mouse_click', self.state.position)
    end
  end
end