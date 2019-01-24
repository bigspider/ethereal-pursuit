pragma solidity >=0.4.21 <0.6.0;

contract Quiz {
    address public owner;

    enum Phase { Init, Commit, Claim, Withdraw }

    Phase public phase = Phase.Init;

    uint32 quizNumber = 0;
    string public question;
    bytes32 rightAnswerCommitment; // Commitment of the correct answer
    bytes32 public rightAnswer; // Actual answer, after reveal
    
    uint nWinners = 0; // Number of winners for this round
    uint prizeAmount; // Amount that winner can withdraw
    
    mapping(address => bytes32) answers;    // Commitment of the answers for each user
    mapping(address => uint32) userWon;    // userWon[addr] is set to quiz_number if the user gave the right answer


    event PhaseChange(Phase newPhase);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyInitPhase() {
        require(phase == Phase.Init);
        _;
    }

    modifier onlyCommitPhase() {
        require(phase == Phase.Commit);
        _;
    }

    modifier onlyClaimPhase() {
        require(phase == Phase.Claim);
        _;
    }

    modifier onlyWithdrawPhase() {
        require(phase == Phase.Withdraw);
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
    
    function initQuiz(string memory _question, bytes32 _rightAnswerCommitment) onlyInitPhase onlyOwner public {
        question = _question;
        rightAnswerCommitment = _rightAnswerCommitment;
        changePhase(Phase.Commit);
    }


    // 1: COMMIT
    function commitAnswer(bytes32 userAnswer) onlyCommitPhase public payable costs(1 ether) {
        //TODO: check timeout for phase 1
        
        answers[msg.sender] = userAnswer;
    }

    function startClaimPhase() onlyCommitPhase onlyOwner public {
        //TODO: require timeout expiry
        
        changePhase(Phase.Claim);
    }

    // 2: CLAIM
    function claimRightAnswer(bytes32 userAnswer, bytes32 randomness) onlyClaimPhase public {
        //TODO: check timeout

        require(
            keccak256(abi.encodePacked(quizNumber, userAnswer, randomness)) == answers[msg.sender],
            "The answer is wrong or malformed."
        );
        
        nWinners += 1;
        userWon[msg.sender] = quizNumber;
    }
    
    function startWithdrawals() onlyClaimPhase onlyOwner public {
        //TODO: require timeout expiry
        
        prizeAmount = address(this).balance / nWinners;

        changePhase(Phase.Withdraw);
    }


    // 3: WITHDRAW
    function withdrawPrize() onlyWithdrawPhase public {
        if (userWon[msg.sender] == quizNumber) {
            //Make sure user can withdraw only once
            delete userWon[msg.sender];
            delete answers[msg.sender];
            
            msg.sender.transfer(prizeAmount);
        }
    }
    
    function cleanup() onlyWithdrawPhase onlyOwner public {
        //Transfer any remaining balance to the owner (== the caller)
        msg.sender.transfer(address(this).balance);
        
        changePhase(Phase.Init);
        nWinners = 0;
        quizNumber += 1;
    }
}
