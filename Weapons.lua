--[[ Setup ]]--

local setup = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Project-Evolution/Archive/main/V3/modules/setup.lua", true))()
local changelog = setup:getloginfo()
setup:startchecks(changelog)

local LPH_ENCSTR = function(...) return ... end
local LPH_JIT_ULTRA = function(...) return ... end

--[[ Variables ]]--

local maids = {
    character = evov3.imports:fetchsystem("maid"),
    fly = evov3.imports:fetchsystem("maid"),
    nitro = evov3.imports:fetchsystem("maid"),
    flip = evov3.imports:fetchsystem("maid"),
    lights = evov3.imports:fetchsystem("maid"),
    shootcars = evov3.imports:fetchsystem("maid"),
    shoothelis = evov3.imports:fetchsystem("maid"),
    doors = evov3.imports:fetchsystem("maid")
}

local initstamp = tick()

local players = game:GetService("Players")
local replicatedstorage = game:GetService("ReplicatedStorage")
local runservice = game:GetService("RunService")
local userinputservice = game:GetService("UserInputService")
local collectionservice = game:GetService("CollectionService")
local httpservice = game:GetService("HttpService")
local marketplace = game:GetService("MarketplaceService")

local player = players.LocalPlayer
local mouse = player:GetMouse()
local cam = workspace.CurrentCamera

local mainlocalscr = player:WaitForChild("PlayerScripts"):WaitForChild("LocalScript")
local moneystat = player:WaitForChild("leaderstats"):WaitForChild("Money")
local codecontainer = player:WaitForChild("PlayerGui"):WaitForChild("CodesGui"):WaitForChild("CodeContainer"):WaitForChild("Background")
local minimap = player.PlayerGui:WaitForChild("AppUI"):WaitForChild("Buttons"):WaitForChild("Minimap")
local mappoints = minimap:WaitForChild("Map"):WaitForChild("Container"):WaitForChild("Points")
local char, root, hum
local silentaimtarget
local ojtrack

local isaimkeydown = false
local isflying, isopeningsafes = false, false
local baseflyvec = Vector3.new(0, 1e-9, 0)

local flykeys = {
	W = false,
	A = false,
	S = false,
	D = false,
	Space = false,
	LeftShift = false
}

local vehicletable, vehicleclasses
local timefunc, slowidx
local isholdingidx
local crawlidx

local markersystem = replicatedstorage:WaitForChild("Game"):WaitForChild("RobberyMarkerSystem")
local jetskimodule = replicatedstorage.Game:WaitForChild("VehicleSystem"):WaitForChild("JetSki")

