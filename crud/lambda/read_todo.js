const { Client } = require('pg');

let client;

const connectToDatabase = async () => {
    // Check if client is not already connected or closed
    if (!client || client._ending) {
        client = new Client({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASS,
            database: process.env.DB_NAME,
            port: 5432,
            ssl: {
                rejectUnauthorized: false, // Optional: Set to true if you have the certificate.
            },
        });

        try {
            await client.connect();
            console.log('Connected to PostgreSQL database');
        } catch (err) {
            console.error('Error connecting to PostgreSQL database:', err);
            throw new Error('Database connection failed');
        }
    }
};

exports.handler = async (event) => {
    await connectToDatabase(); // Ensure the database connection is established

    const taskId = event.queryStringParameters?.id;
    let sql = 'SELECT * FROM todos';
    const params = [];

    if (taskId) {
        sql += ' WHERE id = $1';
        params.push(taskId);
    }

    try {
        console.log("Executing SQL:", sql, "with params:", params);  // Log the SQL query and parameters

        const res = await client.query(sql, params);

        // Log the result from the database query
        console.log("Query result:", res.rows);

        // Check if there are any results
        if (res.rows.length === 0) {
            return {
                statusCode: 404,
                body: JSON.stringify({ message: 'No tasks found' }),
            };
        }

        return {
            statusCode: 200,
            body: JSON.stringify(res.rows),
        };
    } catch (error) {
        console.error('Error executing query:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Error al leer las tareas', error: error.message }),
        };
    }
};

// Optional cleanup function
const cleanup = async () => {
    if (client) {
        await client.end();
        client = null;
        console.log('Database connection closed');
    }
};
