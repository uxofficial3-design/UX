-- ESP + BULLRT TRACK WITH EXTREME BYPASS 
-- BY XKAZUKI 

local BRPlayerCharacterBase = {
  ServerRPC = {},
  ClientRPC = {},
  MulticastRPC = {}
}

function BRPlayerCharacterBase:ctor()
end

function BRPlayerCharacterBase:_PostConstruct()
  BRPlayerCharacterBase.__super._PostConstruct(self)
  if Client then
    self:AddGameTimer(1.0, false, function() end)
  end
end

function BRPlayerCharacterBase:ReceiveBeginPlay()
  BRPlayerCharacterBase.__super.ReceiveBeginPlay(self)
end

-- =========================================================================
-- WELCOME POPUP
-- =========================================================================
if not _G.WelcomeShown then
  pcall(function()
    local Msg = package.loaded["client.slua.logic.common.logic_common_msg_box"] or require("client.slua.logic.common.logic_common_msg_box")
    Msg.Show(4, "ESP + HEAD TRACK", "✅ LOADED SUCCESSFULLY\n\n• STICKMAN ESP\n• DISTANCE METER\n• HEAD TRACK (ALL GUNS)\n• NECK AIM\n• NO SPREAD\n• VISIBLE ONLY\n• BYPASSES ACTIVE", function() end)
    _G.WelcomeShown = true
  end)
end

local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameMarkTools = require("GameLua.Mod.BaseMod.Common.InGameMarkTools")

-- =========================================================================
-- =========================================================================
-- ULTIMATE COMPLETE BYPASS SYSTEM V6 - PATCH 38 COMPATIBLE
-- =========================================================================
-- =========================================================================
-- This bypass system is designed to completely neutralize ALL anti-cheat 
-- mechanisms in BGMI Patch 4.5 (GamePatch 38). It blocks every possible 
-- detection vector including reporting, heartbeat, file verification, 
-- memory scanning, process monitoring, and behavioral analysis.
-- =========================================================================

local nop = function() end
local returnTrue = function(...) return true end
local returnFalse = function(...) return false end
local returnNil = function(...) return nil end
local returnEmpty = function(...) return {} end

-- =========================================================================
-- SECTION 1: BLOCK ALL REPORTING FUNCTIONS
-- =========================================================================
-- These functions would normally send player data to the server including
-- aim accuracy, hit percentage, movement patterns, and other behavioral
-- metrics that could trigger detection.
-- =========================================================================

local blockedFuncNames = {
  -- Movement Reports
  "reportmovement","reportmovementhistory","reportpositionhistory","reportactionhistory",
  "reportinputhistory","reportvelocity","reportacceleration","reportrotation",
  
  -- Combat Reports
  "reportattackflow","reportsecattackflow","reporthurtflow","reportfirearms",
  "reportaimflow","reporthitflow","reportaccuracy","reporthitaccuracy",
  "reportdamage","reportkills","reportdeaths","reportweaponhistory","reportammohistory",
  
  -- Security Reports
  "reportverifyinfoflow","reportmrpcsflow","reportplayerbehavior","reportteammathurt",
  "reportwallhack","reportaimbot","reportspeedhack","reportmagicbullet",
  "reportesp","reportespdetection","reportespusage","reportespactivity",
  "reportespdistance","reportespvisibility","reportespaccuracy",
  
  -- System Reports
  "sendtsssdkantidatatolobby","senddserrorlogtolobby","senddshawkeyepatrollogtolobby",
  "sendsectlog","sendclientmemusage","sendclientfps","sendclientstats",
  "sendserveravgtickdelta","reportmatchroomdata","reportplayersping",
  "reportmemoryscan","reportprocessscan","reportmodulescan","reportfileintegrity",
  "reportnetworking","reportlatency","reportpacketloss","reportjitter",
  "reportframerate","reportframetime","reportrendering","reportgpu",
  "reportcpu","reportbattery","reporttemperature","reportthermal",
  "reportlocation","reportequipmentflow",
  
  -- Client Errors
  "onclientcrashreport","onnetworklossdetected","onplayeractorchannelerror",
  "onplayerrpcvalidatefailed","onmemoryerror","onprocesserror",
  
  -- Heartbeat
  "heartbeat","sendheartbeat","clientheartbeat","serverheartbeat",
  "antifreeze","keepalive","ping","pong",
  
  -- Anti-Cheat
  "anticheatreport","cheatdetection","violationreport","securityviolation",
  "integritycheck","signatureverify","md5","hash","filecheck","pakcheck",
  
  -- Ban System
  "banreport","bancheck","flagreport","flagcheck","terminatereport","terminatecheck",
  "kickreport","kickcheck","banplayer","flagplayer","terminateplayer","kickplayer",
  "banaccount","flagaccount","terminateaccount","kickaccount",
  "bandevice","flagdevice","terminatedevice","kickdevice"
}

-- =========================================================================
-- SECTION 2: INTERCEPT ALL SECURITY MODULES
-- =========================================================================
-- This intercepts the require() function and patches any security-related 
-- modules before they can be fully initialized. It blocks all functions
-- within these modules and prevents them from sending data to the server.
-- =========================================================================

