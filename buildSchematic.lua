local function selectBlock(blockName, blockDamage)
  for i = 1, 16 do
    local detail = turtle.getItemDetail(i)
    if detail and detail.name == blockName and detail.damage == blockDamage then
      turtle.select(i)
      return true
    end
  end
  return false
end
local currentX, currentY, currentZ = 0, 0, 0  -- Initial position
local currentDir = 0  -- Assuming 0: forward, 1: right, 2: backward, 3: left

local function updatePosition(moveDir)
    if moveDir == "forward" then
        if currentDir == 0 then currentZ = currentZ + 1
        elseif currentDir == 1 then currentX = currentX + 1
        elseif currentDir == 2 then currentZ = currentZ - 1
        elseif currentDir == 3 then currentX = currentX - 1
        end
    elseif moveDir == "up" then
        currentY = currentY + 1
    elseif moveDir == "down" then
        currentY = currentY - 1
    end
end

local function turnRight()
    turtle.turnRight()
    currentDir = (currentDir + 1) % 4
end

local function turnLeft()
    turtle.turnLeft()
    currentDir = (currentDir - 1) % 4
end

local function isBlockInFront()
    return turtle.detect()
end

local function isBlockAbove()
    return turtle.detectUp()
end

local function isBlockBelow()
    return turtle.detectDown()
end

local function moveForwardWithCheck()
    if not isBlockInFront() then
        turtle.forward()
        return true
    end
    return false
end

local function moveUpWithCheck()
    if not isBlockAbove() then
        turtle.up()
        return true
    end
    return false
end

local function moveDownWithCheck()
    if not isBlockBelow() then
        turtle.down()
        return true
    end
    return false
end

local function tryAlternatePaths()
    -- Attempt to move left or right to bypass the obstacle
    turnRight()
    if moveForwardWithCheck() then
        updatePosition("forward")
        turnLeft()  -- Realign to original direction
        return true
    end
    turnLeft()  -- Turn back to original direction
    turnLeft()
    if moveForwardWithCheck() then
        updatePosition("forward")
        turnRight()  -- Realign to original direction
        return true
    end
    turnRight()  -- Turn back to original direction
    return false
end

local function moveTo(x, y, z)
    -- Vertical movement
    while currentY < y do
        if moveUpWithCheck() then
            updatePosition("up")
        elseif not tryAlternatePaths() then
            -- Handle failure to find a path
        end
    end
    while currentY > y do
        if moveDownWithCheck() then
            updatePosition("down")
        elseif not tryAlternatePaths() then
            -- Handle failure to find a path
        end
    end

    -- Horizontal movement (X-axis)
    while currentX < x do
        while currentDir ~= 1 do
           turnLeft()
        end
        if moveForwardWithCheck() then
            updatePosition("forward")
        elseif not tryAlternatePaths() then
            -- Handle failure to find a path
        end
    end
    while currentX > x do
        while currentDir ~= 3 do
           turnLeft()
        end
        if moveForwardWithCheck() then
            updatePosition("forward")
        elseif not tryAlternatePaths() then
    -- Handle failure to find a path
        end
    end

    -- Horizontal movement (Z-axis)
    while currentZ < z do
        while currentDir ~= 0 do
           turnLeft()
        end
        if moveForwardWithCheck() then
            updatePosition("forward")
        elseif not tryAlternatePaths() then
            -- Handle failure to find a path
        end
    end
    while currentZ > z do
        while currentDir ~= 2 do
           turnLeft()
        end
        if moveForwardWithCheck() then
            updatePosition("forward")
        elseif not tryAlternatePaths() then
            -- Handle failure to find a path
        end
    end
end

local function pickUpBlocks()
  turtle.turnRight()
  turtle.turnRight()
  turtle.forward()
  turtle.forward()
  -- Assuming the chest is directly behind the turtle, with a two block gap
  for i = 1, 16 do
    turtle.suck()
  end
  turtle.turnLeft()  -- Turn back to original direction
  turtle.turnLeft()
  turtle.forward()
  turtle.forward()
end

local placedBlocks = {}

local function restockBlocks()
  local lastX, lastY, lastZ = currentX, currentY, currentZ
  print('Restocking...')
  moveTo(0, 0, 0)  -- Move to chest location
  turtle.turnRight()
  turtle.turnRight()
  turtle.forward()
  turtle.forward()
  while currentDir ~= 0 do
   turnLeft()
  end
  for i = 1, 16 do
    turtle.suck()
  end
  turtle.turnLeft()
  turtle.turnLeft()
  turtle.forward()
  turtle.forward()
  moveTo(lastX, lastY, lastZ)  -- Return to the last building position
end
local function outOfStock()
  local lastX, lastY, lastZ = currentX, currentY, currentZ
  print('Out of stock, returning to chest...')
  moveTo(0, 0, 0)  -- Move to chest location
  turtle.turnRight()
  turtle.turnRight()
  turtle.forward()
  turtle.forward()
  while currentDir ~= 0 do
   turnLeft()
  end
  print('Please refill chest, then press any key to continue...')
  os.pullEvent('key')
  for i = 1, 16 do
    turtle.suck()
  end
  turtle.turnLeft()
  turtle.turnLeft()
  turtle.forward()
  turtle.forward()
  moveTo(lastX, lastY, lastZ)  -- Return to the last building position
