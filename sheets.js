// sheets.js
import { google } from "googleapis";
import { JWT } from "google-auth-library";

const SHEET_ID = "1ZqwipNLTzZq3yKfLyMuuDNTYeC2lHCn_a_Os9FXlqIc";
const SHEET_TAB = "whiteList";

const credentials = require("./assets/service-account.json");

const jwtClient = new JWT({
  email: credentials.client_email,
  key: credentials.private_key,
  scopes: ["https://www.googleapis.com/auth/spreadsheets.readonly"],
});

const sheets = google.sheets({ version: "v4", auth: jwtClient });

export async function fetchWhitelistFromSheet() {
  try {
    const res = await sheets.spreadsheets.values.get({
      spreadsheetId: SHEET_ID,
      range: `${SHEET_TAB}!A:A`,
    });

    const rows = res.data.values;
    if (!rows || rows.length === 0) return [];

    return rows.slice(1).map((row) => row[0].toString().trim());
  } catch (error) {
    console.error("❌ Failed to fetch whitelist:", error);
    return [];
  }
}

