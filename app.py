from flask import Flask, jsonify, request, session
from datetime import timedelta,datetime
from flask import send_file
from flask_mail import Mail, Message
import certifi
import requests
import json 
import secrets
from bson import ObjectId
import random
import string
from collections import Counter
from pymongo import MongoClient
from bson import json_util

app = Flask(__name__)

app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587  # or the correct port for your mail server
app.config['MAIL_USE_TLS'] = True  # Set to True if your server requires TLS
app.config['MAIL_USERNAME'] = 'appppp1111123@gmail.com'
app.config['MAIL_PASSWORD'] = 'lkdt zzie fvgy jegj'
app.config['MAIL_DEFAULT_SENDER'] = 'appppp1111123@gmail.com'

mail = Mail(app)
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
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Process each track in the input JSON
    for track in input_json['tracks']:
        # Convert the track to the new format
        new_track = {
            # "_id": generate_oid(),
            "added_at": current_time,
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
############## ARTIST PART##################
# Define the Spotify API endpoint for searching artists
SPOTIFY_SEARCH_API = "https://api.spotify.com/v1/search"

# Function to search for an artist by name and get the artist ID
def get_artist_id(artist_name, access_token):
    headers = {"Authorization": f"Bearer {access_token}"}
    params = {"q": artist_name, "type": "artist"}
    response = requests.get(SPOTIFY_SEARCH_API, headers=headers, params=params)
    result = response.json()
    artists = result.get('artists', {}).get('items', [])
    if artists:
        return artists[0]['id']
    return None

 # Function to fetch artist information from Spotify using the artist ID
def get_artist_info(artist_id, access_token):
    headers = {"Authorization": f"Bearer {access_token}"}
    artist_url = f"https://api.spotify.com/v1/artists/{artist_id}"
    response = requests.get(artist_url, headers=headers)
    return response.json()

# Function to add artist information to the database
def add_artist_to_db(artist_info, client):
    db = client.MusicDB
    Artist_collection = db.Artist
    Artist_collection.insert_one(artist_info)

# Route to add artist information to the database
@app.route('/add_artist_to_db/<artist_name>')
def add_artist_info_to_db(artist_name):
    try:
        client = connect_to_mongo()
        access_token = get_spotify_token()

        # Search for the artist ID using the artist name
        artist_id = get_artist_id(artist_name, access_token)

        if artist_id:
            # Fetch artist information from Spotify using the artist ID
            artist_info = get_artist_info(artist_id, access_token)

            # Extract relevant attributes from the artist_info
            name = artist_info.get('name')
            genres = artist_info.get('genres')
            popularity = artist_info.get('popularity')
            followers = artist_info.get('followers', {}).get('total')
            images = artist_info.get('images', [])

            # Create a new dictionary with the desired attributes
            filtered_artist_info = {
                'name': name,
                'genres': genres,
                'popularity': popularity,
                'followers': followers,
                'images': images
            }

            # Add the filtered_artist_info to the database
            add_artist_to_db(filtered_artist_info, client)

            return 'Success'
        else:
            return 'Artist not found on Spotify'

    except Exception as e:
        print(f"Error: {e}")
        return 'Failed'

import io 
# Route to get the artist image
@app.route('/get_artist_image/<artist_name>')
def get_artist_image(artist_name):
    try:
        client = connect_to_mongo()
        access_token = get_spotify_token()

        # Search for the artist ID using the artist name
        artist_id = get_artist_id(artist_name, access_token)

        if artist_id:
            # Fetch artist information from Spotify using the artist ID
            artist_info = get_artist_info(artist_id, access_token)

            # Extract the first image URL (you might want to handle multiple images)
            image_url = artist_info.get('images', [{}])[0].get('url', '')

            if image_url:
                # Fetch the image data
                response = requests.get(image_url)

                # Check if the request was successful
                if response.status_code == 200:
                    # Set content type as image/jpeg (you may need to adjust based on the actual image format)
                    return send_file(io.BytesIO(response.content), mimetype='image/jpeg')
                else:
                    return 'Failed to fetch artist image from Spotify'

            else:
                return 'No image URL found for the artist'

        else:
            return 'Artist not found on Spotify'

    except Exception as e:
        print(f"Error: {e}")
        return 'Failed'

def get_artist_info_from_db(artist_name):
    try:
        client = connect_to_mongo()
        db = client.MusicDB
        Artist_collection = db.Artist

        # Assume artist_name is a unique identifier in your database
        artist_info = Artist_collection.find_one({'name': artist_name}, {'_id': 0})

        return artist_info

    except Exception as e:
        # Handle the exception appropriately (e.g., log the error)
        print(f"Error in get_artist_info_from_db: {str(e)}")
        return None
# Endpoint to get artist profile information by artist name
@app.route('/get_artist_profile', methods=['GET'])
def get_artist_profile_endpoint():
    try:
        # Get the target artist name from the request parameters
        target_artist_name = request.form.get('artist_name')

        if not target_artist_name:
            return jsonify({'message': 'Target artist name is missing in the request parameters'}), 400

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        Artist_collection = db.Artist

        # Find the target artist in the database
        target_artist = Artist_collection.find_one({'name': target_artist_name})

        # Check if the target artist exists
        if target_artist is None:
            return jsonify({'message': 'Target artist not found'}), 404

        artist_profile_info = {
            'name': target_artist['name'],
            'genres': target_artist.get('genres', []),
            'popularity': target_artist.get('popularity', 0),
            'followers': target_artist.get('followers', 0)
        
            
        }

        return jsonify({'artist_profile_info': artist_profile_info})

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500


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
        email = request.form['email']
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
        existing_user = UserInfo_collection.find_one({'$or': [{'username': username}, {'email': email}]})
        #existing_user = UserInfo_collection.find_one({'username': username})
        if existing_user:
            return jsonify({'message': 'Username or email already exists'}), 400
        # Generate a random userID (replace this with your user ID generation)
        user_id = generate_random_user_id()

        # Insert the new user into the database
        new_user = {
            'name': name,
            'surname': surname,
            'username': username,
            'email': email,
            'userID': user_id,
            'userPassword': password,
            'followers': [],
            'following': [],
            'likedSongs': [],
            'rated_songs': [],
            'playlists': [],
            'likedPlaylists': []
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

@app.route('/forgot_password', methods=['POST'])
def forgot_password_route():
    if request.method == 'POST':
        email = request.form['email']
        result, message = reset_password(email, mail)
        return jsonify({'message': message}), 200 if result else 404
    return jsonify({'message': 'Method not allowed'}), 405

def reset_password(email, mail):
    client = connect_to_mongo()
    db = client.MusicDB
    UserInfo_collection = db.UserInfo

    user = UserInfo_collection.find_one({'email': email})

    if user:
        new_password = generate_random_password()
        UserInfo_collection.update_one({'_id': user['_id']}, {'$set': {'userPassword': new_password}})
        if send_password_reset_email(email, new_password, mail):
            return True, 'Password reset successful. Check your email for the new password.'
        else:
            return False, 'Failed to send password reset email.'
    else:
        return False, 'User not found with the provided email address.'


def generate_random_password():
    # Rastgele 10 karakterlik bir şifre oluştur
    return ''.join(random.choices(string.ascii_letters + string.digits, k=10))

def send_password_reset_email(email, new_password, mail):
    try:
        msg = Message('Password Reset', recipients=[email])
        msg.body = f"Your password has been reset. Your new password is: {new_password}"
        mail.send(msg)
        return True
    except Exception as e:
        print(f"Error sending email: {str(e)}")
        return False

@app.route('/change_password', methods=['POST'])
def change_password():
    if request.method == 'POST':
        # Check if the user is logged in
        current_user = get_current_user()

        if current_user:
            current_password = request.form['current_password']
            new_password = request.form['new_password']
            if not new_password:
                return jsonify({'message': 'New password cannot be empty'}), 400
            
            # Check if the provided current password matches the user's actual password
            if current_user['userPassword'] == current_password:
                # Replace this with your MongoDB connection
                client = connect_to_mongo()
                db = client.MusicDB
                UserInfo_collection = db.UserInfo

                # Update the user's password in the database
                UserInfo_collection.update_one({'_id': current_user['_id']}, {'$set': {'userPassword': new_password}})

                return jsonify({'message': 'Password changed successfully'})

            return jsonify({'message': 'Invalid current password'}), 401

        return jsonify({'message': 'User not logged in'}), 401

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
        access_token = get_spotify_token()
        # Unpack the tuple and access the dictionary
        top_tracks_response_dict = top_tracks_response[0]

        if 'output' in top_tracks_response_dict and 'tracks' in top_tracks_response_dict['output']:
            top_tracks = top_tracks_response_dict['output']['tracks']

            for track_object in top_tracks:
                # Get track ID
                track_id = track_object.get('id')
                if not track_id:
                    continue

                # Use Spotify API to get audio features
                audio_features_url = f'https://api.spotify.com/v1/audio-features?ids={track_id}'
                headers = {
                "Authorization": f"Bearer {access_token}"
                }

                response = requests.get(audio_features_url, headers=headers)
                audio_features = response.json()

                if 'audio_features' in audio_features and audio_features['audio_features']:
                    # Extract relevant attributes from audio features
                    features = audio_features['audio_features'][0]
                    danceability = features.get('danceability')
                    energy = features.get('energy')
                    instrumentalness = features.get('instrumentalness')

                    # Add these attributes to the track_object
                    track_object['danceability'] = danceability
                    track_object['energy'] = energy
                    track_object['instrumentalness'] = instrumentalness

                    # Add the modified track_object to the database
                    add_track_to_db(track_object, client)
            return 'Success'
        else:
            return 'Failed'
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

        # Check if the song is already in the likedSongs
        existing_entry = next((entry for entry in user['likedSongs'] if entry['song'] == song_name), None)

        if existing_entry:
            return jsonify({'message': 'Song already in likedSongs'}), 400

        # Search for the song in the Track collection to get its artist
        track = Track_collection.find_one({'name': song_name})

        if track is None:
            return jsonify({'message': f'Song "{song_name}" not found in the database'}), 404

        # Get the artist from the track
        artist_name = track['artists'][0]['name'] if 'artists' in track and track['artists'] else None

        if artist_name is None:
            return jsonify({'message': f'Artist not found for song "{song_name}"'}), 404

        # Add the new entry to likedSongs with a null rating
        new_entry = {'song': song_name, 'artist': artist_name, 'liked_at': format(datetime.utcnow()), 'rating': None}
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

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo
        Track_collection = db.Track

        # Check if the user has already liked the song
        existing_entry = next((entry for entry in current_user['likedSongs'] if entry['song'] == song_name), None)

        # Fetch the artist from the track
        track_info = Track_collection.find_one({'name': song_name})
        if track_info:
            artist_name = track_info['artists'][0]['name'] if 'artists' in track_info and track_info['artists'] else None
        else:
            artist_name = None

        if existing_entry:
            # Song is already in likedSongs, update the entry with the rating
            existing_entry['rating'] = rating
            existing_entry['artist'] = artist_name
        else:
            # Song is not in likedSongs, add a new entry with the rating
            new_entry = {'song': song_name, 'artist': artist_name, 'liked_at': format(datetime.utcnow()), 'rating': rating}
            current_user['likedSongs'].append(new_entry)

        # Add the rated song information to the user's document in the rated_songs list
        UserInfo_collection.update_one(
            {'username': current_user['username']},
            {'$push': {'rated_songs': {song_name: rating}}}
        )

        # Update the user's document with the modified likedSongs
        result = UserInfo_collection.update_one(
            {'username': current_user['username']},
            {'$set': {'likedSongs': current_user['likedSongs']}}
        )

        if result.modified_count == 1:
            return jsonify({'message': f'Successfully rated the song {song_name} by {artist_name} with {rating} stars'})
        else:
            return jsonify({'message': f'Failed to update rating for song {song_name}'}), 500

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500


    
@app.route('/remove_from_liked_songs', methods=['POST'])
def remove_from_liked_songs():
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

        # Check if the user exists
        user = UserInfo_collection.find_one({'username': username})
        if user is None:
            return jsonify({'message': 'User not found'}), 404

        # Check if the song is in likedSongs
        existing_entry = next((entry for entry in user['likedSongs'] if entry['song'] == song_name), None)

        if existing_entry:
            # Remove the entry from likedSongs
            UserInfo_collection.update_one({'username': username}, {'$pull': {'likedSongs': {'song': song_name}}})
            return jsonify({'message': f'Song "{song_name}" removed from likedSongs'})
        else:
            return jsonify({'message': f'Song "{song_name}" not found in likedSongs'}), 404

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500


# Endpoint to remove a track from the playlist
@app.route('/remove_from_playlist', methods=['POST'])
def remove_from_playlist():
    try:
        # Get the current user from the session
        username = session.get('username')
        if not username:
            return jsonify({'message': 'User is not logged in'}), 400

        # Get the track name and playlist name from the request body
        name = request.form.get('track_name')
        playlist_name = request.form.get('playlist_name')

        if not name or not playlist_name:
            return jsonify({'message': 'Required data is missing in the form data'}), 400

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo

        # Check if the user exists
        user = UserInfo_collection.find_one({'username': username})
        if user is None:
            return jsonify({'message': 'User not found'}), 404

        # Check if the playlist exists within the user's playlists
        playlist = next((pl for pl in user.get('playlists', []) if pl['playlist_name'] == playlist_name), None)
        if not playlist:
            return jsonify({'message': f'Playlist "{playlist_name}" not found in user\'s playlists'}), 404

        # Check if the track exists within the playlist
        track_exists = any(tr['name'] == name for tr in playlist.get('tracks', []))
        if not track_exists:
            return jsonify({'message': f'Track "{name}" not found in the playlist "{playlist_name}"'}), 404

        # Remove the track from the playlist
        playlist['tracks'] = [tr for tr in playlist['tracks'] if tr['name'] != name]

        # Update the user's document with the modified playlists
        result = UserInfo_collection.update_one(
            {'username': username},
            {'$set': {'playlists': user['playlists']}}
        )

        if result.modified_count == 1:
            return jsonify({'message': f'Track "{name}" removed from the playlist "{playlist_name}" successfully'})
        else:
            return jsonify({'message': f'Failed to remove track "{name}" from the playlist "{playlist_name}"'})

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
            'likedSongs': [dict(entry) for entry in target_user['likedSongs']],
            'rated_songs': [dict(entry) for entry in target_user['rated_songs']],  # Convert to a list of dictionaries
            'playlists': [],
            'likedPlaylists': []
        }

        # Add playlists to the profile_info
        if 'playlists' in target_user:
            profile_info['playlists'] = [
                {
                    'playlist_name': playlist['playlist_name'],
                    'tracks': playlist.get('tracks', [])  # Use get to handle the case where 'tracks' is not present
                }
                for playlist in target_user['playlists']
            ]

        # Add likedPlaylists to the profile_info
        if 'likedPlaylists' in target_user:
            profile_info['likedPlaylists'] = target_user['likedPlaylists']

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
                # Create the new playlist object with an empty list of tracks and initialize likes to 0
                new_playlist = {
                    'playlist_name': playlist_name,
                    'tracks': [],
                    'likes': 0  # Initialize likes to 0
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

##################################### COLLABORATIVE PLAYLIST#########################
# Endpoint to create a collaborative playlist
@app.route('/create_collaborative_playlist', methods=['POST'])
def create_collaborative_playlist():
    try:
        # Get the current user from the session
        current_user = get_current_user()
        if not current_user:
            return jsonify({'message': 'User is not logged in'}), 401

        # Get the playlist name from the request
        playlist_name = request.form.get('playlist_name')
        if not playlist_name:
            return jsonify({'message': 'Playlist name is missing in the request'}), 400

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        CollaborativePlaylist_collection = db.CollaborativePlaylist
        UserInfo_collection = db.UserInfo

        # Check if the playlist already exists
        existing_playlist = CollaborativePlaylist_collection.find_one({'name': playlist_name})
        if existing_playlist:
            return jsonify({'message': f'Playlist "{playlist_name}" already exists'}), 400

        # Create the collaborative playlist
        playlist_data = {
            'name': playlist_name,
            'owner': [{'id': current_user['_id'], 'name': current_user['username']}],
            'members': [{'id': current_user['_id'], 'name': current_user['username']}],
            'created_at': format(datetime.utcnow()),
            'likes': 0,
            'songs': []  # You can extend this for collaborative songs
        }

        playlist_id = CollaborativePlaylist_collection.insert_one(playlist_data).inserted_id

        # Update the user's playlists attribute
        UserInfo_collection.update_one(
            {'username': current_user['username']},
            {'$push': {'playlists': {
                'playlist_name': playlist_name,
                'playlist_id': str(playlist_id),
                'owner': [{'id': str(current_user['_id']), 'name': current_user['username']}],
                'members': [{'id': str(current_user['_id']), 'name': current_user['username']}],
                'likes':0,
                'songs': []
            }}}
        )

        return jsonify({'message': f'Collaborative playlist "{playlist_name}" created successfully'})

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

# Endpoint to invite users to a collaborative playlist
@app.route('/invite_to_collaborative_playlist', methods=['POST'])
def invite_to_collaborative_playlist():
    try:
        # Get the current user from the session
        current_user = get_current_user()
        if not current_user:
            return jsonify({'message': 'User is not logged in'}), 401

        # Get the playlist name and friend's username from the request
        playlist_name = request.form.get('playlist_name')
        friend_username = request.form.get('friend_username')
        if not playlist_name or not friend_username:
            return jsonify({'message': 'Playlist name or friend username is missing in the request'}), 400

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        CollaborativePlaylist_collection = db.CollaborativePlaylist
        UserInfo_collection = db.UserInfo

        # Check if the playlist exists
        playlist = CollaborativePlaylist_collection.find_one({'name': playlist_name})
        if not playlist:
            return jsonify({'message': f'Playlist "{playlist_name}" does not exist'}), 404

        # Check if the user is the owner of the playlist
        if (
            playlist['owner'] and
            current_user['_id'] != ObjectId(playlist['owner'][0]['id']) and
            current_user['name'] != playlist['owner'][0]['name']
        ): 

            return jsonify({'message': 'Only the owner can invite users to the playlist'}), 403

        # Check if the friend exists
        friend = UserInfo_collection.find_one({'username': friend_username})
        if not friend:
            return jsonify({'message': f'User "{friend_username}" not found'}), 404

        # Check if the friend is already a member of the playlist
        if friend['_id'] in [member['id'] for member in playlist.get('members', [])]:
            return jsonify({'message': f'User "{friend_username}" is already a member of the playlist'}), 400


        # Add the friend to the playlist
        CollaborativePlaylist_collection.update_one(
            {'_id': playlist['_id']},
            {'$push': {'members': {'id': friend['_id'], 'name': friend['username']}}}
        )
        # Get the updated list of members
        updated_playlist = CollaborativePlaylist_collection.find_one({'_id': playlist['_id']})
        member_details = []

        for member_id in updated_playlist.get('members', []):
            if member_id is not None:
                # Extract user_id and user_name from the member_id dictionary
                user_id = member_id.get('id', '')
                user_name = member_id.get('name')
                
                if user_id:
                    member_details.append({'id': str(user_id), 'name': user_name})

        # Update the collaborative playlist in the user's playlists attribute
        user_query = {'username': current_user['username'], 'playlists.playlist_name': playlist_name}
        user_update = {'$set': {'playlists.$[].members': member_details}}

        UserInfo_collection.update_one(user_query, user_update)

        return jsonify({
            'message': f'User "{friend_username}" invited to playlist "{playlist_name}" successfully',
            'members': member_details
        })


    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500


# Endpoint to add a song to a collaborative playlist
@app.route('/add_to_collaborative_playlist', methods=['POST'])
def add_to_collaborative_playlist():
    try:
        # Get the current user from the session
        current_user = get_current_user()
        if not current_user:
            return jsonify({'message': 'User is not logged in'}), 401

        # Get the playlist name and song name from the request
        playlist_name = request.form.get('playlist_name')
        song_name = request.form.get('song_name')
        if not playlist_name or not song_name:
            return jsonify({'message': 'Playlist name or song name is missing in the request'}), 400

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        CollaborativePlaylist_collection = db.CollaborativePlaylist
        Track_collection = db.Track
        UserInfo_collection = db.UserInfo

        # Check if the playlist exists
        playlist = CollaborativePlaylist_collection.find_one({'name': playlist_name})
        if not playlist:
            return jsonify({'message': f'Playlist "{playlist_name}" does not exist'}), 404

        # Check if the user is a member of the playlist
        if current_user['_id'] not in [member['id'] for member in playlist.get('members', [])]:
            return jsonify({'message': 'User is not a member of the playlist'}), 403

        # Check if the song exists
        song = Track_collection.find_one({'name': song_name})
        if not song:
            return jsonify({'message': f'Song "{song_name}" does not exist'}), 404

        # Add the song to the playlist
        CollaborativePlaylist_collection.update_one(
            {'_id': playlist['_id']},
            {'$push': {'songs': {'name': song_name, 'added_by': current_user['_id'], 'added_at': '{}'.format(datetime.utcnow())}}}
        )

        # Get the updated list of members
        updated_playlist = CollaborativePlaylist_collection.find_one({'_id': playlist['_id']})
        member_details = []

        for member_id in updated_playlist.get('members', []):
            member = UserInfo_collection.find_one({'_id': member_id})
            if member:
                member_details.append({'id': str(member_id), 'name': member['username']})

        # Update the collaborative playlist in the user's playlist attribute
        user_query = {'username': current_user['username'], 'playlists.playlist_name': playlist_name}
        user_update = {'$set': {'playlists.$[].members': member_details, 'playlists.$[].songs': updated_playlist.get('songs', [])}}

        UserInfo_collection.update_one(user_query, user_update)

        return jsonify({
            'message': f'Song "{song_name}" added to playlist "{playlist_name}" successfully',
            'members': member_details
        })

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
                            "genres": []  # Omitting genres for simplicity
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

        # Connect to MongoDB
        client = connect_to_mongo()

        # Example: Insert tracks into MongoDB
        db = client.MusicDB
        track_collection = db.Track
        inserted_data = track_collection.insert_many(extracted_data)

        return jsonify({"inserted_data": str(inserted_data.inserted_ids)})
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"})


@app.route('/add_track_man', methods=['POST'])
def add_track():
    try:
        # Collect form data
        track_data = {
            "album": {
                "id": request.form.get('album_id'),
                "name": request.form.get('album_name'),
                "release_date": request.form.get('release_date')
            },
            "artists": [
                {
                    "id": request.form.get('artist_id'),
                    "name": request.form.get('artist_name'),
                    "genres": []  # Omitting genres for simplicity
                }
                for _ in range(int(request.form.get('num_artists', 0)))  # Default to 0 if 'num_artists' is not present
            ],
            "duration_ms": int(request.form.get('duration_ms', 0)),  # Default to 0 if 'duration_ms' is not present
            "id": request.form.get('track_id'),
            "name": request.form.get('track_name'),
            "popularity": int(request.form.get('popularity', 0))  # Default to 0 if 'popularity' is not present
        }

        # Connect to MongoDB
        client = connect_to_mongo()

        # Insert track into MongoDB
        db = client.MusicDB
        track_collection = db.Track
        insert_result = track_collection.insert_one(track_data)

        return jsonify({"message": "Track added successfully", "track_id": str(insert_result.inserted_id)})
    except Exception as e:
        return jsonify({"error": f"An error occurred: {str(e)}"})



##################################### ANALYSİS#############################
    # Endpoint to get the last added songs and top songs from different artists in the last day
# Endpoint to get 10 songs from different artists added in the last day
@app.route('/get_last_day_songs', methods=['GET'])
def get_last_day_songs():
    try:
        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        Track_collection = db.Track

        # Calculate the timestamp for 24 hours ago
        last_day_timestamp = datetime.utcnow() - timedelta(days=1)

       # Fetch 10 songs from different artists added in the last day
        last_day_songs = Track_collection.aggregate([
            {'$match': {'added_at': {'$gte': last_day_timestamp.strftime("%Y-%m-%d %H:%M:%S")}}},
            {'$group': {'_id': '$artists', 'song': {'$first': '$name'}}},
            {'$project': {'song_name': '$song', 'artist_name': {'$arrayElemAt': ['$_id.name', 0]}, 'genre': {'$arrayElemAt': ['$_id.genres', 0]}}},
            {'$limit': 10}
        ])

        # Convert the cursor to a list for easier JSON serialization
        last_day_songs_list = list(last_day_songs)

        # You can customize the response format based on your requirements
        response_data = {
            'last_day_songs': [{'genre': song.get('genre', 'Unknown'), 'artist_name': song['artist_name'], 'song_name': song['song_name']} for song in last_day_songs_list]
        }
        return response_data
    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500
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
        username = request.args.get('username')
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
    

# Endpoint to analyze user's liked songs for happiness
@app.route('/analyze_user_mode', methods=['GET'])
def analyze_user_happiness():
    try:
        user = get_current_user()
         # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo
        Track_collection = db.Track
        liked_songs = user.get('likedSongs', [])

        if not liked_songs:
            return jsonify({'message': 'User has no liked songs'}), 400

        # Fetch danceability and energy for the liked songs
        liked_songs_info = []
        for liked_song in liked_songs:
            song_name = liked_song.get('song')
            if song_name:
                track_info = Track_collection.find_one({'name': song_name})
                if track_info:
                    liked_songs_info.append({
                        'song_name': song_name,
                        'danceability': track_info.get('danceability', 0.0),
                        'energy': track_info.get('energy', 0.0)
                    })

        # Analyze danceability and energy for happiness and sadness
        happy_songs = [song_info for song_info in liked_songs_info if song_info['danceability'] > 0.5 and song_info['energy'] > 0.5]
        sad_songs = [song_info for song_info in liked_songs_info if song_info['danceability'] <= 0.5 and song_info['energy'] <= 0.5]

        result = {
            'message': 'User has more happy songs' if len(happy_songs) > len(sad_songs) else 'User has more sad songs',
            'happy_songs': happy_songs,
            'sad_songs': sad_songs
        }

        return jsonify(result)

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
    


# Endpoint to recommend tracks for an Energetic Playlist
@app.route('/recommend_energetic_playlist', methods=['GET'])
def recommend_energetic_playlist():
    try:
        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo
        Track_collection = db.Track
        # Get energetic tracks with high danceability and energy
        energetic_tracks = Track_collection.find({
            'danceability': {'$gte': 0.7},  # Adjust threshold as needed
            'energy': {'$gte': 0.7}  # Adjust threshold as needed
        }).limit(10)  # Limit the number of recommended tracks

         # Extract only the song name and artist from the tracks
        recommendations = [
            {'song_name': track['name'], 'artist': track['artists'][0]['name']}
            for track in energetic_tracks
        ]

        return jsonify({'recommendations': recommendations})
    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500


# Endpoint to recommend tracks for a Relaxing Playlist
@app.route('/recommend_relaxing_playlist', methods=['GET'])
def recommend_relaxing_playlist():
    try:
        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo
        Track_collection = db.Track
        # Get relaxing tracks with low danceability and energy
        relaxing_tracks = Track_collection.find({
            'danceability': {'$lt': 0.4},  
            'energy': {'$lt': 0.4}  
        }).limit(10)  # Limit the number of recommended tracks

         # Extract only the song name and artist from the tracks
        recommendations = [
            {'song_name': track['name'], 'artist': track['artists'][0]['name']}
            for track in relaxing_tracks
        ]

        return jsonify({'recommendations': recommendations})

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

# Endpoint to recommend a playlist based on the same artist
@app.route('/recommend_playlist', methods=['GET'])
def recommend_playlist():
    try:
        # Check if the user is logged in
        current_user = get_current_user()
        if current_user is None:
            return jsonify({'message': 'User not logged in'}), 401

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo
        Track_collection = db.Track

        # Get the user's liked artists
        liked_artists = set()
        for liked_song in current_user['likedSongs']:
            artist_name = liked_song.get('artist')
            if artist_name:
                liked_artists.add(artist_name)

        if not liked_artists:
            return jsonify({'message': 'User has not liked any songs yet'}), 400

        # Find other tracks by the same artists
        recommended_tracks = []
        for artist_name in liked_artists:
            artist_tracks = Track_collection.find({
                'artists.name': artist_name,
                'name': {'$nin': [liked_song['song'] for liked_song in current_user['likedSongs']]}
            }).limit(5)  # Limit the number of recommended tracks per artist

            recommended_tracks.extend(list(artist_tracks))

        # Extract relevant information for the recommended tracks
        recommendations = [{
            'song_name': track['name'],
            'artist': track['artists'][0]['name'] if 'artists' in track and track['artists'] else None
        } for track in recommended_tracks]

        return jsonify({'recommendations': recommendations})

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500
    

#FRIENDSHIP ACTIVITY
############################
# Endpoint to add a playlist to the likedPlaylists array
@app.route('/like_playlist', methods=['POST'])
def like_playlist():
    try:
        # Get the current user from the session
        username = session.get('username')
        friend_username = request.form.get('friend_username')  # The owner of the playlist
        playlist_name = request.form.get('playlist_name')

        if not username or not friend_username or not playlist_name:
            return jsonify({'message': 'Required data is missing in the form data'}), 400

        # Connect to the database
        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo

        # Check if the user exists
        user = UserInfo_collection.find_one({'username': username})
        if user is None:
            return jsonify({'message': 'User not found'}), 404

        # Check if the friend (owner of the playlist) exists
        friend = UserInfo_collection.find_one({'username': friend_username})
        if friend is None:
            return jsonify({'message': 'Friend not found'}), 404
        # Check if the playlist exists within the friend's playlists
        friend_playlists = friend.get('playlists', [])
        playlist_exists = any(pl['playlist_name'] == playlist_name for pl in friend_playlists)

        if not playlist_exists:
            return jsonify({'message': f'Playlist "{playlist_name}" not found in friend\'s playlists'}), 404

        # Check if the playlist is already in likedPlaylists
        existing_entry = next(
            (entry for entry in user.get('likedPlaylists', []) if entry.get('friend') == friend_username and entry.get('playlist_name') == playlist_name),
            None
        )
        # Increment the likes for the liked playlist
        UserInfo_collection.update_one(
            {'username': friend_username, 'playlists.playlist_name': playlist_name},
            {'$inc': {'playlists.$.likes': 1}}
        )

        if existing_entry:
            return jsonify({'message': 'Playlist already in likedPlaylists'}), 400

        # Add the new entry to likedPlaylists
        new_entry = {'friend': friend_username, 'playlist_name': playlist_name}
        UserInfo_collection.update_one({'username': username}, {'$push': {'likedPlaylists': new_entry}})

        return jsonify({'message': f'Playlist "{playlist_name}" by "{friend_username}" added to likedPlaylists'})
    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500


       
                           
    

        
# Endpoint to get the last added liked song from the first friend
@app.route('/recommend_last_liked_song_from_first_friend', methods=['GET'])
def recommend_last_liked_song_from_first_friend():
    try:
        # Get the current user from the session
        current_user = session.get('username')
        if not current_user:
            return jsonify({'message': 'User not logged in'}), 401

        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo
        user_document = UserInfo_collection.find_one({'username': current_user})
        
        if user_document:
            following_list = user_document.get('following', [])

        if not following_list:
            return jsonify({'message': 'User is not following anyone'}), 400

        # Choose the first friend from the following list
        first_friend_username = following_list[0]

        # Get the last added liked song from the first friend's liked songs
        last_liked_song = get_last_liked_song(first_friend_username)

        if last_liked_song:
            track_name = last_liked_song['song']
            artist_name = last_liked_song['artist']

            return jsonify({'friend': first_friend_username, 'added': track_name, 'by': artist_name})
        else:
            return jsonify({'message': f'No liked songs found for {first_friend_username}'}), 404

    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

# Helper function to get the last liked song for a friend
def get_last_liked_song(friend_username):
    client = connect_to_mongo()
    db = client.MusicDB
    UserInfo_collection = db.UserInfo
    friend_document = UserInfo_collection.find_one({'username': friend_username})

    if friend_document:
        liked_songs = friend_document.get('likedSongs', [])
        if liked_songs:
            # Sort the liked songs by the liked_at timestamp in descending order
            sorted_liked_songs = sorted(liked_songs, key=lambda x: x['liked_at'], reverse=True)
            return sorted_liked_songs[0]

    return None

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
