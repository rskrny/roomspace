# Setup Guide

## Prerequisites
- Node.js 18+ and npm
- Xcode 15+ (for iOS development)
- Swift 5.8+
- Supabase account
- OpenAI API key
- Amazon Developer account (for Product Advertising API)

## Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Copy environment variables:
   ```bash
   cp .env.example .env
   ```

4. Edit `.env` with your API keys and configuration

5. Start the development server:
   ```bash
   npm run dev
   ```

## iOS Setup

1. Navigate to the iOS directory:
   ```bash
   cd ios
   ```

2. Build the Swift package:
   ```bash
   swift build
   ```

3. Open in Xcode to run on device/simulator

## Database Setup

1. Create a new Supabase project
2. Run the initial schema:
   ```sql
   -- Copy and paste contents of database/schemas/initial_schema.sql
   ```
3. Run seed data migration:
   ```sql
   -- Copy and paste contents of database/migrations/001_seed_data.sql
   ```

## Configuration

Update your environment variables in `backend/.env`:
- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anon key
- `OPENAI_API_KEY`: Your OpenAI API key
- `AMAZON_ACCESS_KEY_ID`: Amazon Product API credentials
- `AMAZON_SECRET_ACCESS_KEY`: Amazon Product API credentials
- `AMAZON_ASSOCIATE_TAG`: Your Amazon Associate tag