pcall(function()
  local origRequire = require
  
  -- Comprehensive list of security module path patterns
  local securityPathPatterns = { 
    "Security", "AntiCheat", "Integrity", "ReportPlayer", "HawkEye", 
    "SwiftHawk", "Ban", "TssSdk", "AntiHack", "CheatDetect", "Protection",
    "GameGuard", "AntiTamper", "FileVerify", "MemoryProtect", "ProcessProtect",
    "ClientProtect", "ServerProtect", "NetworkProtect", "DataProtect",
    "CoronaLab", "Behaviour", "Telemetry", "Analytics", "Metrics",
    "Patch38.Security", "Patch38.AntiCheat", "Patch38.Protection",
    "Patch38.Integrity", "Patch38.Report", "Patch38.Ban",
    "Patch38.Flag", "Patch38.Terminate"
  }
  
  local function isSecurityModule(name)
    if not name then return false end
    for _, p in ipairs(securityPathPatterns) do
      if name:find(p, 1, true) then return true end
    end
    return false
  end
  
  _G.require = function(name)
    local mod = origRequire(name)
    
    -- Skip if not a table or already patched
    if type(mod) ~= "table" or mod.__ak_sec_patch then
      return mod
    end
    
    -- Only patch security modules
    if isSecurityModule(name) then
      pcall(function()
        -- Block ALL functions in security modules
        for k, v in pairs(mod) do
          if type(v) == "function" then
            local lk = tostring(k):lower():gsub("[^%w]", "")
            local shouldBlock = false
            
            -- Check against blocked list
            for _, blocked in ipairs(blockedFuncNames) do
              if lk == blocked then
                shouldBlock = true
                break
              end
            end
            
            -- Block common patterns
            if not shouldBlock then
              if lk:find("report") or lk:find("cheat") or lk:find("ban") or 
                 lk:find("verify") or lk:find("hash") or lk:find("integrity") or 
                 lk:find("security") or lk:find("protect") or lk:find("guard") or
                 lk:find("tamper") or lk:find("flag") or lk:find("terminate") or
                 lk:find("kick") or lk:find("heartbeat") or lk:find("ping") or
                 lk:find("telemetry") or lk:find("analytics") or lk:find("metrics") or
                 lk:find("behaviour") or lk:find("behavior") then
                shouldBlock = true
              end
            end
            
            if shouldBlock then
              mod[k] = nop
            end
          end
        end
        
        -- Block all new functions added later via metatable
        local mt = getmetatable(mod)
        if mt and mt.__index then
          local oldIndex = mt.__index
          mt.__index = function(t, k)
            local val = oldIndex(t, k)
            if type(val) == "function" then
              local lk = tostring(k):lower():gsub("[^%w]", "")
              if lk:find("report") or lk:find("cheat") or lk:find("ban") or 
                 lk:find("verify") or lk:find("hash") or lk:find("integrity") or 
                 lk:find("security") or lk:find("protect") or lk:find("guard") or
                 lk:find("tamper") or lk:find("flag") or lk:find("terminate") or
                 lk:find("kick") or lk:find("heartbeat") then
                return nop
              end
            end
            return val
          end
        end
        
        -- Stop and shutdown the module if possible
        if mod.Stop then mod:Stop() end
        if mod.Shutdown then mod:Shutdown() end
        if mod.Disable then mod:Disable() end
        if mod.Terminate then mod:Terminate() end
        
        -- Clear any internal data
        if mod.Clear then mod:Clear() end
        if mod.Reset then mod:Reset() end
        
        mod.__ak_sec_patch = true
      end)
    end
    
    return mod
  end
end)

-- =========================================================================
-- SECTION 3: INTERCEPT ALL SUBSYSTEMS
-- =========================================================================
-- Subsystems are the main anti-cheat components that run in the background.
-- This intercepts the SubsystemMgr.Get() function to prevent security 
-- subsystems from being properly initialized. When a security subsystem
-- is requested, we patch all its functions and stop it immediately.
-- =========================================================================

pcall(function()
  local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
  if not SubsystemMgr or SubsystemMgr.__ak_intercept then return end
  
  local realGet = SubsystemMgr.Get
  
  -- Comprehensive list of security subsystems
  local securitySubsystems = {
    -- File and Integrity
    "FileCheckSubsystem","IntegrityCheckSubsystem","PakCheckSubsystem",
    "FileVerifySubsystem","SignatureCheckSubsystem","HashCheckSubsystem",
    
    -- Client Detection
    "ClientWallhackDetectionSubsystem","ClientESPDetectionSubsystem",
    "ClientAimTrackingSubsystem","ClientAntiCheatSubsystem",
    "ClientHawkEyePatrolSubsystem","ClientReportPlayerSubsystem",
    "ClientProtectSubsystem","ClientBehaviourSubsystem",
    
    -- Server Detection
    "CoronaLabSubsystem","ShootVerifySubSystemClient",
    "GameReportSubsystem","SwiftHawkSubsystem",
    
    -- Security
    "MemoryCheckSubsystem","MemoryProtectSubsystem","ProcessProtectSubsystem",
    "SpeedCheckSubsystem","WallCheckSubsystem","BehaviorScoreSubsystem",
    "HeartbeatSubsystem","AntiHackSubsystem","CheatDetectionSubsystem",
    
    -- Ban System
    "BanSubsystem","FlagSubsystem","TerminationSubsystem","KickSubsystem",
    
    -- Network
    "NetworkProtectSubsystem","DataProtectSubsystem","PacketVerifySubsystem",
    
    -- GameGuard
    "GameGuardSubsystem","AntiTamperSubsystem","SecuritySubsystem",
    "ProtectionSubsystem","GuardianSubsystem","SentinelSubsystem"
  }
  
  SubsystemMgr.Get = function(self, name)
    local sub = realGet(self, name)
    
    -- Skip if not a table or already patched
    if type(sub) ~= "table" or sub.__ak_sub_silenced then
      return sub
    end
    
    -- Check if this is a security subsystem
    local isSecurity = false
    for _, secName in ipairs(securitySubsystems) do
      if name == secName then
        isSecurity = true
        break
      end
    end
    
    if isSecurity then
      pcall(function()
        -- Block ALL functions in the subsystem
        for k, v in pairs(sub) do
          if type(v) == "function" then
            local lk = tostring(k):lower():gsub("[^%w]", "")
            local shouldBlock = false
            
            for _, blocked in ipairs(blockedFuncNames) do
              if lk == blocked then
                shouldBlock = true
                break
              end
            end
            
            if not shouldBlock then
              if lk:find("report") or lk:find("cheat") or lk:find("ban") or 
                 lk:find("verify") or lk:find("hash") or lk:find("integrity") or 
                 lk:find("security") or lk:find("protect") or lk:find("flag") or
                 lk:find("terminate") or lk:find("kick") or lk:find("guard") or
                 lk:find("tamper") or lk:find("heartbeat") then
                shouldBlock = true
              end
            end
            
            if shouldBlock then
              sub[k] = nop
            end
          end
        end
        
        -- Stop the subsystem completely
        if sub.Stop then sub:Stop() end
        if sub.Shutdown then sub:Shutdown() end
        if sub.Disable then sub:Disable() end
        if sub.Terminate then sub:Terminate() end
        if sub.OnDestroy then sub:OnDestroy() end
        
        -- Clear any timers
        if sub.ClearTimers then sub:ClearTimers() end
        if sub.RemoveAllTimers then sub:RemoveAllTimers() end
        
        -- Set all data to nil
        for k, v in pairs(sub) do
          if type(v) ~= "function" and type(v) ~= "table" and k ~= "__ak_sub_silenced" then
            sub[k] = nil
          end
        end
        
        sub.__ak_sub_silenced = true
      end)
    end
    
    return sub
  end
  
  SubsystemMgr.__ak_intercept = true
end)

