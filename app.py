from flask import Flask, jsonify, request, session
from datetime import timedelta
import certifi
import requests
import json 
import secrets
from bson import ObjectId
import random
import string
from collections import Counter
from pymongo import MongoClient

app = Flask(__name__)
app.secret_key = secrets.token_hex(16)

app.config['SECRET_KEY'] = 'ygmr2002'
app.config['SESSION_PERMANENT'] = True

app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(minutes=30)  
app.config['SESSION_TYPE'] = 'redis'
app.config['SESSION_PERMANENT'] = True
app.config['SESSION_USE_SIGNER'] = True

logged_in_users = set()


# Spotify phase
######################################
def get_spotify_token():
    client_id = "ba1546786ab9481784b81d606cf28669" 
    client_secret = "bb189e4ab82646f89ce464325f1a3cbc" 
    # Spotify token endpoint
    token_url = "https://accounts.spotify.com/api/token"
    # Post data for obtaining token
    post_data = {
        "grant_type": "client_credentials",
        "client_id": client_id,
        "client_secret": client_secret,
    }
    # Headers
    headers = {
        "Content-Type": "application/x-www-form-urlencoded"
    }
    # Make the request
    response = requests.post(token_url, data=post_data, headers=headers)
    token = response.json()["access_token"]
    
    return token


# @app.route('/get_artist/<artist_id>')
def get_artist(artist_name):
    access_token = get_spotify_token()
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
    url = f"https://api.spotify.com/v1/search?q="+artist_name+"&type=artist"
    response = requests.get(url, headers=headers)

    return response.json()["artists"]["items"][0]["id"]

def get_artist_genres(artist_id):
    access_token = get_spotify_token()
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
    url = f"https://api.spotify.com/v1/artists/{artist_id}"
    response = requests.get(url, headers=headers)
    artist_info = response.json()
    genres = artist_info.get("genres", [])
    return genres

@app.route('/artist/<artist_name>/top-tracks')
def get_artist_top_tracks(artist_name):
    market = request.args.get('market', 'US')
    access_token = get_spotify_token()
    artist_id = get_artist(artist_name)
    headers = {
        "Authorization": f"Bearer {access_token}"
    }
    url = f"https://api.spotify.com/v1/artists/{artist_id}/top-tracks?market={market}"
    response = requests.get(url, headers=headers)

    output = convert_track_format(response.json())

    
    

    return {"output": output}, 200



     


def convert_track_format(input_json):
    # New tracks list to build up the converted format
    new_tracks = []
    

    # Process each track in the input JSON
    for track in input_json['tracks']:
        # Convert the track to the new format
        new_track = {
            # "_id": generate_oid(),
            "album": {
                "id": track['album']['id'],
                "name": track['album']['name'],
                "release_date": track['album']['release_date']
            },
            "artists": [
            {
                "id": artist['id'],
                "name": artist['name'],
                "genres": get_artist_genres(artist['id'])
            }
            for artist in track['artists']
                 
            ],
            "duration_ms": track['duration_ms'],
            "id": track['id'],
            "name": track['name'],
            "popularity": track['popularity']
        }

        # Add the converted track to the new tracks list
        new_tracks.append(new_track)

    # Create the new output JSON
    output_json = {
        "tracks": new_tracks,
    }

    return output_json
######################################











# MongoDB Atlas Part
######################################
from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi

def connect_to_mongo():
    uri = "mongodb+srv://yagmurdolunay:yagmurdlny@musicdata.saqinen.mongodb.net/?retryWrites=true&w=majority"

    try:
        # Use certifi for SSL certificate verification
        client = MongoClient(uri, server_api=ServerApi('1'), tlsCAFile=certifi.where())
        client.admin.command('ping')  # Test connection
        print("Pinged your deployment. You successfully connected to MongoDB!")
        return client
    except Exception as e:
        print("Error connecting to MongoDB:", e)
        return None

# Login/out and signup endpoints...
######################################

def generate_session_id():
    # Generate a random session ID
    return secrets.token_urlsafe(16)



def check(username):
    # Check if the user is already logged in
    return username in logged_in_users


@app.route('/login', methods=['POST'])
def login():
    try:
        # Check if the user is already logged in
        if 'username' in session:
            return jsonify({'message': 'User is already logged in'}), 200

        username = request.form['username']
        password = request.form['password']

        if username and password:
            # Connect to the database
            client = connect_to_mongo()
            db = client.MusicDB
            UserInfo_collection = db.UserInfo

            # Find the user in the database
            user = UserInfo_collection.find_one({'username': username})

            # Check if the user exists and the password is correct
            if user and password == user['userPassword']:
                # Set the user in the session with a dynamic key
                session['username'] = username
                return jsonify({'message': 'Login successful'})
            else:
                return jsonify({'message': 'Invalid username or password'}), 401
        else:
            return jsonify({'message': 'Bad Request - Missing credentials'}), 400

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500



