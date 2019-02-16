# Ethereal pursuit
Answer questions, win prizes.

WARNING: Do not use with real money.

## Intro

The Quiz contract manages a trust-minimized game where players are rewarded for answering a question correctly.

Each participant will pay a fee to participate and attempt giving and answer. At the and of the game, participants that gave the right answer will split the money of the contract.

## Protocol

The contract can be in 5 statuses: Init, Commit, Reveal, Claim, Withdraw, that happen in this order.

The owner and the participating players will send their answer in the form of a commitment, H(quizNumber||answer||nonce), and reveal it later by revealing the nonce. The commitment includes quizNumber in order to invalidate any answer given in a previous game (quizNumber is incremented for each quiz)

Note: Timeouts should be added to the protocol, to reduce the power of the contract owner.

1. **Init**: The owner can send the commitment of the right answer, which moves the quiz to status *Commit*.
2. **Commit**: Players can send the commitment to their answer by paying a fee. The owner can move the contract status to *Reveal* (TODO: only allow after a timeout). *(NOTE: Currently, the contract allows users to change their answer, but they have to pay the fee each time.)*
3. **Reveal**: Players wait. The Owner reveals the right answer, and status changes to *Claim*. (TODO: after a timeout, if the owner fails to reveal the right answer, the contract should allow users to withdraw their funds)
4. **Claim**: Each player who gave the right answer can prove it by opening his commitment. The owner can change the status to *Withdraw*
5. **Withdraw**: Winning players can withdraw their prize. The owner can reset the contract and withdraw any unclaimed fund (TODO: only allow after a timeout).

## Comments on the protocol
### Efficiency
Each interaction with the protocol requires a constant amount of gas. Most notably, payouts are withdrawn by each user rather than paid directly to all the winners (which would require gas proportional to the number of users).

### Security

Without the timeouts, the protocol requires a great deal of trust for the owner.

Even after adding timeouts, the owner can still collude with some participants by revealing them the right answer; this is impossible to prevent.

Worse, the owner himself could participate with many accounts to steal the money of winning users.
Thus, this contract would not make sense unless something is put into place to prevent this (e.g.: vetting participants who can access to the quiz).
