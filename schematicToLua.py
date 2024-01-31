import os
import nbtlib
import math
from collections import defaultdict

# MAIN CODE
def main():
    # Terminal UI
    while True:
        schematic_file = input("Enter the name of the schematic file, do not forget the file extension: ")
        if os.path.exists(schematic_file):
            break
        else:
            print("File not found. Please enter a valid file name.")

    # Path to item ID dictionary text file **NOT IN USE, ONLY FOR 1.12.X and below**
#    file_path = 'minecraftIDs.txt' 
#    block_id_mapping = create_block_mapping(file_path) # Now block_id_mapping contains a dictionary where keys are ID numbers and values are tuples (Minecraft name, data value)

    # Read schematic and extract data to an array
    palette, block_states, width, height, length = read_schematic(schematic_file)
    blockData = extract_block_data(palette, block_states, width, height, length)

    # Map extracted data to item IDs readable by ComputerCraft **NOT IN USE, ONLY FOR 1.12.x and below**
#    mappedData = map_block_data_to_names(blockData, block_id_mapping)

    # Sort data array to optimise pathfinding
    sortedData = sortBlockDataIncrementingY(blockData)

    # Generate Lua script
    generate_lua_script(sortedData, 'buildSchematic.lua')

    input("Script generated. RETURN to exit...")

# Read .schem files
def read_schematic(filename):
    # Get the directory of the current script
    script_dir = os.path.dirname(os.path.realpath(__file__))
    # Construct the full path to the schematic file
    file_path = os.path.join(script_dir, filename)

    # Load the schematic file
    schematic = nbtlib.load(file_path)
    
    width = schematic['Width']
    height = schematic['Height']
    length = schematic['Length']
    palette = {v: k for k, v in schematic['Palette'].items()}

    # Assuming block states are stored in block_data
    block_states = list(schematic['BlockData'])

    return palette, block_states, width, height, length

# Write data to file
def write_to_file(data, filename):
    # Get the directory of the current script
    script_dir = os.path.dirname(os.path.realpath(__file__))
    # Construct the full path to the output file
    file_path = os.path.join(script_dir, filename)

    with open(file_path, 'w') as file:
        for item in data:
            file.write(str(item) + '\n')

# Create dictionary to map schematic data to minecraft item IDs
def create_block_mapping(file_path):
    block_mapping = {}
    with open(file_path, 'r') as file:
        for line in file:
            # Skip empty lines
            if not line.strip():
                continue

            parts = line.strip().split(',')
            # Ensure the line has the expected number of parts
            if len(parts) == 3:
                try:
                    id_number = int(parts[0].strip())
                    minecraft_name = parts[1].strip()
                    data_value = int(parts[2].strip())
                    # Creating a mapping
                    block_mapping[id_number] = (minecraft_name, data_value)
                except ValueError:
                    # Handle lines that can't be parsed
                    print(f"Warning: Unable to parse line: {line.strip()}")
                    continue

    return block_mapping

# Extract block data from schematic
def extract_block_data(palette, block_states, width, height, length):
    structure = []
    for y in range(height):
        for z in range(length):
            for x in range(width):
                index = y * width * length + z * width + x
                block_state = block_states[index]
                block_id = palette[block_state]

                # Skip air blocks and blocks with additional properties, eg: stairs, slabs, trapdoors. Only read full blocks
                if block_id == "minecraft:air" or '[' in block_id:
                    continue

                structure.append(((x, y, z), block_id))

    return structure



# Map extracted block data to minecraft IDs
def map_block_data_to_names(block_data, block_mapping):
    """
    Map the block data extracted from the schematic to block names and damage values.

    :param block_data: List of tuples containing block data from the schematic.
    :param block_mapping: Dictionary mapping block IDs to (blockName, blockDamage).
    :return: List of tuples containing (coordinates, blockName, blockDamage).
    """
    mapped_data = []
    for (x, y, z), block_id, block_metadata in block_data:
        if block_id in block_mapping:
            block_name, block_damage = block_mapping[block_id]
            mapped_data.append(((x, y, z), block_name, block_damage))
        else:
            # Handle unknown block IDs
            mapped_data.append(((x, y, z), "unknown", 0))

    return mapped_data

# Find distance between 2 3D co-ordinates
def distanceTwoCoords(coord1, coord2):
    return ((coord2[0]-coord1[0])**2 + (coord2[1]-coord1[1])**2 + (coord2[2]-coord1[2])**2)**(1/2)

