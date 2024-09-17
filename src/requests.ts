import { RequestInfo } from "node-fetch";

export async function DiscordRequest(endpoint: RequestInfo, method: string, body: any /* TODO: Define Discord request object shape. */) {
    const url: RequestInfo = `https://discord.com/api/v10/applications/${process.env.APP_ID}/${endpoint}`;

    const request: RequestInit = {
        method: method,
        headers: {
            Authorization: `Bot ${process.env.DISCORD_TOKEN}`,
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(body)
    };

    // TODO: Handle Discord errors here.
    const res = await fetch(url, request);
    const data = await res.json();
    return data;
}