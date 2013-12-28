
local ffi = require("ffi")
local WTypes = require("WTypes")
local propsys = require("propsys")



ffi.cdef[[
typedef struct IMMNotificationClient IMMNotificationClient;
typedef struct IMMDevice IMMDevice;
typedef struct IMMDeviceCollection IMMDeviceCollection;
typedef struct IMMEndpoint IMMEndpoint;
typedef struct IMMDeviceEnumerator IMMDeviceEnumerator;
typedef struct IMMDeviceActivator IMMDeviceActivator;


typedef struct MMDeviceEnumerator MMDeviceEnumerator;
]]


--[[
#define E_NOTFOUND HRESULT_FROM_WIN32(ERROR_NOT_FOUND)
#define E_UNSUPPORTED_TYPE HRESULT_FROM_WIN32(ERROR_UNSUPPORTED_TYPE)
--]]

ffi.cdef[[
static const int DEVICE_STATE_ACTIVE     = 0x00000001;
static const int DEVICE_STATE_DISABLED   = 0x00000002;
static const int DEVICE_STATE_NOTPRESENT = 0x00000004;
static const int DEVICE_STATE_UNPLUGGED  = 0x00000008;
static const int DEVICE_STATEMASK_ALL    = 0x0000000f;
]]

--[[
#ifdef DEFINE_PROPERTYKEY
#undef DEFINE_PROPERTYKEY
#endif
--]]

--[[
#ifdef INITGUID
#define DEFINE_PROPERTYKEY(name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8, pid) EXTERN_C const PROPERTYKEY name = { { l, w1, w2, { b1, b2,  b3,  b4,  b5,  b6,  b7,  b8 } }, pid }
#else
#define DEFINE_PROPERTYKEY(name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8, pid) EXTERN_C const PROPERTYKEY name
#endif // INITGUID
--]]

function DEFINE_PROPERTYKEY(name, l, w1, w2, b1, b2, b3, b4, b5, b6, b7, b8, pid)
    local pkey = ffi.new("PROPERTYKEY", { { l, w1, w2, { b1, b2,  b3,  b4,  b5,  b6,  b7,  b8 } }, pid })
    _G[name] = pkey
    return pkey
end


DEFINE_PROPERTYKEY("PKEY_AudioEndpoint_FormFactor", 0x1da5d803, 0xd492, 0x4edd, 0x8c, 0x23, 0xe0, 0xc0, 0xff, 0xee, 0x7f, 0x0e, 0); 
DEFINE_PROPERTYKEY("PKEY_AudioEndpoint_ControlPanelPageProvider", 0x1da5d803, 0xd492, 0x4edd, 0x8c, 0x23, 0xe0, 0xc0, 0xff, 0xee, 0x7f, 0x0e, 1); 
DEFINE_PROPERTYKEY("PKEY_AudioEndpoint_Association", 0x1da5d803, 0xd492, 0x4edd, 0x8c, 0x23, 0xe0, 0xc0, 0xff, 0xee, 0x7f, 0x0e, 2);
DEFINE_PROPERTYKEY("PKEY_AudioEndpoint_PhysicalSpeakers", 0x1da5d803, 0xd492, 0x4edd, 0x8c, 0x23, 0xe0, 0xc0, 0xff, 0xee, 0x7f, 0x0e, 3);
DEFINE_PROPERTYKEY("PKEY_AudioEndpoint_GUID", 0x1da5d803, 0xd492, 0x4edd, 0x8c, 0x23, 0xe0, 0xc0, 0xff, 0xee, 0x7f, 0x0e, 4);
DEFINE_PROPERTYKEY("PKEY_AudioEndpoint_Disable_SysFx", 0x1da5d803, 0xd492, 0x4edd, 0x8c, 0x23, 0xe0, 0xc0, 0xff, 0xee, 0x7f, 0x0e, 5);


ffi.cdef[[
static const int ENDPOINT_SYSFX_ENABLED        =  0x00000000;  // System Effects are enabled.
static const int ENDPOINT_SYSFX_DISABLED       =  0x00000001;  // System Effects are disabled.
]]


