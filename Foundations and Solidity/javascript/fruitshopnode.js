const readline = require('readline');

// Create readline interface
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

// Fruit database with prices and stock quantities
const fruits = {
    "apple": { price: 1.5, stock: 10 },
    "banana": { price: 0.5, stock: 15 },
    "orange": { price: 2.0, stock: 8 },
    "mango": { price: 3.0, stock: 5 },
    "grapes": { price: 2.5, stock: 12 }
};

function displayFruits() {
    console.log("\nAvailable Fruits:");
    for (const [fruit, info] of Object.entries(fruits)) {
        console.log(`${fruit} - Price: $${info.price} | Stock: ${info.stock}`);
    }
    console.log(); // Empty line for better formatting
}

function startShop() {
    displayFruits();
    
    rl.question("Enter One of the fruit name from the list above: ", (selectedFruit) => {
        selectedFruit = selectedFruit.trim().toLowerCase();
        
        if (!fruits[selectedFruit]) {
            console.log("\nInvalid fruit selection! Please choose from the available fruits.");
            rl.close();
            return;
        }
        
        rl.question("Enter the quantity you want: ", (quantityInput) => {
            const quantity = parseInt(quantityInput);
            const fruit = fruits[selectedFruit];
            
            if (isNaN(quantity) || quantity <= 0) {
                console.log("\nPlease enter a valid quantity!");
            } else if (quantity > fruit.stock) {
                console.log(`\nSorry, ${selectedFruit} is out of stock!`);
                console.log(`Available stock: ${fruit.stock}`);
            } else {
                const totalPrice = quantity * fruit.price;
                console.log(`\nOrder Successful!`);
                console.log(`Fruit: ${selectedFruit}`);
                console.log(`Quantity: ${quantity}`);
                console.log(`Total Price: $${totalPrice.toFixed(2)}`);
                
                // Update stock (optional)
                // fruit.stock -= quantity;
            }
            
            rl.close();
        });
    });
}

// Start the program
startShop();