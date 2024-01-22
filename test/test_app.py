# Using pytest
import sys
sys.path.append(r'C:\Users\yamur\Desktop\308')

import pytest
import app
from pytest import fixture


@fixture
def mocker():
    from unittest.mock import MagicMock
    return MagicMock()

@pytest.fixture
def client():
    with app.test_client() as test_client:
        yield test_client
################LOGIN###########################
def test_login_success(client):
    response = client.post('/login', data={'username': 'yagmurdolunay', 'password': 'ygmr02'})
    assert response.status_code == 200
    assert response.json['message'] == 'Login successful'

############################# artıst part###############################3
import pytest
from unittest.mock import patch, MagicMock
from app import app, get_artist_id, get_artist_info, add_artist_to_db

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

@patch('app.connect_to_mongo')
@patch('app.get_spotify_token')
def test_add_artist_info_to_db_success(mock_get_spotify_token, mock_connect_to_mongo, client):
    mock_connect_to_mongo.return_value = MagicMock()
    mock_get_spotify_token.return_value = 'fake_token'

    with patch('app.get_artist_id', return_value='fake_artist_id'), \
         patch('app.get_artist_info', return_value={'name': 'Fake Artist', 'genres': ['Pop'], 'popularity': 80, 'followers': 1000, 'images': [{'url': 'fake_url'}]}):
        
        response = client.get('/add_artist_to_db/FakeArtist')

    assert response.data == b'Success'
    assert response.status_code == 200

@patch('app.connect_to_mongo')
@patch('app.get_spotify_token')
def test_add_artist_info_to_db_artist_not_found(mock_get_spotify_token, mock_connect_to_mongo, client):
    mock_connect_to_mongo.return_value = MagicMock()
    mock_get_spotify_token.return_value = 'fake_token'

    with patch('app.get_artist_id', return_value=None):
        response = client.get('/add_artist_to_db/NonExistentArtist')

    assert response.data == b'Artist not found on Spotify'
    assert response.status_code == 200

@patch('app.connect_to_mongo')
@patch('app.get_spotify_token')
def test_add_artist_info_to_db_exception(mock_get_spotify_token, mock_connect_to_mongo, client):
    mock_connect_to_mongo.return_value = MagicMock()
    mock_get_spotify_token.side_effect = Exception('Test Exception')

    response = client.get('/add_artist_to_db/SomeArtist')

    assert response.data == b'Failed'
    assert response.status_code == 200

@patch('app.connect_to_mongo')
def test_get_artist_profile_endpoint_success(mock_connect_to_mongo, client):
    mock_connect_to_mongo.return_value = MagicMock()

    with patch('app.Artist_collection.find_one', return_value={'name': 'Fake Artist', 'genres': ['Pop'], 'popularity': 80, 'followers': 1000}):
        response = client.get('/get_artist_profile?artist_name=FakeArtist')

    expected_response = {
        'artist_profile_info': {
            'name': 'Fake Artist',
            'genres': ['Pop'],
            'popularity': 80,
            'followers': 1000
        }
    }

    assert response.json == expected_response
    assert response.status_code == 200

@patch('app.connect_to_mongo')
def test_get_artist_profile_endpoint_artist_not_found(mock_connect_to_mongo, client):
    mock_connect_to_mongo.return_value = MagicMock()

    with patch('app.Artist_collection.find_one', return_value=None):
        response = client.get('/get_artist_profile?artist_name=NonExistentArtist')

    expected_response = {'message': 'Target artist not found'}

    assert response.json == expected_response
    assert response.status_code == 404

@patch('app.connect_to_mongo')
def test_get_artist_profile_endpoint_missing_artist_name(mock_connect_to_mongo, client):
    mock_connect_to_mongo.return_value = MagicMock()

    response = client.get('/get_artist_profile')

    expected_response = {'message': 'Target artist name is missing in the request parameters'}

    assert response.json == expected_response
    assert response.status_code == 400


