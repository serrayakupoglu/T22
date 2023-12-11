import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './Profile.css';
import logo from '../src/assets/logo.png';

function Profile() {
  const [profileData, setProfileData] = useState({
    name: '',
    surname: '',
    username: '',
    followers: [],
    following: [],
    likedSongs: []
  });
  const [showFollowers, setShowFollowers] = useState(false);
  const [showFollowing, setShowFollowing] = useState(false);

  useEffect(() => {
    const fetchProfileData = async () => {
      const loggedInUsername = localStorage.getItem('username');
      if (!loggedInUsername) {
        console.error('No logged-in user found');
        return;
      }

      try {
        const profileResponse = await axios.get(`http://127.0.0.1:105/get_profile?username=${loggedInUsername}`);
        const followersResponse = await axios.get(`http://127.0.0.1:105/get_followers?username=${loggedInUsername}`);
        const followingResponse = await axios.get(`http://127.0.0.1:105/get_followees?username=${loggedInUsername}`);

        if (profileResponse.data && profileResponse.data.profile_info) {
          setProfileData({
            ...profileResponse.data.profile_info,
            followers: followersResponse.data.followers,
            following: followingResponse.data.followees
          });
        } else {
          console.error('Profile data not found');
        }
      } catch (error) {
        console.error('Error fetching profile data:', error);
      }
    };

    fetchProfileData();
  }, []);

  const handleFollowersClick = () => {
    setShowFollowers(!showFollowers);
  };

  const handleFollowingClick = () => {
    setShowFollowing(!showFollowing);
  };

  return (
    <div className="profileContainer d-flex justify-content-center align-items-center">
      <img src={logo} alt="Logo" className="logo" />
      <div className="profileBox bg-dark p-4 rounded">
        <h2>Profile</h2>
        <div className="profileDetails">
          <h4>Name: {profileData.name}</h4>
          <h4>Surname: {profileData.surname}</h4>
          <h4>Username: {profileData.username}</h4>
          <hr />
          <div className="userConnections">
            <div className="followers-info">
              <span className="numberSpan">{profileData.followers.length}</span>
              <span> Followers</span>
              <button className="button" onClick={handleFollowersClick}>
                {showFollowers ? 'Hide' : 'Show'}
              </button>
              {showFollowers && (
                <div>{profileData.followers.map(follower => <p key={follower}>{follower}</p>)}</div>
              )}
            </div>
            <div className="following-info">
              <span className="numberSpan">{profileData.following.length}</span>
              <span> Following</span>
              <button className="button" onClick={handleFollowingClick}>
                {showFollowing ? 'Hide' : 'Show'}
              </button>
              {showFollowing && (
                <div>{profileData.following.map(following => <p key={following}>{following}</p>)}</div>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Profile;
