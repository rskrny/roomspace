const dotenv = require('dotenv');

// Load environment variables
dotenv.config();

// Validate and provide defaults for environment variables
const validateEnv = () => {
  const config = {
    NODE_ENV: process.env.NODE_ENV || 'development',
    PORT: parseInt(process.env.PORT) || 3000,
    
    // JWT Configuration
    JWT_SECRET: process.env.JWT_SECRET || 'dev-jwt-secret-change-in-production',
    
    // Supabase Configuration
    SUPABASE_URL: process.env.SUPABASE_URL || 'https://localhost:54321',
    SUPABASE_ANON_KEY: process.env.SUPABASE_ANON_KEY || 'mock-supabase-key',
    SUPABASE_SERVICE_KEY: process.env.SUPABASE_SERVICE_KEY || 'mock-service-key',
    
    // OpenAI Configuration
    OPENAI_API_KEY: process.env.OPENAI_API_KEY || '',
    
    // Amazon Configuration
    AMAZON_ACCESS_KEY: process.env.AMAZON_ACCESS_KEY || '',
    AMAZON_SECRET_KEY: process.env.AMAZON_SECRET_KEY || '',
    AMAZON_PARTNER_TAG: process.env.AMAZON_PARTNER_TAG || 'roomspace-20',
    AMAZON_REGION: process.env.AMAZON_REGION || 'us-east-1',
    
    // Optional OAuth Configuration
    GOOGLE_CLIENT_ID: process.env.GOOGLE_CLIENT_ID || '',
    GOOGLE_CLIENT_SECRET: process.env.GOOGLE_CLIENT_SECRET || '',
    APPLE_CLIENT_ID: process.env.APPLE_CLIENT_ID || '',
    APPLE_KEY_ID: process.env.APPLE_KEY_ID || '',
    APPLE_TEAM_ID: process.env.APPLE_TEAM_ID || '',
  };

  // Check for required environment variables in production
  if (config.NODE_ENV === 'production') {
    const requiredVars = [
      'JWT_SECRET',
      'SUPABASE_URL', 
      'SUPABASE_ANON_KEY',
      'OPENAI_API_KEY'
    ];
    
    const missing = requiredVars.filter(key => !process.env[key]);
    
    if (missing.length > 0) {
      console.error('Missing required environment variables:', missing.join(', '));
      process.exit(1);
    }
  }

  return config;
};

// Mock mode for testing without external services
const isMockMode = () => {
  return process.env.NODE_ENV === 'test' || 
         !process.env.SUPABASE_URL || 
         process.env.SUPABASE_URL.includes('localhost') ||
         process.env.SUPABASE_URL === 'your-supabase-project-url';
};

// Service availability checks
const isServiceAvailable = (service) => {
  switch (service) {
    case 'supabase':
      return !isMockMode() && process.env.SUPABASE_URL && process.env.SUPABASE_ANON_KEY;
    case 'openai':
      return process.env.OPENAI_API_KEY && process.env.OPENAI_API_KEY.startsWith('sk-');
    case 'amazon':
      return !!(process.env.AMAZON_ACCESS_KEY && process.env.AMAZON_SECRET_KEY);
    case 'google':
      return !!(process.env.GOOGLE_CLIENT_ID && process.env.GOOGLE_CLIENT_SECRET);
    case 'apple':
      return !!(process.env.APPLE_CLIENT_ID && process.env.APPLE_KEY_ID && process.env.APPLE_TEAM_ID);
    default:
      return false;
  }
};

module.exports = {
  config: validateEnv(),
  isMockMode,
  isServiceAvailable
};