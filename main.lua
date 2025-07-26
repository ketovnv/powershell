-- Load the debugger module
local dbg = require('emmy_core')

dbg.tcpListen('localhost', 9999)
-- Start the TCP debug server

package.cpath = package.cpath .. ';C:/Users/ketov/AppData/Roaming/JetBrains/WebStorm2025.1/plugins/IntelliJ-EmmyLua2/debugger/emmy/windows/x64/?.dll'
-- Wait for IDE connection
dbg.waitIDE()

-- Set a strong breakpoint here
dbg.breakHere()

-- Your Lua code
print("Hello, EmmyLua Debugger!")



