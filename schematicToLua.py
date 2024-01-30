import os
import nbtlib

# Read .schem files
def read_schematic(filename):
    # Get the directory of the current script
    script_dir = os.path.dirname(os.path.realpath(__file__))
    # Construct the full path to the schematic file
    file_path = os.path.join(script_dir, filename)

    # Load the schematic file
    schematic = nbtlib.load(file_path)
    # Further processing will go here
    
    return schematic

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
def extract_block_data(nbt_data):
    # Extract block data and dimensions
    blocks = nbt_data['Blocks']
    data = nbt_data['Data']
    width = nbt_data['Width']
    height = nbt_data['Height']
    length = nbt_data['Length']

    # Create a list to store non-air block data
    structure = []

    # Fill the list with non-air block data
    for y in range(height):
        for z in range(length):
            for x in range(width):
                # Calculate the index in the linear block array
                index = y * width * length + z * width + x
                block_id = blocks[index]
                block_data = data[index]

                # Skip air blocks (block ID 0)
                if block_id != 0:
                    # Store the block information along with its coordinates
                    structure.append(((x, y, z), block_id, block_data))

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
            # Optionally, you can adjust block_damage based on block_metadata if needed
            mapped_data.append(((x, y, z), block_name, block_damage))
        else:
            # Handle unknown block IDs
            mapped_data.append(((x, y, z), "unknown", 0))

    return mapped_data

def generate_lua_script(mapped_block_data, filename):
    # Count block types and quantities
    block_counts = {}
    for _, block_name, block_damage in mapped_block_data:
        block_key = (block_name, block_damage)
        if block_key not in block_counts:
            block_counts[block_key] = 0
        block_counts[block_key] += 1

    # Initialize Lua script lines
    lua_lines = [
        "local function selectBlock(blockName, blockDamage)",
        "  for i = 1, 16 do",
        "    local detail = turtle.getItemDetail(i)",
        "    if detail and detail.name == blockName and detail.damage == blockDamage then",
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
        "local function tryAlternatePaths()",
        "    -- Attempt to move left or right to bypass the obstacle",
        "    turnRight()",
        "    if moveForwardWithCheck() then",
        "        updatePosition(\"forward\")",        
        "        turnLeft()  -- Realign to original direction",
        "        return true",
        "    end",
        "    turnLeft()  -- Turn back to original direction",
        "    turnLeft()",
        "    if moveForwardWithCheck() then",
        "        updatePosition(\"forward\")",         
        "        turnRight()  -- Realign to original direction",
        "        return true",
        "    end",
        "    turnRight()  -- Turn back to original direction",
        "    return false",
        "end",
        "",
        "local function moveTo(x, y, z)",
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
        "end",
        "",
        "local function pickUpBlocks()",
        "  turtle.turnRight()",
        "  -- Assuming the chest is directly to the right of the turtle",
        "  for i = 1, 16 do",
        "    turtle.suck()",
        "  end",
        "  turtle.turnLeft()  -- Turn back to original direction",
        "end",
    ]

    # Print out the list of blocks needed
    for (block_name, block_damage), count in block_counts.items():
        lua_lines.append(f"print('Block {block_name} with damage {block_damage}: {count} blocks')")

    

    # Add user prompt
    lua_lines.append("print('Please organize the blocks in the chest as listed above.')")
    lua_lines.append("print('Press any key to start building...')")
    lua_lines.append("os.pullEvent('key')")

    # Pick up blocks from chest
    lua_lines.append("print('Picking up blocks...')")
    lua_lines.append("pickUpBlocks()")
    lua_lines.append("print('Blocks picked up, starting to build...')")


    # Add building instructions
    for (x, y, z), block_name, block_damage in mapped_block_data:
        lua_lines.append(f"if selectBlock('{block_name}', {block_damage}) then")
        lua_lines.append(f"  moveTo({x}, {y}, {z})")
        lua_lines.append("  turtle.placeDown()")  # Adjust based on orientation
        lua_lines.append("else")
        lua_lines.append(f"  print('Error: Block {block_name} with damage {block_damage} not found.')")
        lua_lines.append("end")

    # Write the Lua script to a file
    with open(filename, 'w') as file:
        for line in lua_lines:
            file.write(line + '\n')

    print(f"Lua script written to {filename}")

# MAIN CODE

file_path = 'minecraftIDs.txt' 
block_id_mapping = create_block_mapping(file_path) # Now block_id_mapping contains a dictionary where keys are ID numbers and values are tuples (Minecraft name, data value)

schematic = read_schematic('test.schematic')
blockData = extract_block_data(schematic)

mappedData = map_block_data_to_names(blockData, block_id_mapping)

generate_lua_script(mappedData, 'buildSchematic.lua')