local modules = {
    actionbuttons = require(replicatedstorage:WaitForChild("ActionButton"):WaitForChild("ActionButtonService")),
    store = require(replicatedstorage:WaitForChild("App"):WaitForChild("store")),
    boat = require(replicatedstorage.Game:WaitForChild("Boat"):WaitForChild("Boat")),
    dispenser = require(replicatedstorage.Game:WaitForChild("DartDispenser"):WaitForChild("DartDispenser")),
    defaultactions = require(replicatedstorage.Game:WaitForChild("DefaultActions")),
    falling = require(replicatedstorage.Game:WaitForChild("Falling")),
    gamepassutils = require(replicatedstorage.Game:WaitForChild("Gamepass"):WaitForChild("GamepassUtils")),
    vehicledata = require(replicatedstorage.Game:WaitForChild("Garage"):WaitForChild("VehicleData")),
    guardnpc = require(replicatedstorage:WaitForChild("GuardNPC"):WaitForChild("GuardNPCShared")),
    gunshoputils = require(replicatedstorage.Game:WaitForChild("GunShop"):WaitForChild("GunShopUtils")),
    gunshopui = require(replicatedstorage.Game.GunShop:WaitForChild("GunShopUI")),
    invconsts = require(replicatedstorage:WaitForChild("Inventory"):WaitForChild("InventoryConsts")),
    invsystem = require(replicatedstorage.Inventory:WaitForChild("InventoryItemSystem")),
    basic = require(replicatedstorage.Game:WaitForChild("Item"):WaitForChild("Basic")),
    gun = require(replicatedstorage.Game.Item:WaitForChild("Gun")),
    plasma = require(replicatedstorage.Game.Item:WaitForChild("PlasmaPistol")),
    emitter = require(replicatedstorage.Game:WaitForChild("ItemSystem"):WaitForChild("BulletEmitter")),
    itemcamera = require(replicatedstorage.Game.ItemSystem:WaitForChild("ItemCamera")),
    itemsystem = require(replicatedstorage.Game.ItemSystem:WaitForChild("ItemSystem")),
    jetpack = require(replicatedstorage.Game:WaitForChild("JetPack"):WaitForChild("JetPack")),
    jpgui = require(replicatedstorage.Game.JetPack:WaitForChild("JetPackGui")),
    jputil = require(replicatedstorage.Game.JetPack:WaitForChild("JetPackUtil")),
    militaryturret = require(replicatedstorage.Game:WaitForChild("MilitaryTurret"):WaitForChild("MilitaryTurret")),
    notification = require(replicatedstorage.Game:WaitForChild("Notification")),
    party = require(replicatedstorage.Game:WaitForChild("Party")),
    plane = require(replicatedstorage.Game:WaitForChild("Plane"):WaitForChild("BaseUserControlledPlane")),
    plrutils = require(replicatedstorage.Game:WaitForChild("PlayerUtils")),
    vehicle = require(replicatedstorage.Game:WaitForChild("Vehicle")),
    shipturret = require(replicatedstorage.Game:WaitForChild("Robbery"):WaitForChild("CargoShip"):WaitForChild("Turret")),
    puzzleflow = require(replicatedstorage.Game.Robbery:WaitForChild("PuzzleFlow")),
    robconsts = require(replicatedstorage.Game.Robbery:WaitForChild("RobberyConsts")),
    chassis = require(replicatedstorage:WaitForChild("Module"):WaitForChild("AlexChassis")),
    raycast = require(replicatedstorage.Module:WaitForChild("RayCast")),
    ui = require(replicatedstorage.Module:WaitForChild("UI")),
    settings = require(replicatedstorage:WaitForChild("Resource"):WaitForChild("Settings")),
    geometry = require(replicatedstorage:WaitForChild("Std"):WaitForChild("GeomUtils")),
    safeconsts = require(replicatedstorage:WaitForChild("Safes"):WaitForChild("SafesConsts")),
    maid = require(replicatedstorage.Std:WaitForChild("Maid")),
    vehiclelink = require(replicatedstorage:WaitForChild("VehicleLink"):WaitForChild("VehicleLinkBinder")),
    linkutils = require(replicatedstorage.VehicleLink:WaitForChild("VehicleLinkUtils"))
}

local originals = {
    boatupdate = modules.boat.UpdatePhysics,
    dispenserfire = modules.dispenser._fire,
    ragdoll = modules.falling.StartRagdolling,
    guardtarget = modules.guardnpc.canSeeTarget,
    emit = modules.emitter.Emit,
    bullethit = modules.gun.BulletEmitterOnLocalHitPlayer,
    camupdate = modules.itemcamera.Update,
    updatemousepos = modules.basic.UpdateMousePosition,
    plasmashoot = modules.plasma.ShootOther,
    isflying = modules.jetpack.IsFlying,
    militaryfire = modules.militaryturret._fire,
    haskey = modules.plrutils.hasKey,
    planepacket = modules.plane.FromPacket,
    pointintag = modules.plrutils.isPointInTag,
    entervehicle = modules.chassis.VehicleEnter,
    raynoncollide = modules.raycast.RayIgnoreNonCollide,
    rayignorelist = modules.raycast.RayIgnoreNonCollideWithIgnoreList,
    updatespec = modules.ui.CircleAction.Update,
    getvehiclepacket = modules.vehicle.GetLocalVehiclePacket,
    shipshoot = modules.shipturret.Shoot,
    vehiclehook = modules.vehiclelink._constructor._hookNearest,
    fireworks = getupvalue(modules.party.Init, 1)
}

local fakesniper = {
    __ClassName = "Sniper",
    Local = true,
    Config = {},
    IgnoreList = {},
    LastImpact = 0,
    LastImpactSound = 0,
    Maid = modules.maid.new()
}

local specs = modules.ui.CircleAction.Specs
local event = getupvalue(modules.chassis.SetEvent, 1)
local puzzle = getupvalue(modules.puzzleflow.Init, 3)
local defaultactions = getupvalue(modules.defaultactions.punchButton.onPressed, 1)

