AddEventHandler("gridsystem:registerMarker", function (marker)

    marker = ParseMarker(marker, GetInvokingResource())
    if not marker then return end
    if marker.permission and CurrentJob == nil then
        table.insert(TempMarkerWithJob, marker)
        return
    end

    CheckMarkerJob(marker)
    local isRegistered, chunkId, index = IsMarkerAlreadyRegistered(marker.name)
    if isRegistered then
        if HasJob(marker) then
            LogInfo("Updating Marker: " .. marker.name .. " Please WAIT!")
            RegisteredMarkers[chunkId][index] = marker
            CurrentZone = nil
            HasAlreadyEnteredMarker = false
        else
            LogInfo("Removing Marker Because job changed: " .. marker.name)
            RegisteredMarkers[chunkId][index] = nil
        end
    else
        if HasJob(marker) then
            local chunk = InsertMarkerIntoGrid(marker)
            LogSuccess("Registering Marker: " .. marker.name .. " in chunk: " .. chunk)
        end
    end
end)


AddEventHandler("gridsystem:hasEnteredMarker", function (zone)
    if #(MyCoords.xy - zone.pos.xy) < #(zone.size.xy/2) and math.abs(MyCoords.z - zone.pos.z) < zone.scaleZ then
        if zone.onEnter then
            local status, err = pcall(zone.onEnter)
            if not status then
                LogError(string.format("Error executing action for marker %s. Error: %s", zone.name, err))
            end
        end
    else
        LogError("Error: enter event triggered but player is outside of marker", GetInvokingResource())
    end
end)

AddEventHandler("gridsystem:hasExitedMarker", function ()
    if CurrentZone then
        if CurrentZone.mustExit then
            CurrentZone.mustExit = nil
        end
        if CurrentZone.onExit then
            local status, err = pcall(CurrentZone.onExit)
            if not status then
                LogError(string.format("Error executing action for marker %s. Error: %s", CurrentZone.name, err))
            end
        end
        CurrentZone = nil
        
        Citizen.InvokeNative(0x8DFCED7A656F8802, true)
        -- ClearHelp(true)
    else
        LogError("Error: exit event triggered but marker never entered", GetInvokingResource())
    end
end)

AddEventHandler("gridsystem:unregisterMarker", function(markerName)
    local isRegistered, chunkId, index = IsMarkerAlreadyRegistered(markerName)
    if isRegistered then
        LogInfo("Removing Marker: " .. markerName)
        RegisteredMarkers[chunkId][index] = nil
    end
end)

RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function (job)
    CurrentJob = job
    RemoveAllJobMarkers()
    AddJobMarkers()
end)


AddEventHandler("onResourceStop", function (resource)
    local markers = GetMarkersFromResource(resource)
    if #markers > 0 then
        for _, m in pairs(markers) do
            local isRegistered, chunkId, index = IsMarkerAlreadyRegistered(m.name)
            if isRegistered then
                LogInfo(string.format("Removing Marker For Stopping of Resource %s: %s", resource, m.name))
                RegisteredMarkers[chunkId][index] = nil
            end
        end
    end
end)