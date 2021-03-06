
local ffi = require("ffi")
local bit = require("bit")
local band = bit.band

local WinSock = require("WinSock_Utils");
local ws2_32 = require("ws2_32");
local core_sysinfo = require("core_sysinfo_l1_2_0");

local WSAProtocolInfo_t = {}
local WSAProtocolInfo_mt = {
	__index = WSAProtocolInfo_t;

	__tostring = function(self)
		local res = {}

		table.insert(res, "Name: "..self.Name)
		table.insert(res, "Version: "..self.Version)
		table.insert(res, "Family: "..WinSock.families[self.AddressFamily]);
		table.insert(res, "Sock Type: "..WinSock.socktypes[self.SocketType]);
		table.insert(res, "Protocol: "..WinSock.protocols[self.Protocol]);
		table.insert(res, "Message Size: "..self.MessageSize);
		table.insert(res, "Byte Order: "..self.NetworkByteOrder);
		table.insert(res, "Min Address: "..self.MinSockAddr);
		table.insert(res, "Max Address: "..self.MaxSockAddr);

		return table.concat(res, '\n')
	end,
}

local function WSAProtocolInfo(info)
	local obj = {
		dwServiceFlags1 = info.dwServiceFlags1;
		--ProviderId = GUID.new(info.ProviderId);
		--ProtocolChain = info.ProtocolChain;
		Version = info.iVersion;
		CatalogEntry = info.dwCatalogEntryId;
		AddressFamily = info.iAddressFamily;
		MaxSockAddr = info.iMaxSockAddr;
		MinSockAddr = info.iMinSockAddr;
		SocketType = info.iSocketType;
		Protocol = info.iProtocol;
		ProtocolMaxOffset = info.iProtocolMaxOffset;
		NetworkByteOrder = info.iNetworkByteOrder;
		SecurityScheme = info.iSecurityScheme;
		MessageSize = info.dwMessageSize;
		Name = ffi.string(info.szProtocol)
	}
	setmetatable(obj, WSAProtocolInfo_mt)

	return obj;
end


local Network = {}

function Network.getHostName(self, nametype)
	nametype = nametype or ffi.C.ComputerNameDnsFullyQualified
	local bufflen = 256;
	local lpBuffer = ffi.new("char[?]", bufflen);
	local nSize = ffi.new("DWORD[1]", bufflen);

	local NameType = nametype;

	local res = core_sysinfo.GetComputerNameExA (NameType,lpBuffer,nSize);

	if res == 0 then
		return false --, GetLastError();
	end

	return ffi.string(lpBuffer, nSize[0])
end

function Network.GetProtocols(self)
	local results, err = WinSock.WSAEnumProtocols();

	if not results then
		--print("GetProtocols(), ERROR: ", err)
		return nil, err
	end


	local protos = {}
	
	for counter = 0, results.count-1 do
		table.insert(protos, WSAProtocolInfo(results.infos[counter]))
	end

	return protos;
end

function Network.GetInterfaces(self, stype)
    stype = stype or SOCK_STREAM;

    local interfaces = {};

    -- create a socket of the specified type
    local sd, err = WinSock.WSASocket(AF_INET, stype, 0, nil, 0, 0);

    if (sd == nil) then
        return false, err;
    end

    -- Allocate some storage for the list of interfaces
    local InterfaceList = ffi.new("INTERFACE_INFO[20]");
    local lpnBytesReturned = ffi.new("uint32_t[1]");
    local success, err = WinSock.WSAIoctl(sd, 
    	SIO_GET_INTERFACE_LIST, 
    	nil, 0, 
    	InterfaceList,
        ffi.sizeof(InterfaceList), 
        lpnBytesReturned, 
        nil, nil);

    if not success then
        --io.stderr:write("Failed calling WSAIoctl: error ", WSAGetLastError(), "\n");
        return false, err;
    end


    local nBytesReturned = lpnBytesReturned[0];

    local nNumInterfaces = nBytesReturned / ffi.sizeof("INTERFACE_INFO");

    local i = 0;
    while (i < nNumInterfaces) do

        local pAddress = ffi.cast("struct sockaddr_in *", InterfaceList[i].iiAddress);
        local bAddress = ffi.cast("struct sockaddr_in *", InterfaceList[i].iiBroadcastAddress);
        local nMask = ffi.cast("struct sockaddr_in *", InterfaceList[i].iiNetmask);
        local nFlags = InterfaceList[i].iiFlags;

        table.insert(interfaces,{
        	address = ffi.string(ws2_32.inet_ntoa(pAddress.sin_addr)),
        	broadcast = ffi.string(ws2_32.inet_ntoa(bAddress.sin_addr)),
        	netmask = ffi.string(ws2_32.inet_ntoa(nMask.sin_addr)),
        	
        	isloopback = band(nFlags, IFF_LOOPBACK)>0,
        	ispointtopoint = band(nFlags, IFF_POINTTOPOINT)>0,
    	   	isup = band(nFlags, IFF_UP) > 0,

        	canbroadcast = band(nFlags, IFF_BROADCAST)>0,
        	canmulticast = band(nFlags, IFF_MULTICAST)>0,
        	});

        i = i + 1;
    end

    return interfaces;
end

function Network.GetLocalAddress(self)

	local interfaces = Network:GetInterfaces();

	for _,interface in pairs(interfaces) do
		if (not interface.isloopback) and interface.isup then
			return interface.address
		end
	end	
end

return Network