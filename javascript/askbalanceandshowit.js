const readline = require("readline");
const rl = readline.createInterface({
input: process.stdin,
output: process.stdout
});
rl.question("What is your Balance ?", function(answer) {
    console.log("Your Balance is: £ " +(answer))
rl.close();
});