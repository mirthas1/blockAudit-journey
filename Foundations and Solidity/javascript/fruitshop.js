// Fruit database with prices and stock quantities
const fruits = {
    "Apple": { price: 1.5, stock: 10 },
    "Banana": { price: 0.5, stock: 15 },
    "Orange": { price: 2.0, stock: 8 },
    "Mango": { price: 3.0, stock: 5 },
    "Grapes": { price: 2.5, stock: 12 }
};

// Display available fruits and stock
console.log("Available Fruits:");
for (const [fruit, info] of Object.entries(fruits)) {
    console.log(`${fruit} - Price: $${info.price} | Stock: ${info.stock}`);
}

// Get user input
const selectedFruit = prompt("Enter the fruit name from the list above:").trim();
const quantity = parseInt(prompt("Enter the quantity you want:"));

// Check if fruit exists and stock is available
if (fruits[selectedFruit]) {
    const fruit = fruits[selectedFruit];
    
    if (quantity <= fruit.stock && quantity > 0) {
        const totalPrice = quantity * fruit.price;
        console.log(`\nOrder Successful!`);
        console.log(`Fruit: ${selectedFruit}`);
        console.log(`Quantity: ${quantity}`);
        console.log(`Total Price: $${totalPrice.toFixed(2)}`);
        
        // Update stock (optional)
        // fruit.stock -= quantity;
    } else {
        console.log(`\nSorry, ${selectedFruit} is out of stock or invalid quantity requested!`);
        console.log(`Available stock: ${fruit.stock}`);
    }
} else {
    console.log("\nInvalid fruit selection! Please choose from the available fruits.");
}