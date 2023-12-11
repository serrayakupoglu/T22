import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import axios from 'axios';
import './Login.css';
import logo from '../src/assets/logo.png';


function Signup() {
  const [username, setUsername] = useState('');
  const [name, setName] = useState('');
  const [surname, setSurname] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (password !== confirmPassword) {
      alert('Passwords do not match!');
      return;
    }

    const formData = new FormData();
    formData.append('username', username);
    formData.append('name', name);
    formData.append('surname', surname);
    formData.append('password', password);
    formData.append('password2', confirmPassword);

    try {
      const response = await axios.post('http://127.0.0.1:105/signup', formData);
      alert(response.data.message); // Display success message from server
      navigate('/login'); // Redirect to login page
    } catch (error) {
      if (error.response) {
        alert(error.response.data.message);
      } else if (error.request) {
        console.log(error.request);
      } else {
        console.log('Error', error.message);
      }
    }
  };

  return (
    <div style={{ backgroundColor: '#000000', height: '100vh' }} className="d-flex justify-content-center align-items-center">
      <img src={logo} alt="Logo" className="logo" />
      <div className="bg-secondary p-4 rounded" style={{ width: '40%' }}>
        <h2>Register</h2>
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
            <label htmlFor="name" className="form-label">
              <strong>Name</strong>
            </label>
            <input
              type="text"
              placeholder="Enter Name"
              name="name"
              className="form-control rounded-0"
              onChange={(e) => setName(e.target.value)}
            />
          </div>
          <div className="mb-3">
            <label htmlFor="surname" className="form-label">
              <strong>Surname</strong>
            </label>
            <input
              type="text"
              placeholder="Enter Surname"
              name="surname"
              className="form-control rounded-0"
              onChange={(e) => setSurname(e.target.value)}
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
          <div className="mb-3">
            <label htmlFor="confirmPassword" className="form-label">
              <strong>Confirm Password</strong>
            </label>
            <input
              type="password"
              placeholder="Confirm Password"
              name="confirmPassword"
              className="form-control rounded-0"
              onChange={(e) => setConfirmPassword(e.target.value)}
            />
          </div>
          <button type="submit" className="btn" style={{ backgroundColor: '#800020', color: 'white', width: '100%' }}>
            Register
          </button>
        </form>
        <p>Already have an account?</p>
        <Link to="/login" className="btn btn-default border w-100 bg-light rounded-0 text-decoration-none">
          Login
        </Link>
      </div>
    </div>
  );
}

export default Signup;
