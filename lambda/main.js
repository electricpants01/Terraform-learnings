// Import the required AWS SDK clients and commands
const { SESClient, SendEmailCommand } = require('@aws-sdk/client-ses');

// Configure AWS SES
const sesClient = new SESClient({ region: 'us-east-1' }); // Change to your AWS SES region

// Function to send email
const sendEmail = async () => {
    const params = {
        Source: 'roperoendemoniado1@gmail.com', // Change to your verified SES email
        Destination: {
            ToAddresses: ['christorricoavila@gmail.com'], // Change to your destination email
        },
        Message: {
            Subject: {
                Data: 'Daily Email Reminder',
            },
            Body: {
                Text: {
                    Data: 'This is your daily reminder email.',
                },
            },
        },
    };

    try {
        const command = new SendEmailCommand(params);
        await sesClient.send(command);
        console.log('Email sent successfully!');
    } catch (error) {
        console.error('Error sending email:', error);
    }
};

sendEmail();