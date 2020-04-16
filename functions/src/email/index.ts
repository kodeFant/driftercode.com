import * as mailgun from "mailgun-js";
import * as functions from "firebase-functions";

const apiKey = functions.config().mailgun.apikey;
const domain = "mg.driftercode.com";
const options: mailgun.ConstructorParams = {
  host: "api.eu.mailgun.net",
  apiKey,
  domain,
};

export const from = "DrifterCode <noreply@driftercode.com>"; // Set your from email
export const mg = mailgun(options);
