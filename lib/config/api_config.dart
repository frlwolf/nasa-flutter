class ApiConfig {
  // NASA API Configuration
  static const String nasaApiKey = 'nG0NTHAoaaM6ofwe9HUqgDoLdEIFBiy2A1NQQ968'; // Replace with your actual API key
  
  // API Endpoints
  static const String nasaApodBaseUrl = 'https://api.nasa.gov/planetary/apod';
  
  // Rate limiting and timeout settings
  static const Duration requestTimeout = Duration(seconds: 30);
  static const int maxRetryAttempts = 3;
  
  // Default parameters
  static const int defaultApodCount = 30; // Days to load by default
  static const int maxApodCount = 100;    // Maximum items to load at once
}

// Instructions for getting a NASA API key:
// 1. Go to https://api.nasa.gov
// 2. Click "Generate API Key" 
// 3. Fill out the form with your information
// 4. Replace 'DEMO_KEY' above with your generated key
// 
// Note: DEMO_KEY has limited requests per hour (30 requests/hour)
// A personal API key allows 1000 requests/hour