var Quiz = artifacts.require("./Quiz.sol");

contract("Quiz", function(accounts) {
  it("initializes in phase 0", function() {
    return Quiz.deployed().then(function(instance) {
      return instance.phase();
    }).then(function(phase) {
      assert.equal(phase, 0);
    });
  });
});