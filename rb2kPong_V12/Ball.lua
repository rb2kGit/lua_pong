Ball = Class{}

--First we define the initializer, similar to a constructor.
function Ball:init(x, y, width, height)
    --These variable are location properties and physical properties of the ball.
    self.x = x
    self.y = y

    self.width = width
    self.height = height

    --The ball also has a trajectory
    self.deltaY = math.random(75, -75)
    self.deltaX = math.random(2) == 1 and 100 or -100
end

--The game will require the ball to reset its properties.
function Ball:resetBall()
    --Reset its position.
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2

    --Reset its trajectory.

    self.deltaY = math.random(-50, 50)
    self.deltaX = math.random(2) == 1 and 100 or -100

end

--The game will require the ball to update itself when things happen.
function Ball:update(dt) --The ball will still update itself to delta time.
    self.x = self.x + self.deltaX * dt
    self.y = self.y + self.deltaY * dt
end

--The game will require the ball to draw itself after each update.
function Ball:render()
    love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
end

--The ball collision function.
function Ball:ballCollision(Paddle) --It takes in a player paddle object because thats what it interacts with.
    --[[Check if the ball's top edge (x + width) is greater (to the right of) the paddles top edge (x + width) and vice versa.
    This means that its not possible for there to be a collision]]
    if self.x > Paddle.x + Paddle.width or Paddle.x > self.x + self.width then
        return false
    end

    --[[Check if the ball's left edge (y + height) is greater (below) the paddles right edge (y + width) and vise versa.
    This means that its not possible for there to be a collision.]]
    if self.y > Paddle.y + Paddle.height or Paddle.y > self.y + self.height then
        return false
    end

    --[[If either of one of these is not true, there must be an overlap.
    So we will always assume there is a collision until proven otherwise.]]
    return true
end