local punchidx = evov3.utils:tablefind(getconstants(defaultactions.attemptPunch), 0.5)
local boatidx = evov3.utils:tablefind(getconstants(originals.boatupdate), 0.3)

local doorstore = getupvalue(getconnections(collectionservice:GetInstanceRemovedSignal("Door"))[1].Function, 1)
local equipstore = getupvalue(modules.itemsystem.GetEquipped, 1)
local vehiclestore = {}

local robstates = {}
local roblabels = {}
local wallbanglist = {}
local guntables, gundata = {}, {}
local planetables, planedata = {}, {}
local boatdata = {}
local vehiclestats = {}
local noflyzones = {}
local carnames, helinames = {}, {}
local ammosources, ammodrop = {}, {}
local times = {}
local jptable
local crawlcondition
local invfolder


--[[ Garbage Collection ]]--

local garbage, hasbypassedac = LPH_JIT_ULTRA(function()
    local cache = {}
    local hasbypassedac = false
    for i, v in next, getgc() do
        if type(v) == "function" and islclosure(v) then
            local scr = getfenv(v).script
            if scr == mainlocalscr then
                local name, consts = getinfo(v).name, getconstants(v)
                if name == "DoorSequence" then
                    cache.opendoor = v
                elseif name == "StopNitro" then
                    cache.events = getupvalue(getupvalue(v, 1), 2)
                elseif evov3.utils:tablefind(consts, "VehicleHornId") then
                    cache.hornsound = v
                elseif evov3.utils:tablefind(consts, "FailedPcall") then
                    setupvalue(v, 2, true) -- Anticheat
                    hasbypassedac = true
                end
            elseif scr == markersystem and getinfo(v).name == "setRobberyMarkerState" then
                cache.markerstates = getupvalue(v, 1)
            elseif scr == jetskimodule and evov3.utils:tablefind(getconstants(v), "FindPartOnRay") then
                cache.jetskiupdate = v
            end
        end
    end
    return cache, hasbypassedac
end)()

local jetskiidx = evov3.utils:tablefind(getconstants(garbage.jetskiupdate), 0.3)

local clienthashes = {}

--[[ Functions ]]--

local function orangejustice()
    if hum then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://3066265539"
        ojtrack = hum:LoadAnimation(anim)
        ojtrack:Play()
    end
end

local function registerchar(character)
    char, root, hum = character, character:WaitForChild("HumanoidRootPart"), character:WaitForChild("Humanoid")
    if library.flags.walkspeed then
        if library.flags.orangejustice then
            orangejustice()
        end
        if library.flags.walkspeed.enabled then
            hum.WalkSpeed = library.flags.walkspeed.value
        end
        if library.flags.jumppower.enabled then
            hum.JumpPower = library.flags.jumppower.value
        end
    end
    maids.character:givetask(hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if hum and library.flags.walkspeed.enabled then
            hum.WalkSpeed = library.flags.walkspeed.value
        end
    end))
    maids.character:givetask(hum.Died:Connect(function()
        maids.character:dispose()
        char, root, hum = nil, nil, nil
    end))
end

local function getseat(plr)
    for _, veh in next, workspace.Vehicles:GetChildren() do
        for i, v in next, veh:GetChildren() do
            if (v.Name == "Seat" or v.Name == "Passenger") and v.PlayerName.Value == plr.Name then
                return veh.Name
            end
        end
    end
end

local function registerplayercharacter(plr, team, character)
    espgroups[team]:add(character, { name = plr.Name, colour = plr.TeamColor.Color })
    if character:FindFirstChild("InVehicle") then
        vehiclestore[plr] = getseat(plr)
    end

    maids[plr.Name]:givetask(character.ChildAdded:Connect(function(child)
        if child.Name == "InVehicle" then
            vehiclestore[plr] = getseat(plr)
        end
    end))

    maids[plr.Name]:givetask(character.ChildRemoved:Connect(function(child)
        if child.Name == "InVehicle" then
            vehiclestore[plr] = nil
        end
    end))

    maids[plr.Name]:givetask(character:WaitForChild("Humanoid").Died:Connect(function()
        maids[plr.Name]:dispose()
        vehiclestore[plr] = nil
    end))
