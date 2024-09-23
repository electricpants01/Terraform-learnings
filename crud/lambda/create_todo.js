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

    let title, description;
    try {
        console.log("event", event);
        console.log("event body", event.body);

        // Parse the body if it's a string
        const body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;

        title = body?.title;
        description = body?.description;

        console.log("title", title);
        console.log("description", description);

        if (!title || !description) {
            return {
                statusCode: 400,
                body: JSON.stringify({ message: 'Title and description are required' }),
            };
        }

        const sql = 'INSERT INTO todos (title, description) VALUES ($1, $2) RETURNING id';
        const res = await client.query(sql, [title, description]);

        return {
            statusCode: 201, // Use 201 for resource creation
            body: JSON.stringify({ message: 'Tarea creada con éxito', taskId: res.rows[0].id }),
        };
    } catch (error) {
        console.error('Error inserting task:', error); // Log the error details
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Error al insertar la tarea', error: error.message }),
        };
    }
};

// Optional cleanup function (but not used in each request)
const cleanup = async () => {
    if (client) {
        await client.end();
        client = null;
        console.log('Database connection closed');
    }
};