# Find distance between 2 2D co-ordinates
def distance_2d(coord1, coord2):
    # Calculate distance ignoring the Y-coordinate
    return math.sqrt((coord1[0] - coord2[0])**2 + (coord1[2] - coord2[2])**2)

# Sort block array by distance to optimise pathfinding
def sortBlockData(mapped_block_data):
    n = len(mapped_block_data)
    for i in range(n):
        swapped = False
        for j in range(0, n - i - 1):
            # Calculate the reference point (previous block or origin)
            ref_point = mapped_block_data[j - 1][0] if j > 0 else (0, 0, 0)

            # Current and next distances from the reference point
            current_dist = distanceTwoCoords(ref_point, mapped_block_data[j][0])
            next_dist = distanceTwoCoords(ref_point, mapped_block_data[j + 1][0])
            
            # Swap if the next block is closer to the reference point than the current block
            if next_dist < current_dist:
                swapped = True
                mapped_block_data[j], mapped_block_data[j + 1] = mapped_block_data[j + 1], mapped_block_data[j]

        # Break the loop if no swap happened in this pass
        if not swapped:
            break

# This sorts the block array, by distance, similar to the function before, 
# but does this layer by layer (y-axis) layers, starting from the lowest, and working upwards.
def sortBlockDataIncrementingY(mapped_block_data):
    # Group blocks by Y-coordinate
    groups = defaultdict(list)
    for coord, block_name in mapped_block_data:
        groups[coord[1]].append((coord, block_name))

    sorted_data = []
    for y in sorted(groups.keys()):
        # Sort each group using nearest neighbor in 2D (ignoring Y)
        unvisited = groups[y]
        current = unvisited.pop(0)
        sorted_group = [current]
        while unvisited:
            last_coord = sorted_group[-1][0]
            closest_index = min(range(len(unvisited)), key=lambda i: distance_2d(last_coord, unvisited[i][0]))
            sorted_group.append(unvisited.pop(closest_index))
        sorted_data.extend(sorted_group)

    return sorted_data

