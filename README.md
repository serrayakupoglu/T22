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


## Development Artifacts
- **Backlog in Gherkin format:**
  Feature: User Authentication
  As a registered user
  I want to log in
  So that I can access my personalized content

Scenario: Successful Login
  Given the user is on the login page
  When the user enters valid credentials
  Then the user should be logged in successfully

Scenario: Invalid Credentials
  Given the user is on the login page
  When the user enters invalid credentials
  Then an error message should be displayed
  And the user should remain on the login page
- E-R diagram


## Technology 
Jira, Python, MongoDB, Reactjs, Flutter, Android studio 
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
2. Web group: Ezgi Duman, Berke Kayhan
3. Mobile app group: Kemal Ayhan, Bahri Baran Coskun
4. Team Leader: Serra Yakupoglu   



