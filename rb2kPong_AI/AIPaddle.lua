AIPaddle = Class{}

--Initialize the paddles positional and physical properties.
function AIPaddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.deltaY = 0
end

--The game will require the paddles to update them selves.
function AIPaddle:update(dt, Ball) --The paddles will still use delta time to update.
    --The only thing that the paddle will have to update is its own position.
    --Including stopping at the edge of the screen.
    self.y = Ball.y - self.height / 2

    if self.deltaY < 0 then --If its trajectory less than 0, which means its moving up.
        self.y = math.max(0, self.y + self.deltaY * dt)
    else --If the opposite trajectory (down) is true.
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.deltaY * dt)
    end
end

--The game will require the paddle to draw themselves.
function AIPaddle:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end