def get_user_by_username(username):
    # Connect to the database
    client = connect_to_mongo()
    db = client.MusicDB
    UserInfo_collection = db.UserInfo

    # Find the user in the database
    user = UserInfo_collection.find_one({'username': username})
    return user
def get_current_user():
     # Get the current user from the session
    username = session.get('username')
    if username:
        return get_user_by_username(username)

    return None





@app.route('/logout', methods=['POST'])
def logout():
    try:
        # Check if the user is logged in
        username = request.form.get('username')

        # Log the received username for testing
        print(f'Received username: {username}')

        # Check if the username in the session matches the one provided in the request
        if 'username' in session and username == session['username']:
            # Clear the user from the session
            session.pop('username', None)
            return jsonify({'message': 'Logout successful'})
        else:
            return jsonify({'message': 'User not logged in or invalid username'}), 401
    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

# Initialize an empty dictionary for logged-in users
logged_in_users = {}

@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        password2 = request.form['password2']
        name = request.form['name']
        surname = request.form['surname']

        if password != password2:
            return jsonify({'message': 'Passwords do not match'}), 400

        # Replace this with your MongoDB connection
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo

        # Check if the username already exists
        existing_user = UserInfo_collection.find_one({'username': username})
        if existing_user:
            return jsonify({'message': 'Username already exists'}), 400

        # Generate a random userID (replace this with your user ID generation)
        user_id = generate_random_user_id()

        # Insert the new user into the database
        new_user = {
            'name': name,
            'surname': surname,
            'username': username,
            'userID': user_id,
            'userPassword': password,
            'followers': [],
            'following': [],
            'likedSongs': [],
            'rated_songs': [],
            'playlists': []
        }
        insert_result = UserInfo_collection.insert_one(new_user)

        # Optionally, you can add the user to the logged_in_users dictionary
        if username not in logged_in_users:
            logged_in_users[username] = {'session_ids': []}

        # Set the user-specific identifier in the session
        session['user_identifier'] = generate_session_id()
        logged_in_users[username]['session_ids'].append(session['user_identifier'])

        print(f"Logged in users after signup: {logged_in_users}")  # Debugging line

        return jsonify({'message': 'Signup successful'})

    return jsonify({'message': 'Method not allowed'}), 405

def generate_random_user_id():
    # Generate a random 6-digit user ID
    return ''.join(random.choices(string.digits, k=6))

def add_track_to_db(track_object, client):
    db = client.MusicDB
    track_collection = db.Track
    # Insert the track data into the 'Track' collection
    insert_result = track_collection.insert_one(track_object)
   



@app.route('/add_tracks_to_db/<artist_name>')
def add(artist_name):
    try:
        client = connect_to_mongo()
        top_tracks_response = get_artist_top_tracks(artist_name)

        # Unpack the tuple and access the dictionary
        top_tracks_response_dict = top_tracks_response[0]


        if 'output' in top_tracks_response_dict and 'tracks' in top_tracks_response_dict['output']:
            top_tracks = top_tracks_response_dict['output']['tracks']

            for track_object in top_tracks:
                add_track_to_db(track_object, client)

            return 'Success'
        else:
            return 'Failed: "tracks" key not found in the response output'

    except Exception as e:
        print(f"Error: {e}")
        return 'Failed'

@app.route('/delete_track', methods=['DELETE'])
def delete_track():
    try:
        # Get parameters from the request
        song_name = request.args.get('song_name')
        artist_name = request.args.get('artist_name')

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        track_collection = db.Track

        # Use the parameters in the MongoDB query
        query = {'name': song_name, 'artists.name': {'$regex': f'.*{artist_name}.*', '$options': 'i'}}

        # Delete the track with the specified parameters
        result = track_collection.delete_one(query)

        if result.deleted_count == 1:
            return jsonify({'message': 'Track deleted successfully'})
        else:
            return jsonify({'message': 'Track not found'})

    except Exception as e:
        print(f"Error: {e}")
        return jsonify({'message': 'Failed to delete track'})


