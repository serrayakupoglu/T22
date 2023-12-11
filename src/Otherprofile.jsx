import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useParams } from 'react-router-dom';
import './Otherprofile.css';
import logo from '../src/assets/logo.png';

function OtherProfile() {
  const currentUser = localStorage.getItem('username');
  const { username } = useParams();
  const [profileData, setProfileData] = useState({
    name: '',
    surname: '',
    username: '',
    followers: [],
    following: [],
    likedSongs: []
  });
  const [isFollowing, setIsFollowing] = useState(false);
  const [showFollowers, setShowFollowers] = useState(false);
  const [showFollowing, setShowFollowing] = useState(false);

  useEffect(() => {
    const fetchProfileData = async () => {
      try {
        const profileResponse = await axios.get(`http://127.0.0.1:105/get_profile?username=${username}`);
        setProfileData(profileResponse.data.profile_info);

        const loggedInUsername = localStorage.getItem('username');
        setIsFollowing(profileResponse.data.profile_info.followers.includes(loggedInUsername));
      } catch (error) {
        console.error('Error fetching profile data:', error);
      }
    };

    fetchProfileData();
  }, [username]);

  const handleFollow = async () => {
    try {
      await axios.post('http://127.0.0.1:105/follow', { target_username: username });
      setIsFollowing(true);
    } catch (error) {
      console.error('Error during follow action:', error);
    }
  };

  const handleUnfollow = async () => {
    try {
      await axios.post(`http://127.0.0.1:105/unfollow`, { target_username: username });
      setIsFollowing(false);
    } catch (error) {
      console.error('Error during unfollow action:', error);
    }
  };

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
        <h2>Profile: {profileData.username}</h2>
        <h4>Username: {profileData.username}</h4>
        <h4>Name: {profileData.name}</h4>
        <h4>Surname: {profileData.surname}</h4>
        <div>
          <button className="button followButton" onClick={handleFollow} disabled={isFollowing}>
            Follow
          </button>
          <button className="button followButton" onClick={handleUnfollow} disabled={!isFollowing}>
            Unfollow
          </button>
        </div>

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
  );
}

export default OtherProfile;
