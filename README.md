# computercraft-build-schematic
This is the source for a program takes in a WorldEdit schematic file, and converts it to a Lua script with instructions for building, made for ComputerCraft Turtles.

## Contributing
For contributions, fork this repo, and in your fork, make any modifications you want. Once you are done, make a pull request to contribute your changes to this repository.

## Prerequisites
- Python ( [Link](https://www.python.org/downloads/) )

## Usage
1. Place your WorldEdit.schematic file and the minecraftIDs.txt file in the same folder as the schematicToLua Python script.
2. Run schematicToLua.py
3. Enter the schematic file name in the terminal window, and wait for the Lua script to be generated.
4. In-game, place a Turtle down, go into your Minecraft profile's save folder, find the folder for the world you are in, and go to the "computer" folder. Then, find the folder with the ID number of the Turtle you have just placed down, you can check this by typing "id" into the Turtle's terminal. (Alternatively, you can paste the Lua script into Pastebin, and download this directly to the Turtle).
5. Paste the generated Lua script into this folder.
6. Run "buildSchematic" on the Turtle's terminal.

## Notes
- Ensure that the entire building space is empty.
- The building blocks' chest must be placed directly behind the Turtle, leaving a two-block gap. Ensure that you place the chest in the block opposite the direction the Turtle is facing.
