pragma solidity >=0.4.21 <0.6.0;

contract Quiz {
    address public owner;

    uint8 phase = 0;

    uint32 quiz_number = 0;
    string question;
    bytes32 rightAnswerCommitment; // Commitment of the correct answer
    bytes32 rightAnswer; // Actual answer, after reveal
    
    uint n_winners = 0; // Number of winners for this round
    uint prize_amount; // Amount that winner can withdraw
    
    mapping(address => bytes32) answers;    // Commitment of the answers for each user
    mapping(address => uint32) userWon;    // userWon[addr] is set to quiz_number if the user gave the right answer

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


    // This modifier requires a certain
    // fee being associated with a function call.
    // If the caller sent too much, he or she is
    // refunded, but only after the function body.
    // This was dangerous before Solidity version 0.4.0,
    // where it was possible to skip the part after `_;`.
    modifier costs(uint _amount) {
        require(
            msg.value >= _amount,
            "Not enough Ether provided."
        );
        _;
        if (msg.value > _amount)
            msg.sender.send(msg.value - _amount);
    }

    // Returns current question
    // TODO: Redundant? question is public
    function whichQuestion() onlyOwner public returns (string memory ){
        return question;
    }
    
    // Returns current phase
    // TODO: Redundant? phase is public
    function whichPhase() onlyOwner public returns (uint8 ){
        return phase;
    }
    
    // 0: INIT - Please commit hashed answer
    
    function initQuiz(string memory _question, bytes32 _rightAnswerCommitment) onlyInitPhase onlyOwner public {
        question = _question;
        rightAnswerCommitment = _rightAnswerCommitment;
        phase += 1;
    }


    // 1: COMMIT
    function commitAnswer(bytes32 user_answer) onlyCommitPhase public payable costs(1 ether) {
        //TODO: check timeout for phase 1
        
        answers[msg.sender] = user_answer;
    }

    function startClaimPhase() onlyCommitPhase onlyOwner public {
        //TODO: require timeout expiry
        
        phase += 1;
    }

    // 2: CLAIM
    function claimRightAnswer(bytes32 user_answer, bytes32 randomness) onlyClaimPhase public {
        //TODO: check timeout

        require(
            keccak256(abi.encodePacked(quiz_number, user_answer, randomness)) == answers[msg.sender],
            "The answer is wrong or malformed."
        );
        
        n_winners += 1;
        userWon[msg.sender] = quiz_number;
    }
    
    function startWithdrawals() onlyClaimPhase onlyOwner public {
        //TODO: require timeout expiry
        
        prize_amount = address(this).balance / n_winners;
        
        phase += 1;
    }


    // 3: WITHDRAW
    function withdrawPrize() onlyWithdrawPhase public {
        if (userWon[msg.sender] == quiz_number) {
            //Make sure user can withdraw only once
            delete userWon[msg.sender];
            delete answers[msg.sender];
            
            msg.sender.transfer(prize_amount);
        }
    }
    
    function cleanup() onlyWithdrawPhase onlyOwner public {
        //Transfer any remaining balance to the owner (== the caller)
        msg.sender.transfer(address(this).balance);
        
        phase = 0;
        n_winners = 0;
        quiz_number += 1;
    }
}
