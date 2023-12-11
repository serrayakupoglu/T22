# Music Recommendation API

This API provides endpoints for a music recommendation system, allowing users to interact with their music preferences, get recommendations, and perform various other actions related to music.

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [API Endpoints](#api-endpoints)
- [Usage Examples](#usage-examples)
- [Contributing](#contributing)
- [License](#license)

## Features

- User authentication and profile management.
- Song rating and analysis of user preferences.
- Genre-based song recommendations.
- Friendship activities, such as recommending the last liked song from a friend.
- Search functionality for songs, artists, and users.
- Manual addition and deletion of tracks.

## Getting Started

### Prerequisites

- Python 3.x
- MongoDB

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/music-recommendation-api.git


## Install dependencies:

cd music-recommendation-api
pip install -r requirements.txt
Set up MongoDB:

Create a MongoDB database.
Update the MongoDB connection details in the config.py file.
## Run the application:
python app.py

The API will be accessible at http://localhost:105.

## API Endpoints
User Authentication:

/register (POST): Register a new user.
/login (POST): Log in an existing user.
/logout (GET): Log out the current user.
Song Analysis:

/get_higher_rated_genre (GET): Get the higher-rated genre for a user.
/get_genre_percentage (GET): Get genres and their percentage of rating for a user.
/get_average_release_year (GET): Get the average release year of liked songs for a user.
Song Recommendations:

/recommend_song (GET): Recommend a song based on the genre of the highest-rated song.
Friendship Activities:

/recommend_last_liked_song_from_friend (GET): Recommend the last added liked song from a friend.
Song Management:

/increase_rate/<track_name> (GET): Increase the popularity of a song.
/decrease_rate/<track_name> (GET): Decrease the popularity of a song.
/add_tracks_to_db/<artist_name> (GET): Add top tracks of an artist to the database.
/delete_track (DELETE): Delete a track from the database.
Search Functionality:

/search_user (POST): Search for users by username.
/search_song (POST): Search for songs by name.
/search_tracks_by_artist (POST): Search for tracks by artist.
User Liked Songs:

/get_users_liked_songs (GET): Get a user's liked songs.
Additional Functionality:

/fetch_from_id (GET): Fetch a song by its ID.
/search_song_from_db (GET): Search for songs from the database.
File Processing and Manual Track Addition:

/extract_track_info (POST): Extract track information from a text file and add it to the database.
/add_track_man (POST): Manually add a track to the database.


## Contributing:
-Ata Egemen Gürel
-Yağmur Dolunay





