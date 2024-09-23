const { Client } = require('pg');

let client;

const connectToDatabase = async () => {
    if (!client) {
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


    const taskId = event.queryStringParameters?.id
    console.log("task id", taskId);

    if (!taskId) {
        return {
            statusCode: 400,
            body: JSON.stringify({ message: 'ID no proporcionado' }),
        };
    }

    try {
        const sql = 'DELETE FROM todos WHERE id = $1';
        const res = await client.query(sql, [taskId]);

        if (res.rowCount === 0) {
            return {
                statusCode: 404,
                body: JSON.stringify({ message: 'Tarea no encontrada' }),
            };
        }

        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Tarea eliminada con éxito' }),
        };
    } catch (error) {
        console.error('Error executing query:', error); // Log the error details
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Error al eliminar la tarea', error: error.message }),
        };
    }
};

// Cleanup function to close the database connection (optional)
const cleanup = async () => {
    if (client) {
        await client.end();
        client = null;
        console.log('Database connection closed');
    }
};