import React, { useState, useEffect } from 'react';
import axios from 'axios';

const TodoApp = () => {
  const [title, setTitle] = useState(''); // State to handle the input
  const [todos, setTodos] = useState([]); // State to handle the list of todos

  // Get the API URL from the environment variables
  const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:5000'; // Default to localhost if not set

  // Fetch existing todos from the backend when the component is mounted
  useEffect(() => {
    fetchTodos();
  }, []);

  const fetchTodos = async () => {
    try {
      const response = await axios.get(`${API_URL}/todos`);
      setTodos(response.data);
    } catch (error) {
      console.error('Error fetching todos:', error);
    }
  };

  const handleAddTodo = async () => {
    if (!title) {
      return; // Don't proceed if the title is empty
    }

    try {
      const response = await axios.post(`${API_URL}/todos`, { title });
      setTodos([...todos, response.data]); // Add the new todo to the list
      setTitle(''); // Clear the input field
    } catch (error) {
      console.error('Error adding todo:', error);
    }
  };

  const handleDeleteTodo = async (id) => {
    try {
      await axios.delete(`${API_URL}/todos/${id}`);
      setTodos(todos.filter(todo => todo.id !== id)); // Remove the deleted todo from the list
    } catch (error) {
      console.error('Error deleting todo:', error);
    }
  };

  return (
    <div>
      <h1>Todo App</h1>
      <input
        type="text"
        value={title}
        onChange={(e) => setTitle(e.target.value)}
        placeholder="Enter todo title"
      />
      <button onClick={handleAddTodo}>Add Todo</button>

      <ul>
        {todos.map((todo) => (
          <li key={todo.id}>
            {todo.title}
            <button onClick={() => handleDeleteTodo(todo.id)}>Delete</button>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default TodoApp;
