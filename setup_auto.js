import fetch from 'node-fetch';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

/**
 * NocoDB PostgreSQL Integration Automation Script
 * 
 * This script automates the process of:
 * 1. Authenticating with NocoDB
 * 2. Creating a new base
 * 3. Adding a PostgreSQL data source
 * 4. Configuring the base to use the PostgreSQL source
 */

// ========================================
// Configuration
// ========================================

const CONFIG = {
    // NocoDB Configuration
    nocodb: {
        baseUrl: process.env.NOCODB_BASE_URL || 'http://localhost:8080',
        credentials: {
            email: process.env.NOCODB_EMAIL || 'admin@example.com',
            password: process.env.NOCODB_PASSWORD || 'admin1234'
        }
    },

    // PostgreSQL Configuration
    postgres: {
        host: process.env.POSTGRES_HOST || 'postgres_db',
        port: process.env.POSTGRES_PORT || 5432,
        user: process.env.POSTGRES_USER || 'nocouser',
        password: process.env.POSTGRES_PASSWORD || 'yoursecurepassword',
        database: process.env.POSTGRES_DB || 'nocodb_starter',
        ssl: process.env.POSTGRES_SSL === 'true'
    },

    // Base Configuration
    base: {
        title: process.env.BASE_TITLE || 'Automated App Base (Postgres)',
        sourceAlias: process.env.SOURCE_ALIAS || 'AutomatedProductionPostgres'
    }
};

// ========================================
// Utility Functions
// ========================================

/**
 * Makes authenticated HTTP requests to NocoDB API
 * @param {string} apiPath - The API endpoint path
 * @param {string} method - HTTP method (GET, POST, PATCH, DELETE)
 * @param {object|null} body - Request body for POST/PATCH requests
 * @param {string|null} authToken - Authentication token
 * @returns {Promise<object|null>} API response data or null for empty responses
 */
async function makeNocoDBRequest(apiPath, method = 'GET', body = null, authToken = null) {
    const url = `${CONFIG.nocodb.baseUrl}${apiPath}`;
    const headers = {
        'Content-Type': 'application/json'
    };

    // Add authentication header
    if (authToken) {
        if (authToken.startsWith('eyJ')) {
            headers['xc-auth'] = authToken; // JWT token
        } else {
            headers['xc-token'] = authToken; // API token
        }
    }

    const options = { method, headers };
    if (body) {
        options.body = JSON.stringify(body);
    }

    console.log(`→ ${method} ${apiPath}`);

    try {
        const response = await fetch(url, options);
        const responseText = await response.text();

        if (!response.ok) {
            let errorData;
            try {
                errorData = JSON.parse(responseText);
            } catch (e) {
                errorData = { message: response.statusText, details: responseText };
            }

            const errorMessage = `API Error ${response.status}: ${errorData.message || response.statusText}`;
            console.error(`✗ ${errorMessage}`);
            throw new Error(errorMessage);
        }

        // Handle empty responses
        if (response.status === 204 || !responseText) {
            console.log(`✓ ${method} ${apiPath} - Success (no content)`);
            return null;
        }

        const jsonData = JSON.parse(responseText);
        console.log(`✓ ${method} ${apiPath} - Success`);
        return jsonData;

    } catch (error) {
        if (!error.message.startsWith('API Error')) {
            console.error(`✗ Network error: ${error.message}`);
        }
        throw error;
    }
}

/**
 * Logs sensitive data safely by masking passwords
 * @param {object} data - Data to log
 * @returns {object} Data with sensitive fields masked
 */
function maskSensitiveData(data) {
    const masked = JSON.parse(JSON.stringify(data));

    if (masked.config?.connection?.password) {
        masked.config.connection.password = '********';
    }
    if (masked.password) {
        masked.password = '********';
    }

    return masked;
}

// ========================================
// Authentication Functions
// ========================================

/**
 * Authenticates with NocoDB and returns a JWT token
 * @param {string} email - User email
 * @param {string} password - User password
 * @returns {Promise<string>} JWT authentication token
 */
async function signIn(email, password) {
    console.log(`\n🔐 Signing in as: ${email}`);

    const payload = { email, password };
    const response = await makeNocoDBRequest('/api/v1/auth/user/signin', 'POST', payload);

    if (!response?.token) {
        throw new Error('Sign-in failed: No token returned');
    }

    console.log('✓ Sign-in successful');
    return response.token;
}

/**
 * Creates an API token using the JWT token
 * @param {string} jwtToken - JWT token from sign-in
 * @returns {Promise<string>} API token for subsequent requests
 */
async function createApiToken(jwtToken) {
    console.log('\n🔑 Creating API token...');

    const payload = { description: `Auto-generated token ${new Date().toISOString()}` };
    const response = await makeNocoDBRequest('/api/v1/tokens', 'POST', payload, jwtToken);

    if (!response?.token) {
        throw new Error('API token creation failed: No token returned');
    }

    console.log('✓ API token created successfully');
    return response.token;
}

// ========================================
// Base Management Functions
// ========================================

/**
 * Creates a new base in NocoDB
 * @param {string} title - Base title
 * @param {string} apiToken - API token for authentication
 * @returns {Promise<object>} Created base object
 */
async function createBase(title, apiToken) {
    console.log(`\n📊 Creating base: "${title}"`);

    const payload = { title };
    const response = await makeNocoDBRequest('/api/v2/meta/bases', 'POST', payload, apiToken);

    if (!response?.id) {
        throw new Error('Base creation failed: No ID returned');
    }

    console.log(`✓ Base created successfully (ID: ${response.id})`);
    return response;
}