#################################
@app.route('/add_followings', methods=['POST'])
def add_followings():
    # Get the current user (logged in user)
    current_user = get_current_user()

    try:
        # Check if the current user is logged in
        if current_user is None:
            return jsonify({'message': 'User not logged in'}), 401

        # Get the target username from the request body
        target_username = request.form.get('target_username')

        if not target_username:
            return jsonify({'message': 'Target username is missing in the request body'}), 400

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo

        # Find the target user in the database
        target_user = get_user_by_username(target_username)

        # Check if the target user exists
        if target_user is None:
            return jsonify({'message': 'Target user not found'}), 404

        # Check if the current user is already following the target user
        if current_user['username'] in target_user.get('followers', []):
            return jsonify({'message': 'User already follows the target user'}), 400

        # Add the target user to the current user's followings
        UserInfo_collection.update_one({'username': current_user['username']}, {'$push': {'following': target_user['username']}})

        # Add the current user to the target user's followers
        UserInfo_collection.update_one({'username': target_username}, {'$push': {'followers': current_user['username']}})

        return jsonify({'message': f'User {current_user["username"]} is now following {target_username}'})

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500
    
@app.route('/unfollow', methods=['POST'])
def unfollow_user():
    try:
        # Get the current user (logged in user)
        current_user = get_current_user()

        # Get the target username from the request body
        target_username = request.form.get('target_username')

        if not target_username:
            return jsonify({'message': 'Target username is missing in the request body'}), 400

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo

        # Find the target user in the database
        target_user = get_user_by_username(target_username)

        # Check if the target user exists
        if target_user is None:
            return jsonify({'message': 'Target user not found'}), 404

        # Check if the current user is following the target user
        if current_user and current_user['username'] not in target_user.get('followers', []):
            return jsonify({'message': 'User is not following the target user'}), 400

        # Remove the target user from the current user's followings
        if current_user:
            UserInfo_collection.update_one({'username': current_user['username']}, {'$pull': {'following': target_user['username']}})

        # Remove the current user from the target user's followers
        UserInfo_collection.update_one({'username': target_username}, {'$pull': {'followers': current_user['username']}})

        return jsonify({'message': f'User {current_user["username"]} has unfollowed {target_username}'})

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500
    

# Endpoint to add a song and its artist to the likedSongs array
@app.route('/add_to_liked_songs', methods=['POST'])
def add_to_liked_songs():
    try:
        # Get the current user from the session
        username = session.get('username')
        song_name = request.form.get('song_name')

        if not username or not song_name:
            return jsonify({'message': 'Required data is missing in the form data'}), 400

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo
        Track_collection = db.Track

        # Check if the user exists
        user = UserInfo_collection.find_one({'username': username})
        if user is None:
            return jsonify({'message': 'User not found'}), 404

        # Search for the song in the Track collection to get its artist
        track = Track_collection.find_one({'name': song_name})

        if track is None:
            return jsonify({'message': f'Song "{song_name}" not found in the database'}), 404

        # Get the artist from the track
        artist_name = track['artists'][0]['name'] if 'artists' in track and track['artists'] else None

        if artist_name is None:
            return jsonify({'message': f'Artist not found for song "{song_name}"'}), 404

        # Check if the song and artist combination is already in likedSongs
        existing_entry = next((entry for entry in user['likedSongs'] if entry['song'] == song_name and entry['artist'] == artist_name), None)

        if existing_entry:
            return jsonify({'message': 'Song and artist already in likedSongs'}), 400

        # Add the new entry to likedSongs
        new_entry = {'song': song_name, 'artist': artist_name}
        UserInfo_collection.update_one({'username': username}, {'$push': {'likedSongs': new_entry}})

        return jsonify({'message': f'Song "{song_name}" by "{artist_name}" added to likedSongs'})

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

# Endpoint to rate a song
@app.route('/rate_song', methods=['POST'])
def rate_song():
    # Check if the user is logged in
    current_user = get_current_user()
    if current_user is None:
        return jsonify({'message': 'User not logged in'}), 401

    try:
        # Get the song name and rating from the request body
        song_name = request.form.get('song_name')
        rating = int(request.form.get('rating'))

        if not song_name or rating is None:
            return jsonify({'message': 'Song name or rating is missing in the request body'}), 400

        # Validate the rating (between 1 and 10)
        if 1 <= rating <= 10:
            # Connect to the database
            client = connect_to_mongo()
            db = client.MusicDB
            Track_collection = db.Track
            UserInfo_collection = db.UserInfo

            # Check if the song exists in the Track_collection
            song = Track_collection.find_one({'name': song_name})
            if song is None:
                return jsonify({'message': 'Song not found in the track collection'}), 404

            # Check if the user has already rated the song
            existing_rating = UserInfo_collection.find_one(
                {'username': current_user['username'], 'rated_songs': {song_name: {'$exists': True}}}
            )
            if existing_rating:
                return jsonify({'message': f'You have already rated the song {song_name}'}), 400

            # Add the rated song information to the user's document
            UserInfo_collection.update_one(
                {'username': current_user['username']},
                {'$push': {'rated_songs': {song_name: rating}}}
            )

            return jsonify({'message': f'Successfully rated the song {song_name} with {rating} stars'})

        else:
            return jsonify({'message': 'Invalid rating. Please provide a rating between 1 and 10'}), 400

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500
    

