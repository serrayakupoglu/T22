
import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Link } from 'react-router-dom';

const API_BASE_URL = 'http://127.0.0.1:105'; 

function LikedSongs() {
    const [likedSongs, setLikedSongs] = useState([]); 

    
    const username = localStorage.getItem('username');

    const fetchLikedSongs = async () => {
        if (!username) {
            console.error('Kullanıcı adı bulunamadı');
            return;
        }

        try {
            const response = await axios.get(`${API_BASE_URL}/get_users_liked_songs`, {
                params: { username }
            });
          
            if (response.data && Array.isArray(response.data.likedSongs)) {
                setLikedSongs(response.data.likedSongs);
            } else {
                
                setLikedSongs([]);
            }
        } catch (error) {
            console.error('Beğenilen şarkıları çekerken hata oluştu:', error);
            
            setLikedSongs([]);
        }
    };

    return (
        <div className="liked-songs-container">
            <h1>Liked Songs</h1>
            <div className="liked-songs-list">
                {likedSongs.map((song, index) => (
                    <div key={index} className="liked-song">
                        <p>{song.song} - {song.artist}</p>
                    </div>
                ))}
            </div>
        </div>
    );
}

export default LikedSongs;
