const { Client } = require('pg');

// Initialize the client, but don't connect immediately
const client = new Client({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
    port: 5432,
    ssl: {
        rejectUnauthorized: false, // Optional: Set to true if you have the certificate.
    }
});

// Connect to the database outside the handler to reuse connection
client.connect()
    .then(() => console.log('Connected to PostgreSQL database'))
    .catch(err => console.error('Error connecting to PostgreSQL database:', err));

exports.handler = async (event) => {
    let id, title, description, status;

    try {
        console.log("event.body", event.body);

        // Parse event.body (because it's likely a string in API Gateway)
        const body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;

        id = body.id;
        title = body.title;
        description = body.description;
        status = body.status;  // Optional field in case you want to update the status as well

        console.log("id", id);
        console.log("title", title);
        console.log("description", description);
        console.log("status", status);

        if (!id || !title || !description) {
            return {
                statusCode: 400,
                body: JSON.stringify({ message: 'id, title, and description are required' }),
            };
        }

        const sql = 'UPDATE todos SET title = $1, description = $2, status = $3 WHERE id = $4';
        const res = await client.query(sql, [title, description, status || 'pending', id]);

        if (res.rowCount === 0) {
            return {
                statusCode: 404,
                body: JSON.stringify({ message: 'Tarea no encontrada' }),
            };
        }

        return {
            statusCode: 200,
            body: JSON.stringify({ message: 'Tarea actualizada con éxito' }),
        };

    } catch (error) {
        console.error('Error updating task:', error);  // Log the error
        return {
            statusCode: 500,
            body: JSON.stringify({ message: 'Error al actualizar la tarea', error: error.message }),
        };
    }
};

const cleanup = async () => {
    if (client) {
        await client.end();
        client = null;
        console.log('Database connection closed');
    }
};