/**
 * Adds a PostgreSQL data source to a base
 * @param {string} baseId - Base ID
 * @param {string} alias - Source alias/name
 * @param {object} pgConfig - PostgreSQL connection configuration
 * @param {string} apiToken - API token for authentication
 * @returns {Promise<object>} Created source object
 */
async function addPostgreSQLSource(baseId, alias, pgConfig, apiToken) {
    console.log(`\n🔗 Adding PostgreSQL source: "${alias}"`);

    const payload = {
        alias,
        type: 'pg',
        config: {
            client: 'pg',
            connection: {
                host: pgConfig.host,
                port: pgConfig.port,
                user: pgConfig.user,
                password: pgConfig.password,
                database: pgConfig.database,
                ...(pgConfig.ssl && { ssl: pgConfig.ssl })
            }
        },
        enabled: true
    };

    console.log('Connection details:', maskSensitiveData(payload));

    const response = await makeNocoDBRequest(
        `/api/v2/meta/bases/${baseId}/sources`,
        'POST',
        payload,
        apiToken
    );

    if (!response?.id) {
        throw new Error('PostgreSQL source creation failed: No ID returned');
    }

    console.log(`✓ PostgreSQL source added successfully (ID: ${response.id})`);
    return response;
}

/**
 * Configures a base to use a specific data source
 * @param {string} baseId - Base ID
 * @param {object} sourceDetails - Source details (id, alias, type)
 * @param {string} apiToken - API token for authentication
 * @returns {Promise<object>} Updated base object
 */
async function configureBaseSource(baseId, sourceDetails, apiToken) {
    console.log(`\n⚙️  Configuring base to use source: "${sourceDetails.alias}"`);

    const payload = {
        sources: [{
            id: sourceDetails.id,
            alias: sourceDetails.alias,
            type: sourceDetails.type,
            enabled: true,
            is_meta: true
        }]
    };

    const response = await makeNocoDBRequest(
        `/api/v2/meta/bases/${baseId}`,
        'PATCH',
        payload,
        apiToken
    );

    console.log('✓ Base configuration updated successfully');
    return response;
}

// ========================================
// Main Execution Function
// ========================================

/**
 * Main automation workflow
 */
async function runAutomation() {
    console.log('🚀 Starting NocoDB PostgreSQL Integration Automation\n');
    console.log('Configuration:');
    console.log(`  NocoDB URL: ${CONFIG.nocodb.baseUrl}`);
    console.log(`  PostgreSQL Host: ${CONFIG.postgres.host}:${CONFIG.postgres.port}`);
    console.log(`  Database: ${CONFIG.postgres.database}`);
    console.log(`  Base Title: ${CONFIG.base.title}\n`);

    try {
        // Step 1: Authentication
        const jwtToken = await signIn(
            CONFIG.nocodb.credentials.email,
            CONFIG.nocodb.credentials.password
        );

        const apiToken = await createApiToken(jwtToken);

        // Step 2: Create Base
        const base = await createBase(CONFIG.base.title, apiToken);

        // Step 3: Add PostgreSQL Source
        const pgSource = await addPostgreSQLSource(
            base.id,
            CONFIG.base.sourceAlias,
            CONFIG.postgres,
            apiToken
        );

        // Step 4: Configure Base to Use PostgreSQL Source
        await configureBaseSource(base.id, pgSource, apiToken);

        // Success Summary
        console.log('\n🎉 Automation completed successfully!');
        console.log('\nSummary:');
        console.log(`  Base ID: ${base.id}`);
        console.log(`  Base Title: ${CONFIG.base.title}`);
        console.log(`  Source ID: ${pgSource.id}`);
        console.log(`  Source Alias: ${CONFIG.base.sourceAlias}`);
        console.log(`  NocoDB URL: ${CONFIG.nocodb.baseUrl}/dashboard`);

        return {
            success: true,
            base,
            source: pgSource
        };

    } catch (error) {
        console.error('\n❌ Automation failed!');
        console.error(`Error: ${error.message}`);

        return {
            success: false,
            error: error.message
        };
    }
}

// ========================================
// Validation Functions
// ========================================

/**
 * Validates configuration before running automation
 */
function validateConfiguration() {
    const errors = [];

    // Check required NocoDB configuration
    if (!CONFIG.nocodb.baseUrl || CONFIG.nocodb.baseUrl === 'https://your-nocodb-instance.com') {
        errors.push('NOCODB_BASE_URL is not properly configured');
    }

    if (!CONFIG.nocodb.credentials.email || !CONFIG.nocodb.credentials.password) {
        errors.push('NocoDB credentials (email/password) are not configured');
    }

    // Check PostgreSQL configuration
    if (CONFIG.postgres.host === 'your_pg_host' || !CONFIG.postgres.password) {
        errors.push('PostgreSQL connection details are not properly configured');
    }

    if (errors.length > 0) {
        console.error('❌ Configuration errors:');
        errors.forEach(error => console.error(`  • ${error}`));
        console.error('\nPlease set the required environment variables or update the CONFIG object.');
        return false;
    }

    return true;
}

// ========================================
// Script Execution
// ========================================

console.log('🔧 Validating configuration...');
if (validateConfiguration()) {
    runAutomation()
        .then(result => {
            process.exit(result.success ? 0 : 1);
        })
        .catch(error => {
            console.error('Unexpected error:', error);
            process.exit(1);
        });
} else {
    process.exit(1);
}