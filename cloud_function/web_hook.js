"use strict";

// Import the Dialogflow module from the Actions on Google client library.
const { dialogflow } = require("actions-on-google");
// Import the firebase-functions package for deployment.
const functions = require("firebase-functions");

// Instantiate the Dialogflow client.
const app = dialogflow({ debug: true });

app.intent("luckyNum", (conv, { userName }) => {
	let name = userName.name;
	conv.close("Your lucky number is: " + name.length);
});

// Set the DialogflowApp object to handle the HTTPS POST request.
exports.dialogflowFirebaseFulfillment = functions.https.onRequest(app);
