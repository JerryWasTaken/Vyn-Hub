

local originals = {
    vehicle = require(game.ReplicatedStorage.Game.Vehicle),
    alexChassis = require(game.ReplicatedStorage.Module.AlexChassis)
}
local getLocalVehiclePacket = originals.vehicle.GetLocalVehiclePacket

local playerSpeed = 150
local vehicleSpeed = 350
local tpHeight = 300

local function getXZDir(start, target)
	local xzNow = Vector3.new(start.Position.X, 0, start.Position.Z)
	local xzEnd = Vector3.new(target.Position.X, 0, target.Position.Z)
	return (xzEnd - xzNow).Unit
end

local function getXZMag(start, target)
	local xzNow = Vector3.new(start.Position.X, 0, start.Position.Z)
	local xzEnd = Vector3.new(target.Position.X, 0, target.Position.Z)
	return (xzEnd - xzNow).Magnitude
end


local function getTeleportIgnoreList()
    local ignoreList = { workspace.Vehicles, workspace.Items, workspace.Trains, workspace.Terrain.Clouds }
    if workspace:FindFirstChild("Rain") then
        ignoreList[#ignoreList + 1] = workspace.Rain
    end
    return ignoreList
end

local function randomVector()
    local x, y, z = math.random(-150, 150), math.random(-150, 150), math.random(-150, 150)
    return Vector3.new(x / 1000, y / 1000, z / 1000)
end

local function getNextLocation(start, target, speed, step)
    local dir, mag = getXZDir(start, target), math.min((speed * step) + (math.random(-150, 150) / 1000), getXZMag(start, target))
    return CFrame.new(Vector3.new(start.Position.X, tpHeight, start.Position.Z) + ((dir * mag) + randomVector()), Vector3.new(target.Position.X, start.Position.Y, target.Position.Z) + target.LookVector)
end

local function getNextDirectLocation(start, target, speed, step)
    local dir, mag = (target.Position - start.Position).Unit, math.min((speed * step) + (math.random(-150, 150) / 1000), (target.Position - start.Position).Magnitude)
    return CFrame.new(start.Position + ((dir * mag) + randomVector()), Vector3.new(target.Position.X, start.Position.Y, target.Position.Z) + target.LookVector)
end


function carTeleport(target, options)
    local success = true
    local isInstance = typeof(target) == "Instance"
    local vehicle = getLocalVehiclePacket()
    local vehicleModel = vehicle.Model
    local VehiclePart = vehicle.Model.PrimaryPart
    local arrived = false
    local hasLift = vehicle.Lift ~= nil
    local stallDrop
    if hasLift then
		originals.alexChassis.SetGravity(vehicle, 0)
    elseif vehicle.Type ~= "Heli" then
        workspace.Gravity = 0
	end
    local conn = game.RunService.Stepped:Connect(function(dur, step)
        if vehicle.Model.PrimaryPart then
            vehicleModel:SetPrimaryPartCFrame(getNextLocation(VehiclePart, isInstance and target.CFrame or target, vehicleSpeed, step))
            VehiclePart.Velocity, VehiclePart.RotVelocity = Vector3.new(), Vector3.new()
            if getXZMag(VehiclePart, target) < 0.5 then
                arrived = true
            end
        else
            success = false
            arrived = true
        end
	end)
    repeat task.wait() until arrived
    conn:Disconnect()
    if success then
        if stallDrop then
            repeat
                vehicleModel:SetPrimaryPartCFrame(getNextLocation(VehiclePart, isInstance and target.CFrame or target, vehicleSpeed, 1))
                VehiclePart.Velocity, VehiclePart.RotVelocity = Vector3.new(), Vector3.new()
                task.wait()
            until stallDrop()
        end
        vehicleModel:SetPrimaryPartCFrame(isInstance and target.CFrame or target)
        VehiclePart.Velocity, VehiclePart.RotVelocity = Vector3.new(), Vector3.new()
        if hasLift then
            originals.alexChassis.SetGravity(vehicle, options.drop and 100 or 0)
        elseif vehicle.Type ~= "Heli" then
            workspace.Gravity = 196.2
        end
    end
end

return carTeleport
