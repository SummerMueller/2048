# 2048 in Assembly
Welcome to my version of 2048 in Assembly Language! In this project, I tried to recreate the classic 2048 game and maintain all of its traditional functionalities. Read on for instructions regarding the gameplay and installation/usage.

## Gameplay

### Overview
If you're unfamiliar with how 2048 works, the environment is a 4x4 grid containing a total of 16 individual cells that may or may not contain numbers at a given time. A player wins when they achieve the 2048 block and lose if the board is full and there are no available moves left.
### Shifts
The player interacts with the environment by using wasd commands to indicate a desired shift in that particular direction. For example, pressing 'a' will trigger a left shift. During a shift, all numbers are pushed toward the corresonding wall as far as they can move without crashing into one another. 
### Merges
Merging occurs when two numbers of the same value are pushed against each other. In that case, they are combined into one block with the value of the original block's sum. A block will not merge twice during one shift. 
### Block Generation
During every shift, a new block will spawn randomly in an empty cell. The new block has a 75% chance of being a '2' and a 25% chance of being a '4'.
### Score
In my version, the score is computed as the complete of sum of all blocks in the grid at the current state.
### Goal and Game Over
While traditionally the goal is to reach the 2048 block, it is possible to go much further. Therefore, the game allows you to continue playing so you can improve your score. The game only terminates when the grid is completely full and there are no more available merges to free up space. In that case, the player is effectively out of moves. The program will then prompt the user if they'd like to play again.
## Installation and Usage
