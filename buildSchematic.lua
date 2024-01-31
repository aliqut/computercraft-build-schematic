local function selectBlock(blockName)
  for i = 1, 16 do
    local detail = turtle.getItemDetail(i)
    if detail and detail.name == blockName then
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

local function tryMove(direction, steps)
    for i = 1, steps do
        local moved = false
        if direction == 'forward' then
            moved = moveForwardWithCheck()
            if moved then updatePosition('forward') end
        elseif direction == 'up' then
            moved = moveUpWithCheck()
            if moved then updatePosition('up') end
        elseif direction == 'down' then
            moved = moveDownWithCheck()
            if moved then updatePosition('down') end
        end
        if not moved then
            return false -- Stop if unable to move further in this direction
        end
    end
    return true
end

local function tryAlternatePaths()
    local depth = 3 -- Set the search depth

    local function recursiveTryPaths(currentDepth)
        if currentDepth == 0 then
            return false
        end

        if tryMove('forward', 1) then
            return true
        end

        if tryMove('up', 1) then
            local success = recursiveTryPaths(currentDepth - 1)
            if not success then moveDownWithCheck() end
            return success
        end

        if tryMove('down', 1) then
            local success = recursiveTryPaths(currentDepth - 1)
            if not success then moveUpWithCheck() end
            return success
        end

        -- Attempt lateral movements
        turnRight()
        if tryMove('forward', 1) then
            local success = recursiveTryPaths(currentDepth - 1)
            if not success then
                moveBackWithCheck() -- Undo move if it leads to a dead end
            end
            turnLeft() -- Correct orientation
            return success
        end
        turnLeft() -- Return to original direction for the next attempt

        turnLeft()
        if tryMove('forward', 1) then
            local success = recursiveTryPaths(currentDepth - 1)
            if not success then
                moveBackWithCheck() -- Undo move if it leads to a dead end
            end
            turnRight() -- Correct orientation
            return success
        end
        turnRight() -- Return to original direction

        return false -- No paths found within the given depth
    end

    return recursiveTryPaths(depth)
end


