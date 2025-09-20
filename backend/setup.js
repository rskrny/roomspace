#!/usr/bin/env node
const fs = require('fs');
const path = require('path');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

const question = (query) => {
  return new Promise((resolve) => {
    rl.question(query, resolve);
  });
};

async function setupEnvironment() {
  console.log('🚀 Welcome to RoomSpace Backend Setup\n');
  
  const envPath = path.join(__dirname, '.env');
  const envExamplePath = path.join(__dirname, '.env.example');
  
  // Check if .env already exists
  if (fs.existsSync(envPath)) {
    console.log('⚠️  .env file already exists.');
    const overwrite = await question('Do you want to overwrite it? (y/N): ');
    if (overwrite.toLowerCase() !== 'y') {
      console.log('Setup cancelled.');
      rl.close();
      return;
    }
  }

  console.log('Setting up your environment configuration...\n');
  
  // Basic server configuration
  console.log('📡 Server Configuration:');
  const nodeEnv = await question('Environment (development/production) [development]: ') || 'development';
  const port = await question('Port [3000]: ') || '3000';
  
  // JWT Secret
  console.log('\n🔐 Security Configuration:');
  let jwtSecret = await question('JWT Secret (leave empty to auto-generate): ');
  if (!jwtSecret) {
    jwtSecret = require('crypto').randomBytes(64).toString('hex');
    console.log('✅ Auto-generated JWT secret');
  }
  
  // Supabase Configuration
  console.log('\n🗄️  Database Configuration (Supabase):');
  console.log('Visit https://supabase.com to create a project and get your credentials');
  const supabaseUrl = await question('Supabase URL (optional for development): ') || 'your-supabase-project-url';
  const supabaseAnonKey = await question('Supabase Anon Key (optional for development): ') || 'your-supabase-anon-key';
  const supabaseServiceKey = await question('Supabase Service Role Key (optional): ') || 'your-supabase-service-role-key';
  
  // OpenAI Configuration
  console.log('\n🤖 OpenAI Configuration:');
  console.log('Visit https://platform.openai.com to get your API key');
  const openaiApiKey = await question('OpenAI API Key (optional for development): ') || '';
  
  // Amazon Configuration
  console.log('\n📦 Amazon Product API Configuration (Optional):');
  const amazonAccessKey = await question('Amazon Access Key: ') || '';
  const amazonSecretKey = await question('Amazon Secret Key: ') || '';
  const amazonPartnerTag = await question('Amazon Partner Tag [roomspace-20]: ') || 'roomspace-20';
  const amazonRegion = await question('Amazon Region [us-east-1]: ') || 'us-east-1';
  
  // OAuth Configuration
  console.log('\n🔑 OAuth Configuration (Optional):');
  const googleClientId = await question('Google Client ID: ') || '';
  const googleClientSecret = await question('Google Client Secret: ') || '';
  const appleClientId = await question('Apple Client ID: ') || '';
  const appleKeyId = await question('Apple Key ID: ') || '';
  const appleTeamId = await question('Apple Team ID: ') || '';
  
  // Create .env file
  const envContent = `# Server Configuration
NODE_ENV=${nodeEnv}
PORT=${port}

# JWT Secret
JWT_SECRET=${jwtSecret}

# Supabase Configuration
SUPABASE_URL=${supabaseUrl}
SUPABASE_ANON_KEY=${supabaseAnonKey}
SUPABASE_SERVICE_KEY=${supabaseServiceKey}

# OpenAI API Configuration
OPENAI_API_KEY=${openaiApiKey}

# Amazon Product Advertising API
AMAZON_ACCESS_KEY=${amazonAccessKey}
AMAZON_SECRET_KEY=${amazonSecretKey}
AMAZON_PARTNER_TAG=${amazonPartnerTag}
AMAZON_REGION=${amazonRegion}

# Apple Sign In (optional)
APPLE_CLIENT_ID=${appleClientId}
APPLE_KEY_ID=${appleKeyId}
APPLE_TEAM_ID=${appleTeamId}

# Google OAuth (optional)
GOOGLE_CLIENT_ID=${googleClientId}
GOOGLE_CLIENT_SECRET=${googleClientSecret}
`;

  fs.writeFileSync(envPath, envContent);
  
  console.log('\n✅ Environment configuration saved to .env');
  
  // Show next steps
  console.log('\n📋 Next Steps:');
  console.log('1. Run "npm run dev" to start the development server');
  console.log('2. Test the API with: curl http://localhost:' + port + '/api/health');
  
  if (supabaseUrl === 'your-supabase-project-url') {
    console.log('3. Set up Supabase database (see docs/SETUP.md)');
  }
  
  if (!openaiApiKey) {
    console.log('4. Add OpenAI API key for design generation');
  }
  
  console.log('5. See docs/SETUP.md for complete setup instructions');
  
  console.log('\n🎉 Setup complete! Happy coding!');
  
  rl.close();
}

// Run setup if this script is executed directly
if (require.main === module) {
  setupEnvironment().catch(console.error);
}

module.exports = { setupEnvironment };