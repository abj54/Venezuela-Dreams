// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const logging = require('@google-cloud/logging')();

admin.initializeApp(functions.config().firebase);

const stripe = require('stripe')(functions.config().stripe.testkey);
const currency = functions.config().stripe.currency || 'USD';

// [START chargecustomer]
// Charge the Stripe customer whenever an amount is written to the Realtime database
var child_id = ""
exports.createStripeCharge = functions.database.ref('/transactions/userId/{userId}/transactionId/{transactionId}').onWrite((event) => {
    
  const val = event.data.val();
  child_id = val.child_id
  // This onWrite will trigger whenever anything is written to the path, so
  // noop if the charge was deleted, errored out, or the Stripe API returned a result (id exists)
  if (val === null || val.transactionId || val.error) return null;
  // Look up the Stripe userId and transactionId
  return admin.database().ref(`/user/${event.params.userId}/stripe_id`).once('value').then((snapshot) => {
    return snapshot.val();
  }).then((customer) => {
    // Create a charge using the transactionId as the idempotency key, protecting against double charges
    const amount = val.amount;
    const idempotency_key = event.params.transactionId;
      
    let charge = {amount, currency, customer};
    if (val.source !== null) charge.source = val.source;
    if (val.token !== null) charge.source = val.token;
    return stripe.charges.create(charge, {idempotency_key});
  }).then((response) => {
    // If the result is successful, write it back to the database
    //admin.database().ref(`/transactions/userId/${event.params.userId}/transactionId/${event.params.transactionId}/child_id`).set(child_id);
    return event.data.adminRef.set(response)
  }).catch((error) => {
    // We want to capture errors and render them in a user-friendly way, while
    // still logging an exception with Stackdriver
    return event.data.adminRef.child('error').set(userFacingMessage(error));
  }).then(() => {
    return reportError(error, {user: event.params.userId});
  });
});
// [END chargecustomer]]

exports.StripeEphemeralKeys = functions.https.onRequest((req, res) => {
  const stripe_version = req.body.api_version;
  const customerId = req.body.customerId
  if (!stripe_version) {
    console.log('I did not see any api version')
    res.status(400).end()
    return;
  }

  stripe.ephemeralKeys.create(
    {customer: customerId},
    {stripe_version: stripe_version}
  ).then((key) => {
     console.log("Ephemeral key: " + key)
     res.status(200).json(key)
     return
  }).catch((err) => {
    console.log('stripe version is ' + stripe_version + " and customer id is " + customerId + " for key: " + stripe_key + " and err is " + err.message )
    res.status(500).json(err)
    return
  });
});

// When a user is created, register them with Stripe
exports.createStripeCustomer = functions.auth.user().onCreate((event) => {
  const data = event.data;
  return stripe.customers.create({
    email: data.email,
  }).then((customer) => {
    return admin.database().ref(`/user/${data.uid}/stripe_id`).set(customer.id);
  });
});

// To keep on top of errors, we should raise a verbose error report with Stackdriver rather
// than simply relying on console.error. This will calculate users affected + send you email
// alerts, if you've opted into receiving them.
// [START reporterror]
function reportError(err, context = {}) {
  // This is the name of the StackDriver log stream that will receive the log
  // entry. This name can be any valid log stream name, but must contain "err"
  // in order for the error to be picked up by StackDriver Error Reporting.
  const logName = 'errors';
  const log = logging.log(logName);

  // https://cloud.google.com/logging/docs/api/ref_v2beta1/rest/v2beta1/MonitoredResource
  const metadata = {
    resource: {
      type: 'cloud_function',
      labels: {function_name: process.env.FUNCTION_NAME},
    },
  };

  // https://cloud.google.com/error-reporting/reference/rest/v1beta1/ErrorEvent
  const errorEvent = {
    message: err.stack,
    serviceContext: {
      service: process.env.FUNCTION_NAME,
      resourceType: 'cloud_function',
    },
    context: context,
  };

  // Write the error log entry
  return new Promise((resolve, reject) => {
    log.write(log.entry(metadata, errorEvent), (error) => {
      if (error) {
 reject(error);
}
      resolve();
    });
  });
}
// [END reporterror]

// Sanitize the error message for the user
function userFacingMessage(error) {
  return error.type ? error.message : 'An error occurred, developers have been alerted';
}