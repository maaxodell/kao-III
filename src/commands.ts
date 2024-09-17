import { DiscordRequest } from "./requests";

// kaø's bath house id.
const guildId = "738243778187493537";

export function InstallCommands() {
    const commandsEndpoint = `guilds/${guildId}/commands`;

    // Sample command to test the system.
    const TEST_COMMAND = {
        name: 'test',
        description: 'Basic command',
        type: 1,
        integration_types: [0, 1],
        contexts: [0, 1, 2],
    };

    DiscordRequest(commandsEndpoint, "POST", TEST_COMMAND).then((res) => console.log(res));
};

export function HandleCommandInteraction(data: any /* TODO: Interaction object */) {
    // Log the command data.
    console.log("Command name:", data.name);
    console.log("Command payload:", data);

    // Placeholder message response.
    return { content: "Hello World!" };
}