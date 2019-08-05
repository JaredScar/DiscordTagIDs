local showPlayerBlips = false
local ignorePlayerNameDistance = false
local playerNamesDist = 15
local displayIDHeight = 1.5 --Height of ID above players head(starts at center body mass)
--Set Default Values for Colors
local red = 255
local green = 255
local blue = 255

function DrawText3D(x,y,z, text) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)

    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    
    if onScreen then
        SetTextScale(0.0*scale, 0.55*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(red, green, blue, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
		World3dToScreen2d(x,y,z, 0) --Added Here
        DrawText(_x,_y)
    end
end

prefixes = {}
hidePrefix = {}
hideTags = {}
hideAll = false
prefixStr = ""

RegisterNetEvent("ID:HideTag")
AddEventHandler("ID:HideTag", function(arr, error)
	hideTags = arr
end)

RegisterNetEvent("ID:Tags-Toggle")
AddEventHandler("ID:Tags-Toggle", function(val, error)
	if val then
		hideAll = true
	else
		hideAll = false
	end
end)

RegisterNetEvent("ID:Tag-Toggle")
AddEventHandler("ID:Tag-Toggle", function(arr, error)
	hidePrefix = arr
end)

RegisterNetEvent("GetStaffID:StaffStr:Return")
AddEventHandler("GetStaffID:StaffStr:Return", function(arr, error)
	prefixes = arr
end)

AddEventHandler('playerSpawned', function()
	TriggerServerEvent('dtid:playerSpawned')
end)

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

Citizen.CreateThread(function()
    while true do
        for i=0,99 do
            N_0x31698aa80e0223f8(i)
        end
		if not (hideAll) then
			for _, id in ipairs(GetActivePlayers()) do
				if  ((NetworkIsPlayerActive( id )) and GetPlayerPed( id ) ~= GetPlayerPed( -1 )) then
					ped = GetPlayerPed( id )
					blip = GetBlipFromEntity( ped ) 
	 
					x1, y1, z1 = table.unpack( GetEntityCoords( GetPlayerPed( -1 ), true ) )
					x2, y2, z2 = table.unpack( GetEntityCoords( GetPlayerPed( id ), true ) )
					distance = math.floor(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))
					-- THIS IF IS FALSE BELOW, DO NOT WORRY ABOUT IT - Badger
					if(ignorePlayerNameDistance) then
						if NetworkIsPlayerTalking(id) then
							red = 0
							green = 0
							blue = 255
							for i = 1, #prefixes do
								if prefixes[i][1] == GetPlayerName(id) then
									prefixStr = prefixes[i][2]
								end
							end
							DrawText3D(x2, y2, z2 + displayIDHeight, prefixStr .. "~b~[" .. GetPlayerServerId(id) .. "]")
						else
							red = 255
							green = 255
							blue = 255
							for i = 1, #prefixes do
								if prefixes[i][1] == GetPlayerName(id) then
									prefixStr = prefixes[i][2]
								end
							end
							DrawText3D(x2, y2, z2 + displayIDHeight, prefixStr .. "~w~[" .. GetPlayerServerId(id) .. "]")
						end
					end
					local playName = GetPlayerName(GetPlayerFromServerId(GetPlayerServerId(id)))
					if ((distance < playerNamesDist)) then
						if not (ignorePlayerNameDistance) then
							if NetworkIsPlayerTalking(id) then
								red = 0
								green = 0
								blue = 255
								for i = 1, #prefixes do
									if prefixes[i][1] == GetPlayerName(GetPlayerFromServerId(GetPlayerServerId(id))) then
										prefixStr = prefixes[i][2]
									end
								end
								if not has_value(hideTags, playName) then
									if not (has_value(hidePrefix, playName)) then
										-- Show their ID tag with prefix then
										DrawText3D(x2, y2, z2 + displayIDHeight, prefixStr .. "~b~[" .. GetPlayerServerId(id) .. "]")
									else
										-- Don't show their ID tag with prefix then
										DrawText3D(x2, y2, z2 + displayIDHeight, "~b~[" .. GetPlayerServerId(id) .. "]")
									end
								end
								prefixStr = ""
							else
								red = 255
								green = 255
								blue = 255
								for i = 1, #prefixes do
									if prefixes[i][1] == GetPlayerName(GetPlayerFromServerId(GetPlayerServerId(id))) then
										prefixStr = prefixes[i][2]
									end
								end
								if not has_value(hideTags, playName) then
									if not (has_value(hidePrefix, playName)) then
										-- Show their ID tag with prefix then
										DrawText3D(x2, y2, z2 + displayIDHeight, prefixStr .. "~w~[" .. GetPlayerServerId(id) .. "]")
									else
										-- Don't show their ID tag with prefix then
										DrawText3D(x2, y2, z2 + displayIDHeight, "~w~[" .. GetPlayerServerId(id) .. "]")
									end
								end
								prefixStr = ""
							end
						end
					end  
				end
			end
		end
        Citizen.Wait(0)
    end
end)