def test_get_artist_top_tracks(client):
    artist_name = "YourArtistName"
    response = client.get(f'/artist/{artist_name}/top-tracks?market=US')
    assert response.status_code == 200
    assert "output" in response.json

from unittest.mock import patch

@pytest.fixture
def client():
    with app.test_client() as test_client:
        yield test_client
###################SIGN UP#######################
@patch('app.connect_to_mongo')  # Mock the connect_to_mongo function
def test_signup_success(mock_db, client):
    # Mock database behavior
    mock_db.return_value.MusicDB.UserInfo.find_one.return_value = None

    response = client.post('/signup', data={
        'username': 'newUser',
        'password': 'pass123',
        'password2': 'pass123',
        'name': 'Test',
        'surname': 'User'
    })
    assert response.status_code == 200
    assert response.json['message'] == 'Signup successful'

@patch('app.connect_to_mongo')  # Mock the connect_to_mongo function
def test_signup_password_mismatch(mock_db, client):
    response = client.post('/signup', data={
        'username': 'newUser',
        'password': 'pass123',
        'password2': 'pass124',
        'name': 'Test',
        'surname': 'User'
    })
    assert response.status_code == 400
    assert response.json['message'] == 'Passwords do not match'

@patch('app.connect_to_mongo')  # Mock the connect_to_mongo function
def test_signup_existing_user(mock_db, client):
    # Mock existing user in database
    mock_db.return_value.MusicDB.UserInfo.find_one.return_value = {'username': 'existingUser'}

    response = client.post('/signup', data={
        'username': 'existingUser',
        'password': 'pass123',
        'password2': 'pass123',
        'name': 'Test',
        'surname': 'User'
    })
    assert response.status_code == 400
    assert response.json['message'] == 'Username already exists'

def test_signup_method_not_allowed(client):
    response = client.get('/signup')
    assert response.status_code == 405
    assert response.json['message'] == 'Method not allowed'

############## CREATE PLAYLIST###############

from unittest.mock import patch, MagicMock

@pytest.fixture
def client():
    with app.test_client() as test_client:
        with test_client.session_transaction() as session:
            yield test_client, session

@patch('app.connect_to_mongo')
def test_create_playlist_success(mock_connect_to_mongo, client):
    client, session = client
    session['username'] = 'yagmurdolunay'

    # Mock database behavior for a successful scenario
    mock_db = MagicMock()
    mock_connect_to_mongo.return_value = mock_db
    mock_db.MusicDB.UserInfo.find_one.return_value = {'username': 'yagmurdolunay'}

    response = client.post('/create_playlist', data={'playlist_name': 'My Playlist'})
    assert response.status_code == 200
    assert response.json['message'] == 'Playlist created successfully'

@patch('app.connect_to_mongo')
def test_create_playlist_user_not_found(mock_connect_to_mongo, client):
    client, session = client
    session['username'] = 'nonexistentuser'

    # Mock database behavior for user not found scenario
    mock_db = MagicMock()
    mock_connect_to_mongo.return_value = mock_db
    mock_db.MusicDB.UserInfo.find_one.return_value = None

    response = client.post('/create_playlist', data={'playlist_name': 'My Playlist'})
    assert response.status_code == 404
    assert response.json['message'] == 'User not found'

def test_create_playlist_user_not_logged_in(client):
    client, session = client

    # No username in session
    response = client.post('/create_playlist', data={'playlist_name': 'My Playlist'})
    assert response.status_code == 401
    assert response.json['message'] == 'User not logged in or no provided playlist name'

@patch('app.connect_to_mongo')
def test_create_playlist_exception(mock_connect_to_mongo, client):
    client, session = client
    session['username'] = 'yagmurdolunay'

    # Mock an exception during database interaction
    mock_connect_to_mongo.side_effect = Exception("Database error")

    response = client.post('/create_playlist', data={'playlist_name': 'My Playlist'})
    assert response.status_code == 500
    assert response.json['message'] == 'Error: Database error'