def get_current_user():
    # Get the current user from the session
    username = session.get('username')
    if username:
        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo

        # Find the user in the database
        user = UserInfo_collection.find_one({'username': username})

        return user

    return None
##################################
# Endpoint to get followers of a user by username
@app.route('/get_followers', methods=['GET'])
def get_followers_endpoint():
    try:
        # Get the target username from the request parameters
        target_username = request.args.get('username')

        if not target_username:
            return jsonify({'message': 'Target username is missing in the request parameters'}), 400

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo

        # Find the target user in the database
        target_user = UserInfo_collection.find_one({'username': target_username})

        # Check if the target user exists
        if target_user is None:
            return jsonify({'message': 'Target user not found'}), 404

        # Return the followers as an array of strings
        followers = [str(follower) for follower in target_user['followers']]

        return jsonify({'followers': followers})

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500


# Endpoint to get followees of a user by username
@app.route('/get_followees', methods=['GET'])
def get_followees():
    try:
        # Get the target username from the request parameters
        target_username = request.args.get('username')

        if not target_username:
            return jsonify({'message': 'Target username is missing in the request parameters'}), 400

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo

        # Find the target user in the database
        target_user = UserInfo_collection.find_one({'username': target_username})

        # Check if the target user exists
        if target_user is None:
            return jsonify({'message': 'Target user not found'}), 404

        # Return the followees as an array of strings
        followees = [str(followee) for followee in target_user['following']]

        return jsonify({'followees': followees})

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

    
###############################################

# Endpoint to get profile information by username
@app.route('/get_profile', methods=['GET'])
def get_profile_endpoint():
    try:
        # Get the target username from the request parameters
        target_username = request.args.get('username')

        if not target_username:
            return jsonify({'message': 'Target username is missing in the request parameters'}), 400

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo

        # Find the target user in the database
        target_user = UserInfo_collection.find_one({'username': target_username})

        # Check if the target user exists
        if target_user is None:
            return jsonify({'message': 'Target user not found'}), 404

        
        profile_info = {
            'name': target_user['name'],
            'surname': target_user['surname'],
            'username': target_user['username'],
            'followers': [str(follower) for follower in target_user['followers']],
            'following': [str(followee) for followee in target_user['following']],
            'likedSongs': [str(song) for song in target_user['likedSongs']],
            'playlists': [list(playlist_name) for playlist_name in target_user['playlists']]
        }

        return jsonify({'profile_info': profile_info})

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500
#####################################################


# Endpoint to create a new playlist
@app.route('/create_playlist', methods=['POST'])
def create_playlist():
    try:

        # Get data from the request body
        playlist_name = request.form.get('playlist_name')

        # Perform necessary validation and database operations to create the playlist
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo

        # Get the current user from the session
        username = session.get('username')

        if username and playlist_name:
            # Find the user in the database
            user = UserInfo_collection.find_one({'username': username})

            if user:
                # Create the new playlist object with an empty list of tracks
                new_playlist = {
                    'playlist_name': playlist_name,
                    'tracks': [],
                }

                # Add the playlist to the user's playlists array
                UserInfo_collection.update_one({'username': username}, {'$push': {'playlists': new_playlist}})

                return jsonify({'message': 'Playlist created successfully'})
            else:
                return jsonify({'message': 'User not found'}), 404
        else:
            return jsonify({'message': 'User not logged in or no provided playlist name'}), 401

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500



