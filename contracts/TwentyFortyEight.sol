pragma solidity ^0.5.0;

contract TwentyFortyEight {
    struct game {
        uint id;
        bool init;
        uint[16] board;
        uint [] empty;
        bool isOver;
    }

    uint gameCounter = 0;
    mapping(uint => game) public games;
    
    function startGame() public {
        gameCounter++;
        
        uint[16] memory boof;
        for (uint i=0; i<16; ++i) {
            boof[i] = 0;
        }
        boof[random(15)] = 2;

        uint[] memory temp; 
        games[gameCounter] = game(gameCounter, true, boof, temp, false);
        
        for (uint j=0; j<16; ++j) {
            if (games[gameCounter].board[j] == 0) {
                games[gameCounter].empty.push(j);
            }
        }

        games[gameCounter].board[games[gameCounter].empty[random(14) - 1]] = 2;
       
        emit gameStarted(gameCounter);
    }

    event gameStarted(uint gameId);

    function showBoard(uint gameNumber) public view returns (uint[16] memory currentBoard) {
        if (games[gameNumber].init) {
            return games[gameNumber].board;
        } else {
            return currentBoard;
        }
    }

    function moveDown(uint gameId) public {
        require(games[gameId].isOver == false, "Game is Over");
        uint[16] memory board = games[gameId].board;
        for (uint i=15; i>=0 && i<16; --i) {
            if (board[i] > 0) {
                for (uint j=12+(i%4); j>i; j-=4) {
                    if (board[j] == 0 && board[i] != 0) {
                        board[j] = board[i];
                        board[i] = 0;
                        break;
                    }
                    else if (board[j] == board[i] && board[i] != 0) {
                        if ((j-i == 4) || ((j-i) == 8 && board[j-4] == 0) || ((j-i) == 12 && board[j-4] == 0 && board[j-8] == 0)) {
                            board[j] = board[i] + board[j];
                            board[i] = 0;
                            break;
                        }
                    } 
                }
            }
        }
        games[gameId].board = board;
        if (isLost(gameId) == true || isWon(gameId) == true) {
            games[gameId].isOver = true;
        } else {
            addTile(gameId);
        }
    }

    function moveUp(uint gameId) public {
        require(games[gameId].isOver == false, "Game is Over");
        uint[16] memory board = games[gameId].board;
        bool didMove = false;
        for (uint i=0; i<16; ++i) {
            if (board[i] > 0) {
                for (uint j=i%4; j<i; j+=4) {
                    if (board[j] == 0) {
                        board[j] = board[i];
                        board[i] = 0;
                        didMove = true;
                        break;
                    } else if (board[j] == board[i] && board[i] != 0) {
                        if ((i-j == 4) || (i-j == 8 && board[j+4] == 0) || (i-j == 12 && board[j+4] == 0 && board[j+8] == 0)) {
                            board[j] = board[i] + board[j];
                            board[i] = 0;
                            didMove = true;
                            break;
                        }
                    }
                }
            }
        }
        games[gameId].board = board;
        if (isLost(gameId) == true || isWon(gameId) == true) {
            games[gameId].isOver = true;
        } else if (didMove) {
            addTile(gameId);
        } 
    }

    function moveRight(uint gameId) public {
        require(games[gameId].isOver == false, "Game is Over");
        uint[16] memory board = games[gameId].board;
        bool didMove = false;
        for (uint i=15; i>=0 && i<16; --i) {
            if (board[i] > 0) {
                for (uint j=i-(i%4)+3; j>i; --j) {
                    if (board[j] == 0) {
                        board[j] = board[i];
                        board[i] = 0;
                        didMove = false;
                        break;
                   } else if (board[j] == board[i] && board[i] != 0) {
                        if ((j-i == 1) || (j-i == 2 && board[j-1] == 0) || (j-i == 3 && board[j-1] == 0 && board[j-2] == 0)) {
                            board[j] = board[i] + board[j];
                            board[i] = 0;
                            didMove = false;
                            break;
                        }
                   }
                }
            }
        }
        games[gameId].board = board;
        if (isLost(gameId) == true || isWon(gameId) == true) {
            games[gameId].isOver = true;
        } else if (didMove) {
            addTile(gameId);
        }
    }

    function moveLeft(uint gameId) public {
        require(games[gameId].isOver == false, "Game is Over");
        uint[16] memory board = games[gameId].board;
        bool didMove = false;
        for (uint i=0; i<16; ++i) {
            if (board[i] > 0) {
                for (uint j=(i/4)*4; j<i; ++j) {
                    if (board[j] == 0) {
                        board[j] = board[i];
                        board[i] = 0;
                        didMove = false;
                        break;
                    } else if (board[j] == board[i] && board[i] != 0) {
                        if ((i-j == 1) || (i-j == 2 && board[j+1] == 0) || (i-j == 3 && board[j+1] == 0 && board[j+2] == 0)) {
                            board[j] = board[i] + board[j];
                            board[i] = 0;
                            didMove = false;
                            break;
                        }
                    }
                }
            }
        }
        games[gameId].board = board;
        if (isLost(gameId) == true || isWon(gameId) == true) {
            games[gameId].isOver = true;
        } else if (didMove) {
            addTile(gameId);
        }
    }

    function addTile(uint gameId) public {
        for (uint i=0; i<16; ++i) {
            if (games[gameId].board[i] == 0) {
                games[gameId].empty.push(i);
            }
        }

        require(games[gameId].empty.length > 0, "GAME OVER");

        uint emptyIndex = random(games[gameId].empty.length) - 1;
        
        uint boardIndex = games[gameId].empty[emptyIndex];
        games[gameId].board[boardIndex] = random(2) * 2;
        games[gameId].empty.length = 0;
    }

    event gameLost(uint gameId);
    function isLost(uint gameId) public view returns (bool) {
        uint[16] memory board = games[gameId].board;
        if (games[gameId].empty.length == 0) {
            bool canMove = false;
            for (uint j=0; j<12; ++j) {
                if (board[j] == board[j+4]) {
                    canMove = true;
                    return false;
                }
            }
            for (uint k=15; k>3; --k) {
                if (board[k] == board[k-4]) {
                    canMove = true;
                    return false;
                }
            }
            for (uint l=0; l<=12; l+=4) {
                for (uint m=0; m<3; ++m) {
                    if (board[l+m] == board[l+m+1]) {
                        canMove = true;
                        return false;
                    }
                }
            }
            for (uint n=3; n<=15; n+=4) {
                for (uint p=0; p<3; ++p) {
                    if (board[n-p] == board[n-p-1]) {
                        canMove = true;
                        return false;
                    }
                }
            }
            return true;
        } else {
            return false;
        }
    }

    event gameWon(uint gameId);
    function isWon(uint gameId) public view returns (bool) {
        for (uint i=0; i<16; ++i) {
           if (games[gameId].board[i] >= 2048) {
                return true;
                break;
           } 
        }
    }

    function updateBoard(uint gameId, uint[16] memory newBoard) public {
        games[gameId].board = newBoard;
    }

    function viewEmpty(uint gameId) public view returns (uint[] memory) {
        return games[gameId].empty;
    }

    function random(uint modulus) public view returns (uint) {
        return uint(blockhash(block.number-1)) % modulus + 1; 
    }
}
