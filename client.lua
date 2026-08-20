local playerDiscordNames = nil;
local formatDisplayedName = "[{SERVER_ID}]";
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

function Draw2DText(x, y, text, scale, center)
    -- Draw text on screen
    SetTextFont(4)
    SetTextProportional(7)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextDropShadow()
    SetTextEdge(4, 0, 0, 0, 255)
    SetTextOutline()
    if center then 
    	SetTextJustification(0)
    end
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

prefixes = {}
hidePrefix = {}
hideTags = {}
hideAll = false
if Config.TagsForStaffOnly then 
	hideAll = true;
end
prefixStr = ""

RegisterNetEvent("ID:HideTag")
AddEventHandler("ID:HideTag", function(arr, error)
	hideTags = arr; 
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

RegisterNetEvent("DiscordTag:Server:GetDiscordName:Return")
AddEventHandler("DiscordTag:Server:GetDiscordName:Return", function(serverId, discordUsername, format, useDiscordName)
	if (useDiscordName) then 
		if playerDiscordNames == nil then 
			playerDiscordNames = {};
		end
		playerDiscordNames[serverId] = discordUsername;
	end
	formatDisplayedName = format;
end)

RegisterNetEvent("GetStaffID:StaffStr:Return")
AddEventHandler("GetStaffID:StaffStr:Return", function(arr, activeTagTrack, error)
	prefixes = arr
	activeTagTracker = activeTagTrack
end)
activeTagTracker = {}

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

Citizen.CreateThread(function()
	-- The player has spawned, we gotta get their tag 
	Wait(1000);
	TriggerServerEvent('DiscordTag:Server:GetTag'); 
	TriggerServerEvent('DiscordTag:Server:GetDiscordName');
end)

colorPatternIndex      = {}
colorPatternLastChange = {}

-- Resolve all ColorPattern tokens in a tag string to their current cycling color.
-- Uses GetGameTimer() for millisecond-accurate timing independent of framerate.
local function resolvePatternColors(tag)
	local now = GetGameTimer()
	for patternName, patternColors in pairs(Config.ColorPatterns) do
		if tag:find(patternName, 1, true) then
			if not colorPatternLastChange[patternName] then
				colorPatternLastChange[patternName] = now
				colorPatternIndex[patternName]      = 1
			end
			local idx = colorPatternIndex[patternName]
			tag = tag:gsub(patternName, patternColors[idx], 1)
			if (now - colorPatternLastChange[patternName]) >= Config.ColorChangeSpeed then
				colorPatternLastChange[patternName] = now
				colorPatternIndex[patternName]      = (idx % #patternColors) + 1
			end
		end
	end
	return tag
end
function triggerTagUpdate()
	if not (hideAll) then
		for _, id in ipairs(GetActivePlayers()) do
			local activeTag = activeTagTracker[GetPlayerServerId(id)]
			if activeTag == nil then 
				activeTag = ''
			end
			if  ((NetworkIsPlayerActive( id )) and (GetPlayerPed( id ) ~= GetPlayerPed( -1 ) or Config.ShowOwnTag) ) then
				ped = GetPlayerPed( id )
				blip = GetBlipFromEntity( ped ) 

				x1, y1, z1 = table.unpack( GetEntityCoords( GetPlayerPed( -1 ), true ) )
				x2, y2, z2 = table.unpack( GetEntityCoords( GetPlayerPed( id ), true ) )
				distance = math.floor(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))
				local displayName = formatDisplayedName;
				local name = nil;
				if playerDiscordNames ~= nil then 
					name = playerDiscordNames[GetPlayerServerId(id)];
				end
				if (name == nil) then 
					displayName = displayName:gsub("{PLAYER_NAME}", GetPlayerName(id)):gsub("{SERVER_ID}", GetPlayerServerId(id));
				else
					displayName = displayName:gsub("{PLAYER_NAME}", name):gsub("{SERVER_ID}", GetPlayerServerId(id));
				end
				local playName = GetPlayerName(GetPlayerFromServerId(GetPlayerServerId(id)))
				if ((distance < playerNamesDist)) then
					if not (ignorePlayerNameDistance) then
						if (Config.RequiresLineOfSight) then 
							if (not HasEntityClearLosToEntity(PlayerPedId(), GetPlayerPed(id), 17) and (GetPlayerPed( id ) ~= GetPlayerPed( -1 )) ) then 
								return; -- They cannot see this player
							end
						end

						local resolvedTag = resolvePatternColors(activeTag)

						if NetworkIsPlayerTalking(id) then
							red = 0; green = 0; blue = 255
							if not has_value(hideTags, playName) then
								if not (has_value(hidePrefix, playName)) then
									DrawText3D(x2, y2, z2 + displayIDHeight, resolvedTag .. "~b~" .. displayName)
								else
									DrawText3D(x2, y2, z2 + displayIDHeight, "~b~" .. displayName)
								end
							end
							prefixStr = ""
						else
							red = 255; green = 255; blue = 255
							if not has_value(hideTags, playName) then
								if not (has_value(hidePrefix, playName)) then
									DrawText3D(x2, y2, z2 + displayIDHeight, resolvedTag .. "~w~" .. displayName)
								else
									DrawText3D(x2, y2, z2 + displayIDHeight, "~w~" .. displayName)
								end
							end
						end
					end
				end  
			end
		end
	end
end

if (Config.HUD.Display) then 
	Citizen.CreateThread(function()
		while true do 
			Citizen.Wait(0);
			local headtag = activeTagTracker[GetPlayerServerId(PlayerId())];
			if (headtag == nil) then 
				headtag = Config.roleList[1][2];
			end
			if (headtag == nil) then 
				headtag = 'N/A'
			end
			Draw2DText(Config.HUD.x, Config.HUD.y, Config.HUD.Format:gsub("{HEADTAG}", headtag), Config.HUD.Scale, true);
		end
	end)
end 

showTags = Config.KeyBindToggleDefaultShow;

Citizen.CreateThread(function()
    while true do
        for i=0,99 do
            N_0x31698aa80e0223f8(i)
        end
		if (Config.UseKeyBind) then
			if (not Config.UseKeyBindToggle) then 
				if (IsControlPressed(0, Config.KeyBind)) then 
					triggerTagUpdate();
				end
			else 
				if (IsControlJustReleased(0, Config.KeyBind)) then 
					showTags = not showTags;
				end
				if (showTags) then 
					triggerTagUpdate();
				end
			end
		else
			triggerTagUpdate(); 
		end
        Citizen.Wait(0);
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Custom Player Headtag – NUI
-- ─────────────────────────────────────────────────────────────────────────────
if Config.CustomTags.Enabled then

local nuiOpen = false

local function OpenCustomTagUI()
	TriggerServerEvent('DiscordTag:CustomTag:Open')
end

local function CloseCustomTagUI()
	nuiOpen = false
	SetNuiFocus(false, false)
	SendNUIMessage({action = "close"})
end

-- Server sends back the data needed to populate the NUI
RegisterNetEvent('DiscordTag:CustomTag:OpenReturn')
AddEventHandler('DiscordTag:CustomTag:OpenReturn', function(tags, slots, patterns)
	nuiOpen = true
	SetNuiFocus(true, true)
	SendNUIMessage({
		action   = "open",
		tags     = tags,
		slots    = slots,
		patterns = patterns,
		maxLen   = Config.CustomTags.MaxTextLength,
	})
end)

-- Server confirms a save/delete; refresh the tag list in the NUI
RegisterNetEvent('DiscordTag:CustomTag:SaveReturn')
AddEventHandler('DiscordTag:CustomTag:SaveReturn', function(tags, slots)
	SendNUIMessage({
		action = "refresh",
		tags   = tags,
		slots  = slots,
	})
end)

-- Server sends an error message to display in the NUI
RegisterNetEvent('DiscordTag:CustomTag:Error')
AddEventHandler('DiscordTag:CustomTag:Error', function(msg)
	SendNUIMessage({action = "error", message = msg})
end)

-- Server confirms an activation; highlight the active tag in the NUI
RegisterNetEvent('DiscordTag:CustomTag:ActivateReturn')
AddEventHandler('DiscordTag:CustomTag:ActivateReturn', function(index)
	SendNUIMessage({action = "activated", index = index})
	-- Close the NUI after activation
	Citizen.SetTimeout(800, function()
		CloseCustomTagUI()
	end)
end)

-- NUI callbacks (messages sent from the browser to Lua)
RegisterNUICallback('save', function(data, cb)
	TriggerServerEvent('DiscordTag:CustomTag:Save', {
		index = data.index,
		text  = data.text,
		color = data.color,
	})
	cb({ok = true})
end)

RegisterNUICallback('delete', function(data, cb)
	TriggerServerEvent('DiscordTag:CustomTag:Delete', {index = data.index})
	cb({ok = true})
end)

RegisterNUICallback('activate', function(data, cb)
	TriggerServerEvent('DiscordTag:CustomTag:Activate', {index = data.index})
	cb({ok = true})
end)

RegisterNUICallback('close', function(data, cb)
	CloseCustomTagUI()
	cb({ok = true})
end)

-- /customtag command opens the panel
RegisterCommand("customtag", function(source, args, rawCommand)
	if not nuiOpen then
		OpenCustomTagUI()
	else
		CloseCustomTagUI()
	end
end, false)

-- ESC also closes the panel
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if nuiOpen and IsControlJustReleased(0, 200) then -- INPUT_FRONTEND_CANCEL (ESC)
			CloseCustomTagUI()
		end
	end
end)

end -- Config.CustomTags.Enabled
