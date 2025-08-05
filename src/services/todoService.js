// src/services/todoService.js

import axios from "axios";

// Use environment variable for the base API URL
const API_URL = process.env.REACT_APP_API_URL;

/**
 * Add a new todo.
 * @param {string} title - The title of the todo.
 * @returns {Promise<Object>} - The response data from the API.
 */
export const addTodo = async (title) => {
  try {
    const response = await axios.post(`${API_URL}/todos`, { title });
    return response.data;
  } catch (error) {
    console.error("Error adding todo:", error);
    throw error; // Optional: Re-throw error to handle it in the calling component
  }
};