@app.route('/add_to_playlist', methods=['POST'])
def add_to_playlist():
    try:
        # Get data from the request
        playlist_name = request.form.get('playlist_name')
        tracks = request.form.getlist('tracks[]')

        if not playlist_name or not tracks:
            return jsonify({'message': 'Required data is missing in the form data'}), 400

        # Get the current user from the session
        username = session.get('username')

        if not username:
            return jsonify({'message': 'User not logged in'}), 401

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo
        Track_collection = db.Track

        # Remove leading and trailing spaces from playlist_name
        playlist_name = playlist_name.strip()
        # Find the playlist in the user's playlists
        playlist_query = {'username': username, 'playlists.playlist_name': playlist_name}
        playlist_update = {
            '$push': {
                'playlists.$.tracks': {
                    '$each': []
                }
            }
        }

        for track_name in tracks:
            # Search for the track in the Track collection to get its details
            track = Track_collection.find_one({'name': track_name})

            if track is None:
                return jsonify({'message': f'Track "{track_name}" not found in the database'}), 404

            # Get all attributes of the track
            track_attributes = {
                "album": {
                "id": track['album']['id'],
                "name": track['album']['name'],
                "release_date": track['album']['release_date']
            },
            "artists": [
            {
                "id": artist['id'],
                "name": artist['name'],
                "genres": get_artist_genres(artist['id'])
            }
            for artist in track['artists']
                 
            ],
            "duration_ms": track['duration_ms'],
            "id": track['id'],
            "name": track['name'],
            "popularity": track['popularity']
            }

            # Check if the track is already in the playlist
            if any(entry['song'] == track_attributes['song'] and entry['artist'] == track_attributes['artist'] for entry in playlist_update['$push']['playlists.$.tracks']['$each']):
                return jsonify({'message': f'Track "{track_attributes["song"]}" by "{track_attributes["artist"]}" already in the playlist'}), 400

            # Add the new track entry to the playlist_update
            playlist_update['$push']['playlists.$.tracks']['$each'].append(track_attributes)

        # Update the playlist in the user's playlists array
        result = UserInfo_collection.update_one(playlist_query, playlist_update)

        if result.modified_count == 0:
            return jsonify({'message': f'Playlist "{playlist_name}" not found for user "{username}"'}), 404

        return jsonify({'message': f'Tracks added to playlist "{playlist_name}" successfully'})

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500


@app.route('/get_all_tracks', methods=['GET'])
def get_all_tracks():
    try:
        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        track_collection = db.Track

        # Retrieve all tracks from the database
        all_tracks = track_collection.find({})

        # Convert the cursor to a list
        tracks_list = list(all_tracks)

        if not tracks_list:
            return jsonify({'tracks': []})

        # Format the results
        formatted_tracks = []
        for track in tracks_list:
            formatted_track = {
                 "album": {
                "id": track['album']['id'],
                "name": track['album']['name'],
                "release_date": track['album']['release_date']
            },
            "artists": [
            {
                "id": artist['id'],
                "name": artist['name'],
                "genres": get_artist_genres(artist['id'])
            }
            for artist in track['artists']
                 
            ],
            "duration_ms": track['duration_ms'],
            "id": track['id'],
            "name": track['name'],
            "popularity": track['popularity']
            }
            formatted_tracks.append(formatted_track)

        return jsonify({'tracks': formatted_tracks})

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500


@app.route('/increase_rate/<track_name>')
def increase_rate(track_name):        
    client = connect_to_mongo()

    db = client.MusicDB
    track_collection = db.Track

    # Use `find_one()` instead of `find()` when you expect a single result.
    query_result = track_collection.find_one({'name': track_name})

    # Since `find_one()` returns a document, we can use `get` directly on the result.
    if query_result:  # if a document is found
        pop_value = query_result.get('popularity', 0)  # Get the current popularity, default to 0 if not set.
        pop_value += 1  # Increase popularity by 1.
        try:
            # Update the document with the new popularity value.
            track_collection.update_one({'name': track_name}, {'$set': {'popularity': pop_value}})
            return 'Increased popularity of: ' + track_name
        except Exception as e:
            print("Error:", e)
            return None
    else:
        # If no document is found, you may choose to insert a new one or handle the case accordingly.
        print(f"No track found with name {track_name}")
        return None




@app.route('/decrease_rate/<track_name>')
def decrease_rate(track_name):
    client = connect_to_mongo()

    db = client.MusicDB
    track_collection = db.Track

    # Use `find_one()` instead of `find()` when you expect a single result.
    query_result = track_collection.find_one({'name': track_name})

    # Since `find_one()` returns a document, we can use `get` directly on the result.
    if query_result:  # if a document is found
        pop_value = query_result.get('popularity', 0)  # Get the current popularity, default to 0 if not set.
        pop_value -= 1  # Increase popularity by 1.
        try:
            # Update the document with the new popularity value.
            track_collection.update_one({'name': track_name}, {'$set': {'popularity': pop_value}})
            return 'Decreased popularity of: ' + track_name
        except Exception as e:
            print("Error:", e)
            return None
    else:
        # If no document is found, you may choose to insert a new one or handle the case accordingly.
        print(f"No track found with name {track_name}")
        return None


######################################