############################## RATE SONG ##############################
import pytest
from app import app
from unittest.mock import patch, MagicMock
from datetime import datetime

@pytest.fixture
def client():
    with app.test_client() as test_client:
        with test_client.session_transaction() as session:
            yield test_client, session

@patch('app.get_current_user')
@patch('app.connect_to_mongo')
def test_rate_song_user_not_logged_in(mock_connect_to_mongo, mock_get_current_user, client):
    client, _ = client
    mock_get_current_user.return_value = None

    response = client.post('/rate_song', data={'song_name': 'Some Song', 'rating': 5})
    assert response.status_code == 401
    assert response.json['message'] == 'User not logged in'

@patch('app.get_current_user')
@patch('app.connect_to_mongo')
def test_rate_song_missing_data(mock_connect_to_mongo, mock_get_current_user, client):
    client, _ = client
    mock_get_current_user.return_value = {'username': 'testuser', 'likedSongs': []}

    response = client.post('/rate_song', data={'song_name': 'Some Song'})
    assert response.status_code == 400
    assert response.json['message'] == 'Song name or rating is missing in the request body'

@patch('app.get_current_user')
@patch('app.connect_to_mongo')
def test_rate_song_success(mock_connect_to_mongo, mock_get_current_user, client):
    client, _ = client
    mock_get_current_user.return_value = {'username': 'testuser', 'likedSongs': []}
    mock_db = MagicMock()
    mock_connect_to_mongo.return_value = mock_db
    mock_db.MusicDB.Track.find_one.return_value = {'name': 'Some Song', 'artists': [{'name': 'Some Artist'}]}

    response = client.post('/rate_song', data={'song_name': 'Some Song', 'rating': 5})
    assert response.status_code == 200
    assert 'Successfully rated the song Some Song by Some Artist with 5 stars' in response.json['message']

######################### COLLABORATIVE PLAYLIST##############################

from datetime import datetime

@pytest.fixture
def client():
    with app.test_client() as test_client:
        with test_client.session_transaction() as session:
            yield test_client, session

@patch('app.get_current_user')
@patch('app.connect_to_mongo')
def test_create_collaborative_playlist_user_not_logged_in(mock_connect_to_mongo, mock_get_current_user, client):
    client, _ = client
    mock_get_current_user.return_value = None

    response = client.post('/create_collaborative_playlist', data={'playlist_name': 'Test Playlist'})
    assert response.status_code == 401
    assert response.json['message'] == 'User is not logged in'

@patch('app.get_current_user')
@patch('app.connect_to_mongo')
def test_create_collaborative_playlist_missing_playlist_name(mock_connect_to_mongo, mock_get_current_user, client):
    client, _ = client
    mock_get_current_user.return_value = {'_id': '123', 'username': 'testuser'}

    response = client.post('/create_collaborative_playlist')
    assert response.status_code == 400
    assert response.json['message'] == 'Playlist name is missing in the request'

@patch('app.get_current_user')
@patch('app.connect_to_mongo')
def test_create_collaborative_playlist_already_exists(mock_connect_to_mongo, mock_get_current_user, client):
    client, _ = client
    mock_get_current_user.return_value = {'_id': '123', 'username': 'testuser'}
    mock_db = MagicMock()
    mock_connect_to_mongo.return_value = mock_db
    mock_db.MusicDB.CollaborativePlaylist.find_one.return_value = {'name': 'Test Playlist'}

    response = client.post('/create_collaborative_playlist', data={'playlist_name': 'Test Playlist'})
    assert response.status_code == 400
    assert response.json['message'] == 'Playlist "Test Playlist" already exists'

