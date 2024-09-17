// Imports.
import "dotenv/config";
import express from "express";
import { verifyKeyMiddleware, InteractionType, InteractionResponseType } from "discord-interactions";
import { HandleCommandInteraction, InstallCommands } from "./commands";

// Create express app.
const app = express();
// Default to port 3000 if not specified.
const PORT = process.env.PORT || 3000;

/**
 * Main entry point for Discord's API.
 */
app.post("/interactions", verifyKeyMiddleware(process.env.PUBLIC_KEY as string), async function (req, res) {
    const { type, data } = req.body;

    switch (type) {
        case InteractionType.PING:
            {
                // Handle Discord verification requests.
                return res.send({ type: InteractionResponseType.PONG });
            }
        case InteractionType.APPLICATION_COMMAND:
            {
                // Handle actual application commands. 
                const responseData = HandleCommandInteraction(data);
                return res.send({
                    type: InteractionResponseType.CHANNEL_MESSAGE_WITH_SOURCE,
                    data: responseData
                });
            }
        default:
            break;
    }

    // Fallthrough - TODO: replace placeholder with real fallthrough response.
    return res.sendStatus(200);
});

app.listen(PORT, () => {
    console.log('Server started on port', PORT);

    // Install bot commands.
    InstallCommands();
});