def extract_track_info(text):
    try:
        data = json.loads(text)
        if 'tracks' in data:
            tracks = data['tracks']
            extracted_data = [
                {
                    "album": {
                "id": track['album']['id'],
                "name": track['album']['name'],
                "release_date": track['album']['release_date']
            },
            "artists": [
            {
                "id": artist['id'],
                "name": artist['name'],
                "genres": get_artist_genres(artist['id'])
            }
            for artist in track['artists']
                 
            ],
            "duration_ms": track['duration_ms'],
            "id": track['id'],
            "name": track['name'],
            "popularity": track['popularity']
                }
                for track in tracks
            ]
            return extracted_data
        else:
            return {"error": "Invalid JSON structure. 'tracks' key not found."}
    except json.JSONDecodeError:
        return {"error": "Invalid JSON format."}

@app.route('/extract_track_info', methods=['POST'])
def process_text_file():
    if 'file' not in request.files:
        return jsonify({"error": "No file part"})
    
    file = request.files['file']

    if file.filename == '':
        return jsonify({"error": "No selected file"})

    try:
        text_content = file.read().decode('utf-8')
        extracted_data = extract_track_info(text_content)
        return jsonify({"extracted_data": extracted_data})
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"})


##################################### ANALYSİS#############################
# Endpoint to get the higher-rated genre

@app.route('/get_higher_rated_genre', methods=['GET'])
def get_higher_rated_genre():
    try:
        # Get the username from the query parameters
        username = request.args.get('username')


        if not username:
            return jsonify({'message': 'Username is missing in the query parameters'}), 400
        
        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo
        Track_collection = db.Track

        # Get the user's document
        user_document = UserInfo_collection.find_one({'username': username})

        if user_document:
            # Extract rated songs with all ratings
            rated_songs = user_document.get('rated_songs', [])

            if not rated_songs:
                return jsonify({'message': 'User has not rated any songs'}), 400

            # Calculate average rating for each genre
            genre_ratings = {}

            for rated_song in rated_songs:
                # Ensure there is at least one item in the list
                if not rated_song:
                    continue

                # Directly access the dictionary keys and values
                song_name, rating = next(iter(rated_song.items()))
                track = Track_collection.find_one({'name': song_name})

                if track and 'artists' in track:
                    for artist_info in track['artists']:
                        artist_id = artist_info.get('id')

                        if artist_id:
                            artist_genres = get_artist_genres(artist_id)

                            for genre in artist_genres:
                                if genre not in genre_ratings:
                                    genre_ratings[genre] = {'total_rating': 0, 'count': 0}

                                genre_ratings[genre]['total_rating'] += rating
                                genre_ratings[genre]['count'] += 1

            # Calculate average rating for each genre
            average_ratings = {genre: info['total_rating'] / info['count'] for genre, info in genre_ratings.items()}

            # Get the genre with the highest average rating
            higher_rated_genre = max(average_ratings, key=average_ratings.get)

            return jsonify({'higher_rated_genre': higher_rated_genre, 'average_rating': average_ratings[higher_rated_genre]})

        return jsonify({'message': 'User not found'}), 404

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

# Endpoint to get genres and their percentage of rating
@app.route('/get_genre_percentage', methods=['GET'])
def get_genre_percentage():
    try:
        # Get the username from the body
        username = request.form.get('username')
         # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo
        Track_collection = db.Track

        if not username:
            return jsonify({'message': 'Username is missing in the query parameters'}), 400

        # Get the user's document
        user_document = UserInfo_collection.find_one({'username': username})

        if user_document:
            # Extract rated songs with all ratings
            rated_songs = user_document.get('rated_songs', [])

            if not rated_songs:
                return jsonify({'message': 'User has not rated any songs'}), 400

            # Calculate total rating and rating count for each genre
            genre_ratings = {}

            for rated_song in rated_songs:
                # Ensure there is at least one item in the list
                if not rated_song:
                    continue

                # Directly access the dictionary keys and values
                song_name, rating = next(iter(rated_song.items()))
                track = Track_collection.find_one({'name': song_name})

                if track and 'artists' in track:
                    for artist_info in track['artists']:
                        artist_id = artist_info.get('id')

                        if artist_id:
                            artist_genres = get_artist_genres(artist_id)

                            for genre in artist_genres:
                                if genre not in genre_ratings:
                                    genre_ratings[genre] = {'total_rating': 0, 'count': 0}

                                genre_ratings[genre]['total_rating'] += rating
                                genre_ratings[genre]['count'] += 1

            # Calculate percentage rating for each genre
             # Calculate percentage rating for each genre
            genre_percentage = {genre: (info['count'] / info['total_rating']) * 100 for genre, info in genre_ratings.items()}
            
            return jsonify({'genre_percentage': genre_percentage})

        return jsonify({'message': 'User not found'}), 404

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500
    



