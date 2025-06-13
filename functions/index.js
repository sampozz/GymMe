const functions = require('firebase-functions');
const axios = require('axios'); // Axios per le richieste HTTP
const stripe = require('stripe')('sk_test_51R1qAYKV9FRxFMV6QiiOrWipJKLR95PfcBc6FoNnd6pet4tSnOQUrln8OhZ3Su19R1VKjKCEWvvFO1pntZWa4NnK00o7EplLVW');
const cors = require('cors')({ origin: true });

exports.createCheckout = functions.https.onRequest({ cors: true }, async (req, res) => {
    try {
        const origin = req.query.origin || req.headers.origin || 'https://app.sampoz.tech';
        const amount = parseInt(req.query.amount || '0');
        const bookingId = req.query.bookingId || 'defaultBookingId';
        const platform = req.query.platform || 'web'; // Add platform parameter

        let successUrl, cancelUrl;
        successUrl = `${origin}/#/stripesuccess?bookingId=${bookingId}`;
        cancelUrl = `${origin}/#/stripefailed`;

        const session = await stripe.checkout.sessions.create({
            payment_method_types: ['card'],
            line_items: [
                {
                    price_data: {
                        currency: 'eur',
                        product_data: {
                            name: 'Ricarica',
                        },
                        unit_amount: amount,
                    },
                    quantity: 1,
                },
            ],
            mode: 'payment',
            success_url: successUrl,
            cancel_url: cancelUrl,
        });

        res.send({ url: session.url });
    } catch (error) {
        console.error("Errore durante la creazione della sessione di checkout:", error);
        res.status(500).send('Errore interno del server');
    }
});