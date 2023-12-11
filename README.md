# T22
Music Data Collection and Analysis System

This project is a system that gathers users' data of liked songs and then the project offers various different analysis on musical preferances, making recommendations accordingly. 

## Table of Content 
- [Features](#features)
- [Installation](#installation)
- [Development Artifacts](#development-artifacts)
- [Pogress of the groups](#progressofthegroups)
- [Tecnology](#technology)
- [Usage](#usage)
- [Authors](#Authors)


## Features 
- Rating songs out of 10 
-  Song recommendations based on liked songs and friends playlists
- Analysis of song preferences and common features of liked songs.
- Seeing statistical information over users analysis 
- Being able to add songs manually via web/mobile application, txt file or cloud database service
- The system requires authentication
- Being able to search other users and follow/unfollow them 


## Installation 
1. Clone the repository:
    ```bash
    git clone https://github.com/serrayakupoglu/T22.git
    ```
2. **Navigate to the Project Directory:**
    ```bash
    cd T22
    ```
3. **Install Dependencies:**
    ```bash
    pip3 install Flask==2.0.1 certifi==2021.5.30  requests==2.26.0  pymongo==3.12.0  bson==0.5.10
    ```
4. **Obtain Spotify Token:**
    - Create a Spotify Developer account and obtain a client ID and client secret.
    - Update the `get_spotify_token` function in your code with your client ID and client secret.

5. **Connect to MongoDB:**
    - Create a MongoDB Atlas account and set up a cluster.
    - Update the `uri` variable in the `connect_to_mongo` function with your MongoDB connection string.
    - Ensure that your MongoDB Atlas cluster allows connections from your application's IP address.
6. **Run the Application:**



## Development Artifacts
- **Backlog in Gherkin format:**
  
-  Feature: User Authentication
  As a registered user
  I want to log in
  So that I can access my personalized content

1. Scenario: Successful Login
  Given the user is on the login page
  When the user enters valid credentials
  Then the user should be logged in successfully

2. Scenario: Invalid Credentials
  Given the user is on the login page
  When the user enters invalid credentials
  Then an error message should be displayed
  And the user should remain on the login page
  
  - Feature: Rating songs 
  As a user
  I want to rate songs i like
  So that my preferances can be analyized
  
 1.  Scenario: Successful rating
      Given the user picks and rates a song 
      When the rate is between 1-10, song is in the database and song is not already rated
      Then user will be able to rate the song succesfully
 2.  Scenario: Unsuccessful rating
      Given the user pick and rates a song 
      When the rate is not 1-10, song is not in database or the song is already rated 
      Then user will get an error message 
      
 -  Feature: Song analysis 
  As a user 
  I want to get my music preferance analysis
  So that i have my statistical data
 1.  Scenerio: Analysis based on genre
      Given the user requested analysis
      When there are songs that the user has rated 
      Then the user will get preferance analysis based on the genre of the songs
  2. Scenerio: Analysis based on year 
      Given the user requested analysis
      When there aren't songs that the user has rated but there are liked songs 
      Then the user will get preferance analysis based on the relase date of the songs
-  Feature: Adding songs manually
 As a user
 I want to add songs to the system 
 So that i can rate any song i like
1. Scenario: Successfull add
    Given the user requesting to add a song to the database
    When the format is in json in the txt file 
    Then the user will be able to add song
2. Scenario: Unsuccessfull add 
    Given the user requesting to add a song in the database
    When the format is not in json form 
    Then user will not be able to add the song
- Feature: Follow/Unfollow other users
As a user
I want to follow/unfollow other users
So that i can connect with friends
1. Scenario: Successfull follow/unfollow
    Given the user followed/unfollowed other users
    When the target user is found and they are not already followed/unfollowed
    Then user can follow/unfollow them
2. Scenario: Unssuccessfull follow/unfollow
    Given the user followed/unfollowed other users
    When the target user is not found and they are already followed/unfollowed
    Then user can not follow/unfollow them
- Feature: Recommedation 
As a user 
I want the system to recommend songs to me
So that i can have new songs to listen to 
1. Scenario: Song recommended
    Given the user asked for recommendations
    When there is enough data on users prefarence
    Then system will recommend songs

2. Scenario: Unable to recommend songs
    Given the user asked for recommendations
    When there is not enough data on users prefarence
    Then system can not recommend songs
  
- **UML Class diagram**
  https://lucid.app/lucidchart/9d5facbf-866e-4b1f-8ad4-885a01875e43/edit?beaconFlowId=E4A18F26AF9DF22D&invitationId=inv_78fda0ac-d8e1-4f83-a965-7ccca2dff53b&page=0_0#


## Technology 
Jira, Python, MongoDB, Reactjs, Flutter, Android studio, Postman
## Usage 
1. **User Registration:**
   - Through the register page on the website or the sign up page in the mobile app register to the system. After registering with your name and password the user can log in to the system.
2. **Rating Songs:**
    - User can search song from the search page and rate songs out of ten or add songs you like and enter your rating. 

3. **Adding Songs:**
    - From the add song section the user can add songs manually, via txt files or cloud data base services.

4. **Exploring Recommendations:**
    - After rating songs in the system it can reccomend user songs based on your rating or your friends' likings. 

5. **User Interaction:**
    - The user can search for other users in the system and follow/unfollow them.

6. **Accessing Statistical Information:**
    - The user  can ask for their musical analysis. The system will give them statistical data on their likings. The user can display tables and charts on their analysis. 

## Authors
1. Backend group: Yagmur Dolunay, Ata Egemen Gurel
2. Web group: Ezgi Duman
3. Mobile app group: Kemal Ayhan, Bahri Baran Coskun
4. Team Leader: Serra Yakupoglu   




