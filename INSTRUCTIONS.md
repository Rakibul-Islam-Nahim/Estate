# Real Estate App - Setup Instructions

## Overview

Your Flutter real estate app now has:

- ✅ Login page connected to backend
- ✅ Signup page connected to backend
- ✅ Beautiful homepage with bottom navigation
- ✅ Clean white and lime green color scheme

## Running the Application

### 1. Start the Backend Server

Open a terminal and run:

```bash
cd backend
python app.py
```

The backend will run on `http://localhost:8000`

### 2. Run the Flutter App

In another terminal, run:

```bash
flutter run
```

Choose your target device (Chrome, Android emulator, etc.)

## Features Implemented

### Backend Integration

- **Login**: POST request to `/api/login` with email and password
- **Signup**: POST request to `/api/register` with username, address, email, and password
- Both pages include error handling and loading states

### HomePage

- Clean white background with lime green (#9ACD32) accents
- Displays user's name in the app bar
- Bottom navigation with 4 tabs (Home, Search, Favorites, Profile)
- Featured properties section with sample data
- Smooth transitions and modern design

## API Endpoints

- **Register**: `POST http://localhost:8000/api/register`

  - Body: `{ "username": "...", "address": "...", "email": "...", "password": "..." }`

- **Login**: `POST http://localhost:8000/api/login`
  - Body: `{ "email": "...", "password": "..." }`

## Color Scheme

- **Primary Background**: White (`Colors.white`)
- **Accent/Highlights**: Lime Green (`#9ACD32`)
- **Text**: Dark Grey (`Colors.grey[800]`)
- **Subtle Elements**: Light Grey (`Colors.grey[600]`)

## Next Steps

The bottom navigation buttons are ready but not yet functional. You can extend the app by:

1. Creating separate pages for Search, Favorites, and Profile
2. Adding real property listings
3. Implementing property search functionality
4. Adding user profile management
