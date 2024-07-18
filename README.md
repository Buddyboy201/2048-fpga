# 2048 FPGA Game

This is a version of the popular 2048 game implemented on a Nexys3 Spartan-6 FPGA board with VGA output. The game is played using the board's 4 directional buttons to move the tiles on the board and the center button to reset the game.

## Installation and Setup

1. Clone the repository
2. Install Xilinx ISE Design Suite
3. Open the project in Xilinx ISE
4. Connect the FPGA board to a VGA output
5. Program the FPGA board using the included bit file

## Usage

To play the game, use the 4 buttons on the board to move up, right, down, left, and the center button for clearing the game. The grid begins with two boxes, which are placed on randomly chosen coordinates on the board. Each square has a value assigned to it, and if two squares with the same value collide, they “combine” and make a new square with double the value.

If you lose, the screen will turn red, and you can reset the game with a new random generation.

## Repository Contents

The following files are included in this project:

- `five12.bit`: The precompiled bit file for programming the FPGA board
- `debouncer.v`: A module for debouncing the push buttons on the board
- `clk_gen.v`: A module for generating a clock signal for the VGA output
- `clk_n.v`: A module for inverting the clock signal
- `extract.v`: A module for extracting bits from a value
- `five12.v`: The top-level module for the game logic
- `game_state.v`: A module for keeping track of the state of the game
- `game_state_update.v`: A module for updating the state of the game
- `inverter.v`: A module for inverting a valuej
- `row_ops.v`: A module for manipulating rows of the game board
- `vga_controller_demo.v`: A module for testing the VGA output

## Pictures

<p>This is the initial generation:</p>
<img src="https://www.linkpicture.com/q/IMG_9168.jpg" data-canonical-src="https://www.linkpicture.com/q/IMG_9168.jpg" width="400" height="400" />

<p>After playing for a while:</p>
<img src="https://www.linkpicture.com/q/IMG_9172.jpg" data-canonical-src="https://www.linkpicture.com/q/IMG_9172.jpg" width="400" height="400" />

<p>This is the lose state:</p>
<img src="https://www.linkpicture.com/q/IMG_9163.jpg" data-canonical-src="https://www.linkpicture.com/q/IMG_9163.jpg" width="400" height="400" />
