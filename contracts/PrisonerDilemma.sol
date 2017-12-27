pragma solidity ^0.4.15;

contract PrisonerDilemma {

  /*
Need to add: time lock waiting for withdraw

  */

  enum Stage {
    Commit,
    StartReveal,
    WaitForOtherReveal,
    Withdraw
  }

  struct Player {
    bytes32 commitment;
    uint reveal;
    bool committed;
    bool revealed;

  }
  struct Dilemma {
    Stage currentStage;
    uint [] prices;
    mapping (address => Player) players;
    address player1;
    address player2;
    address jail;
    mapping (address => uint) balances;
    mapping (address => mapping (uint => mapping (uint => uint))) penalty;
  }


  mapping (uint => Dilemma) allGames;
  uint DilemmaID = 0;

  modifier playersOnly (address player, uint _DilemmaID) {
    require (allGames[_DilemmaID].player1 == player || allGames[_DilemmaID].player2 == player);
    _;
  }

  function createDilemma (address _player1, address _player2, address _jail, uint [] _prices) {
    uint length = _prices.length;
    require (length == 4);
    // make sure prices are formatted correctly
    for (uint i = 1; i < length; i ++) {
      require (_prices[i-1] < _prices[i]);
    }
    DilemmaID ++;
    allGames[DilemmaID].player1 = _player1;
    allGames[DilemmaID].player2 = _player2;
    allGames[DilemmaID].jail = _jail;
    allGames[DilemmaID].prices = _prices;
    allGames[DilemmaID].currentStage = Stage.Commit;
    createBoard(_prices, DilemmaID, _player1, _player2);

  }

  /*
  Lets say that _prices are 0, 5, 8
  Both players must deposit 8 ether
  The prices correspond to years in jail
  Instead of serving time in jail, you give ether to the jail
  */



// their committment must be in the order: user address, random Number, response
  function commit (bytes32 _commitment, uint _DilemmaID) playersOnly (msg.sender, _DilemmaID) payable {
    require (allGames[DilemmaID].currentStage == Stage.Commit);
    require (allGames[DilemmaID].prices[3] <= msg.value);
    allGames[_DilemmaID].balances[msg.sender] += msg.value;
    allGames[_DilemmaID].players[msg.sender].commitment = _commitment;
    allGames[_DilemmaID].players[msg.sender].committed = true;

    // check to change state
    address player1 = allGames[_DilemmaID].player1;
    address player2 = allGames[_DilemmaID].player2;
    if (allGames[_DilemmaID].players[player1].committed && allGames[_DilemmaID].players[player2].committed) {
      allGames[_DilemmaID].currentStage = Stage.StartReveal;
    }
  }

  // response 0 represents "say nothing"
  // response 1 represents "turn parter in"
  function reveal (uint _randomNumber, uint _response, uint _DilemmaID) playersOnly (msg.sender, _DilemmaID) {
    require (allGames[DilemmaID].currentStage == Stage.StartReveal || allGames[DilemmaID].currentStage == Stage.WaitForOtherReveal);
    bytes32 check = sha256(msg.sender, _randomNumber, _response);
    if (allGames[_DilemmaID].players[msg.sender].commitment == check) {
      allGames[_DilemmaID].players[msg.sender].reveal = _response;
    } else {
      // penalty for trying to cheat
    }



  }


  function createBoard (uint [] prices, uint _DilemmaID, address _player1, address _player2) internal {
    // (1,1)
    allGames[_DilemmaID].penalty[_player1][1][1] = prices[1];
    allGames[_DilemmaID].penalty[_player2][1][1] = prices[1];
    // (1,0)
    allGames[_DilemmaID].penalty[_player1][1][0] = prices[0];
    allGames[_DilemmaID].penalty[_player2][1][0] = prices[3];
    // (0,1)
    allGames[_DilemmaID].penalty[_player1][0][1] = prices[3];
    allGames[_DilemmaID].penalty[_player2][0][1] = prices[0];
    // (0,0)
    allGames[_DilemmaID].penalty[_player1][0][0] = prices[2];
    allGames[_DilemmaID].penalty[_player2][0][0] = prices[2];
  }
}