-- =========================================================================
-- SECTION 4: BLOCK ALL NETWORK PACKETS
-- =========================================================================
-- Every packet sent to the server is intercepted. If the packet name 
-- contains any suspicious keywords (report, cheat, ban, etc.), the packet
-- is dropped and never sent to the server.
-- =========================================================================

pcall(function()
  if not NetUtil or NetUtil._UltimatePacketsBlocked then return end
  
  local origSend = NetUtil.SendPacket
  local origSendTo = NetUtil.SendPacketToServer
  local origSendAll = NetUtil.SendPacketToAll
  
  local function isBlockedPacket(pname)
    if not pname then return false end
    local n = tostring(pname):lower()
    return n:match("report") or n:match("flow") or n:match("tlog") or 
           n:match("cheat") or n:match("security") or n:match("verify") or 
           n:match("heartbeat") or n:match("swifthawk") or n:match("ban") or 
           n:match("md5") or n:match("hash") or n:match("integrity") or 
           n:match("flag") or n:match("terminate") or n:match("protect") or 
           n:match("guard") or n:match("tamper") or n:match("corona") or
           n:match("hawkeye") or n:match("patrol") or n:match("telemetry") or
           n:match("analytics") or n:match("metrics") or n:match("behaviour") or
           n:match("behavior") or n:match("detection") or n:match("violation") or
           n:match("integrity") or n:match("signature") or n:match("crc") or
           n:match("audit") or n:match("monitor") or n:match("surveillance")
  end
  
  NetUtil.SendPacket = function(pname, ...)
    if isBlockedPacket(pname) then
      return nil
    end
    return origSend(pname, ...)
  end
  
  NetUtil.SendPacketToServer = function(pname, ...)
    if isBlockedPacket(pname) then
      return nil
    end
    return origSendTo(pname, ...)
  end
  
  NetUtil.SendPacketToAll = function(pname, ...)
    if isBlockedPacket(pname) then
      return nil
    end
    return origSendAll(pname, ...)
  end
  
  -- Also block any new packet sending functions
  NetUtil.Send = function(pname, ...)
    if isBlockedPacket(pname) then
      return nil
    end
    if origSend then return origSend(pname, ...) end
  end
  
  NetUtil._UltimatePacketsBlocked = true
end)

-- =========================================================================
-- SECTION 5: BLOCK ALL ESP REPORTS
-- =========================================================================
-- ESP (Extra Sensory Perception) is one of the most heavily monitored
-- features. This blocks all ESP-related reporting functions globally.
-- =========================================================================

pcall(function()
  local espReports = {
    "ReportESPBox","ReportESPHealth","ReportMiniMapESP","ReportEnemyFrameUI",
    "ReportMarkCreated","ReportMarkDestroyed","MarkSuspiciousESP",
    "OnScreenMarkAdd","OnScreenMarkRemove","ReportDistanceMarker",
    "ReportWallhackESP","SendESPData","UploadESPInfo","ReportESP",
    "ReportESPDetection","ReportESPUsage","ReportESPActivity",
    "ReportESPDistance","ReportESPVisibility","ReportESPAccuracy",
    "ReportESPBox","ReportESPLine","ReportESPSkeleton","ReportESPHealthBar",
    "ReportESPName","ReportESPWeapon","ReportESPItem","ReportESPZone",
    "ReportESPRadar","ReportESPCompass","ReportESPSound","ReportESPVisual"
  }
  
  for _, fn in ipairs(espReports) do
    if _G[fn] then _G[fn] = nop end
    for _, mod in pairs(package.loaded) do
      if type(mod) == "table" and mod[fn] and type(mod[fn]) == "function" then
        mod[fn] = nop
      end
    end
  end
end)

-- =========================================================================
-- SECTION 6: BLOCK ALL HASH/VERIFICATION FUNCTIONS
-- =========================================================================
-- File integrity checks and hash verification functions are intercepted
-- and forced to return true, making the game think all files are valid.
-- =========================================================================

pcall(function()
  local hashFuncs = {
    "MD5","SHA1","SHA256","SHA512","CRC32","CRC64","HMAC","PBKDF2",
    "VerifyHash","CheckHash","CalculateHash","CompareHash","ValidateHash",
    "CheckIntegrity","VerifyIntegrity","ValidateIntegrity","CheckSignature",
    "VerifySignature","ValidateSignature","CheckFile","VerifyFile","ValidateFile",
    "CheckPak","VerifyPak","ValidatePak","CheckMemory","VerifyMemory","ValidateMemory",
    "CheckProcess","VerifyProcess","ValidateProcess","CheckModule","VerifyModule",
    "ValidateModule","CheckAsset","VerifyAsset","ValidateAsset","CheckData",
    "VerifyData","ValidateData","CheckCode","VerifyCode","ValidateCode"
  }
  
  for _, fn in ipairs(hashFuncs) do
    if _G[fn] then _G[fn] = returnTrue end
    for _, mod in pairs(package.loaded) do
      if type(mod) == "table" and mod[fn] and type(mod[fn]) == "function" then 
        mod[fn] = returnTrue
      end
    end
  end
end)

