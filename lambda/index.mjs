const nacl = require('tweetnacl');

/**
 * Lambda function entry point event handler.
 * @param event Discord event object.
 * @see https://discord.com/developers/docs/interactions/application-commands#application-command-object
 * @see https://discord.com/developers/docs/interactions/overview#setting-up-an-endpoint
 * @returns HTTP Response object.
 */
exports.handler = async (event) => {
	// Define bare response object - https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html?icmpid=apigateway_console#api-gateway-simple-proxy-for-lambda-output-format
	let res = {
		"statusCode": 200,
		"headers": {
			"Access-Control-Allow-Origin": "*",
			"Content-Type": "application/json"
		},
		"body": ""
	};

	// Check signature of Discord event object.
	const PUBLIC_KEY = process.env.PUBLIC_KEY;
	const reqSignature = event.headers['x-signature-ed25519'];
	const reqTimestamp = event.headers['x-signature-timestamp'];
	const reqBody = event.body;

	const isVerified = nacl.sign.detached.verify(
		Buffer.from(reqTimestamp + reqBody),
		Buffer.from(reqSignature, 'hex'),
		Buffer.from(PUBLIC_KEY, 'hex')
	);

	// Return a 401 Unauthorized - used during Discord security checks.
	if (!isVerified) {
		res.statusCode = 401;
		return res;
	}

	// Reply to ping from Discord.
	const body = JSON.parse(reqBody);
	if (body.type == 1) {
		res.body = JSON.stringify({ "type": 1 });
		return res;
	}
}