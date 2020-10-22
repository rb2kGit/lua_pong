push = require('push')
Class = require 'class'

--Require the ball and paddle classes.
require 'Paddle'
require 'Ball'

--Initialize screen size constants.
SCREEN_WIDTH = 1280;
SCREEN_HEIGHT = 720;

--Initialize virtual screen size.
VIRTUAL_WIDTH = 432;
VIRTUAL_HEIGHT = 243;

--Initialize paddle constants
PADDLE_SPEED = 200;

--Initialize ball constants.
BALL_SPEED = 300;

--The resize function that will be called anytime the window is resized. We are using Push so it will call the push function.
function love.resize(w, h)
    push:resize(w, h)
end 

function love.load()
    --Set the title
    love.window.setTitle('Pong')
    -- Initialize the math.random method with a seeded number. Using Epoch Time.
    math.randomseed(os.time())

    --Initialize fonts to be used.
    smallFont = love.graphics.newFont('font.ttf', 8)
    scoreFont = love.graphics.newFont('font.ttf', 32)

    --Initialize player paddle by instantiating objects.
    player1 = Paddle(10, 30, 5, 25)
    player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 40, 5, 25)

    --Initialize the ball by instantiating the object.
    ball = Ball(VIRTUAL_WIDTH / 2 -2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    --Initialize sounds with a Lua table.
    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    --Initialize player scores.
    p1Score = 0
    p2Score = 0

    --Use a variable to determine the serving player. Will either be 1 or 2.
    servingPlayer = 1

    --Use a variable to determine a winning player.
    winner = 0

    --Initialize the game state. We will be keeping track of the game state using a string value.
    gamestate = 'start'

    --Set a font to be used when loaded.
    love.graphics.setFont(smallFont)

    --Setup the filter that we will be using.
    love.graphics.setDefaultFilter('nearest', 'nearest')

    --Set up our screen with a virtual resolution.
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })
end