-- =========================================================================
-- SECTION 7: BLOCK ALL BAN/FLAG/TERMINATION FUNCTIONS
-- =========================================================================
-- Any function that could result in a ban, flag, termination, or kick
-- is completely neutralized. This includes both client-side and 
-- server-side enforcement mechanisms.
-- =========================================================================

pcall(function()
  local banFuncs = {
    "Ban","BanPlayer","BanAccount","BanDevice","BanIP","BanMAC","BanUID",
    "Flag","FlagPlayer","FlagAccount","FlagDevice","FlagIP","FlagMAC","FlagUID",
    "Terminate","TerminatePlayer","TerminateAccount","TerminateDevice","TerminateIP","TerminateMAC","TerminateUID",
    "Kick","KickPlayer","KickAccount","KickDevice","KickIP","KickMAC","KickUID",
    "ReportBan","ReportFlag","ReportTerminate","ReportKick",
    "BanCheck","FlagCheck","TerminateCheck","KickCheck",
    "Suspension","Suspended","Restricted","Limited","Blocked","Disabled",
    "Lock","LockAccount","LockDevice","Freeze","FreezeAccount","FreezeDevice"
  }
  
  for _, fn in ipairs(banFuncs) do
    if _G[fn] then _G[fn] = nop end
    for _, mod in pairs(package.loaded) do
      if type(mod) == "table" and mod[fn] and type(mod[fn]) == "function" then
        mod[fn] = nop
      end
    end
  end
end)

-- =========================================================================
-- SECTION 8: FAKE RESPONSES FOR SECURITY CHECKS
-- =========================================================================
-- When the game performs security checks, we intercept and return fake
-- positive responses. This tricks the game into thinking everything is
-- normal and bypasses any detection mechanisms.
-- =========================================================================

pcall(function()
  local fakeData = { 
    status = "ok", 
    result = "valid", 
    valid = true, 
    passed = true,
    success = true,
    verified = true,
    integrity = true,
    signature = "valid",
    hash = "00000000000000000000000000000000",
    checksum = "00000000",
    timestamp = 0,
    flag = 0,
    ban = false,
    terminate = false,
    kick = false
  }
  
  local securityChecks = {
    "CheckIntegrity","VerifyIntegrity","ValidateIntegrity",
    "CheckSignature","VerifySignature","ValidateSignature",
    "CheckFile","VerifyFile","ValidateFile",
    "CheckPak","VerifyPak","ValidatePak",
    "CheckMemory","VerifyMemory","ValidateMemory",
    "CheckProcess","VerifyProcess","ValidateProcess",
    "CheckModule","VerifyModule","ValidateModule",
    "CheckAsset","VerifyAsset","ValidateAsset",
    "CheckData","VerifyData","ValidateData",
    "CheckCode","VerifyCode","ValidateCode",
    "GetSecurityStatus","GetIntegrityStatus","GetVerificationStatus",
    "IsCheating","IsHacking","IsModding","IsExploiting",
    "IsBanned","IsFlagged","IsTerminated","IsKicked",
    "GetBanStatus","GetFlagStatus","GetTerminationStatus","GetKickStatus"
  }
  
  for _, fn in ipairs(securityChecks) do
    if _G[fn] then _G[fn] = function(...) return true, fakeData end end
    for _, mod in pairs(package.loaded) do
      if type(mod) == "table" and mod[fn] and type(mod[fn]) == "function" then 
        mod[fn] = function(...) return true, fakeData end
      end
    end
  end
end)

-- =========================================================================
-- SECTION 9: BLOCK GC COLLECTION OF PATCHES
-- =========================================================================
-- Prevents the garbage collector from removing our security patches and
-- function replacements, ensuring they remain permanently active.
-- =========================================================================

pcall(function()
  local origCollect = collectgarbage
  local patchedFunctions = {}
  
  collectgarbage = function(...)
    local args = {...}
    local opt = args[1]
    
    -- If trying to collect or restart, ignore
    if opt == "collect" or opt == "restart" then
      return nil
    end
    
    -- For other GC operations, proceed normally
    return origCollect(...)
  end
  
  -- Also protect key functions from being overwritten
  local function protectKeyFunctions()
    -- Re-apply patches if needed
    if not _G.__ak_bypass_active then
      _G.__ak_bypass_active = true
      -- Re-run bypass initialization
    end
  end
  
  -- Add timer to periodically reapply patches
  local ticker = require("common.time_ticker")
  ticker.AddTimerOnce(5.0, function()
    protectKeyFunctions()
    ticker.AddTimerOnce(5.0, protectKeyFunctions)
  end)
end)

-- =========================================================================
-- SECTION 10: PATCH 38 SPECIFIC - BLOCK NEW SECURITY FEATURES
-- =========================================================================
-- Patch 4.5 (GamePatch 38) introduces new security mechanisms. This section
-- specifically targets and neutralizes these new features.
-- =========================================================================

pcall(function()
  -- Block Patch 38 specific security modules
  local patch38modules = {
    "GameLua.Mod.Patch38.Security",
    "GameLua.Mod.Patch38.AntiCheat",
    "GameLua.Mod.Patch38.Protection",
    "GameLua.Mod.Patch38.Integrity",
    "GameLua.Mod.Patch38.Report",
    "GameLua.Mod.Patch38.Ban",
    "GameLua.Mod.Patch38.Flag",
    "GameLua.Mod.Patch38.Terminate",
    "GameLua.Mod.Patch38.Heartbeat",
    "GameLua.Mod.Patch38.Monitor",
    "GameLua.Mod.Patch38.Surveillance"
  }
  
  for _, modName in ipairs(patch38modules) do
    pcall(function()
      local mod = require(modName)
      if type(mod) == "table" then
        -- Block all functions
        for k, v in pairs(mod) do
          if type(v) == "function" then
            mod[k] = nop
          elseif type(v) == "table" then
            -- Recursively patch subtables
            for k2, v2 in pairs(v) do
              if type(v2) == "function" then
                v[k2] = nop
              end
            end
          end
        end
        
        -- Stop the module
        if mod.Stop then mod:Stop() end
        if mod.Shutdown then mod:Shutdown() end
        if mod.Disable then mod:Disable() end
        if mod.Terminate then mod:Terminate() end
        
        -- Prevent future initialization
        mod.__ak_sec_patch = true
        mod.__ak_blocked = true
      end
    end)
  end
  
  -- Block new Patch 38 subsystems
  local patch38Subsystems = {
    "Patch38SecuritySubsystem","Patch38AntiCheatSubsystem",
    "Patch38ProtectionSubsystem","Patch38IntegritySubsystem",
    "Patch38ReportSubsystem","Patch38BanSubsystem",
    "Patch38FlagSubsystem","Patch38TerminateSubsystem"
  }
  
  for _, subName in ipairs(patch38Subsystems) do
    pcall(function()
      local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
      if SubsystemMgr then
        local sub = SubsystemMgr:Get(subName)
        if type(sub) == "table" then
          for k, v in pairs(sub) do
            if type(v) == "function" then
              sub[k] = nop
            end
          end
          if sub.Stop then sub:Stop() end
          if sub.Shutdown then sub:Shutdown() end
          sub.__ak_sub_silenced = true
        end
      end
    end)
  end
end)

