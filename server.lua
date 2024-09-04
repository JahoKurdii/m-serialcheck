
-- Use the configuration values
local expectedSerial = "YourSerialNumber" -- open cmd and type | wmic bios get serialnumber 
local webhookURL = "YOUR_WEBHOOK" -- discord webhook

-- Function to send an embed message to the Discord webhook
function sendDiscordEmbed(title, description, color, fields)
    local embed = {
        ["title"] = title,
        ["description"] = description,
        ["color"] = color,
        ["fields"] = fields,
        ["footer"] = {
            ["text"] = "M Developemnt / JahoKurdi",
        },
        ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ") -- UTC time in ISO format
    }

    local payload = json.encode({embeds = {embed}})
    PerformHttpRequest(webhookURL, function(err, text, headers) 
        if err == 204 then
            print("[Webhook] Message sent but no content returned (Error 204).")
        elseif err == 0 then
            print("[Webhook] Embed sent successfully!")
        else
            print("[Webhook] Failed to send embed. Error: " .. err)
        end
    end, "POST", payload, {["Content-Type"] = "application/json"})
end

-- Function to trim whitespace
function string:trim()
    return self:match("^%s*(.-)%s*$")
end

-- Function to retrieve the BIOS serial number using WMIC
function getSerialNumber()
    local handle = io.popen("wmic bios get serialnumber")
    if handle then
        local result = handle:read("*a")
        handle:close()
        -- Extract the serial number using pattern matching
        local serial = result:match("SerialNumber%s+(.+)")
        if serial then
            return serial:trim()
        end
    end
    return nil
end

-- Function to retrieve the server's IP address
function getServerIPAddress()
    local handle = io.popen("curl -s ifconfig.me")
    if handle then
        local ipAddress = handle:read("*a")
        handle:close()
        return ipAddress:trim()
    end
    return "Unknown IP"
end

-- Thread to perform the serial check and send webhook notifications
Citizen.CreateThread(function()
    -- Notify Discord that the server is starting
    sendDiscordEmbed("🚀 Server Starting", "The server is initializing.", 3066993, {}) -- Green color

    -- Allow some time for the server to initialize
    Citizen.Wait(1000)

    local serial = getSerialNumber()
    local ipAddress = getServerIPAddress()

    if not serial then
        sendDiscordEmbed(
            "❌ Server Error",
            "Unable to retrieve the server's serial number. Shutting down.",
            15158332, -- Red color
            {
                {["name"] = "IP Address", ["value"] = ipAddress, ["inline"] = true},
            }
        )
        print("^1[Serial Check] ERROR: Unable to retrieve the server's serial number. Shutting down.^0")
        Citizen.Wait(5000) -- Wait for 5 seconds before shutting down
        os.exit()
    elseif serial ~= expectedSerial then
        sendDiscordEmbed(
            "❌ Serial Number Mismatch",
            "Server serial number mismatch. Shutting down.",
            15158332, -- Red color
            {
                {["name"] = "Serial Number", ["value"] = serial, ["inline"] = true},
                {["name"] = "IP Address", ["value"] = ipAddress, ["inline"] = true},
            }
        )
        print("^1[Serial Check] ERROR: Server serial number mismatch. Shutting down.^0")
        Citizen.Wait(5000) -- Wait for 5 seconds before shutting down
        os.exit()
    else
        sendDiscordEmbed(
            "✅ Server Running",
            "Server serial number verified. Server is running normally.",
            3066993, 
            {}
        )
        print("^2[Serial Check] Server serial number verified. Server is running normally.^0")
    end
end)

-- Function to notify Discord when the server shuts down
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        sendDiscordEmbed("🔌 Server Shutting Down", "The server is shutting down.", 10038562, {}) 
    end
end)
