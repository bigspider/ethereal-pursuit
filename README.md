# Ethereal pursuit
Answer questions, win prizes


### Action Board

- **16/1/19: Select your user story!** : I selected my ones, but happy to change/discuss!
- **TBD**: start development!!

### User Stories 

Instead of using taiga.io (which I recommend as it's an amazing tool), I thought it would be faster to slice the chunks of work required here. 


### Basic Requirements

|ID|Name|Description|
|---|---|---|
|01|AntiDDoS|Must include economic incentive not to DDOS contract|
|02|Timing|Must specify a question time init and timeout|
|03|Owner|Must ensure only the owner can change question|
|04|Don't trick|Must ensure every answer submmited cannot be reconstructed|
|05|Participants|Could preset a number of possible participants|
|06|Modularity|Could support modular architecture|


### User Stories 
Ref. sequence diagram posted in the picture. 


|ID|User Story|Acceptance Criteria|Doer|
|---|---|---|---|
|01|As the EtherealPursuit contract owner, I deploy my contract so that the game can start|Given I am a user, I can access the question stored in the contract on Rinkeby |SC|
|02|As the EtherealPursuit contract owner, I change the question of my contract so that the game can restart|Given I am a user, I can see the new question stored by the contract on Rinkeby|SC|
|03 |As User, I submit my hidden answer and a deposit to the contract so that nobody can steal my answer|Given I am a user, I receive an event confirming my question being logged |TBD|
|04|As a User, I record the contract timeout so that I can start revealing my answer| Given I am a user, I can receive an event from the contract certifying that at block X the contract answer collection has timed out |SC|
|05|As a User, I reveal my answer to the contract so that I can understand if I am winner or not  |Given I am a user, I receive an event confirming my question being matched with the encrypted answer previously stored|TBD|
|06|As a winner user, I withdraw my part of the funds from the contract so that I can take what I won|Given I am a user, I receive an event which certifies my winning and I collect the funds held in the contract |TBD|
|07|As a loser user, I receive my deposit back so that I can close my participation|Given I am a user, I receive my deposit back|TBD|


### Vanilla Kanban board

|Backlog|Refinement needed|In progress|Testing|Done|
|---|---|---|---|---|
|||01, SC||
|02, SC||||
|03, TBD||||
|04, SC||||
|05, TBD||||
|06, TBD||||