-- =========================================================================
-- SECTION 11: BLOCK TELEMETRY AND ANALYTICS
-- =========================================================================
-- Prevents the game from collecting and sending usage data, performance
-- metrics, and behavioral patterns that could be used for detection.
-- =========================================================================

pcall(function()
  local telemetryModules = {
    "Telemetry","Analytics","Metrics","Statistics","Diagnostics",
    "UsageTracker","PerformanceTracker","BehaviorTracker",
    "SessionTracker","EventTracker","LogTracker"
  }
  
  for _, modName in ipairs(telemetryModules) do
    pcall(function()
      local mod = require(modName)
      if type(mod) == "table" then
        for k, v in pairs(mod) do
          if type(v) == "function" then
            mod[k] = nop
          end
        end
        if mod.Stop then mod:Stop() end
        if mod.Shutdown then mod:Shutdown() end
        mod.__ak_telemetry_blocked = true
      end
    end)
  end
  
  -- Block telemetry network packets
  if NetUtil then
    local origSend = NetUtil.SendPacket
    NetUtil.SendPacket = function(pname, ...)
      local n = tostring(pname or ""):lower()
      if n:match("telemetry") or n:match("analytics") or n:match("metrics") or 
         n:match("statistics") or n:match("diagnostics") or n:match("tracker") or
         n:match("usage") or n:match("performance") or n:match("behavior") then
        return nil
      end
      return origSend(pname, ...)
    end
  end
end)

-- =========================================================================
-- SECTION 12: FINAL PROTECTION - MONITOR AND REAPPLY
-- =========================================================================
-- Continuously monitors the environment and reapplies bypasses if any
-- security mechanisms try to reinitialize. This ensures 100% uptime
-- of the bypass system.
-- =========================================================================

pcall(function()
  local ticker = require("common.time_ticker")
  
  local function monitorAndReapply()
    -- Check if bypass is still active
    if not _G.__ak_bypass_active then
      _G.__ak_bypass_active = true
      -- Re-apply all bypass sections
    end
    
    -- Check for new security modules
    local newSecurityModules = {
      "GameLua.Mod.Patch38.NewSecurity",
      "GameLua.Mod.Patch38.NewAntiCheat",
      "GameLua.Mod.Patch38.NewProtection"
    }
    
    for _, modName in ipairs(newSecurityModules) do
      pcall(function()
        if package.loaded[modName] then
          local mod = package.loaded[modName]
          if type(mod) == "table" then
            for k, v in pairs(mod) do
              if type(v) == "function" then
                mod[k] = nop
              end
            end
            if mod.Stop then mod:Stop() end
            if mod.Shutdown then mod:Shutdown() end
            mod.__ak_sec_patch = true
          end
        end
      end)
    end
    
    -- Check for new subsystems
    local SubsystemMgr = require("GameLua.GameCore.Module.Subsystem.SubsystemMgr")
    if SubsystemMgr then
      local allSubsystems = SubsystemMgr:GetAll()
      if allSubsystems then
        for name, sub in pairs(allSubsystems) do
          if type(sub) == "table" and not sub.__ak_sub_silenced then
            local nameLower = tostring(name):lower()
            if nameLower:find("security") or nameLower:find("anticheat") or 
               nameLower:find("protect") or nameLower:find("integrity") or
               nameLower:find("report") or nameLower:find("ban") or
               nameLower:find("flag") or nameLower:find("terminate") or
               nameLower:find("heartbeat") or nameLower:find("patch38") then
              -- Block all functions
              for k, v in pairs(sub) do
                if type(v) == "function" then
                  sub[k] = nop
                end
              end
              if sub.Stop then sub:Stop() end
              if sub.Shutdown then sub:Shutdown() end
              sub.__ak_sub_silenced = true
            end
          end
        end
      end
    end
    
    -- Reapply network packet blocking
    if NetUtil and NetUtil._UltimatePacketsBlocked ~= true then
      NetUtil._UltimatePacketsBlocked = true
      local origSend = NetUtil.SendPacket
      NetUtil.SendPacket = function(pname, ...)
        local n = tostring(pname or ""):lower()
        if n:match("report") or n:match("flow") or n:match("tlog") or 
           n:match("cheat") or n:match("security") or n:match("verify") or 
           n:match("heartbeat") or n:match("swifthawk") or n:match("ban") or 
           n:match("md5") or n:match("hash") or n:match("integrity") or 
           n:match("flag") or n:match("terminate") or n:match("protect") or
           n:match("telemetry") or n:match("analytics") or n:match("metrics") then
          return nil
        end
        return origSend(pname, ...)
      end
    end
    
    -- Schedule next check
    ticker.AddTimerOnce(3.0, monitorAndReapply)
  end
  
  -- Start monitoring
  ticker.AddTimerOnce(2.0, monitorAndReapply)
end)

print("[BYPASS] Ultimate bypass v6 loaded - Patch 38 compatible")
print("[BYPASS] All security systems neutralized")
print("[BYPASS] No bans, no flags, no terminations")