@patch('app.get_current_user')
@patch('app.connect_to_mongo')
def test_create_collaborative_playlist_success(mock_connect_to_mongo, mock_get_current_user, client):
    client, _ = client
    mock_get_current_user.return_value = {'_id': '123', 'username': 'testuser'}
    mock_db = MagicMock()
    mock_connect_to_mongo.return_value = mock_db
    mock_db.MusicDB.CollaborativePlaylist.find_one.return_value = None

    response = client.post('/create_collaborative_playlist', data={'playlist_name': 'New Playlist'})
    assert response.status_code == 200
    assert response.json['message'] == 'Collaborative playlist "New Playlist" created successfully'

@patch('app.get_current_user')
@patch('app.connect_to_mongo')
def test_create_collaborative_playlist_exception(mock_connect_to_mongo, mock_get_current_user, client):
    client, _ = client
    mock_get_current_user.return_value = {'_id': '123', 'username': 'testuser'}
    mock_connect_to_mongo.side_effect = Exception("Database error")

    response = client.post('/create_collaborative_playlist', data={'playlist_name': 'New Playlist'})
    assert response.status_code == 500
    assert response.json['message'] == 'Error: Database error'

from bson import ObjectId
from datetime import datetime

@pytest.fixture
def client():
    with app.test_client() as test_client:
        with test_client.session_transaction() as session:
            yield test_client, session

# Tests for /invite_to_collaborative_playlist
@patch('app.get_current_user')
@patch('app.connect_to_mongo')
def test_invite_to_collaborative_playlist_user_not_logged_in(mock_connect_to_mongo, mock_get_current_user, client):
    client, _ = client
    mock_get_current_user.return_value = None

    response = client.post('/invite_to_collaborative_playlist', data={'playlist_name': 'Test Playlist', 'friend_username': 'friend'})
    assert response.status_code == 401
    assert response.json['message'] == 'User is not logged in'



# Tests for /add_to_collaborative_playlist
@patch('app.get_current_user')
@patch('app.connect_to_mongo')
def test_add_to_collaborative_playlist_user_not_logged_in(mock_connect_to_mongo, mock_get_current_user, client):
    client, _ = client
    mock_get_current_user.return_value = None

    response = client.post('/add_to_collaborative_playlist', data={'playlist_name': 'Test Playlist', 'song_name': 'Test Song'})
    assert response.status_code == 401
    assert response.json['message'] == 'User is not logged in'

########################################### LIKE SONG #############################
def test_add_to_liked_songs_success(client, mocker):
    # Mock necessary functions to simulate database operations
    mocker.patch('app.connect_to_mongo')
    mocker.patch('app.datetime.utcnow', return_value='2022-01-01T00:00:00.000000')

    # Set up test data
    username = 'test_user'
    song_name = 'Test Song'

    # Make a request to the endpoint
    response = client.post('/add_to_liked_songs', data={'song_name': song_name}, session={'username': username})

    # Assert the response status code
    assert response.status_code == 200

    # Assert the response message
    assert 'added to likedSongs' in response.json['message']

def test_add_to_liked_songs_missing_data(client):
    # Set up test data with missing form data
    response = client.post('/add_to_liked_songs', json={}, session={})


    # Assert the response status code
    assert response.status_code == 400

    # Assert the response message
    assert 'Required data is missing' in response.json['message']

def test_add_to_liked_songs_user_not_found(client, mocker):
    # Mock necessary functions to simulate database operations
    mocker.patch('app.connect_to_mongo')

    # Set up test data with a non-existent user
    response = client.post('/add_to_liked_songs', data={'song_name': 'Test Song'}, session={'username': 'nonexistent'})

    # Assert the response status code
    assert response.status_code == 404

    # Assert the response message
    assert 'User not found' in response.json['message']

######################### ANALYSIS ##############################################################


@pytest.fixture
def client():
    with app.test_client() as test_client:
        yield test_client
#################### release year #################################
def test_get_average_release_year_success(client, mocker):
    mocker.patch('app.connect_to_mongo')
    mocker.patch('app.Track_collection.find_one', return_value={'album': {'release_date': '2022-01-01'}})

    response = client.get('/get_average_release_year?username=gata')

    assert response.status_code == 200
    assert 'most liked average year' in response.json['message']

