

MyPed = nil
MyCoords = vector3(0,0,0)
CurrentZone = nil

local CurrentChunk = nil
local CurrentChunks = {}
local MarkersToCheck = {}
RegisteredMarkers = {}
MarkerWithJob = {}
TempMarkerWithJob = {}
MarkerPeds = {}
CurrentJob = nil

LetSleep = true
local abs = math.abs

CreateThread(function ()
    RegisterTempMarkers()
end)

CreateThread(function ()
    while true do
        MyPed = PlayerPedId()
        MyCoords = GetEntityCoords(MyPed)
        -- print(MyCoords)
        Wait(200)
    end
end)

CreateThread(function()
    while true do
        local chunk = GetCurrentChunk(MyCoords)
        if chunk ~= CurrentChunk then
            CurrentChunks = GetNearbyChunks(MyCoords)
        end
        MarkersToCheck = {}
        for i = 1, #CurrentChunks do
            if RegisteredMarkers[CurrentChunks[i]] then
                for _, zone in pairs(RegisteredMarkers[CurrentChunks[i]]) do
                    table.insert(MarkersToCheck, zone)
                end
            end
        end
        Wait(1000)
    end
end)

CreateThread(function ()
    while true do
        local isInMarker, _currentZone = false, nil
        LetSleep = true
        for i = 1, #MarkersToCheck do
            local zone = MarkersToCheck[i]
            local distance = #(MyCoords - zone.pos)
            if distance < zone.drawDistance then
                LetSleep = false
                if zone.show3D then
                    DrawText3D(zone.pos.x, zone.pos.y, zone.pos.z, zone.msg)
                else
                    if zone.type ~= -1 then
                        Citizen.InvokeNative(0x2A32FAA57B937173, zone.type, zone.pos.x, zone.pos.y, zone.pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 
                        zone.scale.x, zone.scale.y, zone.scale.z, zone.color.r, zone.color.g, zone.color.b, 100, zone.shouldBob or false, true, 2, zone.shouldRotate or false, nil, nil, false)
 
                    end
                end
                
                if #(MyCoords.xy - zone.pos.xy) < #(zone.size.xy/2) and abs(MyCoords.z - zone.pos.z) < zone.scaleZ then
                    isInMarker, _currentZone = true, zone
                    
                end
            end
        end

		if isInMarker and not HasAlreadyEnteredMarker then
            CurrentZone = _currentZone
			HasAlreadyEnteredMarker = true
			TriggerEvent("gridsystem:hasEnteredMarker", _currentZone)
            if (_currentZone.showPrompt) then
                SetupPrompt(_currentZone)
            end
		end
		if HasAlreadyEnteredMarker and ( not isInMarker or _currentZone ~= CurrentZone) then
			HasAlreadyEnteredMarker = false
			TriggerEvent("gridsystem:hasExitedMarker")
            ResetPrompt()
		end
        Wait(3)
		if LetSleep then
			Citizen.Wait(700)
		end
    end
end)

function ResetPrompt()
    PromptDelete(currentPrompt);
end

local currentPrompt
local promptGroup

function SetupPrompt(zone)
    promptGroup = GetRandomIntInRange(0, 0xffffff)
    Citizen.CreateThread(function()
        local str = zone.hint or ''
        currentPrompt = PromptRegisterBegin()
        PromptSetControlAction(currentPrompt, zone.control or Keys["G"])
        str = CreateVarString(10, 'LITERAL_STRING', str)
        PromptSetText(currentPrompt, str)
        PromptSetEnabled(currentPrompt, 1)
        PromptSetVisible(currentPrompt, 1)
        PromptSetStandardMode(currentPrompt, 1)
        -- PromptSetHoldMode(currentPrompt, 1)
        PromptSetGroup(currentPrompt, promptGroup)
        PromptRegisterEnd(currentPrompt)
    end)
end

CreateThread(function ()

    while true do
        if CurrentZone then

            local _zone = CurrentZone
            if _zone and not _zone.mustExit then

                if _zone.showPrompt or not _zone.show3D then
                    local label  = CreateVarString(10, 'LITERAL_STRING', _zone.promptName or "")
                    PromptSetActiveGroupThisFrame(promptGroup, label)
                    if PromptHasStandardModeCompleted(currentPrompt, false) then
                        local status, err = pcall(_zone.action)
                        if not status then
                            LogError(string.format("Error executing action for marker %s. Error: %s", _zone.name, err))
                        end
                    elseif PromptHasHoldModeCompleted(currentPrompt) then
                        --Not yet working
                    end
                else 
                    if IsControlJustReleased(0, _zone.control) then 
                        if _zone.action then
                            local status, err = pcall(_zone.action)
                            if not status then
                                LogError(string.format("Error executing action for marker %s. Error: %s", _zone.name, err))
                            end
                        end
    
                        if _zone.forceExit then
                            CurrentZone.mustExit = true
                        end
                    end
                end


            end
        end
        Wait(0)
        if LetSleep then
            Wait(700)
        end
    end
end)