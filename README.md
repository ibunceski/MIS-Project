# Mobile Information Systems - Project

## Macedonian Market Pulse - Mobile Application for Analysis of the Macedonian Stock Exchange

### Overview
This project involves the development of a mobile application for analyzing data from the Macedonian stock exchange. The application connects to a backend service that processes and provides the necessary data for the proper functioning of the application.

### Features
- Display the list of stocks on the Macedonian stock exchange
- Display the details for each stock
- Display of a chart for daily price changes of stocks
- Display of the latest news related to a stock
- Tracking the user's favorite stocks
- LSTM analysis for predicting the price of a stock
- Fundamental analysis of stocks
- Technical analysis of stocks
- Custom UI Elements
- Custom Theme
- State Management with Provider
- Authentication with Firebase
- Error Handling
- Location Services

### Technologies
- Flutter
- Dart
- Firebase
- Java(Spring Boot) & Python(FastAPI) for the backend and PostgreSQL for the database 
### Prerequisites
For proper functioning, it is necessary to set up the backend service locally. The backend repository is available at the following link:

**[Backend Repository](https://github.com/ibunceski/MIS-SeminarskaBackend)**

### Instructions
The backend is containerized. Follow these steps to set up the backend:

1. Clone the backend repository:
   ```bash
   git clone https://github.com/ibunceski/MIS-SeminarskaBackend
   ```
2. Navigate to the project directory:
   ```bash
   cd MIS-SeminarskaBackend
   ```
3. Start the backend service with Docker Compose:
   ```bash
   docker compose up
   ```

### Usage
Once the backend service is started, you can use the mobile application.

### Authors
- Ilija Buncheski - 221094
- Milovan Kostojchinoski - 206014