def generate_lua_script(mapped_block_data, filename):
    # Count block types and quantities
    block_counts = {}
    for _, block_name in mapped_block_data:
        if block_name not in block_counts:
            block_counts[block_name] = 0
        block_counts[block_name] += 1

    # Initialize Lua script lines
    lua_lines = [
        "local function selectBlock(blockName)",
        "  for i = 1, 16 do",
        "    local detail = turtle.getItemDetail(i)",
        "    if detail and detail.name == blockName then",
        "      turtle.select(i)",
        "      return true",
        "    end",
        "  end",
        "  return false",
        "end",
        "local currentX, currentY, currentZ = 0, 0, 0  -- Initial position",
        "local currentDir = 0  -- Assuming 0: forward, 1: right, 2: backward, 3: left",
        "",
        "local function updatePosition(moveDir)",
        "    if moveDir == \"forward\" then",
        "        if currentDir == 0 then currentZ = currentZ + 1",
        "        elseif currentDir == 1 then currentX = currentX + 1",
        "        elseif currentDir == 2 then currentZ = currentZ - 1",
        "        elseif currentDir == 3 then currentX = currentX - 1",
        "        end",
        "    elseif moveDir == \"up\" then",
        "        currentY = currentY + 1",
        "    elseif moveDir == \"down\" then",
        "        currentY = currentY - 1",
        "    end",
        "end",
        "",
        "local function turnRight()",
        "    turtle.turnRight()",
        "    currentDir = (currentDir + 1) % 4",
        "end",
        "",
        "local function turnLeft()",
        "    turtle.turnLeft()",
        "    currentDir = (currentDir - 1) % 4",
        "end",
        "",
        "local function isBlockInFront()",
        "    return turtle.detect()",
        "end",
        "",
        "local function isBlockAbove()",
        "    return turtle.detectUp()",
        "end",
        "",
        "local function isBlockBelow()",
        "    return turtle.detectDown()",
        "end",
        "",
        "local function moveForwardWithCheck()",
        "    if not isBlockInFront() then",
        "        turtle.forward()",
        "        return true",
        "    end",
        "    return false",
        "end",
        "",
        "local function moveUpWithCheck()",
        "    if not isBlockAbove() then",
        "        turtle.up()",
        "        return true",
        "    end",
        "    return false",
        "end",
        "",
        "local function moveDownWithCheck()",
        "    if not isBlockBelow() then",
        "        turtle.down()",
        "        return true",
        "    end",
        "    return false",
        "end",
        "",
        "local function tryMove(direction, steps)",
        "    for i = 1, steps do",
        "        local moved = false",
        "        if direction == 'forward' then",
        "            moved = moveForwardWithCheck()",
        "            if moved then updatePosition('forward') end",
        "        elseif direction == 'up' then",
        "            moved = moveUpWithCheck()",
        "            if moved then updatePosition('up') end",
        "        elseif direction == 'down' then",
        "            moved = moveDownWithCheck()",
        "            if moved then updatePosition('down') end",
        "        end",
        "        if not moved then",
        "            return false -- Stop if unable to move further in this direction",
        "        end",
        "    end",
        "    return true",
        "end",
        "",
        "local function tryAlternatePaths()",
        "    local depth = 3 -- Set the search depth",
        "",
        "    local function recursiveTryPaths(currentDepth)",
        "        if currentDepth == 0 then",
        "            return false",
        "        end",
        "",
        "        if tryMove('forward', 1) then",
        "            return true",
        "        end",
        "",
        "        if tryMove('up', 1) then",
        "            local success = recursiveTryPaths(currentDepth - 1)",
        "            if not success then moveDownWithCheck() end",  # Correct position after unsuccessful move",
        "            return success",
        "        end",
        "",
        "        if tryMove('down', 1) then",
        "            local success = recursiveTryPaths(currentDepth - 1)",
        "            if not success then moveUpWithCheck() end",  # Correct position after unsuccessful move",
        "            return success",
        "        end",
        "",
        "        -- Attempt lateral movements",
        "        turnRight()",
        "        if tryMove('forward', 1) then",
        "            local success = recursiveTryPaths(currentDepth - 1)",
        "            if not success then",
        "                moveBackWithCheck() -- Undo move if it leads to a dead end",
        "            end",
        "            turnLeft() -- Correct orientation",
        "            return success",
        "        end",
        "        turnLeft() -- Return to original direction for the next attempt",
        "",
        "        turnLeft()",
        "        if tryMove('forward', 1) then",
        "            local success = recursiveTryPaths(currentDepth - 1)",
        "            if not success then",
        "                moveBackWithCheck() -- Undo move if it leads to a dead end",
        "            end",
        "            turnRight() -- Correct orientation",
        "            return success",
        "        end",
        "        turnRight() -- Return to original direction",
        "",
        "        return false -- No paths found within the given depth",
        "    end",
        "",
        "    return recursiveTryPaths(depth)",
        "end",
        "",
        "",
        "local function moveTo(x, y, z)",
        "    -- Horizontal movement (X-axis)",
        "    while currentX < x do",
        "        while currentDir ~= 1 do",
        "           turnLeft()",
        "        end",
        "        if moveForwardWithCheck() then",
        "            updatePosition(\"forward\")",
        "        elseif not tryAlternatePaths() then",
        "            -- Handle failure to find a path",
        "        end",
        "    end",
        "    while currentX > x do",
        "        while currentDir ~= 3 do",
        "           turnLeft()",
        "        end",
        "        if moveForwardWithCheck() then",
        "            updatePosition(\"forward\")",
        "        elseif not tryAlternatePaths() then",
        "    -- Handle failure to find a path",
        "        end",
        "    end",
        "",
        "    -- Horizontal movement (Z-axis)",
        "    while currentZ < z do",
        "        while currentDir ~= 0 do",
        "           turnLeft()",
        "        end",
        "        if moveForwardWithCheck() then",
        "            updatePosition(\"forward\")",
        "        elseif not tryAlternatePaths() then",
        "            -- Handle failure to find a path",
        "        end",
        "    end",
        "    while currentZ > z do",
        "        while currentDir ~= 2 do",
        "           turnLeft()",
        "        end",
        "        if moveForwardWithCheck() then",
        "            updatePosition(\"forward\")",
        "        elseif not tryAlternatePaths() then",
        "            -- Handle failure to find a path",
        "        end",
        "    end",
        "    -- Vertical movement",
        "    while currentY < y do",
        "        if moveUpWithCheck() then",
        "            updatePosition(\"up\")",
        "        elseif not tryAlternatePaths() then",
        "            -- Handle failure to find a path",
        "        end",
        "    end",
        "    while currentY > y do",
        "        if moveDownWithCheck() then",
        "            updatePosition(\"down\")",
        "        elseif not tryAlternatePaths() then",
        "            -- Handle failure to find a path",
        "        end",
        "    end",
        "",
        "end",
        "",
        "local function pickUpBlocks()",
        "  turtle.turnRight()",
        "  turtle.turnRight()",
        "  turtle.forward()",
        "  turtle.forward()",        
        "  -- Assuming the chest is directly behind the turtle, with a two block gap",
        "  for i = 1, 16 do",
        "    turtle.suck()",
        "  end",
        "  turtle.turnLeft()  -- Turn back to original direction",
        "  turtle.turnLeft()",
        "  turtle.forward()",
        "  turtle.forward()",
        "end",
        "",
        "local placedBlocks = {}",
        "",
        "local function restockBlocks()",
        "  local lastX, lastY, lastZ = currentX, currentY, currentZ",  # Save the last position
        "  print('Restocking...')",
        "  moveTo(0, 0, 0)  -- Move to chest location",
        "  turtle.turnRight()",
        "  turtle.turnRight()",
#        "  for blockKey, totatlNeeded in pairs(block_counts) do",
#        "    local blockName, blockDamage = unpack(blockKey)",
#        "    local placed = placedBlocks[blockName] or 0",
#        "    local toPickUp = math.min(64, totalNeeded - placed)",
#        "    if toPickUp > 0 then",
#        "      for i = 1, toPickUp do",
#        "        turtle.suck()  -- Adjust as needed to pick up specific blocks",
#        "      end",
#        "    end",
#        "  end",
        "  while currentDir ~= 0 do",
        "   turnLeft()",
        "  end",
        "  turtle.forward()",
        "  turtle.forward()",
        "  for i = 1, 16 do",
        "    turtle.suck()",
        "  end",
        "  turtle.turnLeft()",
        "  turtle.turnLeft()",
        "  turtle.forward()",
        "  turtle.forward()",
        "  moveTo(lastX, lastY, lastZ)  -- Return to the last building position",
        "end",
        "local function outOfStock()",
        "  local lastX, lastY, lastZ = currentX, currentY, currentZ",  # Save the last position
        "  print('Out of stock, returning to chest...')",
        "  moveTo(0, 0, 0)  -- Move to chest location",
        "  turtle.turnRight()",
        "  turtle.turnRight()",
        "  while currentDir ~= 0 do",
        "   turnLeft()",
        "  end",
        "  turtle.forward()",
        "  turtle.forward()",
        "  print('Please refill chest, then press any key to continue...')",
        "  os.pullEvent('key')",
        "  for i = 1, 16 do",
        "    turtle.suck()",
        "  end",
        "  turtle.turnLeft()",
        "  turtle.turnLeft()",
        "  turtle.forward()",
        "  turtle.forward()",
        "  moveTo(lastX, lastY, lastZ)  -- Return to the last building position",
        "end",
    ]

    # Store total block counts needed for build
    # lua_lines.append("local block_counts = {"),
    # for (block_name, block_damage), count in block_counts.items():
    #    lua_lines.append(f"  ['{block_name}', {block_damage}] = {count},")
    # lua_lines.append("}")

    # Print out the list of blocks needed
    for block_name, count in block_counts.items():
        lua_lines.append(f"print('Block {block_name}: {count} blocks')")

    # Add user prompt
    lua_lines.append("print('Please organize the blocks in the chest as listed above.')")
    lua_lines.append("print('Press any key to start building...')")
    lua_lines.append("os.pullEvent('key')")

    # Pick up blocks from chest
    lua_lines.append("print('Picking up blocks...')")
    lua_lines.append("pickUpBlocks()")
    lua_lines.append("print('Blocks picked up, starting to build...')")
    

    # Add building instructions
    for (x, y, z), block_name in mapped_block_data:
        lua_lines.append(f"if not selectBlock('{block_name}') then")
        lua_lines.append("  restockBlocks()")
        lua_lines.append(f"  if not selectBlock('{block_name}') then")
        lua_lines.append("    print('Error: Block not found:')")
        lua_lines.append(f"    print('{block_name}')")
        lua_lines.append("    outOfStock()")
        lua_lines.append("  end")
        lua_lines.append("end")
        lua_lines.append(f"moveTo({x+1}, {y+1}, {z+1})")
        lua_lines.append("turtle.placeDown()")
        lua_lines.append(f"placedBlocks['{block_name}'] = (placedBlocks['{block_name}'] or 0) + 1")

    lua_lines.append("print('Completed')")
    lua_lines.append("moveTo(0,0,0)")

    # Write the Lua script to a file
    with open(filename, 'w') as file:
        for line in lua_lines:
            file.write(line + '\n')

    print(f"Lua script written to {filename}")

if __name__ == "__main__":
    main()