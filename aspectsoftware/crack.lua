local httpserv = game:GetService("HttpService")

local _request = request or http_request or http and http.request
local new_request = newcclosure(function(http)
    --print(http.Url)
    if http.Url:find("key")
    then
	return {
    StatusMessage = "OK",
    StatusCode = 200,
    Body = httpserv:JSONEncode({
   valid = true,
   key = "CRACKA",
   expiresAt = 99999999999999999,
   duration = 999999999999,
   remainingTime = 999999999999,
   remainingHours = 999,
   createdAt = 1771834112412,
   ip = "14.88.14.88",
   step = 1,
   durationLabel = "99h",
   hwid = nil,
   keyType = "PREMIUM",
   gameId = nil,
   serverId = nil,
   username = 'some11'
    })
}
end
return _request (http)
end)

if request then
    request = new_request 
end

loadstring(game:HttpGet("https://raw.githubusercontent.com/caualelek12/Aspect-Software/refs/heads/main/Loader.lua"))()

