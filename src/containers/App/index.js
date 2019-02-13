import React, { Component } from 'react';
import { MuiThemeProvider } from '@material-ui/core/styles';
import {
  HashRouter,
  Route,
  Redirect,
  Switch
} from 'react-router-dom';
import theme from 'configs/theme/config-theme';
import AdminView from 'containers/AdminView';
import HomeView from 'containers/HomeView';
import Header from './components/Header';
import Footer from './components/Footer';

import QuizContext from '../../contexts/QuizContext';

import Web3 from 'web3';
import { soliditySha3, randomHex, toWei } from 'web3-utils';

import TruffleContract from 'truffle-contract';
import Quiz from '../../../build/contracts/Quiz.json';

import './styles.scss' // global styles

class App extends Component {
  constructor(props) {
    super(props);

    this.state = {
      ready: false,
      account: null, //current MetaMask account owner

      owner: null, //contract owner
      question: null,
      quizNumber: null,
      phase: null, //quiz phase
      rightAnswer: null, //right answer, after reveal

      //Local data for owner
      answer: localStorage.getItem("answer"),
      answerNonce: localStorage.getItem("answerNonce"),

      //Local data for player
      playerAnswer: localStorage.getItem("playerAnswer"),
      playerAnswerNonce: localStorage.getItem("playerAnswerNonce"),
      playerCanWithdraw: localStorage.getItem("playerCanWithdraw")
    };


    if (typeof window.web3 != 'undefined') {
      this.web3Provider = window.web3.currentProvider;
    } else {
      this.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
    }
    this.web3 = new Web3(this.web3Provider);
    this.quiz = TruffleContract(Quiz);
    this.quiz.setProvider(this.web3Provider);
  }

  computeAnswerCommitment = (answer, nonce) => {
    return soliditySha3({
      type: 'uint32',
      value: this.state.quizNumber
    }, {
      type: 'string',
      value: answer
    }, {
      type: 'bytes32',
      value: nonce
    });
  };

  reloadStatus = () => {
    this.setState({ ready: false });
    this.web3.eth.getCoinbase((err, account) => {
      this.setState({ account });
      this.quiz.deployed().then(quizInstance => {
        this.quizInstance = quizInstance;

        //Make sure we are notified when the phase changes
        quizInstance.PhaseChange().watch((error, event) => {
          const phase = event.args.newPhase.toNumber();

          console.log("Phase changed", event);
          this.setState({ phase });

          //The quiz was just initialized, load the question!
          if (phase == 1) {
            quizInstance.question().then( question => this.setState({ question }));
          }
        });

        quizInstance.AnswerRevealed().watch((error, event) => {
          this.setState({ rightAnswer: event.args.answer });
        });


        Promise.all([
          quizInstance.quizNumber(),
          quizInstance.question(),
          quizInstance.phase().then(p => p.toNumber()),
          quizInstance.owner()])
        .then(([quizNumber, question, phase, owner]) => {
          this.setState({
            quizNumber,
            question,
            phase,
            owner,
            ready: true
          });
        })
      });
    });    
  };

  componentDidMount() {
    this.reloadStatus();
  }

  onCreateNewQuiz = (newQuestion, newAnswer) => {
    const nonce = soliditySha3({ type: "bytes32", value: randomHex(32) }); //TODO: better way of generating the nonce?
    const newAnswerCommitment = this.computeAnswerCommitment(newAnswer, nonce);
    this.quizInstance.initQuiz(newQuestion, newAnswerCommitment, { from: this.state.account }).then(() => {
      localStorage.setItem("answer", newAnswer);
      localStorage.setItem("answerNonce", nonce);
      this.setState({
        answer: newAnswer,
        answerNonce: nonce
      });
    });
  };

  onStartRevealPhase = () => {
    this.quizInstance.startRevealPhase({ from: this.state.account });
  };

  onRevealAnswer = () => {
    this.quizInstance.revealAnswer(this.state.answer, this.state.answerNonce, { from: this.state.account });
  };

  onStartWithdrawals = () => {
    this.quizInstance.startWithdrawals({ from: this.state.account });
  };

  onCleanup = () => {
    this.quizInstance.cleanup({ from: this.state.account }).then(() => {
      localStorage.removeItem("playerAnswer");
      localStorage.removeItem("playerAnswerNonce");
      this.setState({
        answer: null,
        answerNonce: null,
        question: null,
        playerAnswer: null,
        playerAnswerNonce: null
      });
    });
  };

  onCommitAnswer = (answer) => {
    const nonce = soliditySha3({ type: "bytes32", value: randomHex(32) }); //TODO: better way of generating the nonce?
    const newAnswerCommitment = this.computeAnswerCommitment(answer, nonce);
    this.quizInstance.commitAnswer(newAnswerCommitment, { from: this.state.account, value: toWei("1", "ether") }).then(() => {
      localStorage.setItem("playerAnswer", answer);
      localStorage.setItem("playerAnswerNonce", nonce);
      this.setState({
        playerAnswer: answer,
        playerAnswerNonce: nonce
      });
    });
  };

  onClaimRightAnswer = (answer, nonce) => {
    this.quizInstance.claimRightAnswer(answer, nonce, { from: this.state.account }).then(() => {
      localStorage.setItem("playerCanWithdraw", "true");
      this.setState({
        playerCanWithdraw: "true"
      });
    });
  };

  onWithdrawPrize = () => {
    this.quizInstance.withdrawPrize({ from: this.state.account }).then(() => {
      localStorage.removeItem("playerAnswer");
      localStorage.removeItem("playerAnswerNonce");
      localStorage.removeItem("playerCanWithdraw");
      this.setState({
        playerAnswer: null,
        playerAnswerNonce: null,
        playerCanWithdraw: null
      });
    });
  };

  render() {
    const context = {
      ...this.state,
      onCreateNewQuiz: this.onCreateNewQuiz,
      onStartRevealPhase: this.onStartRevealPhase,
      onRevealAnswer: this.onRevealAnswer,
      onStartWithdrawals: this.onStartWithdrawals,
      onCleanup: this.onCleanup,
      onCommitAnswer: this.onCommitAnswer,
      onClaimRightAnswer: this.onClaimRightAnswer,
      onWithdrawPrize: this.onWithdrawPrize
    };

    return (
      <MuiThemeProvider theme={theme}>
        <QuizContext.Provider value={context}>
          <HashRouter>
            <div>
              <Header />
              <Footer />
              <div className="app-shell">
                <Switch>
                  <Route path="/admin" component={AdminView} />
                  <Route path="/home" component={HomeView} />
                  <Redirect from="/" to="/home" />
                </Switch>
              </div>
            </div>
          </HashRouter>
        </QuizContext.Provider>
      </MuiThemeProvider>
    );
  }
}

export default App;
