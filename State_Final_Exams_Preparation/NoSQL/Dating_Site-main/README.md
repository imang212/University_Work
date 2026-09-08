# Dating Site App (Flask)
**Description:**  
A modern **web-based dating application** built with Flask. The app allows users to create personal profiles, like other users, and form relationships through mutual matches.  

## Overview
The project serves as a **prototype for a full-featured dating platform**, focused on:
- Secure profile management  
- Real-time user interactions  
- Efficient data storage and matching logic using graph and relational databases  

It’s designed to demonstrate how multiple data storage technologies (Neo4j, Redis, PostgreSQL) can cooperate in one Flask application.

## Tech Stack
| Component | Technology | Description |
|------------|-------------|-------------|
| **Backend** | Flask (Python) | Handles routing, user logic, and database communication |
| **Frontend** | HTML, Vanilla CSS, Bootstrap | Provides the responsive and modern UI |
| **Databases** | Neo4j, Redis, PostgreSQL | Neo4j for relationships, Redis for caching, PostgreSQL for persistent data |
| **Containerization** | Docker | The entire application runs in isolated Docker containers for easy deployment |

## Key Features
- **User registration & profile creation**  
  Users can sign up, create a personal profile, and upload basic info.  
- **Profile editing**  
  Update personal information, profile photo, and other details anytime.  
- **Likes & matches**  
  Like other users’ profiles via a heart icon.  
  - If both users like each other → they form a **match** in the *Relationships* tab.  
  - All likes and matches are stored and synchronized between databases.  
- **Notifications system**  
  Users receive alerts when they are liked or matched.  
- **Fast caching**  
  Redis improves data access speed for user feeds and likes.  
- **Graph-based recommendations**  
  Neo4j allows exploring user relationships and potential matches efficiently.  

## Screenshots (Test Version)

### Registration
<img width="1881" height="929" alt="Registration" src="https://github.com/user-attachments/assets/96bd4363-e835-48d5-959a-a2f848a0394a" />  
Users can create an account and register on the platform.

### Profile Management
<img width="1903" height="701" alt="Profile" src="https://github.com/user-attachments/assets/08a52261-84a0-4c4e-a299-d9bed512ed82" />  
Users can modify their profiles — edit information, upload or change their photo, and manage their visibility.

### Liking Profiles
<img width="1895" height="787" alt="Likes" src="https://github.com/user-attachments/assets/06bf27ca-1cf1-4102-a6d8-5bc4b4ade2a9" />  
Users can like other profiles via a heart icon (only if they have a profile picture).  
If both users like each other, they will appear in the **Relationships** tab.  
Notifications are shown under the **Notifications** section.  

## Deployment
The entire project runs inside **Docker containers** for easy setup and portability.  
To start the app locally:

```bash
docker-compose up --build
```

**This will:**
- Install all dependencies
- Launch the Flask server
- Start the Neo4j, Redis, and PostgreSQL services

Then open your browser and navigate to:

```arduino
http://localhost:5000
```

### Future Improvements
- Implement JWT authentication
- Add real-time chat between matches
- Improve AI-based recommendations for compatible profiles
- Develop a responsive mobile version

### Author
Author: Patrik Poklop
Framework: Flask (Python)
Year: 2025

“A modern dating web app combining Flask, graph databases, and clean UI to connect people in meaningful ways.”
