// TODO: Convert to TypeScript.

// Imports.
import "dotenv/config";
import express from "express";
import { verifyKeyMiddleware, InteractionType, InteractionResponseType } from "discord-interactions";

// Create express app.
const app = express();
// Default to port 3000 if not specified.
const PORT = process.env.PORT || 3000;

/**
 * Main entry point for Discord's API.
 */
app.post("/interactions", verifyKeyMiddleware(process.env.PUBLIC_KEY), async function (req, res) {
    const { type, data } = req.body;

    // Handle Discord verification requests.
    if (type === InteractionType.PING) {
        return res.send({ type: InteractionResponseType.PONG });
    }

    // Fallthrough - TODO: replace placeholder with real fallthrough response.
    return res.sendStatus(200);
});

app.listen(PORT, () => {
    console.log('Listening on port', PORT);
});