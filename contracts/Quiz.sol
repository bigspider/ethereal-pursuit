pragma solidity >=0.4.21 <0.6.0;

contract Quiz {
    address public owner;

    enum Phase { Init, Commit, Reveal, Claim, Withdraw }

    Phase public phase = Phase.Init;

    uint32 public quizNumber = 0;
    string public question;
    bytes32 rightAnswerCommitment; // Commitment of the correct answer (H(quizNumber || rightAnswer || randomness))
    string public rightAnswer; // Actual answer, after reveal
    
    uint nWinners = 0; // Number of winners for this round
    uint prizeAmount; // Amount that winner can withdraw
    
    mapping(address => bytes32) answers; // Commitment of the answers for each user (H(quizNumber || rightAnswer || randomness))
    mapping(address => uint32) userWon; // userWon[addr] is set to quiz_number if the user gave the right answer


    event PhaseChange(Phase newPhase);
    event AnswerRevealed(string answer);

    constructor() public {
        owner = msg.sender;
    }


    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can execute this function");
        _;
    }
    
    //Only allow when the contract is in a certain phase
    modifier onlyInPhase(Phase _phase) {
        require(phase == _phase, "This function cannot be called in this phase");
        _;
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

    function changePhase(Phase newPhase) internal {
        phase = newPhase;
        emit PhaseChange(newPhase);
    }


    // 0: INIT
    
    function initQuiz(string memory _question, bytes32 _rightAnswerCommitment) public onlyInPhase(Phase.Init) onlyOwner {
        question = _question;
        rightAnswerCommitment = _rightAnswerCommitment;
        changePhase(Phase.Commit);
    }


    // 1: COMMIT
    function commitAnswer(bytes32 userAnswerCommitment) public onlyInPhase(Phase.Commit) payable costs(1 ether) {
        //TODO: check timeout for phase 1
        
        answers[msg.sender] = userAnswerCommitment;
    }

    function startRevealPhase() public onlyInPhase(Phase.Commit) onlyOwner {
        //TODO: require timeout expiry
        
        changePhase(Phase.Reveal);
    }


    // 2: REVEAL
    function revealAnswer(string memory answer, bytes32 randomness) public onlyInPhase(Phase.Reveal) onlyOwner {
        require(
            keccak256(abi.encodePacked(quizNumber, answer, randomness)) == rightAnswerCommitment,
            "The answer is wrong or malformed."
        );
        
        emit AnswerRevealed(answer);

        rightAnswer = answer;

        changePhase(Phase.Claim);
    }


    // 3: CLAIM
    function claimRightAnswer(string memory userAnswer, bytes32 randomness) public onlyInPhase(Phase.Claim) {
        //TODO: check timeout

        require(
            keccak256(abi.encodePacked(quizNumber, msg.sender, userAnswer, randomness)) == answers[msg.sender],
            "The answer is wrong or malformed."
        );
        
        //Check if answer matches the official correct answer
        require(keccak256(abi.encodePacked(userAnswer)) == keccak256(abi.encodePacked(rightAnswer)), "Your answer is wrong.");

        nWinners += 1;
        userWon[msg.sender] = quizNumber;
    }
    
    function startWithdrawals() public onlyInPhase(Phase.Claim) onlyOwner {
        //TODO: require timeout expiry
        
        if (nWinners == 0) {
            prizeAmount = 0;
        } else {
            prizeAmount = address(this).balance / nWinners;
        }

        changePhase(Phase.Withdraw);
    }
    

    // 4: WITHDRAW
    function withdrawPrize() public onlyInPhase(Phase.Withdraw) {
        if (userWon[msg.sender] == quizNumber) {
            //Make sure user can withdraw only once
            delete userWon[msg.sender];
            delete answers[msg.sender];
            
            msg.sender.transfer(prizeAmount);
        }
    }
    
    function cleanup() public onlyInPhase(Phase.Withdraw) onlyOwner {
        //Transfer any remaining balance to the owner (== the caller)
        msg.sender.transfer(address(this).balance);
        
        changePhase(Phase.Init);
        nWinners = 0;
        quizNumber += 1;
    }
}