end

local function registerplayer(plr)
    maids[plr.Name] = evov3.imports:fetchsystem("maid")

    local team = string.lower(plr.Team.Name)
    if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        registerplayercharacter(plr, team, plr.Character)
    end

    plr.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart")
        registerplayercharacter(plr, team, character)
    end)

    plr:GetPropertyChangedSignal("Team"):Connect(function()
        local newteam = string.lower(plr.Team.Name)
        if plr.Character then
            espgroups[team]:remove(plr.Character)
            espgroups[newteam]:add(plr.Character, { name = plr.Name, colour = plr.TeamColor.Color })
        end
        team = newteam
    end)
end

local function getaimpart(hitbox, flag)
    if library.flags[flag] == "Closest Part" then
        local retpart, dist = nil, math.huge
        for i, v in next, hitbox:GetChildren() do
            if v:IsA("BasePart") then
                local pos = cam:WorldToScreenPoint(v.Position)
                local mag = Vector2.new(pos.X - mouse.X, pos.Y - mouse.Y).Magnitude
                if mag < dist then
                    retpart, dist = v, mag
                end
            end
        end
        return retpart
    end
    return hitbox:FindFirstChild(library.flags[flag])
end

local function getsilentaimtarget(equipped)
    local ret, dist = nil, library.flags.silentaimfov.enabled and silentaimfovcircle.Radius or math.huge
    local startpos = equipped.Tip.CFrame.Position
    for i, v in next, players:GetPlayers() do
        if v.Team ~= player.Team then
            local part = v.Character and getaimpart(v.Character, "silentaimaimpart")
            if part and v.Character.Humanoid.Health > 0 then
                local partpos = part.Position
                local screenpos, vis = cam:WorldToViewportPoint(partpos)
                local iswallbetween = workspace:FindPartOnRayWithIgnoreList(Ray.new(startpos, partpos - startpos), { cam, char, equipped.Model, v.Character }, true) ~= nil
                if vis and (iswallbetween == false or library.flags.silentaimwallcheck == false) then
                    local mag = Vector2.new(screenpos.X - mouse.X, screenpos.Y - mouse.Y).Magnitude
                    if mag < dist then
                        ret, dist = {
                            part = part,
                            iswallbetween = iswallbetween
                        }, mag
                    end
                end
            end
        end
    end
    return ret
end

local function getaimbottarget(equipped)
    local ret, dist = nil, library.flags.aimbotfov.enabled and aimbotfovcircle.Radius or math.huge
    local startpos = cam.CFrame.Position
    for i, v in next, players:GetPlayers() do
        if v.Team ~= player.Team then
            local part = v.Character and getaimpart(v.Character, "aimbotaimpart")
            if part and v.Character.Humanoid.Health > 0 then
                local partpos = part.Position
                local screenpos, vis = cam:WorldToViewportPoint(partpos)
                if vis and (library.flags.aimbotwallcheck == false or workspace:FindPartOnRayWithIgnoreList(Ray.new(startpos, partpos - startpos), { cam, char, equipped.Model, v.Character }, true) == nil) then
                    local mag = Vector2.new(screenpos.X - mouse.X, screenpos.Y - mouse.Y).Magnitude
                    if mag < dist then
                        ret, dist = part, mag
                    end
                end
            end
        end
    end
    return ret
end

local function getaimbotposition(aimtarget, equipped)
    local targetroot, pos = aimtarget.Parent.HumanoidRootPart, aimtarget.Position
    local speed = equipped.Config.BulletSpeed
    if speed then
        local dur = (aimtarget.Position - cam.CFrame.Position).Magnitude / speed
        if library.flags.aimbotpredictmove then
            pos = pos + (targetroot.Velocity * dur)
        end
        if library.flags.aimbotcompensatedrop then
            pos = pos + Vector3.new(0, (workspace.Gravity / 20) * dur ^ 2, 0)
        end
    end
    return pos
end

local function updaterobbery(name, pretty, val)
    local isopen = val.Value ~= modules.robconsts.ENUM_STATE.CLOSED
    robstates[name] = isopen
    if roblabels[name] then
        roblabels[name]:update(isopen and "Open" or "Closed", isopen and Color3.fromRGB(15, 180, 85) or Color3.fromRGB(234, 36, 36))
    end
    if val.Value == modules.robconsts.ENUM_STATE.OPENED then
        if library.flags.notifyrobberies then
            game:GetService("StarterGui"):SetCore("SendNotification", { Title = "Evo V3", Text = "'" .. pretty .. "' has just opened!" })
        end
    end
