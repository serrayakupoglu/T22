import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useParams, useNavigate } from 'react-router-dom';
import './Playlist.css';

const Playlist = () => {
  const { playlistId } = useParams();
  const navigate = useNavigate();
  const [tracks, setTracks] = useState([]);
  const [playlistTracks, setPlaylistTracks] = useState([]);
  const [search, setSearch] = useState('');
  const [playlistName, setPlaylistName] = useState('');

  const loadTracks = async () => {
    // ... Mevcut kodunuz
  };

  const handleCreatePlaylist = async () => {
    try {
      const response = await axios.post('http://127.0.0.1:105/create_playlists', { playlist_name: playlistName });
      navigate(`/playlist/${response.data.playlistId}`);
    } catch (error) {
      console.error('Failed to create playlist:', error);
    }
  };

  useEffect(() => {
    loadTracks();
    
  }, [playlistName]);

  return (
    <div className="playlist-manager-container">
      <div className="playlist-form">
        <input
          type="text"
          placeholder="Playlist Name"
          value={playlistName}
          onChange={(e) => setPlaylistName(e.target.value)}
        />
        <button onClick={handleCreatePlaylist}>Create Playlist</button>
      </div>
      <div className="tracks-form">
      </div>
      <h2>Playlist: {playlistName}</h2>
      <ul className="playlist-tracks-list">
        {playlistTracks.map((track) => (
          <li key={track.id}>{track.name}</li>
        ))}
      </ul>
    </div>
  );
};

export default Playlist;
