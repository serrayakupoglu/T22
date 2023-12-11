import { useState } from 'react'
import 'bootstrap/dist/css/bootstrap.min.css';
import Signup from './Signup'
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import Login from './Login'
import Profile from './Profile'
import Home from './Home'
import Playlist from './Playlist';
import OtherProfile from './Otherprofile'; 
import Likedsongs from './Likedsongs';


function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path='/register' element={<Signup />} /> 
        <Route path='/login' element={<Login />} /> 
        <Route path='/profile' element={<Profile />} /> 
        <Route path="/" element={<Home />} /> 
        <Route path='/Playlist' element={<Playlist />} />
        <Route path="/Otherprofile/:username" element={<OtherProfile />} /> 
        <Route path='/likedsongs' element={<Likedsongs />} />
      
      </Routes>
    </BrowserRouter>
  )
}

export default App;