DEFINE_PROPERTYKEY("PKEY_AudioEndpoint_FullRangeSpeakers", 0x1da5d803, 0xd492, 0x4edd, 0x8c, 0x23, 0xe0, 0xc0, 0xff, 0xee, 0x7f, 0x0e, 6);
DEFINE_PROPERTYKEY("PKEY_AudioEndpoint_Supports_EventDriven_Mode", 0x1da5d803, 0xd492, 0x4edd, 0x8c, 0x23, 0xe0, 0xc0, 0xff, 0xee, 0x7f, 0x0e, 7);
DEFINE_PROPERTYKEY("PKEY_AudioEndpoint_JackSubType", 0x1da5d803, 0xd492, 0x4edd, 0x8c, 0x23, 0xe0, 0xc0, 0xff, 0xee, 0x7f, 0x0e, 8);
DEFINE_PROPERTYKEY("PKEY_AudioEngine_DeviceFormat", 0xf19f064d, 0x82c, 0x4e27, 0xbc, 0x73, 0x68, 0x82, 0xa1, 0xbb, 0x8e, 0x4c, 0); 
DEFINE_PROPERTYKEY("PKEY_AudioEngine_OEMFormat", 0xe4870e26, 0x3cc5, 0x4cd2, 0xba, 0x46, 0xca, 0xa, 0x9a, 0x70, 0xed, 0x4, 3); 


ffi.cdef[[
typedef struct tagDIRECTX_AUDIO_ACTIVATION_PARAMS
    {
    DWORD cbDirectXAudioActivationParams;
    GUID guidAudioSession;
    DWORD dwAudioStreamFlags;
    } 	DIRECTX_AUDIO_ACTIVATION_PARAMS;

typedef struct tagDIRECTX_AUDIO_ACTIVATION_PARAMS *PDIRECTX_AUDIO_ACTIVATION_PARAMS;
]]

ffi.cdef[[
typedef enum 
    {	
    eRender	= 0,
	eCapture,
	eAll,
	EDataFlow_enum_count 
    } 	EDataFlow;

typedef enum
    {	eConsole	= 0,
	eMultimedia,
	eCommunications,
	ERole_enum_count 
    } 	ERole;

typedef  enum 
    {	
    RemoteNetworkDevice	= 0,
	Speakers,
	LineLevel,
	Headphones,
	Microphone,
	Headset,
	Handset,
	UnknownDigitalPassthrough,
	SPDIF,
	DigitalAudioDisplayDevice,
	UnknownFormFactor,
	EndpointFormFactor_enum_count
    } 	EndpointFormFactor;
]]
--#define HDMI     DigitalAudioDisplayDevice



ffi.cdef[[
    typedef struct IMMNotificationClientVtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IMMNotificationClient * This,
            REFIID riid,
            /* [annotation][iid_is][out] */ 
            void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IMMNotificationClient * This);
        
        ULONG ( __stdcall *Release )( 
            IMMNotificationClient * This);
        
        HRESULT ( __stdcall *OnDeviceStateChanged )( 
            IMMNotificationClient * This,
            /* [annotation][in] */ 
            LPCWSTR pwstrDeviceId,
            /* [annotation][in] */ 
            DWORD dwNewState);
        
        HRESULT ( __stdcall *OnDeviceAdded )( 
            IMMNotificationClient * This,
            /* [annotation][in] */ 
            LPCWSTR pwstrDeviceId);
        
        HRESULT ( __stdcall *OnDeviceRemoved )( 
            IMMNotificationClient * This,
            /* [annotation][in] */ 
            LPCWSTR pwstrDeviceId);
        
        HRESULT ( __stdcall *OnDefaultDeviceChanged )( 
            IMMNotificationClient * This,
            /* [annotation][in] */ 
            EDataFlow flow,
            /* [annotation][in] */ 
            ERole role,
            /* [annotation][in] */ 
            LPCWSTR pwstrDefaultDeviceId);
        
        HRESULT ( __stdcall *OnPropertyValueChanged )( 
            IMMNotificationClient * This,
            /* [annotation][in] */ 
            LPCWSTR pwstrDeviceId,
            /* [annotation][in] */ 
            const PROPERTYKEY key);
        
    } IMMNotificationClientVtbl;

    typedef struct IMMNotificationClient
    {
        const struct IMMNotificationClientVtbl *lpVtbl;
    } IMMNotificationClient;
]]
    
