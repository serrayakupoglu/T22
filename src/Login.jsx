import React, { useState } from 'react';
import { Link, Navigate } from 'react-router-dom';
import axios from 'axios';
import './Profile.css';
import logo from '../src/assets/logo.png';

function Login() {
  const [username, setUsername] = useState(''); // State for username
  const [password, setPassword] = useState(''); // State for password
  const [redirectToHome, setRedirectToHome] = useState(false);

  function handleSubmit(event) {
    event.preventDefault(); 

    const formData = new FormData();
    formData.append('username', username);
    formData.append('password', password);

    axios.post('http://127.0.0.1:105/login', formData, {
        headers: {
            'Content-Type': 'multipart/form-data'
        },
        withCredentials: true
    })
    .then(response => {
        if (response.data.message === 'Login successful') {
            localStorage.setItem('username', username); // Kullanıcı adını kaydet
            console.log('Login successful:', response.data);
            setRedirectToHome(true); 
        }
    })
    .catch(error => {
        console.error('Login error:', error);
    });
  }

  if (redirectToHome) {
    return <Navigate to="/" />;
  }

  return (
    <div style={{ backgroundColor: '#000000', height: '100vh' }} className="d-flex justify-content-center align-items-center">
      <img src={logo} alt="Logo" className="logo" />
      <div className="bg-secondary p-4 rounded" style={{ width: '40%' }}>
        <h2>Login</h2>
        <form onSubmit={handleSubmit}>
          <div className="mb-3">
            <label htmlFor="username" className="form-label">
              <strong>Username</strong>
            </label>
            <input
              type="text"
              placeholder="Enter Username"
              name="username"
              className="form-control rounded-0"
              onChange={(e) => setUsername(e.target.value)}
            />
          </div>
          <div className="mb-3">
            <label htmlFor="password" className="form-label">
              <strong>Password</strong>
            </label>
            <input
              type="password"
              placeholder="Enter Password"
              name="password"
              className="form-control rounded-0"
              onChange={(e) => setPassword(e.target.value)}
            />
          </div>
          <button type="submit" className="btn" style={{ backgroundColor: '#800020', color: 'white', width: '100%' }}>
            Login
          </button>
        </form>
        <p>Don't have an account?</p>
        <Link to="/register" className="btn btn-default border w-100 bg-light rounded-0 text-decoration-none">
          Register
        </Link>
      </div>
    </div>
  );
}

export default Login;