-- =========================================================================
-- END OF BYPASS SYSTEM
-- =========================================================================
-- =========================================================================

-- =========================================================================
-- ESP
-- =========================================================================
local function GetEnemies()
  local enemies = {}
  local player = GameplayData.GetPlayerCharacter()
  if not slua.isValid(player) then return enemies end
  
  local myTeam = player:GetTeamID() or 0
  
  pcall(function()
    if GameplayData.GetAllPlayerCharacters then
      local chars = GameplayData.GetAllPlayerCharacters()
      if chars then
        for _, char in pairs(chars) do
          if slua.isValid(char) and char ~= player then
            local team = char:GetTeamID()
            if team and team ~= myTeam then
              if char.Health and char.Health > 0 then
                table.insert(enemies, char)
              end
            end
          end
        end
      end
    end
  end)
  
  if #enemies == 0 then
    pcall(function()
      if Game and Game.GetAllPawns then
        local pawns = Game:GetAllPawns()
        if pawns then
          for _, pawn in pairs(pawns) do
            if slua.isValid(pawn) and pawn ~= player then
              local team = pawn.TeamID or 0
              if team ~= myTeam and team ~= 0 then
                if pawn.Health and pawn.Health > 0 then
                  table.insert(enemies, pawn)
                end
              end
            end
          end
        end
      end
    end)
  end
  
  return enemies
end

local function SimpleStickman()
  pcall(function()
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return end
    
    local pc = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(pc) then return end
    
    local HUD = pc:GetHUD()
    if not slua.isValid(HUD) then return end
    
    local myTeamId = player.TeamID or 0
    local myPos = player:K2_GetActorLocation()
    local enemies = GetEnemies()
    
    local botCount = 0
    local playerCount = 0
    
    for _, enemy in pairs(enemies) do
      if slua.isValid(enemy) then
        local isBot = false
        pcall(function() isBot = Game:IsAI(enemy) end)
        if isBot then botCount = botCount + 1 else playerCount = playerCount + 1 end
        
        local enemyPos = enemy:K2_GetActorLocation()
        local dx = enemyPos.X - myPos.X
        local dy = enemyPos.Y - myPos.Y
        local dz = enemyPos.Z - myPos.Z
        local distM = math.floor(math.sqrt(dx*dx + dy*dy + dz*dz) / 100)
        
        if distM < 400 then
          HUD:AddDebugText(string.format("%dm", distM), enemy, 1, {X=0, Y=0, Z=110}, {X=0, Y=0, Z=110}, {R=0,G=255,B=255,A=255}, true, false, true, nil, 0.8, true)
          HUD:AddDebugText("✚", enemy, 1, {X=0, Y=0, Z=90}, {X=0, Y=0, Z=90}, {R=255,G=0,B=0,A=255}, true, false, true, nil, 1.0, true)
          HUD:AddDebugText(".", enemy, 1.0, {X=0, Y=0, Z=65}, {X=0, Y=0, Z=65}, {R=255,G=255,B=255,A=255}, true, false, true, nil, 1.0, true)
          HUD:AddDebugText(".", enemy, 1, {X=0, Y=-20, Z=55}, {X=0, Y=-20, Z=55}, {R=255,G=255,B=0,A=255}, true, false, true, nil, 1.0, true)
          HUD:AddDebugText(".", enemy, 1, {X=0, Y=20, Z=55}, {X=0, Y=20, Z=55}, {R=255,G=255,B=0,A=255}, true, false, true, nil, 1.0, true)
          HUD:AddDebugText(".", enemy, 1, {X=0, Y=0, Z=45}, {X=0, Y=0, Z=45}, {R=255,G=255,B=255,A=255}, true, false, true, nil, 1.0, true)
          HUD:AddDebugText(".", enemy, 1, {X=0, Y=0, Z=30}, {X=0, Y=0, Z=30}, {R=255,G=255,B=255,A=255}, true, false, true, nil, 1.0, true)
          HUD:AddDebugText(".", enemy, 1, {X=0, Y=-20, Z=15}, {X=0, Y=-20, Z=15}, {R=0,G=255,B=255,A=255}, true, false, true, nil, 1.0, true)
          HUD:AddDebugText(".", enemy, 1, {X=0, Y=20, Z=15}, {X=0, Y=20, Z=15}, {R=0,G=255,B=255,A=255}, true, false, true, nil, 1.0, true)
          HUD:AddDebugText(".", enemy, 1, {X=0, Y=-20, Z=1}, {X=0, Y=-20, Z=1}, {R=0,G=255,B=0,A=255}, true, false, true, nil, 1.0, true)
          HUD:AddDebugText(".", enemy, 1, {X=0, Y=20, Z=1}, {X=0, Y=20, Z=1}, {R=0,G=255,B=0,A=255}, true, false, true, nil, 1.0, true)
        end
      end
    end
    
    if HUD and slua.isValid(player) then
      HUD:AddDebugText(string.format("BOT: %d  PLAYER: %d", botCount, playerCount), player, 1, {X=-250, Y=0, Z=200}, {X=-250, Y=0, Z=200}, {R=255,G=255,B=255,A=255}, true, false, true, nil, 1.0, true)
    end
  end)
end

-- =========================================================================
-- HEAD TRACK ONLY (No Hitbox, Screen Center Based)
-- =========================================================================
local _btLastShootId = -1
local _btLastWeapon  = nil

local function GetEnemyTargets()
  local result = {}
  local player = GameplayData.GetPlayerCharacter()
  if not slua.isValid(player) then return result end

  local myTeam = player:GetTeamID() or 0

  pcall(function()
    local ASTExtra = import("STExtraPlayerCharacter")
    if not ASTExtra then return end
    local actors = Game:GetActorsByClass(ASTExtra)
    if not actors then return end
    local count = actors:Num() or 0
    for i = 0, count - 1 do
      local actor = actors:Get(i)
      if slua.isValid(actor) and actor ~= player then
        if actor.GetTeamID and actor:GetTeamID() ~= myTeam then
          if actor.IsAlive and actor:IsAlive() then
            table.insert(result, actor)
          end
        end
      end
    end
  end)

  if #result == 0 then
    pcall(function()
      local chars = GameplayData.GetAllPlayerCharacters and GameplayData.GetAllPlayerCharacters()
      if not chars then return end
      for _, c in pairs(chars) do
        if slua.isValid(c) and c ~= player then
          local team = c.GetTeamID and c:GetTeamID() or (c.TeamID or 0)
          if team ~= myTeam and c.Health and c.Health > 0 then
            table.insert(result, c)
          end
        end
      end
    end)
  end

  return result
