# Data Flow of Control Extension

Top Down Flow:

1. EEP.exe with internal Lua 5.3 (stand-alone program outside control exe)
   - provides API to be used by 2. including variables, setters, getters and callbacks, see `EepOriginalApi.d.lua`

2. Lua Hub (lua/LUA/ce/hub/)
   - sends data to 3. via DataChangeBus
   - receives Lua Commands from 3. after registering

3. Data Bridge (lua/LUA/ce/databridge/)
   - sends data down to 4. via ServerEventBuffer.lua (to file events-from-ce, contract in Lua: `lua/LUA/ca/hub/data/*/*DTOFactory` connected to `apps/web-server/src/server/ce/dto`)
   - receives commands from 4. via IncomingCommandExecutor.lua (from commands-to-ce)

4. Web Server (apps/web-server/)
   - stores data in server store to be independent from Lua
   - sends and receices data to 5. via (Socket.IO / REST-API)

5. Web App (apps/web-app/)
   - connects to server only to send commands and receive data - contract: DTOs in `apps/web-shared/src/dtos/server`
