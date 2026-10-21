
local GameplayData = require("GameLua.GameCore.Data.GameplayData")

local GAME_PACKAGES = {
    "com.tencent.ig",
    "com.rekoo.pubgm",
    "com.pubg.krmobile",
    "com.vng.pubgmobile",
}

local CONFIG_PATH = nil

for _, pkg in ipairs(GAME_PACKAGES) do
    local path = "/storage/emulated/0/Android/data/" .. pkg .. "/Erenconfig.h"
    local f = io.open(path, "r")
    if f then
        CONFIG_PATH = path
        f:close()
        break
    end
end

local CONFIG = {
    BULLET_TRACK = 0,
    TRACK_DISTANCE = 99999999,
    TRACK_BOT = 0,
    TRACK_NEARDEATH = 0,
    TRACK_RANGE = 99999,
    TRACK_PART = 0,
    WEAPON_IDS = {},
}

local BONE_MAP = {
    [0] = "Head",
    [1] = "neck_01",
    [2] = "spine_03",
}

local function LoadConfig()
    if not CONFIG_PATH then return end
    local file = io.open(CONFIG_PATH, "r")
    if not file then return end
    CONFIG.WEAPON_IDS = {}
    for line in file:lines() do
        if line then
            local trimmed = line:match("^%s*(.-)%s*$")
            if trimmed and trimmed ~= "" and not trimmed:match("^#") then
                local key, value = trimmed:match("^([^=]+)%s*=%s*(.+)$")
                if key and value then
                    key = key:match("^%s*(.-)%s*$")
                    value = value:match("^%s*(.-)%s*$")
                    local numValue = tonumber(value)
                    if key == "bullet_track" then
                        CONFIG.BULLET_TRACK = numValue or 0
                    elseif key == "track_distance" then
                        CONFIG.TRACK_DISTANCE = numValue or 99999999
                    elseif key == "track_bot" then
                        CONFIG.TRACK_BOT = numValue or 0
                    elseif key == "track_neardeath" then
                        CONFIG.TRACK_NEARDEATH = numValue or 0
                    elseif key == "track_range" then
                        CONFIG.TRACK_RANGE = numValue or 99999
                    elseif key == "track_part" then
                        CONFIG.TRACK_PART = numValue or 0
                    end
                else
                    local id, prob = trimmed:match("^(%d+)%s+(%d+)$")
                    if id and prob then
                        CONFIG.WEAPON_IDS[tonumber(id)] = tonumber(prob)
                    else
                        local num = tonumber(trimmed)
                        if num then
                            CONFIG.WEAPON_IDS[num] = 100
                        end
                    end
                end
            end
        end
    end
    file:close()
end

local function IsBot(pawn)
    local teamId = pawn.TeamID or 0
    return teamId > 100
end

local function GetEnemyTargetsFromActors(radius)
    local result = {}
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return result end
    local uPlayerController = player:GetPlayerControllerSafety()
    if not slua.isValid(uPlayerController) then return result end
    local ASTExtraPlayerCharacter = import("STExtraPlayerCharacter")
    if not ASTExtraPlayerCharacter then return result end
    local Actors = Game:GetActorsByClass(ASTExtraPlayerCharacter)
    if not Actors then return result end
    local count = Actors:Num() or 0
    local myTeam = player:GetTeamID()
    for i = 0, count - 1 do
        local actor = Actors:Get(i)
        if slua.isValid(actor) and actor ~= player and actor.GetTeamID and actor.IsAlive and actor:IsAlive() then
            if actor:GetTeamID() ~= myTeam then
                local dist = player:GetDistanceTo(actor)
                if dist <= radius then
                    table.insert(result, actor)
                end
            end
        end
    end
    return result
end