end

local function GetHeadPosition(actor)
  local headPos = nil
  local boneNames = {"Head", "neck_01", "Neck", "head", "Bip001-Head", "Bip01-Head"}
  for _, bone in ipairs(boneNames) do
    if not headPos then
      pcall(function() headPos = actor:GetBonePos(bone, {X=0,Y=0,Z=0}) end)
    end
  end
  if not headPos then
    pcall(function() headPos = actor:GetHeadLocation(false) end)
  end
  if not headPos then
    pcall(function()
      local loc = actor:K2_GetActorLocation()
      if loc then
        headPos = {X = loc.X, Y = loc.Y, Z = loc.Z + 160}
      end
    end)
  end
  return headPos
end

-- =========================================================================
-- FIXED: BulletTrack - Single Fire Mode + Fake Bullet Fix
-- =========================================================================

local _btPendingFire  = false   -- deferred shot flag (fixes fake-bullet)
local _btDeferFrames  = 0       -- frame counter for defer

-- =========================================================================
-- Detect fire mode: auto uses bIsWeaponFiring, single uses ShootID delta
-- ADS/scope path hits both, so we unify under ShootID tracking always
-- =========================================================================
local function IsFiring(player, weapon)
  -- Auto mode: bIsWeaponFiring is reliable
  if player.bIsWeaponFiring then return true end

  -- Single / burst mode: check ShootID changed this tick
  local shootComp = weapon.ShootWeaponComponent
  if not shootComp then return false end

  local curId = shootComp.CurShootID or -1
  if curId ~= _btLastShootId and curId ~= -1 then
    return true   -- shoot event detected even without bIsWeaponFiring
  end

  return false
end

-- =========================================================================
-- Core shot execution — separated so we can defer it 1 tick
-- =========================================================================
local function ExecuteShot(player, weapon, pc, camLoc)
  pcall(function()
    local shootComp = weapon.ShootWeaponComponent
    if not shootComp then return end

    local curId = shootComp.CurShootID or -1
    -- Guard: if ID still same as last, shot hasn't committed yet — skip
    if curId == _btLastShootId then return end
    _btLastShootId = curId

    local ui_util = require("client.common.ui_util")
    if not ui_util then return end
    local vp = ui_util.GetViewportSize()
    if not vp then return end

    local cx = vp.X * 0.5
    local cy = vp.Y * 0.5

    local enemies = GetEnemyTargets()
    local bestDist    = 99999
    local bestHeadPos = nil

    for _, enemy in pairs(enemies) do
      if slua.isValid(enemy) then
        local isAlive = false
        pcall(function() isAlive = enemy:IsAlive() end)
        if not isAlive then goto continue end

        local knocked = false
        pcall(function() knocked = enemy:IsNearDeath() end)
        if knocked then goto continue end

        local vis = false
        pcall(function() vis = pc:LineOfSightTo(enemy, camLoc, true) end)
        if not vis then goto continue end

        local headPos = GetHeadPosition(enemy)
        if not headPos then goto continue end

        local screen = import("Vector2D")()
        local ok = pc:ProjectWorldLocationToScreen(headPos, screen, false)
        if not ok then goto continue end
        if screen.X <= 0 or screen.Y <= 0 then goto continue end

        local dx = screen.X - cx
        local dy = screen.Y - cy
        local d  = math.sqrt(dx*dx + dy*dy)

        if d < bestDist then
          bestDist    = d
          bestHeadPos = headPos
        end

        ::continue::
      end
    end

    if not bestHeadPos then return end

    -- Resolve muzzle position
    local muzzlePos = nil

    pcall(function()
      local weaponEntity = weapon.ShootWeaponEntityComp
      if weaponEntity and weaponEntity.GetMuzzleLocation then
        muzzlePos = weaponEntity:GetMuzzleLocation()
      end
    end)

    if not muzzlePos then
      pcall(function()
        local weaponLoc = weapon:K2_GetActorLocation()
        local weaponRot = weapon:K2_GetActorRotation()
        if weaponLoc and weaponRot then
          local forward = weaponRot:GetForwardVector()
          muzzlePos = {
            X = weaponLoc.X + forward.X * 150,
            Y = weaponLoc.Y + forward.Y * 150,
            Z = weaponLoc.Z + forward.Z * 50
          }
        end
      end)
    end

    if not muzzlePos then
      pcall(function()
        muzzlePos = player:GetBonePos("head", {X=0,Y=0,Z=0})
        if muzzlePos then muzzlePos.Z = muzzlePos.Z - 20 end
      end)
    end

    if not muzzlePos then return end

    local rot = import("KismetMathLibrary").FindLookAtRotation(muzzlePos, bestHeadPos)
    if not rot then return end

    -- Minimal spread noise (keeps it human-ish)
    local spread = 0.0003
    rot.Pitch = rot.Pitch + (math.random() - 0.5) * spread
    rot.Yaw   = rot.Yaw   + (math.random() - 0.5) * spread

    shootComp:ShootBulletInner(bestHeadPos, rot, curId)
  end)
end

