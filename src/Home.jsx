import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Link, useNavigate, Navigate } from 'react-router-dom';
import './Home.css';
import logo from '../src/assets/logo.png';

const API_BASE_URL = 'http://127.0.0.1:105'; //API base URL

function HomePage() {
    const [playlists, setPlaylists] = useState([]);
    const [likedSongs, setLikedSongs] = useState([]);
    const [recommendedSongs, setRecommendedSongs] = useState([]);
    const [searchTerm, setSearchTerm] = useState('');
    const [searchResults, setSearchResults] = useState({ users: [], songs: [] });
    const [activeTab, setActiveTab] = useState('playlists');
    const [redirectToLogin, setRedirectToLogin] = useState(false);
    const navigate = useNavigate();

    function handleLogout() {
        const username = localStorage.getItem('username'); // Retrieve the username from local storage
    
        if (!username) {
            console.error('No user logged in.');
            return;
        }
    
        axios.post('http://127.0.0.1:105/logout', { username }, {
            withCredentials: true
        })
        .then(response => {
            localStorage.removeItem('username'); // Remove the username from local storage on successful logout
            console.log('Logout successful:', response.data);
            
        })
        .catch(error => {
            console.error('Logout error:', error);
        });
    }
    
    

    


    const searchUsers = async (username) => {
        try {
            const response = await axios.post(`${API_BASE_URL}/search_user`, { username });
            setSearchResults({ ...searchResults, users: response.data.results });
        } catch (error) {
            console.error('Search error:', error);
        }
    };

    const searchSongs = async (songName) => {
        try {
            const response = await axios.post(`${API_BASE_URL}/search_song`, { song_name: songName });
            setSearchResults({ ...searchResults, songs: response.data.results });
        } catch (error) {
            console.error('Song search error:', error);
        }
    };

    const handleSearchUsers = async () => {
        await searchUsers(searchTerm);
    };

    const handleSearchSongs = async () => {
        await searchSongs(searchTerm);
    };

    const handleRateSong = async (songId) => {
    
        const rating = 5;
        await axios.post(`${API_BASE_URL}/rate_song`, { song_id: songId, rating: rating });
    };

    const handleAddToPlaylist = async (songId) => {
        
        const playlistName = 'My Playlist'; 
        await axios.post(`${API_BASE_URL}/add_to_playlist`, { playlist_name: playlistName, tracks: [songId] });
    };

    const handleLikeSong = async (songId) => {
        await axios.post(`${API_BASE_URL}/add_to_liked_songs`, { song_id: songId });
        
    };

    useEffect(() => {
        
    }, [activeTab]);

    const clearSearchResults = () => {
        setSearchResults({ users: [], songs: [] });
    };

    return (
        <div className="home-container">
            {/* Sidebar */}
            <div className="sidebar">
                <img src={logo} alt="Logo" className="home-logo" />
                <button onClick={() => navigate('/profile')} className="profile-button">My Profile</button>
                <button onClick={handleLogout} className="logout-button">Logout</button>
            </div>

            {/* Main content */}
            <div className="main-content">
                {/* Search bar */}
                <div className="search-bar">
                    <input
                        type="text"
                        placeholder="Search for songs, artists, users..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                        className="search-input"
                    />
                    <button className="search-button" onClick={handleSearchUsers}>Search Users</button>
                    <button className="search-button" onClick={handleSearchSongs}>Search Songs</button>
                    <button className="search-button" onClick={clearSearchResults}>Clear Search</button>
                </div>

                {/* Search results */}
                <div className="search-results">
                    {searchResults.users.map((user, index) => (
                        <div key={index} className="search-result-item">
                            <Link to={`/otherprofile/${user.username}`} className="search-result-link">{user.username}</Link>
                        </div>
                    ))}
                    {searchResults.songs.map((song, index) => (
                        <div key={index} className="search-result-item">
                        <span className="song-title">{song.name}</span>
                        <button className="rate-button action-button" onClick={() => handleRateSong(song.id)}>Rate</button>
                        <button className="add-to-playlist-button action-button" onClick={() => handleAddToPlaylist(song.id)}>Add to Playlist</button>
                        <button className="like-button action-button" onClick={() => handleLikeSong(song.id)}>Like</button>
                    </div>
                    ))}
                </div>

                {/* Tab buttons  */}
                <div className="tab-buttons">
                <button 
                    className={`tab-button ${activeTab === 'playlists' ? 'active' : ''}`}
                    onClick={() => navigate('/playlist')}
                >
                    Playlists
                </button>
                <button
                    className={`tab-button ${activeTab === 'likedSongs' ? 'active' : ''}`}
                    onClick={() => navigate('/likedsongs')}
                >
                    Liked Songs
                </button>


                    <button className={`tab-button ${activeTab === 'recommendedSongs' ? 'active' : ''}`} onClick={() => setActiveTab('recommendedSongs')}>
                        Recommended Songs
                    </button>
                </div>

                {activeTab === 'playlists' && (
                    <div className="playlist-section">
                        {playlists.map((playlist) => (
                            <div key={playlist.id} className="playlist-item">
                                <Link to={`/playlist/${playlist.id}`}>{playlist.name}</Link>
                            </div>
                        ))}
                    </div>
                )}
                {activeTab === 'likedSongs' && (
                    <div className="liked-songs-section">
                        {likedSongs.map((song, index) => (
                            <div key={index} className="song-item">
                                <Link to={`/likedsongs/${song.id}`}>{song.name}</Link>
                            </div>
                        ))}
                    </div>
                )}
                {activeTab === 'recommendedSongs' && (
                    <div className="recommended-songs-section">
                        {recommendedSongs.map((song, index) => (
                            <div key={index} className="song-item">
                                <p>{song.name}</p>
                            </div>
                        ))}
                    </div>
                )}
            </div>

            {redirectToLogin && <Navigate to="/login" />}
        </div>
    );
}

export default HomePage;