local function SniperBulletTrack()
    if CONFIG.BULLET_TRACK ~= 1 then return end
    local player = GameplayData.GetPlayerCharacter()
    if not slua.isValid(player) then return end
    local pc = player:GetPlayerControllerSafety()
    if not slua.isValid(pc) then return end
    if not player.bIsWeaponFiring then return end
    local weaponManager = player.WeaponManagerComponent
    if not weaponManager then return end
    local currentWeapon = weaponManager.CurrentWeaponReplicated
    if not currentWeapon then return end
    local shootComp = currentWeapon.ShootWeaponComponent
    if not shootComp then return end
    local shootEntity = shootComp.ShootWeaponEntityComponent
    if not shootEntity then return end
    local weaponID = shootEntity.WeaponID
    local weaponProb = CONFIG.WEAPON_IDS[weaponID]
    if not weaponProb then return end
    if weaponProb < 100 then
        local rand = math.random(1, 100)
        if rand > weaponProb then return end
    end
    local enemies = GetEnemyTargetsFromActors(CONFIG.TRACK_DISTANCE)
    if not enemies or #enemies == 0 then return end
    local filteredEnemies = {}
    for _, target in ipairs(enemies) do
        if slua.isValid(target) then
            local skip = false
            if CONFIG.TRACK_BOT == 0 and IsBot(target) then
                skip = true
            end
            if not skip and CONFIG.TRACK_NEARDEATH == 0 then
                local isNearDeath = false
                pcall(function() isNearDeath = target:IsNearDeath() end)
                if isNearDeath then
                    skip = true
                end
            end
            if not skip then
                table.insert(filteredEnemies, target)
            end
        end
    end
    if #filteredEnemies == 0 then return end
    local camManager = import("GameplayStatics").GetPlayerCameraManager(pc, 0)
    if not slua.isValid(camManager) then return end
    local camLoc = camManager:GetCameraLocation()
    if not camLoc then return end
    local ui_util = require("client.common.ui_util")
    if not ui_util then return end
    local viewportSize = ui_util.GetViewportSize()
    if not viewportSize then return end
    local centerX = viewportSize.X * 0.5
    local centerY = viewportSize.Y * 0.5
    local trackRange = CONFIG.TRACK_RANGE or 99999
    local closest = nil
    local closestDist = trackRange
    local boneName = BONE_MAP[CONFIG.TRACK_PART] or "Head"
    for _, target in ipairs(filteredEnemies) do
        if slua.isValid(target) then
            local aimPos = target:GetBonePos(boneName, {X = 0, Y = 0, Z = 0})
            if aimPos then
                local visible = pc:LineOfSightTo(target, camLoc, true)
                if visible then
                    local screen = import("Vector2D")()
                    local success = pc:ProjectWorldLocationToScreen(aimPos, screen, false)
                    if success and screen.X > 0 and screen.Y > 0 then
                        local dx = screen.X - centerX
                        local dy = screen.Y - centerY
                        local dist = math.sqrt(dx * dx + dy * dy)
                        if dist < trackRange and dist < closestDist then
                            closestDist = dist
                            closest = target
                        end
                    end
                end
            end
        end
    end
    if not slua.isValid(closest) then return end
    local aimPos = closest:GetBonePos(boneName, {X = 0, Y = 0, Z = 0})
    if not aimPos then return end
    local rot = import("KismetMathLibrary").FindLookAtRotation(camLoc, aimPos)
    local ShootId = shootComp.CurShootID
    shootComp:ShootBulletInner(aimPos, rot, ShootId)
end

local function MainTick()
    pcall(LoadConfig)
    pcall(SniperBulletTrack)
end

pcall(function()
    local tmr = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(tmr) then
        tmr = import("GameplayStatics").GetPlayerController(slua_GameFrontendHUD:GetWorld(), 0)
    end
    if not slua.isValid(tmr) then return end
    if _G.Eren_SNIPER_TIMER == tmr then return end
    _G.Eren_SNIPER_TIMER = tmr
    tmr:AddGameTimer(0.1, false, function()
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(pc) then
            pc:AddGameTimer(0.05, true, MainTick)
        end
    end)
end)

print("Eren - Bullet track loaded")