@app.route('/get_average_release_year', methods=['GET'])
def get_average_release_year():
    try:
        # Get the username from the query parameters
        username = request.args.get('username')

        if not username:
            return jsonify({'message': 'Username is missing in the query parameters'}), 400

        # Get the user's document
         # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo
        Track_collection = db.Track

        user_document = UserInfo_collection.find_one({'username': username})

        if user_document:
            # Extract liked songs with all details
            liked_songs = user_document.get('likedSongs', [])

            if not liked_songs:
                return jsonify({'message': 'User has not liked any songs'}), 400

            total_release_year = 0
            total_songs = 0

            for liked_song in liked_songs:
                # Ensure there is at least one item in the list
                if not liked_song:
                    continue

                # Directly access the dictionary keys and values
                song_name = liked_song.get('song')
                track = Track_collection.find_one({'name': song_name})

                if track and 'album' in track and 'release_date' in track['album']:
                    release_year = int(track['album']['release_date'][:4])  # Extract the release year
                    total_release_year += release_year
                    total_songs += 1

            if total_songs > 0:
                average_release_year = total_release_year / total_songs
                return jsonify({'most liked average year': round(average_release_year)})
            else:
                return jsonify({'message': 'No valid release years found for liked songs'}), 400

        return jsonify({'message': 'User not found'}), 404

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500
    
##RECCOMENDATION

# Endpoint to recommend a song based on the genre of the highest-rated song
@app.route('/recommend_song', methods=['GET'])
def recommend_song():
    try:
         # Get the current user from the session
        username = session.get('username')
        if not username:
            return jsonify({'message': 'User is not logged in'}), 400
        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo
        Track_collection = db.Track

        # Get the user's document
        user_document = UserInfo_collection.find_one({'username': username})

        if user_document:
            # Extract rated songs with all ratings
            rated_songs = user_document.get('rated_songs', [])

            if not rated_songs:
                return jsonify({'message': 'User has not rated any songs'}), 400

            # Calculate average rating for each genre
            genre_ratings = {}

            for rated_song in rated_songs:
                # Ensure there is at least one item in the list
                if not rated_song:
                    continue

                # Directly access the dictionary keys and values
                song_name, rating = next(iter(rated_song.items()))
                track = Track_collection.find_one({'name': song_name})

                if track and 'artists' in track:
                    for artist_info in track['artists']:
                        artist_id = artist_info.get('id')

                        if artist_id:
                            artist_genres = get_artist_genres(artist_id)

                            for genre in artist_genres:
                                if genre not in genre_ratings:
                                    genre_ratings[genre] = {'total_rating': 0, 'count': 0}

                                genre_ratings[genre]['total_rating'] += rating
                                genre_ratings[genre]['count'] += 1

            # Calculate average rating for each genre
            average_ratings = {genre: info['total_rating'] / info['count'] for genre, info in genre_ratings.items()}
            # Get the genre with the highest average rating
            higher_rated_genre = max(average_ratings, key=average_ratings.get)
            # Find a recommended song of the same genre not in the user's database
            recommended_song = Track_collection.find_one({
            'artists.genres': {'$in': [higher_rated_genre]},
            'name': {'$nin': [song.get('song') for song in user_document.get('likedSongs', [])]}
                })

            if recommended_song:
                return jsonify({'recommended_song': recommended_song['name'], 'genre': higher_rated_genre})
            else:
                return jsonify({'message': f'No recommended song found for the genre "{higher_rated_genre}"'}), 404

        return jsonify({'message': 'User not found'}), 404

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500
#FRIENDSHIP ACTIVITY
############################
# Connect to the database
        
# Function to get the last added liked song from a user's liked songs
def get_last_liked_song(username):
    client = connect_to_mongo()
    db = client.MusicDB
    UserInfo_collection = db.UserInfo
    
    user_document = UserInfo_collection.find_one({'username': username})
    if user_document:
        liked_songs = user_document.get('likedSongs', [])
        if liked_songs:
            # Assuming the liked songs are ordered by the time they were added
            return liked_songs[-1]
    return None
# Endpoint to get the last added liked song from a friend
@app.route('/recommend_last_liked_song_from_friend', methods=['GET'])
def recommend_last_liked_song_from_friend():
    try:
        # Get the current user from the session
        current_user = session.get('username')
        if not current_user:
            return jsonify({'message': 'User not logged in'}), 401

        client=connect_to_mongo()
        db=client.MusicDB
        UserInfo_collection=db.UserInfo
        user_document = UserInfo_collection.find_one({'username': current_user})
        if user_document:
            following_list= user_document.get('following', [])
       

        if not following_list:
            return jsonify({'message': 'User is not following anyone'}), 400

        # Choose one user from the following list
        friend_username = following_list[0]  

        # Get the last added liked song from the friend's liked songs
        last_liked_song = get_last_liked_song(friend_username)

        if last_liked_song:
            track_name = last_liked_song['song']
            artist_name =last_liked_song['artist']
           

            return jsonify({'friend': friend_username, 'added': track_name, 'by': artist_name})
        else:
            return jsonify({'message': f'No liked songs found for {friend_username}'}), 404

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500