--[[
#define IMMNotificationClient_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IMMNotificationClient_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IMMNotificationClient_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IMMNotificationClient_OnDeviceStateChanged(This,pwstrDeviceId,dwNewState)	\
    ( (This)->lpVtbl -> OnDeviceStateChanged(This,pwstrDeviceId,dwNewState) ) 

#define IMMNotificationClient_OnDeviceAdded(This,pwstrDeviceId)	\
    ( (This)->lpVtbl -> OnDeviceAdded(This,pwstrDeviceId) ) 

#define IMMNotificationClient_OnDeviceRemoved(This,pwstrDeviceId)	\
    ( (This)->lpVtbl -> OnDeviceRemoved(This,pwstrDeviceId) ) 

#define IMMNotificationClient_OnDefaultDeviceChanged(This,flow,role,pwstrDefaultDeviceId)	\
    ( (This)->lpVtbl -> OnDefaultDeviceChanged(This,flow,role,pwstrDefaultDeviceId) ) 

#define IMMNotificationClient_OnPropertyValueChanged(This,pwstrDeviceId,key)	\
    ( (This)->lpVtbl -> OnPropertyValueChanged(This,pwstrDeviceId,key) ) 

#endif /* COBJMACROS */
--]]






ffi.cdef[[
    typedef struct IMMDeviceVtbl
    {      
        HRESULT ( __stdcall *QueryInterface )(IMMDevice * This,
            REFIID riid,
            void **ppvObject);
        
        ULONG ( __stdcall *AddRef )(IMMDevice * This);
        
        ULONG ( __stdcall *Release )(IMMDevice * This);
        
        HRESULT ( __stdcall *Activate )( 
            IMMDevice * This,
            REFIID iid,
            DWORD dwClsCtx,
            PROPVARIANT *pActivationParams,
            void **ppInterface);
        
        HRESULT ( __stdcall *OpenPropertyStore )( 
            IMMDevice * This,
            DWORD stgmAccess,
            IPropertyStore **ppProperties);
        
        HRESULT ( __stdcall *GetId )( 
            IMMDevice * This,
            LPWSTR *ppstrId);
        
        HRESULT ( __stdcall *GetState )( 
            IMMDevice * This,
            DWORD *pdwState);
        
    } IMMDeviceVtbl;

    typedef struct IMMDevice
    {
        const struct IMMDeviceVtbl *lpVtbl;
    }IMMDevice;
]]
    
local IMMDevice = ffi.typeof("IMMDevice")
local IMMDevice_mt = {
    __index = {
        GetId = function(self, ppstrId)
            self.lpVtbl.GetId(self,ppstrId) 
        end,

        GetState = function(self, pdwState)
            self.lpVtbl.GetState(self,pdwState)
        end,

        OpenPropertyStore = function(self, stgmAccess, ppProperties)
            stgmAccess = stgmAccess or ffi.C.STGM_READ
            return self.lpVtbl.OpenPropertyStore(self,stgmAccess,ppProperties) 
        end,

    },
}
ffi.metatype(IMMDevice, IMMDevice_mt)


--[[
#define IMMDevice_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IMMDevice_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IMMDevice_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IMMDevice_Activate(This,iid,dwClsCtx,pActivationParams,ppInterface)	\
    ( (This)->lpVtbl -> Activate(This,iid,dwClsCtx,pActivationParams,ppInterface) ) 

--]]