def test_get_average_release_year_missing_username(client):
    response = client.get('/get_average_release_year')

    assert response.status_code == 400
    assert 'Username is missing' in response.json['message']

def test_get_average_release_year_no_liked_songs(client, mocker):
    mocker.patch('app.connect_to_mongo')
    mocker.patch('app.UserInfo_collection.find_one', return_value={'likedSongs': []})

    response = client.get('/get_average_release_year?username=gata')

    assert response.status_code == 400
    assert 'User has not liked any songs' in response.json['message']
######################## user mood ################################
def test_analyze_user_happiness_success(client, mocker):
    mocker.patch('app.get_current_user', return_value={'likedSongs': [{'song': 'Happy Song', 'danceability': 0.8, 'energy': 0.9}]})
    mocker.patch('app.Track_collection.find_one', return_value={'danceability': 0.8, 'energy': 0.9})

    response = client.get('/analyze_user_mode')

    assert response.status_code == 200
    assert 'User has more happy songs' in response.json['message']

def test_analyze_user_happiness_no_liked_songs(client, mocker):
    mocker.patch('app.get_current_user', return_value={'likedSongs': []})

    response = client.get('/analyze_user_mode')

    assert response.status_code == 400
    assert 'User has no liked songs' in response.json['message']


 ################################## RECOMMENDATIONS #########################
import pytest
from app import app

@pytest.fixture
def client():
    with app.test_client() as test_client:
        yield test_client

def test_recommend_song_success(client, mocker):
    mocker.patch('app.connect_to_mongo')
    mocker.patch('app.Track_collection.find_one', return_value={'name': 'Recommended Song', 'artists': [{'name': 'Artist'}]})

    response = client.get('/recommend_song', session={'username': 'test_user'})

    assert response.status_code == 200
    assert 'recommended_song' in response.json

def test_recommend_song_user_not_logged_in(client):
    response = client.get('/recommend_song')

    assert response.status_code == 400
    assert 'User is not logged in' in response.json['message']

def test_recommend_song_no_rated_songs(client, mocker):
    mocker.patch('app.connect_to_mongo')
    mocker.patch('app.UserInfo_collection.find_one', return_value={'rated_songs': []})

    response = client.get('/recommend_song', session={'username': 'test_user'})

    assert response.status_code == 400
    assert 'User has not rated any songs' in response.json['message']



def test_recommend_energetic_playlist_success(client, mocker):
    mocker.patch('app.connect_to_mongo')
    mocker.patch('app.Track_collection.find', return_value=[
        {'name': 'Energetic Song 1', 'artists': [{'name': 'Artist1'}]},
        {'name': 'Energetic Song 2', 'artists': [{'name': 'Artist2'}]},
    ])

    response = client.get('/recommend_energetic_playlist')

    assert response.status_code == 200
    assert 'recommendations' in response.json



def test_recommend_relaxing_playlist_success(client, mocker):
    mocker.patch('app.connect_to_mongo')
    mocker.patch('app.Track_collection.find', return_value=[
        {'name': 'Relaxing Song 1', 'artists': [{'name': 'Artist1'}]},
        {'name': 'Relaxing Song 2', 'artists': [{'name': 'Artist2'}]},
    ])

    response = client.get('/recommend_relaxing_playlist')

    assert response.status_code == 200
    assert 'recommendations' in response.json


def test_recommend_playlist_success(client, mocker):
    mocker.patch('app.get_current_user', return_value={'likedSongs': [{'artist': 'Liked Artist'}]})
    mocker.patch('app.connect_to_mongo')
    mocker.patch('app.Track_collection.find', return_value=[
        {'name': 'Recommended Song 1', 'artists': [{'name': 'Liked Artist'}]},
        {'name': 'Recommended Song 2', 'artists': [{'name': 'Liked Artist'}]},
    ])

    response = client.get('/recommend_playlist')

    assert response.status_code == 200
    assert 'recommendations' in response.json

