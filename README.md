# computercraft-build-schematic
This program takes in a WorldEdit schematic file, and converts it to a Lua script with instructions for building, made for ComputerCraft Turtles.

---

## Prerequisites
- Python ( [Link](https://www.python.org/downloads/) )

## Usage
1. Place your WorldEdit.schematic file in the same folder as the program.
2. Run schematicToLua.py
3. Enter the schematic file name in the terminal window, and wait for the Lua script to be generated.
4. In-game, place a Turtle down, and go into your Minecraft profile's save folder, find the folder for the world you are in, and go to the "computer" folder. Then, find the folder with the ID number of the Turtle you have just placed down, you can check this by typing "id" into the Turtle's terminal.
5. Paste the generated Lua script into this folder.
6. Run "buildSchematic" on the Turtle's terminal.

## Notes
- Ensure that the entire building space is empty.
- The building blocks' chest must be placed directly behind the Turtle. Ensure that you place the chest in the block opposite the direction the Turtle is facing.