end
print('Block minecraft:stone with damage 6: 126 blocks')
print('Block minecraft:glass with damage 0: 7 blocks')
print('Please organize the blocks in the chest as listed above.')
print('Press any key to start building...')
os.pullEvent('key')
print('Picking up blocks...')
pickUpBlocks()
print('Blocks picked up, starting to build...')
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 0, 0)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 0, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(1, 0, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(2, 0, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(3, 0, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(4, 0, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(5, 0, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(6, 0, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(7, 0, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(8, 0, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(9, 0, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 0, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 0, 0)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 0, 2)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 0, 3)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 0, 4)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 0, 5)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 0, 6)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 0, 7)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 0, 8)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 0, 9)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 0, 10)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 0, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(9, 0, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(8, 0, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(7, 0, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(6, 0, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(5, 0, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(4, 0, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(3, 0, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(2, 0, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(1, 0, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 0, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 0, 10)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 0, 9)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 0, 8)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 0, 7)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 0, 6)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 0, 5)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 0, 4)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 0, 3)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 0, 2)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 1, 0)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 1, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(1, 1, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 1, 2)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:glass', 0) then
  restockBlocks()
  if not selectBlock('minecraft:glass', 0) then
    print('Error: Block not found:')
    print('minecraft:glass')
    outOfStock()
  end
end
moveTo(0, 1, 3)
turtle.placeDown()
placedBlocks['minecraft:glass'] = (placedBlocks['minecraft:glass'] or 0) + 1
if not selectBlock('minecraft:glass', 0) then
  restockBlocks()
  if not selectBlock('minecraft:glass', 0) then
    print('Error: Block not found:')
    print('minecraft:glass')
    outOfStock()
  end
end
moveTo(0, 1, 4)
turtle.placeDown()
placedBlocks['minecraft:glass'] = (placedBlocks['minecraft:glass'] or 0) + 1
if not selectBlock('minecraft:glass', 0) then
  restockBlocks()
  if not selectBlock('minecraft:glass', 0) then
    print('Error: Block not found:')
    print('minecraft:glass')
    outOfStock()
  end
end
moveTo(0, 1, 5)
turtle.placeDown()
placedBlocks['minecraft:glass'] = (placedBlocks['minecraft:glass'] or 0) + 1
if not selectBlock('minecraft:glass', 0) then
  restockBlocks()
  if not selectBlock('minecraft:glass', 0) then
    print('Error: Block not found:')
    print('minecraft:glass')
    outOfStock()
  end
end
moveTo(0, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:glass'] = (placedBlocks['minecraft:glass'] or 0) + 1
if not selectBlock('minecraft:glass', 0) then
  restockBlocks()
  if not selectBlock('minecraft:glass', 0) then
    print('Error: Block not found:')
    print('minecraft:glass')
    outOfStock()
  end
end
moveTo(0, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:glass'] = (placedBlocks['minecraft:glass'] or 0) + 1
if not selectBlock('minecraft:glass', 0) then
  restockBlocks()
  if not selectBlock('minecraft:glass', 0) then
    print('Error: Block not found:')
    print('minecraft:glass')
    outOfStock()
  end
end
moveTo(0, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:glass'] = (placedBlocks['minecraft:glass'] or 0) + 1
if not selectBlock('minecraft:glass', 0) then
  restockBlocks()
  if not selectBlock('minecraft:glass', 0) then
    print('Error: Block not found:')
    print('minecraft:glass')
    outOfStock()
  end
end
moveTo(0, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:glass'] = (placedBlocks['minecraft:glass'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(1, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(9, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 1, 2)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 1, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 1, 0)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(9, 1, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 2, 0)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 2, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(1, 2, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 2, 2)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 2, 10)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 2, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(1, 2, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(9, 2, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 2, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 2, 10)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 2, 2)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 2, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 2, 0)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(9, 2, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 3, 0)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 3, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(1, 3, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 3, 2)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 3, 10)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 3, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(1, 3, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(9, 3, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 3, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 3, 10)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 3, 2)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 3, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 3, 0)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(9, 3, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 4, 0)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 4, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(1, 4, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 4, 2)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 4, 10)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 4, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(1, 4, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(9, 4, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 4, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 4, 10)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 4, 2)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 4, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 4, 0)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(9, 4, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 5, 0)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 5, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(1, 5, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 5, 2)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 5, 10)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 5, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(1, 5, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(9, 5, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 5, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 5, 10)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 5, 2)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 5, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 5, 0)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(9, 5, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 6, 0)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 6, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(1, 6, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 6, 2)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 6, 10)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(0, 6, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(1, 6, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(9, 6, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 6, 11)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 6, 10)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 6, 2)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 6, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 6, 0)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone', 6) then
  restockBlocks()
  if not selectBlock('minecraft:stone', 6) then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(9, 6, 1)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
print('Completed')
