from flask import Flask, jsonify, request, session

import requests
import json 
import secrets
from bson import ObjectId
import random
import string


app = Flask(_name_)
app.secret_key = 'ygmr2002'


# Dictionary to track logged-in users
logged_in_users = {}







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
    # Create a new client and connect to the server
    client = MongoClient(uri, server_api=ServerApi('1'))
    # Send a ping to confirm a successful connection
    try:
        client.admin.command('ping')
        print("Pinged your deployment. You successfully connected to MongoDB!")
        return client
    except Exception as e:
        print(e)
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
            session[username] = True
            return jsonify({'message': 'Login successful'})
        else:
            return jsonify({'message': 'Invalid username or password'}), 401
    else:
        return jsonify({'message': 'Bad Request - Missing credentials'}), 400


@app.route('/logout', methods=['POST'])
def logout():
    # Check if the user is logged in
    username = request.form['username']
    if username in session:
        # Clear the user from the session
        session.pop(username, None)
        return jsonify({'message': 'Logout successful'})
    else:
        return jsonify({'message': 'User not logged in'}), 401

'''@app.route('/signup', methods=['POST'])
def signup():
    username = request.form['username']
    password = request.form['password']
    return 'Signing up %s with password %s' % ((username), (password))
######################################'''
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
            'likedSongs': []
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
def search_song():
    term = request.args.get('song_name')
    # Process the search term and return results
    return 'Results for: {}'.format(term)


@app.route('/get_users_liked_songs')
def liked_songs_of_user():
    term = request.args.get('username')
    # Process the search term and return results
    return 'Liked songs of: [{}]'.format(term)
######################################




 

if _name_ == "_main_":
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
