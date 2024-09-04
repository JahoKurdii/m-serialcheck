Serial Check with Webhook Integration

This FiveM server script performs a security check by verifying the server's serial number against an expected value. If the serial number does not match or cannot be retrieved, the server will shut down, and a notification will be sent to a specified Discord webhook.

Key Features:
  Serial Number Verification: Ensures that the server is running with a valid serial number.
  Discord Notifications: Sends detailed notifications to a Discord webhook when:
  The server starts.
  There is a serial number mismatch.
  The server encounters an error.
  The server shuts down.

Configuartion 
local expectedSerial = "YourSerialNumber" -- open cmd and type | wmic bios get serialnumber 
local webhookURL = "YOUR_WEBHOOK" -- discord webhook

Just Change Serial Number to your SerialNumber

webhookURL you discordwebhook

Start the Resource: Load the resource using the FiveM server.
