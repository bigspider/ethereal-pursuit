import React, { Component } from 'react';
import QuizContext from '../../contexts/QuizContext';

import Button from '@material-ui/core/Button';
import TextField from '@material-ui/core/TextField';

class HomeView extends Component {
  state = {
    newQuestion: "",
    newQuestionAnswer: ""
  };

  
  render() {
    const { newQuestion, newQuestionAnswer } = this.state;
    
    return (
      <QuizContext.Consumer>
      { ({
          ready, phase, answer,
          onCreateNewQuiz, onStartRevealPhase, onRevealAnswer, onStartWithdrawals, onCleanup
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
                  <p>Chose the next question and answer.</p>
                  <TextField
                    value={newQuestion}
                    label="Question"
                    onChange={ e => this.setState({ newQuestion: e.target.value })}
                  />
                  <TextField
                    value={newQuestionAnswer}
                    label="Correct answer"
                    onChange={ e => this.setState({ newQuestionAnswer: e.target.value })}
                  />
                  <Button
                    variant="contained"
                    disabled={!newQuestion || !newQuestionAnswer}
                    onClick={() => onCreateNewQuiz(newQuestion, newQuestionAnswer)}
                  >
                    Start quiz
                  </Button>
                </div>
              )}

              { phase === 1 && (
                <div>
                  <p>Press the button to close the quiz.</p>
                  <Button
                    variant="contained"
                    onClick={() => onStartRevealPhase()}
                  >
                    Time's up
                  </Button>
                </div>
              )}

              { phase === 2 && (
                <div>
                  <p>The right answer is: {answer}</p>
                  <p>Reveal the right answer.</p>
                  <Button
                    variant="contained"
                    onClick={() => onRevealAnswer()}
                  >
                    Reveal
                  </Button>
                </div>
              )}

              { phase === 3 && (
                <Button
                  variant="contained"
                  onClick={() => onStartWithdrawals()}
                >
                  Start withdrawals
                </Button>
              )}

              { phase === 4 && (
                <Button
                  variant="contained"
                  onClick={() => onCleanup()}
                >
                  Reset quiz
                </Button>
              )}

            </React.Fragment>
          )
        }
      }
      </QuizContext.Consumer>
    );
  }
}

export default HomeView;
