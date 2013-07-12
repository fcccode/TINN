
local ffi = require("ffi");

local IOProcessor = require("IOProcessor");
local IOCPSocket = require("IOCPSocket");


IOProcessor:setMessageQuanta(nil);

SocketServer = {}
setmetatable(SocketServer, {
  __call = function(self, ...)
    return self:create(...);
  end,
});

SocketServer_mt = {
  __index = SocketServer;
}

SocketServer.init = function(self, socket, datafunc)
--print("SocketServer.init: ", socket, datafunc)
  local obj = {
    ServerSocket = socket;
    OnData = datafunc;
  };

  setmetatable(obj, SocketServer_mt);

  return obj;
end

SocketServer.create = function(self, port, datafunc)
  port = port or 9090;

  local socket, err = IOProcessor:createServerSocket({port = port, backlog = 15});
	
  if not socket then 
    print("Server Socket not created!!")
    return nil, err
  end

  return self:init(socket, datafunc);
end


-- The primary application loop
SocketServer.loop = function(self)
  local bufflen = 1500;
  local buff = ffi.new("uint8_t[?]", bufflen);

  while true do
    local sock, err = self.ServerSocket:accept();

    if sock then
      local socket = IOCPSocket:init(sock, IOProcessor);
      local bytesread, err = socket:receive(buff, bufflen);
			
      if not bytesread then
        print("RECEIVE ERROR: ", err);
      elseif self.OnData ~= nil then
        self.OnData(socket, buff, bytesread);
      else
        socket:closeDown();
        socket = nil
			end
    else
       print("Accept ERROR: ", err);
    end

    collectgarbage();
  end
end

SocketServer.run = function(self, datafunc)
  if datafunc then
    self.OnData = datafunc;
  end

  print("spawn: ", spawn(self.loop, self));
  run();
end


return SocketServer;