end

local function registerrobbery(val)
    local name, pretty = garbage.markerstates[tonumber(val.Name)].Name, modules.robconsts.PRETTY_NAME[tonumber(val.Name)]
    updaterobbery(name, pretty, val)
    val:GetPropertyChangedSignal("Value"):Connect(function()
        updaterobbery(name, pretty, val)
    end)
end

local function updatevehicle(prop, val)
    local vehicle = originals.getvehiclepacket()
    if vehicle and vehicle[prop] and not vehicle.Passenger then
        vehicle[prop] = vehiclestats[vehicle.Model][prop] + val
        modules.chassis.UpdateStats(vehicle)
    end
end

local function solvepuzzle()
    local grid = evov3.utils:deepclone(puzzle.Grid)
	for i, v in next, grid do
		for i2, v2 in next, v do
			v[i2] = v[i2] + 1
		end
	end
	local res = httprequest({
		Url = "", -- Link redacted, the repl.co one from the previous 2 versions of Evo still works tho :)
		Method = "POST",
		Headers = {
			["Content-Type"] = "application/json"
		},
		Body = httpservice:JSONEncode({
			puzzle = grid
		})
	})
    if res.Success then
        local solution = httpservice:JSONDecode(res.Body)
        for i, v in next, solution do
            for i2, v2 in next, v do
                v[i2] = v[i2] - 1
            end
        end
        puzzle.Grid = solution
        puzzle.OnConnection()
    else
        modules.notification.new({ Text = "The Puzzle Solver is not responding. Please try again later" })
    end
end

local function firetouch(part)
    if root then
        firetouchinterest(root, part, 0)
        task.wait()
        firetouchinterest(root, part, 1)
    end
end

local function opendoors()
    for i, v in next, doorstore do
        if not v.State.Open then
            garbage.opendoor(v)
        end
    end
end

local function explodewall()
    for i, v in next, specs do
        if v.Name == "Explode Wall" then
            v:Callback(true)
            break
        end
    end
end

local function liftgate()
    for i, v in next, specs do
        if v.Name == "Lift Gate" then
            v:Callback(true)
            break
        end
    end
end

local function opensewers()
    for i, v in next, specs do
        if v.Name == "Pull Open" then
            v:Callback(true)
        end
    end
end

local function hasrequiredgamepasses(name)
    local gamepasses = gundata[name].RequireAnyGamepass
    if gamepasses then
        for i = 1, #gamepasses do
            if not marketplace:UserOwnsGamePassAsync(player.UserId, modules.gamepassutils.GetGamepassFromEnum(gamepasses[i]).PassId) then
                return false
            end
        end
    end
    return true
end

local function isvehicleshootable(model, teamcheck)
    if not (model:FindFirstChild("Seat") and model.Seat:FindFirstChild("Player")) then
        return false
    end
    return model.Seat.Player.Value and model.Seat.PlayerName.Value ~= player.Name and (teamcheck == false or players[model.Seat.PlayerName.Value].Team ~= player.Team)
end

local function shootvehicle(part)
    fakesniper.LastImpact = 0
    fakesniper.BulletEmitter.OnHitSurface:Fire(part, part.Position, part.Position)
end

local function grabfromshop(category, name)
    setthreadidentity(2)
    local isopen = not select(1, pcall(modules.gunshopui.open))
    modules.gunshopui.displayList(modules.gunshoputils.getCategoryData(category))
    setthreadidentity(7)
    for i, v in next, modules.gunshopui.gui.Container.Container.Main.Container.Slider:GetChildren() do
        if v:IsA("ImageLabel") and (name == "All" or v.Name == name) and (category ~= "Held" or v.Bottom.Action.Text == "FREE" or v.Bottom.Action.Text == "EQUIP") and hasrequiredgamepasses(v.Name) then
			firesignal(v.Bottom.Action.MouseButton1Down)
		end
    end
    if isopen == false then
        modules.gunshopui.close()
    end
end
  
  return grabfromshop