ffi.cdef[[

    typedef struct IMMDeviceCollectionVtbl
    {     
        HRESULT ( __stdcall *QueryInterface )( 
            IMMDeviceCollection * This,
            REFIID riid,
            void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IMMDeviceCollection * This);
        
        ULONG ( __stdcall *Release )( 
            IMMDeviceCollection * This);
        
        HRESULT ( __stdcall *GetCount )( 
            IMMDeviceCollection * This,
            UINT *pcDevices);
        
        HRESULT ( __stdcall *Item )( 
            IMMDeviceCollection * This,
            UINT nDevice,
            IMMDevice **ppDevice);
    } IMMDeviceCollectionVtbl;

    typedef struct IMMDeviceCollection
    {
        const struct IMMDeviceCollectionVtbl *lpVtbl;
    }IMMDeviceCollection;
]]
IMMDeviceCollection = ffi.typeof("IMMDeviceCollection") 
IMMDeviceCollection_mt = {
    __index = {
        GetCount = function(self, pcDevices)
            return self.lpVtbl.GetCount(self,pcDevices) 
        end,

        Item = function(self, nDevice, ppDevice)
            return self.lpVtbl.Item(self, nDevice, ppDevice)
        end, 
    },
}
ffi.metatype(IMMDeviceCollection, IMMDeviceCollection_mt)


--[[
#define IMMDeviceCollection_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IMMDeviceCollection_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IMMDeviceCollection_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 
--]]




ffi.cdef[[
    typedef struct IMMEndpointVtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IMMEndpoint * This,
            REFIID riid,
            void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IMMEndpoint * This);
        
        ULONG ( __stdcall *Release )( 
            IMMEndpoint * This);
        
        HRESULT ( __stdcall *GetDataFlow )( 
            IMMEndpoint * This,
            EDataFlow *pDataFlow);
        
    } IMMEndpointVtbl;

    typedef struct IMMEndpoint
    {
        const struct IMMEndpointVtbl *lpVtbl;
    }IMMEndpoint;
]]
local IMMEndpoint = ffi.typeof("IMMEndpoint")
local IMMEndpoint_mt = {
    __index = {
        GetDataFlow = function(self, pDataFlow)
            return self.lpVtbl.GetDataFlow(self,pDataFlow) 
        end,
    },
}
    
--[[
#define IMMEndpoint_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IMMEndpoint_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IMMEndpoint_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 
--]]




ffi.cdef[[
    typedef struct IMMDeviceEnumeratorVtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IMMDeviceEnumerator * This,
            REFIID riid,
            /* [annotation][iid_is][out] */ 
            void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IMMDeviceEnumerator * This);
        
        ULONG ( __stdcall *Release )( 
            IMMDeviceEnumerator * This);
        
        HRESULT ( __stdcall *EnumAudioEndpoints )( 
            IMMDeviceEnumerator * This,
            EDataFlow dataFlow,
            DWORD dwStateMask,
            IMMDeviceCollection **ppDevices);
        
        HRESULT ( __stdcall *GetDefaultAudioEndpoint )( 
            IMMDeviceEnumerator * This,
            EDataFlow dataFlow,
            ERole role,
            IMMDevice **ppEndpoint);
        
        HRESULT ( __stdcall *GetDevice )( 
            IMMDeviceEnumerator * This,
            LPCWSTR pwstrId,
            IMMDevice **ppDevice);
        
        HRESULT ( __stdcall *RegisterEndpointNotificationCallback )( 
            IMMDeviceEnumerator * This,
            IMMNotificationClient *pClient);
        
        HRESULT ( __stdcall *UnregisterEndpointNotificationCallback )( 
            IMMDeviceEnumerator * This,
            IMMNotificationClient *pClient);
        
    } IMMDeviceEnumeratorVtbl;

    typedef struct IMMDeviceEnumerator
    {
        const struct IMMDeviceEnumeratorVtbl *lpVtbl;
    }IMMDeviceEnumerator;
]]