function love.update(dt)
    --[[In order to implement collision detection we need to establish that the game is in play mode
    because there can only be a collision if the game is playing.]]
    if gamestate == 'play' then
        --If the game is playing we need to check for the ball's collision on each update.
        if ball:ballCollision(player1) then -- If the ballCollision function returns true for player1 paddle.
            ball.deltaX = -ball.deltaX *1.05 --The deltaX becomes negative to indicate the opposite X trajectory.
            ball.x = player1.x + 5 --This will reset the ball's position before the next frame to outside the paddle (wich is 5 pixels wide).

            --[[The Y trajectory works differently because the ball can still be movin upward after hitting the paddle.
            We also would like to randomize it because that prevent the same 4 trajectories being used.]]
            if ball.deltaY < 0 then
                ball.deltaY = -math.random(10, 150) --If the deltaY is less that 0 that means it is moving upward (-), so we will negative the random method.
            else
                ball.deltaY = math.random(10, 150) --The opposite of above.
            end

            --Play a sound when the ball hits the paddle.
            sounds['paddle_hit']:play()
        end
        --We do the same logic for player 2.
        if ball:ballCollision(player2) then -- If the ballCollision function returns true for player2 paddle.
            ball.deltaX = -ball.deltaX *1.05 --The deltaX becomes negative to indicate the opposite X trajectory.
            ball.x = player2.x - 4 --This will reset the ball's position before the next frame to outside the paddle (wich is 5 pixels wide).

            --[[The Y trajectory workd differently because the ball can still be movin upward after hitting the paddle.
            We also would like to randomize it because that prevent the same 4 trajectories being used.]]
            if ball.deltaY < 0 then
                ball.deltaY = -math.random(10, 150) --If the deltaY is less that 0 that means it is moving upward (-), so we will negative the random method.
            else
                ball.deltaY = math.random(10, 150) --The opposite of above.
            end

            --Play a sound when the ball hits the paddle.
            sounds['paddle_hit']:play()
        end

        --Now we can create the top and bottom bounds of the screen.
        if ball.y <= 0 then
            ball.y = 0
            ball.deltaY = -ball.deltaY

            --Play a sound when the ball hits the wall.
            sounds['wall_hit']:play()
        end
        if ball.y >= VIRTUAL_HEIGHT - 4 then -- We use -4 because ball.y refers to the top Y point. We need to compensate for the 4 pixels of the ball size.
            ball.y = VIRTUAL_HEIGHT - 4
            ball.deltaY = -ball.deltaY

            --Play a sound when the ball hits the paddle.
            sounds['wall_hit']:play()
        end

        --Keep track of each player's score.
        --If the ball passes the left boundary of the screen that means that player 2 just scored.
        if ball.x < -4 then
            p2Score = p2Score + 1
            servingPlayer = 1

            --Play a sound when the ball scores.
            sounds['score']:play()

            if p2Score == 10 then
                winner = 2
                gamestate = 'done'
            else
                ball:resetBall()
                gamestate = 'serve'
            end
        end
    
        --If the ball passes the right boundary of the scrren that means that player 1 scored.
        if ball.x > VIRTUAL_WIDTH then
            p1Score = p1Score + 1
            servingPlayer = 2

            --Play a sound when the ball scores.
            sounds['score']:play()

            if p1Score == 10 then
                winner = 1
                gamestate = 'done'
            else
                ball:resetBall()
                gamestate = 'serve'
            end
        end
    elseif gamestate == 'serve' then
        --Before entering the play state we need to initialize the ball's velocity on the player who scored.
        ball.deltaY = math.random(-50, 50)

        if servingPlayer == 1 then
            ball.deltaX = math.random(140, 200)
        else
            ball.deltaX = -math.random(140, 200)
        end
    end


    --Player movement.
    if love.keyboard.isDown('w') then 
        player1.deltaY = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then 
        player1.deltaY = PADDLE_SPEED
    else
        player1.deltaY = 0
    end
    if love.keyboard.isDown('up') then 
        player2.deltaY = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then 
        player2.deltaY = PADDLE_SPEED
    else
        player2.deltaY = 0
    end

    --Ball movement.
    --Now we can update the ball's position only if we are in the play state.
    if gamestate == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function love.draw()
    push:apply('start')
    --Draw the message
    love.graphics.setFont(smallFont)
    if gamestate == 'start' then
        love.graphics.printf('Press enter to play Pong.', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gamestate == 'serve' then
        love.graphics.printf('Player ' ..tostring(servingPlayer)..' press enter to serve.', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gamestate == 'done' then
        -- UI messages
        love.graphics.setFont(scoreFont)
        love.graphics.printf('Player ' .. tostring(winner) .. ' wins!',
            0, VIRTUAL_HEIGHT - 75, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf('Press Enter to restart!', 0, 20, VIRTUAL_WIDTH, 'center') 
    else
        love.graphics.printf('Press enter reset Pong.', 0, 20, VIRTUAL_WIDTH, 'center')
    end

    --Draw the scores
    drawScores()

    --Draw the paddles.
    player1:render()
    player2:render()

    --Draw the ball.
    ball:render()

    --Draw the FPS on the screen using an outsideFunction.
    drawFPS();
    
    push:apply('end')
end

function love.keypressed(key)
    if key == 'escape' then 
        love.event.quit()
    elseif key == 'return' or key =='enter' then
        --If the game is in start mode pressing enter will put it into play mode.
        if gamestate == 'start' then
            gamestate = 'serve'
        elseif gamestate == 'serve' then
            gamestate = 'play'
        elseif gamestate == 'done' then
            gamestate = 'serve'
            ball:resetBall()
            p1Score = 0
            p2Score = 0
            
            --We need to decide who the winning player is for the serve game state.
            if winner == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        else
            --If the game is in play mode, pressing enter will put it into start mode
            --It will also reset the ball position.
            gamestate = 'start'

            --Reset ball position and trajectory.
            ball:resetBall()
        end
    end
end

--A function used to draw the fps to the screen.
function drawFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS : ' .. tostring(love.timer.getFPS()), 5 , 5)
end

--A function used to draw the score to the screen.
function drawScores()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(p1Score), VIRTUAL_WIDTH / 2 - 50, 30)
    love.graphics.print(tostring(p2Score), VIRTUAL_WIDTH / 2 + 50, 30)
end