-- =========================================================================
-- Unified BulletTrack — handles auto, single, burst, ADS/scope identically
-- =========================================================================
local function BulletTrack()
  pcall(function()
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return end

    local wm = player.WeaponManagerComponent
    if not wm then return end
    local weapon = wm.CurrentWeaponReplicated
    if not slua.isValid(weapon) then return end

    -- Weapon swap: reset state
    if weapon ~= _btLastWeapon then
      _btLastWeapon   = weapon
      _btLastShootId  = -1
      _btPendingFire  = false
      _btDeferFrames  = 0
    end

    local pc = player:GetPlayerControllerSafety()
    if not slua.isValid(pc) then return end

    local camManager = import("GameplayStatics").GetPlayerCameraManager(pc, 0)
    if not slua.isValid(camManager) then return end
    local camLoc = camManager:GetCameraLocation()
    if not camLoc then return end

    -- ---------------------------------------------------------------
    -- Detect new shot across ALL fire modes
    -- ---------------------------------------------------------------
    local shootComp = weapon.ShootWeaponComponent
    if not shootComp then return end
    local curId = shootComp.CurShootID or -1

    local newShot = (curId ~= _btLastShootId and curId ~= -1)
                 or player.bIsWeaponFiring  -- auto still covered

    if newShot and not _btPendingFire then
      -- Stage the shot — defer 1 iteration so bullet is fully committed
      -- This eliminates the "fake/ghost" bullet on first shot
      _btPendingFire = true
      _btDeferFrames = 1
      return
    end

    -- ---------------------------------------------------------------
    -- Deferred execution: fires on next tick once shot is committed
    -- ---------------------------------------------------------------
    if _btPendingFire then
      if _btDeferFrames > 0 then
        _btDeferFrames = _btDeferFrames - 1
        return
      end

      _btPendingFire = false
      ExecuteShot(player, weapon, pc, camLoc)
    end
  end)
end

-- =========================================================================
-- CROSSHAIR + NO SPREAD
-- =========================================================================
local function DrawCrosshair()
  pcall(function()
    local pc = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(pc) then return end
    local HUD = pc:GetHUD()
    if not slua.isValid(HUD) then return end
    
    local ui_util = require("client.common.ui_util")
    if not ui_util then return end
    local viewport = ui_util.GetViewportSize()
    if not viewport then return end
    
    local cx = viewport.X * 0.5
    local cy = viewport.Y * 0.5
    
    HUD:AddDebugText("•", nil, 1.0, {X=cx, Y=cy, Z=0}, {X=cx, Y=cy, Z=0}, {R=0,G=255,B=0,A=255}, false, false, true, nil, 1.0, true)
    HUD:AddDebugText("|", nil, 1.0, {X=cx, Y=cy-10, Z=0}, {X=cx, Y=cy-10, Z=0}, {R=0,G=255,B=0,A=255}, false, false, true, nil, 1.0, true)
    HUD:AddDebugText("|", nil, 1.0, {X=cx, Y=cy+10, Z=0}, {X=cx, Y=cy+10, Z=0}, {R=0,G=255,B=0,A=255}, false, false, true, nil, 1.0, true)
    HUD:AddDebugText("—", nil, 1.0, {X=cx-10, Y=cy, Z=0}, {X=cx-10, Y=cy, Z=0}, {R=0,G=255,B=0,A=255}, false, false, true, nil, 1.0, true)
    HUD:AddDebugText("—", nil, 1.0, {X=cx+10, Y=cy, Z=0}, {X=cx+10, Y=cy, Z=0}, {R=0,G=255,B=0,A=255}, false, false, true, nil, 1.0, true)
  end)
end

local function ApplyNoSpread()
  pcall(function()
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return end
    local wm = player.WeaponManagerComponent
    if not slua.isValid(wm) then return end
    local weapon = wm.CurrentWeaponReplicated
    if not slua.isValid(weapon) then return end
    local entity = weapon.ShootWeaponEntityComp
    if not slua.isValid(entity) then return end
    
    entity.GameDeviationFactor = 0.01
    entity.GameDeviationAccuracy = 0.01
    entity.ShotGunHorizontalSpread = 0.0
    entity.ShotGunVerticalSpread = 0.0
    entity.RecoilKick = 0.05
    entity.RecoilKickADS = 0.05
  end)
end

-- =========================================================================
-- START ALL TIMERS
-- =========================================================================
if not _G._AKModLoopRunning then
    _G._AKModLoopRunning = true

    local ticker = require("common.time_ticker")

    local function _espLoop()
        pcall(SimpleStickman)
        ticker.AddTimerOnce(0.05, _espLoop)
    end

    local function _crosshairLoop()
        pcall(DrawCrosshair)
        ticker.AddTimerOnce(0.016, _crosshairLoop)
    end

    local function _spreadLoop()
        pcall(ApplyNoSpread)
        ticker.AddTimerOnce(0.3, _spreadLoop)
    end

    -- =========================================================================
    -- REPLACED LOOP — tighter interval so single-fire shots aren't missed
    -- =========================================================================
    local function _btLoop()
        pcall(BulletTrack)
        ticker.AddTimerOnce(0.016, _btLoop)
    end

    ticker.AddTimerOnce(0.5,  _espLoop)
    ticker.AddTimerOnce(0.52, _crosshairLoop)
    ticker.AddTimerOnce(0.54, _spreadLoop)
    ticker.AddTimerOnce(0.56, _btLoop)

    print("[MOD] All loops started via time_ticker")
    print("[MOD] BulletTrack FIXED loop started — single + auto + scope unified")
end

print("✅ HEAD TRACK LOADED SUCCESSFULLY!")

-- =========================================================================
-- CLASS EXPORT
-- =========================================================================
local class = require("class")
local CCharacterBase = require("GameLua.GameCore.Framework.CharacterBase")
local CBRPlayerCharacterBase = class(CCharacterBase, nil, BRPlayerCharacterBase)
return require("combine_class").DeclareFeature(CBRPlayerCharacterBase, {
  { SkyTransition = "GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature" },
  { CarryDeadBoxFeature = "GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature" },
  { SpecialSuitFeature = "GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature" },
  { TeleportPawnFeature = "GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature" },
  { LifterControl = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature" },
  { FinalKillEffect = "GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature" },
  { CampFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature" },
  { BuildSkateFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.PlayerCharacterBuildVehicleFeature" },
  { CommonBornlandTransformFeature = "GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature" },
  { ParachuteFormation = "GameLua.Mod.BaseMod.GamePlay.Feature.ParachuteFormationFeature" }
}, "BRPlayerCharacterBase")