local IMMDeviceEnumerator = ffi.typeof("struct IMMDeviceEnumerator")
local IMMDeviceEnumerator_mt = {
    __index = {
        EnumAudioEndpoints = function(self, dataFlow, dwStateMask, ppDevices)
        --print("EnumAudioEndpoints: ", self, dataFlow, dwStateMask, ppDevices)
            return self.lpVtbl.EnumAudioEndpoints(self,dataFlow,dwStateMask,ppDevices) 
        end,
    },
}
ffi.metatype(IMMDeviceEnumerator, IMMDeviceEnumerator_mt)

--[[
#define IMMDeviceEnumerator_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IMMDeviceEnumerator_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IMMDeviceEnumerator_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 



#define IMMDeviceEnumerator_GetDefaultAudioEndpoint(This,dataFlow,role,ppEndpoint)	\
    ( (This)->lpVtbl -> GetDefaultAudioEndpoint(This,dataFlow,role,ppEndpoint) ) 

#define IMMDeviceEnumerator_GetDevice(This,pwstrId,ppDevice)	\
    ( (This)->lpVtbl -> GetDevice(This,pwstrId,ppDevice) ) 

#define IMMDeviceEnumerator_RegisterEndpointNotificationCallback(This,pClient)	\
    ( (This)->lpVtbl -> RegisterEndpointNotificationCallback(This,pClient) ) 

#define IMMDeviceEnumerator_UnregisterEndpointNotificationCallback(This,pClient)	\
    ( (This)->lpVtbl -> UnregisterEndpointNotificationCallback(This,pClient) ) 
--]]



ffi.cdef[[
    typedef struct IMMDeviceActivatorVtbl
    {
                
        HRESULT ( __stdcall *QueryInterface )( 
            IMMDeviceActivator * This,
            REFIID riid,
            void **ppvObject);
        
        ULONG ( __stdcall *AddRef )( 
            IMMDeviceActivator * This);
        
        ULONG ( __stdcall *Release )( 
            IMMDeviceActivator * This);
        
        HRESULT ( __stdcall *Activate )( 
            IMMDeviceActivator * This,
            REFIID iid,
            IMMDevice *pDevice,
            PROPVARIANT *pActivationParams,
            void **ppInterface);
        
    } IMMDeviceActivatorVtbl;

    typedef struct IMMDeviceActivator
    {
        const struct IMMDeviceActivatorVtbl *lpVtbl;
    }IMMDeviceActivator;
]]
    


--[[
#define IMMDeviceActivator_QueryInterface(This,riid,ppvObject)	\
    ( (This)->lpVtbl -> QueryInterface(This,riid,ppvObject) ) 

#define IMMDeviceActivator_AddRef(This)	\
    ( (This)->lpVtbl -> AddRef(This) ) 

#define IMMDeviceActivator_Release(This)	\
    ( (This)->lpVtbl -> Release(This) ) 


#define IMMDeviceActivator_Activate(This,iid,pDevice,pActivationParams,ppInterface)	\
    ( (This)->lpVtbl -> Activate(This,iid,pDevice,pActivationParams,ppInterface) ) 
--]]



return {
    CLSID_MMDeviceEnumerator = UUIDFromString("BCDE0395-E52F-467C-8E3D-C4579291692E");
    IID_IMMDevice  = UUIDFromString("D666063F-1587-4E43-81F1-B948E807363F");
    IID_IMMDeviceActivator = UUIDFromString("3B0D0EA4-D0A9-4B0E-935B-09516746FAC0");
    IID_IMMDeviceCollection = UUIDFromString("0BD7A1BE-7A1A-44DB-8397-CC5392387B5E");
    IID_IMMDeviceEnumerator = UUIDFromString("A95664D2-9614-4F35-A746-DE8DB63617E6");
    IID_IMMEndpoint = UUIDFromString("1BE09788-6894-4089-8586-9A2A6C265AC5");
    IID_IMMNotificationClient  = UUIDFromString("7991EEC9-7E89-4D85-8390-6C703CEC60C0");
    
    IMMDeviceEnumerator = IMMDeviceEnumerator,
    IMMDevice = IMMDevice,
    IMMEndpoint = IMMEndpoint,
}
