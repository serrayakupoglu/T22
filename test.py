import unittest
from unittest.mock import patch
from app import app, get_artist, get_artist_genres, add_track_to_db

class TestFlaskApp(unittest.TestCase):

    @patch('app.get_spotify_token')
    @patch('requests.get')
    def test_get_artist(self, mock_requests_get, mock_get_spotify_token):
        # Mocking the get_spotify_token function
        mock_get_spotify_token.return_value = 'mock_token'

        # Mocking the requests.get function
        mock_response = {
            "artists": {"items": [{"id": "artist_id"}]}
        }
        mock_requests_get.return_value.json.return_value = mock_response

        # Run the get_artist function
        response = get_artist('artist_name')

        # Assert that the artist ID was retrieved successfully
        self.assertEqual(response, 'artist_id')

    @patch('app.get_spotify_token')
    @patch('requests.get')
    def test_get_artist_genres(self, mock_requests_get, mock_get_spotify_token):
        # Mocking the get_spotify_token function
        mock_get_spotify_token.return_value = 'mock_token'

        # Mocking the requests.get function
        mock_response = {
            "genres": ["Genre1", "Genre2"]
        }
        mock_requests_get.return_value.json.return_value = mock_response

        # Run the get_artist_genres function
        response = get_artist_genres('artist_id')

        # Assert that the artist genres were retrieved successfully
        self.assertEqual(response, ["Genre1", "Genre2"])

    @patch('app.get_spotify_token')
    @patch('requests.get')
    def test_add_track_to_db(self, mock_requests_get, mock_get_spotify_token):
        # Mocking the get_spotify_token function
        mock_get_spotify_token.return_value = 'mock_token'

        # Mocking the requests.get function
        mock_response = {
            "tracks": [
                {
                    "album": {"id": "album_id", "name": "Album", "release_date": "2023-01-01"},
                    "artists": [{"id": "artist_id", "name": "Artist", "genres": ["Genre"]}],
                    "duration_ms": 300000,
                    "id": "track_id",
                    "name": "Track",
                    "popularity": 80
                }
            ]
        }
        mock_requests_get.return_value.json.return_value = mock_response

        # Create a mock client
        mock_client = unittest.mock.Mock()

        # Run the add_track_to_db function
        track_object = {
            "album": {"id": "album_id", "name": "Album", "release_date": "2023-01-01"},
            "artists": [{"id": "artist_id", "name": "Artist", "genres": ["Genre"]}],
            "duration_ms": 300000,
            "id": "track_id",
            "name": "Track",
            "popularity": 80
        }
        add_track_to_db(track_object, mock_client)

        # Assert that the track was inserted successfully
        mock_client.MusicDB.Track.insert_one.assert_called_once()

if __name__ == '__main__':
    unittest.main()
