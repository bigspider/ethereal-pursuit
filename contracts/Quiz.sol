pragma solidity >=0.4.21 <0.6.0;

contract Quiz {
    address public owner;

    enum Phase { Init, Commit, Reveal, Claim, Withdraw }

    Phase public phase = Phase.Init;

    uint32 quizNumber = 0;
    string public question;
    bytes32 rightAnswerCommitment; // Commitment of the correct answer (H(rightAnswer || randomness))
    bytes32 public rightAnswer; // Actual answer, after reveal
    
    uint nWinners = 0; // Number of winners for this round
    uint prizeAmount; // Amount that winner can withdraw
    
    mapping(address => bytes32) answers; // Commitment of the answers for each user (H(quizNumber || rightAnswer || randomness))
    mapping(address => uint32) userWon; // userWon[addr] is set to quiz_number if the user gave the right answer


    event PhaseChange(Phase newPhase);

    constructor() public {
        owner = msg.sender;
    }


    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    //Only allow when the contract is in a certain phase
    modifier onlyInPhase(Phase _phase) {
        require(phase == _phase);
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
    
    function initQuiz(string memory _question, bytes32 _rightAnswerCommitment) onlyInPhase(Phase.Init) onlyOwner public {
        question = _question;
        rightAnswerCommitment = _rightAnswerCommitment;
        changePhase(Phase.Commit);
    }


    // 1: COMMIT
    function commitAnswer(bytes32 userAnswer) onlyInPhase(Phase.Commit) public payable costs(1 ether) {
        //TODO: check timeout for phase 1
        
        answers[msg.sender] = userAnswer;
    }

    function startRevealPhase() onlyInPhase(Phase.Commit) onlyOwner public {
        //TODO: require timeout expiry
        
        changePhase(Phase.Reveal);
    }


    // 2: REVEAL
    function revealAnswer(bytes32 answer, bytes32 randomness) onlyInPhase(Phase.Reveal) onlyOwner public {
        require(
            keccak256(abi.encodePacked(answer, randomness)) == rightAnswerCommitment,
            "The answer is wrong or malformed."
        );
        
        changePhase(Phase.Claim);
    }


    // 3: CLAIM
    function claimRightAnswer(bytes32 userAnswer, bytes32 randomness) onlyInPhase(Phase.Claim) public {
        //TODO: check timeout

        require(
            keccak256(abi.encodePacked(quizNumber, userAnswer, randomness)) == answers[msg.sender],
            "The answer is wrong or malformed."
        );
        
        nWinners += 1;
        userWon[msg.sender] = quizNumber;
    }
    
    function startWithdrawals() onlyInPhase(Phase.Claim) onlyOwner public {
        //TODO: require timeout expiry
        
        if (nWinners == 0) {
            prizeAmount = 0;
        } else {
            prizeAmount = address(this).balance / nWinners;
        }

        changePhase(Phase.Withdraw);
    }


    // 4: WITHDRAW
    function withdrawPrize() onlyInPhase(Phase.Withdraw) public {
        if (userWon[msg.sender] == quizNumber) {
            //Make sure user can withdraw only once
            delete userWon[msg.sender];
            delete answers[msg.sender];
            
            msg.sender.transfer(prizeAmount);
        }
    }
    
    function cleanup() onlyInPhase(Phase.Withdraw) onlyOwner public {
        //Transfer any remaining balance to the owner (== the caller)
        msg.sender.transfer(address(this).balance);
        
        changePhase(Phase.Init);
        nWinners = 0;
        quizNumber += 1;
    }
}
