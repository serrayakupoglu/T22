
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