# Song fetch api ends....
######################################
@app.route('/fetch_from_id')
def fetch_from_id():
    sid = request.args.get('id')
    return "Fetching the song witd id: " + sid
######################################


# Search song from db
######################################
@app.route('/search_song_from_db')
def search_song_from_db():
    term = request.args.get('song_name')
    # Process the search term and return results
    return 'Results for: {}'.format(term)
# Search song from db
######################################




###################Search panel#############
# Endpoint to search for users by username
@app.route('/search_user', methods=['POST'])
def search_user():
    try:
        # Get the search term from the form data or raw JSON
        if 'username' in request.form:  # form-data
            term = request.form.get('username')
        else:  # raw JSON
            data = request.get_json(force=True)
            term = data.get('username')

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo

        # Use a regular expression to find users that match the search term
        search_results = UserInfo_collection.find({'username': {'$regex': f'.*{term}.*', '$options': 'i'}})

        # Convert the search_results cursor to a list
        results = list(search_results)

        if not results:
            return jsonify({'results': []})

        # Process each user result and format the response
        formatted_results = []
        for result in results:
            formatted_result = {
                'name': result.get('name', ''),
                'surname': result.get('surname', ''),
                'username': result.get('username', ''),
                # You can include other user-related fields as needed
            }
            formatted_results.append(formatted_result)

        # Convert the formatted_results list to JSON format
        return jsonify({'results': formatted_results})

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

@app.route('/search_song', methods=['POST'])
def search_song():
    if'song_name' in request.form:#form-data
        term = request.form.get('song_name')
    else:#raw 
        data = request.get_json(force=True)
        term = data.get('song_name')
    # Connect to the database
    client = connect_to_mongo()
    db = client.MusicDB
    track_collection = db.Track

    # Use a regular expression to find tracks that match the search term
    search_results = track_collection.find({'name': {'$regex': f'.*{term}.*', '$options': 'i'}})

    # Convert the search_results cursor to a list
    results = list(search_results)

    if not results:
        return jsonify({'results': []})

    
    formatted_results = []
    for result in results:
        formatted_result = {
            'name': result['name'],
            'artists': result['artists'],
            'album': result['album'],
            "duration_ms": result['duration_ms'],
            'popularity': result['popularity'],     
        }
        formatted_results.append(formatted_result)

   
    return jsonify({'results': formatted_results})

@app.route('/search_tracks_by_artist', methods=['POST'])
def search_tracks_by_artist():
    if 'artist_name' in request.form:
        artist_name = request.form.get('artist_name')
    else:
        data = request.get_json(force=True)
        artist_name = data.get('artist_name')
    # Connect to the database
    client = connect_to_mongo()
    db = client.MusicDB
    track_collection = db.Track

    # Use a regular expression to find tracks that have the specified artist
    search_results = track_collection.find({'artists.name': {'$regex': f'.*{artist_name}.*', '$options': 'i'}})

    # Convert the search_results cursor to a list
    results = list(search_results)

    if not results:
        return jsonify({'results': []})

    
    formatted_results = []
    for result in results:
        formatted_result = {
            'name': result['name'],
            'artists': result['artists'],
            'album': result['album'],
            'popularity': result['popularity'],
            
        }
        formatted_results.append(formatted_result)

    # formatted_results listesini JSON formatına çevir
    return jsonify({'results': formatted_results})



######get user's liked songs#################
# Endpoint to get a user's liked songs
@app.route('/get_users_liked_songs', methods=['GET'])
def get_users_liked_songs():
    try:
        # Get the username from the query parameters
        username = request.args.get('username')

        if not username:
            return jsonify({'message': 'Username is missing in the query parameters'}), 400

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo

        # Check if the user exists
        user = UserInfo_collection.find_one({'username': username})

        if user is None:
            return jsonify({'message': 'User not found'}), 404

        # Retrieve the liked songs from the user's document
        liked_songs = user.get('likedSongs', [])

        return jsonify({'liked_songs': liked_songs})

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500
######################################




 

if __name__ == "__main__":
    app.secret_key = 'ygmr2002'
    app.run(host='0.0.0.0', port=105)
