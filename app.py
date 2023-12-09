from flask import Flask, jsonify, request, session
from datetime import timedelta
import certifi
import requests
import json 
import secrets
from bson import ObjectId
import random
import string


app = Flask(__name__)
app.secret_key = secrets.token_hex(16)

app.config['SECRET_KEY'] = 'ygmr2002'
app.config['SESSION_PERMANENT'] = True

app.config['PERMANENT_SESSION_LIFETIME'] = timedelta(minutes=30)  # Set as needed
app.config['SESSION_TYPE'] = 'redis'
app.config['SESSION_PERMANENT'] = True
app.config['SESSION_USE_SIGNER'] = True

# Dictionary to track logged-in users
logged_in_users = {}

@app.teardown_request
def teardown_request(exception=None):
    session.pop('username', None)





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

    return output


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
                "name": track['album']['name']
            },
            "artists": [
                {"id": artist['id'], "name": artist['name']}
                for artist in track['artists']
            ],
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

        client = connect_to_mongo()
        db = client.MusicDB
        UserInfo_collection = db.UserInfo

        # Check if the username already exists
        existing_user = UserInfo_collection.find_one({'username': username})
        if existing_user:
            return jsonify({'message': 'Username already exists'}), 400

        # Generate a random userID
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
            'rated_songs': [] 

            # Add other user-related fields as needed
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
    print(insert_result.inserted_id)



######################################
@app.route('/add_tracks_to_db/<artist_name>')
def add(artist_name):
    try:
        client = connect_to_mongo()
        loop = get_artist_top_tracks(artist_name)["tracks"]
        
        for object in loop:
            # print(object["id"])
            add_track_to_db(object, client)
        return 'Success'
    except Exception as e:
        return 'Failed'



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
        # Get data from the request
        username = request.form.get('username')
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
def get_followees_endpoint():
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
            'likedSongs': [str(song) for song in target_user['likedSongs']]
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
                'song': track['name'],
                'artist': track['artists'][0]['name'] if 'artists' in track and track['artists'] else None,
                'album': track['album'],
                'popularity': track['popularity'],
                # Add other attributes as needed
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
                'name': track['name'],
                'artists': track['artists'],
                'album': track['album'],
                'popularity': track['popularity'],
                # Add other attributes as needed
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

    # Her bir şarkıyı daha ayrıntılı bir şekilde işleyerek sonuçları oluştur
    formatted_results = []
    for result in results:
        formatted_result = {
            'name': result['name'],
            'artists': result['artists'],
            'album': result['album'],
            'popularity': result['popularity'],
            # İhtiyaca göre diğer özellikleri de ekleyebilirsiniz
        }
        formatted_results.append(formatted_result)

    # formatted_results listesini JSON formatına çevir
    return jsonify({'results': formatted_results})



######get user's liked songs#################

@app.route('/get_users_liked_songs')
def liked_songs_of_user():
    term = request.args.get('username')
    # Process the search term and return results
    return 'Liked songs of: [{}]'.format(term)
######################################




 

if __name__ == "__main__":
    app.secret_key = 'ygmr2002'
    app.run(host='0.0.0.0', port=105)






'''
# Post with body params example
@app.route('/echo', methods=['POST'])
def echo():
    data = request.json
    return jsonify(data)
'''

'''
    start = time.time()
    username = request.args.get('user_name')
    msg = "Successful"
    api_response = {}

    # cookie check
    insta.check_insta_cookies()

    # get_user_details
    try:
        user_id, followees, followers = insta.get_user_details(username)
        if (user_id == "User Not Found"):
            msg = "User not found!"
            api_response = {"message": msg}
            return api_response
    except Exception as e:
        msg = "get_user_details failed" + str(e)
        api_response = {"message": msg}
        return api_response

    processes = []
    manager = multiprocessing.Manager()
    return_dict = manager.dict()

    if False:
        #insta.follow(response)
        msg = "Follow request has been sent!"
        api_response = {"message": msg}
        print(msg)
    else:
        p1 = multiprocessing.Process(target = get_followees, args=(user_id, followees, username, return_dict))
        p2 = multiprocessing.Process(target = get_followers, args=(user_id, followers, username, return_dict))
        p1.start()
        p2.start()
        processes.append(p1)
        processes.append(p2)

        # Joins all the processes 
        for p in processes:
            p.join()

    api_response = {
        "name": response,
        "followees": return_dict["followees"],
        "followers": return_dict["followers"],
        "message": "Successful",
        "response_time" : time.time()-start
    }
    print("Succesful")
    print(time.time()-start)
    return jsonify(api_response)

def get_followees(user_id, followees, username, return_dict):
    return_dict["followees"] = insta.get_followees(user_id, followees, username)

def get_followers(user_id, followers, username, return_dict):
    return_dict["followers"] = insta.get_followers(user_id, followers, username)
'''
