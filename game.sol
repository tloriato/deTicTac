pragma solidity ^0.4.0;
contract TicTacToe {
    
    // Basic Strucutre of a Game
    
    struct Game {
        uint blockNumberLastMove; 
        uint reward;    
        bool blockchainCourt; // true if the game is only playable through the blockchain
        address proposer;
        address challenged;
        bytes32 state; // 11-char string where 0/1/2 is a empty/proposer/challenged position and the first two
                       // the current round, i.e: "06201210102" is a win by proposer
    }
    
    mapping(address => Game) Games; // TODO: CHANGE HOW THAT WORKS
    mapping(address => address) duels; // TODO: CHANGE HOW THAT WORKS
    
    function proposeGame(address challenged) payable public {
        
        if (Games[msg.sender].blockNumberLastMove != 0) // TODO: Improve this
            revert();
        
        if (duels[challenged] != 0)                     // TODO: Improve this
            revert();
        
        Game storage newGame = Games[msg.sender];
        duels[challenged] = msg.sender;
        
        newGame.reward = msg.value;
        newGame.blockNumberLastMove = block.number;
        newGame.blockchainCourt = false;
        newGame.proposer = msg.sender;
        newGame.challenged = challenged;
        newGame.state = "00000000000";
        
    }
    
    function acceptGame() payable public {
        
        if(msg.value != Games[duels[msg.sender]].reward) {  // The proposed party has to send the same amount of ETH
            revert();                                       // TODO: Customize this
        }
        
        Games[duels[msg.sender]].reward *= 2;
        Games[duels[msg.sender]].blockNumberLastMove = block.number;
    }
    
    function collectFriendlyVictory(bool proposer, bytes32 msgHash, uint8 v, bytes32 r, bytes32 s) public {
        
        if(proposer) {
            if(ecrecover(msgHash, v, r, s) == Games[msg.sender].challenged) {
                if(msgHash == keccak256("surrender")) {
                    
                    uint pReward = Games[msg.sender].reward; // send reward
                    
                    delete duels[Games[msg.sender].challenged]; // clear mapping
                    delete Games[msg.sender];                   // clear structure
                    
                    msg.sender.transfer(pReward);
                    
                } else {
                    revert();
                }
            } else {
                revert();
            }
        } else {
            if(ecrecover(msgHash, v, r, s) == Games[duels[msg.sender]].proposer) {
                if(msgHash == keccak256("surrender")){
                    
                    uint cReward = Games[duels[msg.sender]].reward;
                    
                    delete Games[duels[msg.sender]];
                    delete duels[msg.sender];
                    
                    msg.sender.transfer(cReward);
                    
                } else {
                    revert();
                }
            } else {
                revert();
            }
        }
    }
}
