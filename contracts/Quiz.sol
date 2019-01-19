pragma solidity >=0.4.21 <0.6.0;

contract Quiz {
  address public owner;

  uint8 phase = 0;

  string question;
  bytes32 rightAnswerCommitment; // Commitment of the correct answer
  bytes32 rightAnswer; // Actual answer, after reveal
  
  uint n_winners = 0;
  mapping(address => bytes32) answers;  // Commitment of the answers for each user
  mapping(address => bool) userWon;     // true if user won

  constructor() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender == owner) _;
  }

  modifier onlyInitPhase() {
    if (phase == 0) _;
  }

  modifier onlyCommitPhase() {
    if (phase == 1) _;
  }

  modifier onlyClaimPhase() {
    if (phase == 2) _;
  }

  modifier onlyWithdrawPhase() {
    if (phase == 3) _;
  }

  
  // 0: INIT
  
  function initQuiz(string memory _question, bytes32 _rightAnswer) onlyInitPhase onlyOwner public {
      // TODO
  }



  // 1: COMMIT
  function commitAnswer(bytes32 answer) onlyCommitPhase public {
      // TODO
  }

  function revealRightAnswer(bytes32 _right_answer, bytes32 randomness) onlyOwner onlyCommitPhase oublic {
      //TODO: verifies right answer, save it, switch to phase 2
  }



  // 2: CLAIM
  function claimRightAnswer(bytes32 answer, bytes32 randomness) onlyClaimPhase public {
    //TODO: check correctness, update n_winners and userWon
  }
  
  function startWithdrawals() onlyClaimPhase onlyOwner public {
      //TODO: move to phase 3
  }


  // 3: WITHDRAW
  function withdrawPrize() onlyWithdrawPhase public {
      //TODO: allow withdrawal of the prize if user won
  }
  
  function cleanup() onlyWithdrawPhase onlyOwner public {
      //TODO
  }
}
