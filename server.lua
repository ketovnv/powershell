-- server.lua
local socket = require("socket")
local server = socket.bind("*", 8080)
print("Lua сервер запущен на порту 8080")

while true do
    local client = server:accept()
    client:send("Привет из Lua!\n")
    client:close()
end