local function moveTo(x, y, z)
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
  while currentDir ~= 0 do
   turnLeft()
  end
  turtle.forward()
  turtle.forward()
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
  while currentDir ~= 0 do
   turnLeft()
  end
  turtle.forward()
  turtle.forward()
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
print('Block minecraft:stone_bricks: 542 blocks')
print('Block minecraft:spruce_planks: 256 blocks')
print('Block minecraft:chiseled_stone_bricks: 28 blocks')
print('Block minecraft:stone: 24 blocks')
print('Block minecraft:cobblestone: 8 blocks')
print('Block minecraft:andesite: 20 blocks')
print('Block minecraft:polished_andesite: 34 blocks')
print('Block minecraft:bookshelf: 6 blocks')
print('Block minecraft:smooth_stone: 1 blocks')
print('Block minecraft:iron_ore: 1 blocks')
print('Block minecraft:red_wool: 4 blocks')
print('Block minecraft:white_wool: 3 blocks')
print('Please organize the blocks in the chest as listed above.')
print('Press any key to start building...')
os.pullEvent('key')
print('Picking up blocks...')
pickUpBlocks()
print('Blocks picked up, starting to build...')
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 1, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 1, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 1, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(19, 1, 4)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 1, 4)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(17, 1, 4)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 1, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(16, 1, 5)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(15, 1, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(14, 1, 5)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(13, 1, 5)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(12, 1, 5)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(11, 1, 5)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(10, 1, 5)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(10, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:cobblestone') then
  restockBlocks()
  if not selectBlock('minecraft:cobblestone') then
    print('Error: Block not found:')
    print('minecraft:cobblestone')
    outOfStock()
  end
end
moveTo(9, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:cobblestone'] = (placedBlocks['minecraft:cobblestone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(8, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(7, 1, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(6, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(8, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(9, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(10, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(11, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(11, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(12, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(13, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(14, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(16, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(17, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(17, 1, 5)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 1, 5)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(19, 1, 5)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(20, 1, 5)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:cobblestone') then
  restockBlocks()
  if not selectBlock('minecraft:cobblestone') then
    print('Error: Block not found:')
    print('minecraft:cobblestone')
    outOfStock()
  end
end
moveTo(20, 1, 4)
turtle.placeDown()
placedBlocks['minecraft:cobblestone'] = (placedBlocks['minecraft:cobblestone'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(21, 1, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(20, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(19, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(17, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(16, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(14, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(13, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(12, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(12, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(11, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(10, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(9, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(8, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(8, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(9, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(10, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(11, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(12, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(13, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(13, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(14, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(15, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(16, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(17, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(19, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(19, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(20, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(22, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(22, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(23, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(24, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:cobblestone') then
  restockBlocks()
  if not selectBlock('minecraft:cobblestone') then
    print('Error: Block not found:')
    print('minecraft:cobblestone')
    outOfStock()
  end
end
moveTo(25, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:cobblestone'] = (placedBlocks['minecraft:cobblestone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(26, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(27, 1, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(28, 1, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(26, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(25, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(24, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(23, 1, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(23, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(22, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(21, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(20, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(20, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(19, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(17, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(16, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(15, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(14, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(14, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(13, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(12, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(11, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(10, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(9, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(8, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(8, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(9, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(10, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(11, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(12, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(13, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(14, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(15, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(15, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(16, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(17, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(19, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(20, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(21, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(21, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(22, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(23, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(24, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(24, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(25, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(26, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 1, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(26, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(25, 1, 9)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(25, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(24, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(23, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(22, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(22, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(21, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(20, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(19, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(17, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(16, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(16, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(15, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(14, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(13, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(12, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(11, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(10, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(9, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(8, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(8, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(9, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(10, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(11, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(12, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(13, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(14, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(15, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(16, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(17, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(17, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(19, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(20, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(21, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(22, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(23, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(23, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(24, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(25, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(26, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(26, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 1, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 1, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(26, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(25, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(24, 1, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(24, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(23, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(22, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(21, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(20, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(19, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(14, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(13, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(12, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(11, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(10, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(9, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(8, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(6, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 1, 15)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(22, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(23, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(24, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(25, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(25, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(26, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 1, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(26, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 1, 15)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(28, 1, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:cobblestone') then
  restockBlocks()
  if not selectBlock('minecraft:cobblestone') then
    print('Error: Block not found:')
    print('minecraft:cobblestone')
    outOfStock()
  end
end
moveTo(17, 2, 3)
turtle.placeDown()
placedBlocks['minecraft:cobblestone'] = (placedBlocks['minecraft:cobblestone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 2, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 2, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 2, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(21, 2, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 2, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:cobblestone') then
  restockBlocks()
  if not selectBlock('minecraft:cobblestone') then
    print('Error: Block not found:')
    print('minecraft:cobblestone')
    outOfStock()
  end
end
moveTo(22, 2, 6)
turtle.placeDown()
placedBlocks['minecraft:cobblestone'] = (placedBlocks['minecraft:cobblestone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(23, 2, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(24, 2, 6)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(25, 2, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(26, 2, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 2, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(27, 2, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 2, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 2, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 2, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 2, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 2, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 2, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 2, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(26, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(25, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(24, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(23, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(22, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(14, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(13, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(12, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(11, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(10, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(9, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(8, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 2, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 2, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 2, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 2, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 2, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 2, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 2, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 2, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 2, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(7, 2, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(8, 2, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(9, 2, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(10, 2, 6)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:bookshelf') then
  restockBlocks()
  if not selectBlock('minecraft:bookshelf') then
    print('Error: Block not found:')
    print('minecraft:bookshelf')
    outOfStock()
  end
end
moveTo(9, 2, 8)
turtle.placeDown()
placedBlocks['minecraft:bookshelf'] = (placedBlocks['minecraft:bookshelf'] or 0) + 1
if not selectBlock('minecraft:bookshelf') then
  restockBlocks()
  if not selectBlock('minecraft:bookshelf') then
    print('Error: Block not found:')
    print('minecraft:bookshelf')
    outOfStock()
  end
end
moveTo(8, 2, 8)
turtle.placeDown()
placedBlocks['minecraft:bookshelf'] = (placedBlocks['minecraft:bookshelf'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(14, 2, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 2, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(15, 2, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(16, 2, 4)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 2, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 2, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 2, 15)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 2, 15)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 3, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 3, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(15, 3, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 3, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(14, 3, 6)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 3, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(10, 3, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:cobblestone') then
  restockBlocks()
  if not selectBlock('minecraft:cobblestone') then
    print('Error: Block not found:')
    print('minecraft:cobblestone')
    outOfStock()
  end
end
moveTo(8, 3, 6)
turtle.placeDown()
placedBlocks['minecraft:cobblestone'] = (placedBlocks['minecraft:cobblestone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 3, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(7, 3, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 3, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 3, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:bookshelf') then
  restockBlocks()
  if not selectBlock('minecraft:bookshelf') then
    print('Error: Block not found:')
    print('minecraft:bookshelf')
    outOfStock()
  end
end
moveTo(8, 3, 8)
turtle.placeDown()
placedBlocks['minecraft:bookshelf'] = (placedBlocks['minecraft:bookshelf'] or 0) + 1
if not selectBlock('minecraft:bookshelf') then
  restockBlocks()
  if not selectBlock('minecraft:bookshelf') then
    print('Error: Block not found:')
    print('minecraft:bookshelf')
    outOfStock()
  end
end
moveTo(9, 3, 8)
turtle.placeDown()
placedBlocks['minecraft:bookshelf'] = (placedBlocks['minecraft:bookshelf'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 3, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 3, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 3, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 3, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 3, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(8, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(9, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(10, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(11, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(12, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(13, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(14, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(22, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(23, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(24, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(25, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(26, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 3, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 3, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 3, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 3, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 3, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 3, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 3, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 3, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 3, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(27, 3, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:cobblestone') then
  restockBlocks()
  if not selectBlock('minecraft:cobblestone') then
    print('Error: Block not found:')
    print('minecraft:cobblestone')
    outOfStock()
  end
end
moveTo(26, 3, 6)
turtle.placeDown()
placedBlocks['minecraft:cobblestone'] = (placedBlocks['minecraft:cobblestone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(25, 3, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(23, 3, 6)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(22, 3, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 3, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(21, 3, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(20, 3, 4)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(19, 3, 3)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 3, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 3, 15)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 3, 15)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 4, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(16, 4, 4)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(15, 4, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 4, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(14, 4, 6)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 4, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(10, 4, 6)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(8, 4, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 4, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(7, 4, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 4, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 4, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:bookshelf') then
  restockBlocks()
  if not selectBlock('minecraft:bookshelf') then
    print('Error: Block not found:')
    print('minecraft:bookshelf')
    outOfStock()
  end
end
moveTo(8, 4, 8)
turtle.placeDown()
placedBlocks['minecraft:bookshelf'] = (placedBlocks['minecraft:bookshelf'] or 0) + 1
if not selectBlock('minecraft:bookshelf') then
  restockBlocks()
  if not selectBlock('minecraft:bookshelf') then
    print('Error: Block not found:')
    print('minecraft:bookshelf')
    outOfStock()
  end
end
moveTo(9, 4, 8)
turtle.placeDown()
placedBlocks['minecraft:bookshelf'] = (placedBlocks['minecraft:bookshelf'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 4, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 4, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 4, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 4, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 4, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(8, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(9, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(10, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(11, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(12, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(13, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(14, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(22, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(23, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(24, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(25, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(26, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 4, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 4, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 4, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 4, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 4, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 4, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 4, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 4, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 4, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(27, 4, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(26, 4, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(25, 4, 6)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(23, 4, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(22, 4, 6)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 4, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(21, 4, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 4, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 4, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 4, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 4, 15)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 4, 15)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(17, 5, 3)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 5, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(15, 5, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 5, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(14, 5, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(13, 5, 6)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(12, 5, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(11, 5, 6)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(10, 5, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(8, 5, 6)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 5, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(7, 5, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 5, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 5, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 5, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 5, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 5, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 5, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 5, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(8, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(9, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(10, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(11, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(12, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(13, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(14, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(22, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(23, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(24, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(25, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(26, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 5, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 5, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 5, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 5, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 5, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 5, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 5, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 5, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 5, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(27, 5, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(26, 5, 6)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(25, 5, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(23, 5, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(22, 5, 6)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 5, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(21, 5, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:cobblestone') then
  restockBlocks()
  if not selectBlock('minecraft:cobblestone') then
    print('Error: Block not found:')
    print('minecraft:cobblestone')
    outOfStock()
  end
end
moveTo(20, 5, 4)
turtle.placeDown()
placedBlocks['minecraft:cobblestone'] = (placedBlocks['minecraft:cobblestone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 5, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 5, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 5, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 5, 15)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 5, 15)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 6, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(18, 6, 3)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 6, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 6, 4)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(16, 6, 4)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(15, 6, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 6, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(14, 6, 6)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(13, 6, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(12, 6, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(11, 6, 6)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(10, 6, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(9, 6, 6)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(8, 6, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 6, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(7, 6, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 6, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 6, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 6, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 6, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 6, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 6, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 6, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(8, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(9, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(10, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(11, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(12, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(13, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(14, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(22, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(23, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(24, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(25, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(26, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 6, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 6, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 6, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 6, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 6, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 6, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 6, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 6, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 6, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(27, 6, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(26, 6, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(25, 6, 6)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(24, 6, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(23, 6, 6)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(22, 6, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 6, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(21, 6, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 6, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 6, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(24, 6, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:smooth_stone') then
  restockBlocks()
  if not selectBlock('minecraft:smooth_stone') then
    print('Error: Block not found:')
    print('minecraft:smooth_stone')
    outOfStock()
  end
end
moveTo(31, 6, 10)
turtle.placeDown()
placedBlocks['minecraft:smooth_stone'] = (placedBlocks['minecraft:smooth_stone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 6, 15)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 6, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(9, 6, 7)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 6, 15)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 7, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 7, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(19, 7, 3)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(20, 7, 4)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(21, 7, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 7, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(22, 7, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(23, 7, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(24, 7, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(25, 7, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(26, 7, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 7, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(27, 7, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 7, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 7, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 7, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 7, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 7, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 7, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 7, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(26, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(25, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(24, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(23, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(22, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(14, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(13, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(12, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(11, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(10, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(9, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(8, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 7, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 7, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 7, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 7, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 7, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 7, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 7, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 7, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 7, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(7, 7, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(8, 7, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(9, 7, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(10, 7, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(11, 7, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(12, 7, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(13, 7, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(14, 7, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 7, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(15, 7, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 7, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 7, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 7, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 7, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 7, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 7, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 7, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 7, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(21, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(20, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(19, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(17, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(16, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(15, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(14, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(13, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(12, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(11, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(10, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(9, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(8, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(22, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(23, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(24, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(25, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(26, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 7, 15)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(17, 8, 3)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 8, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 8, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 8, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(21, 8, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 8, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 8, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 8, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 8, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 8, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 8, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 8, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 8, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 8, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(15, 8, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 8, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 8, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 8, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 8, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 8, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 8, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 8, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 8, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 8, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(8, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(9, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(10, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(11, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(12, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(13, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(14, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(15, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(16, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(17, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(19, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(20, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(21, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(22, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(23, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(24, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(25, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(26, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 8, 14)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 8, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 8, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 8, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 8, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 8, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 8, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 8, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 8, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 9, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 9, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(15, 9, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 9, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 9, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(15, 9, 8)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 9, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 9, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 9, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 9, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 9, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(21, 9, 8)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 9, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 9, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(21, 9, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(20, 9, 4)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 9, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 9, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 9, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 9, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 9, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 9, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 9, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(26, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(25, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(24, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(23, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(22, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(21, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(20, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(19, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(17, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(16, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(15, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(14, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(13, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(12, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(11, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(10, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(9, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(8, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 9, 13)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 9, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 9, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 9, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 9, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 9, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 9, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(17, 10, 3)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(16, 10, 4)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(15, 10, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 10, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 10, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 10, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(16, 10, 9)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 10, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 10, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 10, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(20, 10, 9)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 10, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 10, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 10, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(21, 10, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 10, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(19, 10, 3)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(19, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(17, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(16, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(15, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(14, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(13, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(12, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(11, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(10, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(9, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(8, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 10, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 10, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 10, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 10, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(20, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(21, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(22, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(23, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(24, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(25, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(26, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 10, 12)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 10, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 10, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 10, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 10, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 11, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(16, 11, 4)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(15, 11, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 11, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 11, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 11, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 11, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 11, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 11, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(19, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(17, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(16, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(15, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(14, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(13, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(12, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(11, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(11, 11, 9)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(10, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(9, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(9, 11, 9)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(8, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 11, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(8, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(9, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(11, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(12, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(13, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(14, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(15, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(16, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(17, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(19, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(20, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(20, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(21, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(22, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(23, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(24, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(25, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(26, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 11, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 11, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(26, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(25, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(24, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(23, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(22, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(21, 11, 11)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 11, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 11, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 11, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(21, 11, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(20, 11, 4)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 11, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(17, 12, 3)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 12, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(19, 12, 3)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:spruce_planks') then
  restockBlocks()
  if not selectBlock('minecraft:spruce_planks') then
    print('Error: Block not found:')
    print('minecraft:spruce_planks')
    outOfStock()
  end
end
moveTo(18, 12, 4)
turtle.placeDown()
placedBlocks['minecraft:spruce_planks'] = (placedBlocks['minecraft:spruce_planks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 12, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(15, 12, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 12, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 12, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 12, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 12, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 12, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 12, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 12, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 12, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 12, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(21, 12, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 12, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(25, 12, 11)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(27, 12, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(11, 12, 9)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(9, 12, 9)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(9, 12, 11)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(11, 12, 11)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(7, 12, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 13, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(18, 13, 3)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 13, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone') then
  restockBlocks()
  if not selectBlock('minecraft:stone') then
    print('Error: Block not found:')
    print('minecraft:stone')
    outOfStock()
  end
end
moveTo(20, 13, 4)
turtle.placeDown()
placedBlocks['minecraft:stone'] = (placedBlocks['minecraft:stone'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(21, 13, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 13, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 13, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 13, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 13, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 13, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 13, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 13, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 13, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 13, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:chiseled_stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:chiseled_stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:chiseled_stone_bricks')
    outOfStock()
  end
end
moveTo(15, 13, 5)
turtle.placeDown()
placedBlocks['minecraft:chiseled_stone_bricks'] = (placedBlocks['minecraft:chiseled_stone_bricks'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(16, 13, 4)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(11, 13, 9)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(9, 13, 9)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(9, 13, 11)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(11, 13, 11)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:andesite') then
  restockBlocks()
  if not selectBlock('minecraft:andesite') then
    print('Error: Block not found:')
    print('minecraft:andesite')
    outOfStock()
  end
end
moveTo(25, 13, 11)
turtle.placeDown()
placedBlocks['minecraft:andesite'] = (placedBlocks['minecraft:andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 14, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 14, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 14, 3)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 14, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 14, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 14, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 14, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 14, 5)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(15, 14, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 14, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 14, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 14, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 14, 5)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 14, 5)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 14, 5)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 14, 5)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 14, 4)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(21, 14, 5)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 14, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 14, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 14, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 14, 6)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 14, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 14, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 14, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(15, 14, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(16, 14, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 14, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 14, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 14, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 14, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 14, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(21, 14, 7)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(20, 14, 8)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(19, 14, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(18, 14, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(17, 14, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(11, 14, 9)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(10, 14, 9)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(9, 14, 9)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(9, 14, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(10, 14, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(11, 14, 10)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(11, 14, 11)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(10, 14, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:polished_andesite') then
  restockBlocks()
  if not selectBlock('minecraft:polished_andesite') then
    print('Error: Block not found:')
    print('minecraft:polished_andesite')
    outOfStock()
  end
end
moveTo(9, 14, 11)
turtle.placeDown()
placedBlocks['minecraft:polished_andesite'] = (placedBlocks['minecraft:polished_andesite'] or 0) + 1
if not selectBlock('minecraft:iron_ore') then
  restockBlocks()
  if not selectBlock('minecraft:iron_ore') then
    print('Error: Block not found:')
    print('minecraft:iron_ore')
    outOfStock()
  end
end
moveTo(25, 14, 11)
turtle.placeDown()
placedBlocks['minecraft:iron_ore'] = (placedBlocks['minecraft:iron_ore'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(9, 15, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:stone_bricks') then
  restockBlocks()
  if not selectBlock('minecraft:stone_bricks') then
    print('Error: Block not found:')
    print('minecraft:stone_bricks')
    outOfStock()
  end
end
moveTo(11, 15, 11)
turtle.placeDown()
placedBlocks['minecraft:stone_bricks'] = (placedBlocks['minecraft:stone_bricks'] or 0) + 1
if not selectBlock('minecraft:red_wool') then
  restockBlocks()
  if not selectBlock('minecraft:red_wool') then
    print('Error: Block not found:')
    print('minecraft:red_wool')
    outOfStock()
  end
end
moveTo(16, 21, 6)
turtle.placeDown()
placedBlocks['minecraft:red_wool'] = (placedBlocks['minecraft:red_wool'] or 0) + 1
if not selectBlock('minecraft:white_wool') then
  restockBlocks()
  if not selectBlock('minecraft:white_wool') then
    print('Error: Block not found:')
    print('minecraft:white_wool')
    outOfStock()
  end
end
moveTo(16, 22, 6)
turtle.placeDown()
placedBlocks['minecraft:white_wool'] = (placedBlocks['minecraft:white_wool'] or 0) + 1
if not selectBlock('minecraft:red_wool') then
  restockBlocks()
  if not selectBlock('minecraft:red_wool') then
    print('Error: Block not found:')
    print('minecraft:red_wool')
    outOfStock()
  end
end
moveTo(16, 23, 6)
turtle.placeDown()
placedBlocks['minecraft:red_wool'] = (placedBlocks['minecraft:red_wool'] or 0) + 1
if not selectBlock('minecraft:white_wool') then
  restockBlocks()
  if not selectBlock('minecraft:white_wool') then
    print('Error: Block not found:')
    print('minecraft:white_wool')
    outOfStock()
  end
end
moveTo(15, 23, 7)
turtle.placeDown()
placedBlocks['minecraft:white_wool'] = (placedBlocks['minecraft:white_wool'] or 0) + 1
if not selectBlock('minecraft:red_wool') then
  restockBlocks()
  if not selectBlock('minecraft:red_wool') then
    print('Error: Block not found:')
    print('minecraft:red_wool')
    outOfStock()
  end
end
moveTo(14, 23, 7)
turtle.placeDown()
placedBlocks['minecraft:red_wool'] = (placedBlocks['minecraft:red_wool'] or 0) + 1
if not selectBlock('minecraft:white_wool') then
  restockBlocks()
  if not selectBlock('minecraft:white_wool') then
    print('Error: Block not found:')
    print('minecraft:white_wool')
    outOfStock()
  end
end
moveTo(13, 23, 8)
turtle.placeDown()
placedBlocks['minecraft:white_wool'] = (placedBlocks['minecraft:white_wool'] or 0) + 1
if not selectBlock('minecraft:red_wool') then
  restockBlocks()
  if not selectBlock('minecraft:red_wool') then
    print('Error: Block not found:')
    print('minecraft:red_wool')
    outOfStock()
  end
end
moveTo(13, 24, 8)
turtle.placeDown()
placedBlocks['minecraft:red_wool'] = (placedBlocks['minecraft:red_wool'] or 0) + 1
print('Completed')
moveTo(0,0,0)
