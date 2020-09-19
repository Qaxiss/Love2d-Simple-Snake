function love.load()
  cellSize = 20
  gridX = 38
  gridY = 28
  ticker = 0
  speed = 0
  score = 0
  gameState = "dead"
  direction = "right"
  moving = direction
  movePending = false

  math.randomseed(os.time())
  food = {
    x = math.random(0, gridX-1), 
    y = math.random(0, gridY-1)
  }
  
  snake = { 
    {x = 0, y = 0},
    {x = 1, y = 0},
    {x = 2, y = 0}
  }
end

function reset()
  snake = { 
    {x = 0, y = 0},
    {x = 1, y = 0},
    {x = 2, y = 0}
  }
  score = 0
  gameState = "alive"
  direction = "right"
  speed = 0
end

function love.draw()
  for i = 1, gridX, 1 do
    for j = 1, gridY, 1 do
        love.graphics.setColor(.2,.2,.2)
        love.graphics.rectangle('fill', i * cellSize, j * cellSize, cellSize, cellSize)
    end
  end
  for i = 1, #snake do
    if gameState == "alive" then
      love.graphics.setColor(1, .1, 0)
    else
      love.graphics.setColor(.4,.4,.4)
    end
    love.graphics.rectangle('fill', (snake[i].x + 1) * cellSize, (snake[i].y + 1) * cellSize, cellSize - 1, cellSize - 1)
  end
  if gameState == "dead" then
    love.graphics.setColor(1,1,1)
    love.graphics.print("Press 'R' to start a new game!\n\t\tYou're score is: "..score, (gridX - 10) * cellSize / 2 , (gridY - 5) * cellSize / 2)
  end
  
  love.graphics.setColor(.1, 1, 0)
  love.graphics.rectangle('fill', (food.x + 1) * cellSize, (food.y + 1) * cellSize, cellSize - 1, cellSize - 1)
end


function love.update(dt)
  if gameState == "alive" then
    ticker = ticker + 1 * dt
    if ticker > (15 - (speed * 0.5)) * dt then
      ticker = 0
      moveSnake()
      moving = direction
    end
    if snakeCollide() then
      gameState = "dead"
    end
  end
end

function snakeCollide()
  --compare if last element of array's next step is any previous step, return true if snake hits itself
  for i = #snake - 1, 1, -1 do
    if direction == "right" and 
       snake[#snake].x + 1 == snake[i].x and
       snake[#snake].y == snake[i].y then
         return true
    end
    if direction == "left" and
      snake[#snake].x - 1 == snake[i].x and
      snake[#snake].y == snake[i].y then
         return true
    end
    if direction == "up" and
      snake[#snake].y - 1 == snake[i].y and
      snake[#snake].x == snake[i].x then
         return true
    end 
    if direction == "down" and
      snake[#snake].y + 1 == snake[i].y and
      snake[#snake].x == snake[i].x then
         return true
    end 
  end
  return false
end

function eatFood()
  local foodX = food.x
  local foodY = food.y
  table.insert(snake, {x = foodX, y = foodY})
  food.x = math.random(0, gridX - 1)
  food.y = math.random(0, gridY - 1)
  score = score + 1
end

function foodNext()
  if direction == "right" and 
     (snake[#snake].x  + 1) % gridX == food.x and
     snake[#snake].y == food.y then
       return true
  end
  if direction == "left" and
    (snake[#snake].x - 1) % gridX == food.x and
    snake[#snake].y == food.y then
       return true
  end
  if direction == "up" and
    (snake[#snake].y - 1) % gridY == food.y and
    snake[#snake].x == food.x then
       return true
  end 
  if direction == "down" and
    (snake[#snake].y + 1) % gridY == food.y and
    snake[#snake].x == food.x then
       return true
  end 
end

function moveSnake()
  --take an array of coordinates, increment the next one by a direction, then have each subsequent one take the previous one's position
  local prevX
  local prevY
  local curX
  local curY
  moving = direction
  if foodNext() then
    eatFood()
    speed = speed + 1
  else
    for i = #snake, 1, -1 do
      if i == #snake then
        movePending = false
        prevX = snake[i].x
        prevY = snake[i].y
        if direction == "right" then
          snake[i].x = (snake[i].x  + 1) % gridX
        end
        if direction == "left" then
          snake[i].x = (snake[i].x - 1) % gridX
        end
        if direction == "up" then
          snake[i].y = (snake[i].y - 1) % gridY
        end
        if direction == "down" then
          snake[i].y = (snake[i].y + 1) % gridY
        end
      else
        curX = snake[i].x
        curY = snake[i].y
        snake[i].x = prevX
        snake[i].y = prevY
        prevX = curX
        prevY = curY
      end
    end
  end
end


function love.keypressed(key)
  if gameState == "alive" and movePending == false then
    movePending = true
    if key == "up" and direction ~= "down" then
      direction = "up"
    end
    if key == "right" and direction ~= "left" then
      direction = "right"
    end
    if key == "left" and direction ~= "right" then
      direction = "left"
    end
    if key == "down" and direction ~= "up" then
      direction = "down"
    end
  end
  if key == "r" then
    reset()
  end
end


function love.keyreleased(key)
  if key == "escape" then
    love.event.quit()
  end
end

  