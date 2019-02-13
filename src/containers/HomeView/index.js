import React, { Component } from 'react'
import QuizContext from '../../contexts/QuizContext';

import Button from '@material-ui/core/Button';
import TextField from '@material-ui/core/TextField';

class AdminView extends Component {
  state = {
    playerNewAnswer: ""
  };

  render() {
    const { playerNewAnswer } = this.state;
    return (
      <QuizContext.Consumer>
      { ({
          ready, question, phase, rightAnswer, playerAnswer, playerAnswerNonce, playerCanWithdraw,
          onCommitAnswer, onClaimRightAnswer, onWithdrawPrize
        }) =>
        {
          if (!ready) {
            return <p>Loading...</p>;
          }

          return (
            <React.Fragment>
              <p>Contract in phase {phase}</p>
              { phase === 0 && (
                <div>
                  <p>The quiz has not started yet. Try again later!</p>
                </div>
              )}

              { phase >= 1 && (
                <p>Question: {question}</p>
              )}

              { phase === 1 && (
                <div>
                  <p>Do you know the answer? It costs 1 ETH to participate.</p>
                  <TextField
                    value={playerNewAnswer}
                    label="Your answer"
                    onChange={ e => this.setState({ playerNewAnswer: e.target.value }) }
                  />
                  <Button
                    variant="contained"
                    onClick={() => onCommitAnswer(playerNewAnswer)}
                  >
                    Send answer
                  </Button>
                </div>
              )}

              { phase == 2 && (
                <p>Waiting for the right answer to be revealed.</p>
              )}

              { phase == 3 && (
                <React.Fragment>
                  <p>The right answer is: {rightAnswer}.</p>

                  { rightAnswer === playerAnswer && (
                    <div>
                      <p>Congratulations, your answer is correct!</p>
                      <p>Press the button below to claim your prize.</p>
                      <Button
                        variant="contained"
                        onClick={() => onClaimRightAnswer(playerAnswer, playerAnswerNonce)}
                      >
                        Claim right answer!
                      </Button>
                    </div>
                  )}
                </React.Fragment>
              )}

              { phase === 4 && !!playerCanWithdraw && (
                <div>
                  <p>You won! Press button to withdraw your prize!</p>
                  <Button
                        variant="contained"
                        onClick={() => onWithdrawPrize()}
                      >
                        Withdraw
                      </Button>
                </div>
              )}
              { phase === 4 && !playerCanWithdraw && (
                <p>
                  Unfortunately you didn't make it this time. Better luck next time!
                </p>
              )}
  

            </React.Fragment>
          )
        }
      }
      </QuizContext.Consumer>
    );
  }
}

export default AdminView;
