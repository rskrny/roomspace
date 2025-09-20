const { isMockMode } = require('../config/env');

// Mock Supabase implementation for testing
class MockSupabaseClient {
  constructor() {
    this.mockData = {
      users: [],
      room_scans: [],
      saved_designs: [],
      user_favorites: [],
      product_catalog: []
    };
  }

  from(table) {
    return new MockQueryBuilder(table, this.mockData);
  }

  // Mock auth methods if needed
  auth = {
    getUser: () => Promise.resolve({ data: null, error: null }),
    signUp: () => Promise.resolve({ data: null, error: null }),
    signIn: () => Promise.resolve({ data: null, error: null })
  };
}

class MockQueryBuilder {
  constructor(table, mockData) {
    this.table = table;
    this.mockData = mockData;
    this.filters = {};
    this.selectedFields = '*';
    this.orderBy = null;
    this.limitValue = null;
  }

  select(fields = '*') {
    this.selectedFields = fields;
    return this;
  }

  insert(data) {
    const items = Array.isArray(data) ? data : [data];
    items.forEach(item => {
      const newItem = {
        id: `mock-uuid-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
        ...item,
        created_at: new Date().toISOString()
      };
      this.mockData[this.table].push(newItem);
    });
    return this;
  }

  update(data) {
    // Find and update matching items
    const updatedItems = this.mockData[this.table]
      .filter(item => this.matchesFilters(item))
      .map(item => ({ ...item, ...data, updated_at: new Date().toISOString() }));
    
    // Replace items in mock data
    this.mockData[this.table] = this.mockData[this.table].map(item => {
      const updated = updatedItems.find(u => u.id === item.id);
      return updated || item;
    });
    
    return this;
  }

  delete() {
    this.mockData[this.table] = this.mockData[this.table]
      .filter(item => !this.matchesFilters(item));
    return this;
  }

  eq(column, value) {
    this.filters[column] = value;
    return this;
  }

  order(column, options = {}) {
    this.orderBy = { column, ascending: options.ascending !== false };
    return this;
  }

  limit(count) {
    this.limitValue = count;
    return this;
  }

  single() {
    this.isSingle = true;
    return this;
  }

  matchesFilters(item) {
    return Object.entries(this.filters).every(([key, value]) => item[key] === value);
  }

  async execute() {
    let results = this.mockData[this.table].filter(item => this.matchesFilters(item));
    
    if (this.orderBy) {
      results.sort((a, b) => {
        const aVal = a[this.orderBy.column];
        const bVal = b[this.orderBy.column];
        const comparison = aVal < bVal ? -1 : aVal > bVal ? 1 : 0;
        return this.orderBy.ascending ? comparison : -comparison;
      });
    }
    
    if (this.limitValue) {
      results = results.slice(0, this.limitValue);
    }

    if (this.isSingle) {
      return {
        data: results[0] || null,
        error: results.length === 0 ? { message: 'No rows found' } : null
      };
    }

    return {
      data: results,
      error: null
    };
  }

  // Promise interface
  then(onResolve, onReject) {
    return this.execute().then(onResolve, onReject);
  }

  catch(onReject) {
    return this.execute().catch(onReject);
  }
}

// Create appropriate client based on environment
let supabaseClient;

if (isMockMode()) {
  console.log('Using mock Supabase client for testing/development');
  supabaseClient = new MockSupabaseClient();
} else {
  // Use real Supabase client
  const { createClient } = require('@supabase/supabase-js');
  const { config } = require('../config/env');
  
  if (!config.SUPABASE_URL || !config.SUPABASE_ANON_KEY) {
    console.error('Missing Supabase environment variables');
    process.exit(1);
  }
  
  supabaseClient = createClient(config.SUPABASE_URL, config.SUPABASE_ANON_KEY);
}

module.exports = {
  supabase: supabaseClient
};