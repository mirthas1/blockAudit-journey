// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract TodoList {
    struct Todo {
        string text;
        bool completed;
    }
    
    // STORAGE - main data
    Todo[] public todos;
    mapping(address => uint256[]) public userTodos;
    
    function createTodo(string memory _text) public {
        // STORAGE update
        todos.push(Todo(_text, false));
        userTodos[msg.sender].push(todos.length - 1);
    }
    
    function toggleCompleted(uint256 _todoIndex) public {
        // STORAGE update
        todos[_todoIndex].completed = !todos[_todoIndex].completed;
    }
}