roleList = Config.roleList

prefixes = {}
hasPrefix = {}

function stringsplit(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end
hidePrefix = {}
hideAll = {}

local function get_index (tab, val)
	local counter = 1
    for index, value in ipairs(tab) do
        if value == val then
            return counter
        end
		counter = counter + 1
    end

    return nil
end

local function has_value (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
hideTags = {}

function HideUserTag(src)
	if get_index(hideTags, GetPlayerName(src)) == nil then 
		table.insert(hideTags, GetPlayerName(src))
		TriggerClientEvent('ID:HideTag', -1, hideTags, false)
	end
end
function ShowUserTag(src)
	if get_index(hideTags, GetPlayerName(src)) ~= nil then 
		table.remove(hideTags, get_index(hideTags, GetPlayerName(src)))
		TriggerClientEvent('ID:HideTag', -1, hideTags, false)
	end 	
end

RegisterCommand("tag-toggle", function(source, args, rawCommand)
	local name = GetPlayerName(source) 
	if (has_value(hidePrefix, name)) then
		-- Turn on their tag-prefix and remove them
		table.remove(hidePrefix, get_index(hidePrefix, name))
		TriggerClientEvent("ID:Tag-Toggle", -1, hidePrefix, false)
		TriggerClientEvent('chatMessage', source, "^9[^1Badger-Tags^9] ^3Your tag is now ^2active")
	else
		-- Turn off their tag-prefix and add them
		table.insert(hidePrefix, name)
		TriggerClientEvent("ID:Tag-Toggle", -1, hidePrefix, false)
		TriggerClientEvent('chatMessage', source, "^9[^1Badger-Tags^9] ^3Your tag is no longer ^1active")
	end 
end)
RegisterCommand("tags-toggle", function(source, args, rawCommand)
	local name = GetPlayerName(source)
	if not Config.TagsForStaffOnly then
		if (has_value(hideAll, name)) then
			-- Have them not hide all tags
			table.remove(hideAll, get_index(hideAll, name))
			TriggerClientEvent("ID:Tags-Toggle", source, false, false)
			TriggerClientEvent("GetStaffID:StaffStr:Return", -1, prefixes, activeTagTracker, false)
			TriggerClientEvent('chatMessage', source, "^9[^1Badger-Tags^9] ^3Tags of players are now ^2active")
		else
			-- Have them hide all tags
			table.insert(hideAll, name)
			TriggerClientEvent("GetStaffID:StaffStr:Return", -1, prefixes, activeTagTracker, false)
			TriggerClientEvent("ID:Tags-Toggle", source, true, false)
			TriggerClientEvent('chatMessage', source, "^9[^1Badger-Tags^9] ^3Tags of players are no longer ^1active")
		end
	else 
		-- Only for staff 
		if IsPlayerAceAllowed(source, "DiscordTagIDs.Use.Tag-Toggle") then 
			if not (has_value(hideAll, name)) then
				-- Have them not hide all tags
				table.insert(hideAll, name)
				TriggerClientEvent("ID:Tags-Toggle", source, false, false)
				TriggerClientEvent("GetStaffID:StaffStr:Return", -1, prefixes, activeTagTracker, false)
				TriggerClientEvent('chatMessage', source, "^9[^1Badger-Tags^9] ^3Tags of players are now ^2active")
			else
				-- Have them hide all tags
				table.remove(hideAll, get_index(hideAll, name))
				TriggerClientEvent("GetStaffID:StaffStr:Return", -1, prefixes, activeTagTracker, false)
				TriggerClientEvent("ID:Tags-Toggle", source, true, false)
				TriggerClientEvent('chatMessage', source, "^9[^1Badger-Tags^9] ^3Tags of players are no longer ^1active")
			end
		else 
			TriggerClientEvent('chatMessage', source, "^9[^1Badger-Tags^9] ^1ERROR: You do not have access to this...")
		end
	end
end)
prefix = Config.Prefix;
RegisterCommand("headtag", function(source, args, rawCommand)
	-- Change your headtag that is active 
	if #args == 0 then 
		-- List out what they have access to:
		local tags = prefixes[source]
		TriggerClientEvent('chatMessage', source, prefix .. 'You have access to the following Head-Tags:')
		if tags ~= nil then 
			for i = 1, #tags do 
				-- This is a tag 
				TriggerClientEvent('chatMessage', source, '^9[^5' .. i .. '^9] ^3' .. tags[i])
			end
			TriggerClientEvent('chatMessage', source, prefix .. 'You can change your Head-Tag with /headtag <id>')
		else 
			TriggerClientEvent('chatMessage', source, '^1NONE');
		end
	elseif #args == 1 then 
		-- They picked one
		if tonumber(args[1]) ~= nil then
			local index = tonumber(args[1])
			if prefixes[source][index] ~= nil and prefixes[source][index] ~= nil then 
				-- Change their active tag to this 
				activeTagTracker[source] = prefixes[source][index]
				-- Update clients: 
				TriggerClientEvent("GetStaffID:StaffStr:Return", -1, prefixes, activeTagTracker, false)
				TriggerClientEvent('chatMessage', source, prefix .. 'Your Head-Tag has been changed to: ^1' .. prefixes[source][index]);
			else 
				-- Not a valid ID 
				TriggerClientEvent('chatMessage', source, prefix .. '^1ERROR: Not a valid Head-Tag ID');
			end
		else 
			-- Not a valid ID 
			TriggerClientEvent('chatMessage', source, prefix .. '^1ERROR: Not a valid Head-Tag ID');
		end
	else 
		-- Not correct syntax 
		TriggerClientEvent('chatMessage', source, prefix .. '^1ERROR: Not proper usage. /headtag <id>');
	end
end)

alreadyGotRoles = {}
activeTagTracker = {}
AddEventHandler('playerDropped', function (reason) 
	activeTagTracker[source] = nil 
	prefixes[source] = nil 
end)

RegisterNetEvent('DiscordTag:Server:GetDiscordName')
AddEventHandler('DiscordTag:Server:GetDiscordName', function() 
	local src = source;
	local discordName = exports.Badger_Discord_API:GetDiscordName(src);
	if (not Config.ShowDiscordDescrim and discordName ~= nil) then
		discordName = stringsplit(discordName, "#")[1];
	end
	TriggerClientEvent('DiscordTag:Server:GetDiscordName:Return', -1, src, discordName, Config.FormatDisplayName, Config.UseDiscordName);
end)

RegisterNetEvent('DiscordTag:Server:GetTag')
AddEventHandler('DiscordTag:Server:GetTag', function()
--AddEventHandler('chatMessage', function(source, name, msg)
	TriggerClientEvent("GetStaffID:StaffStr:Return", -1, prefixes, activeTagTracker, false)
	if Config.TagsForStaffOnly then
		if IsPlayerAceAllowed(source, "DiscordTagIDs.Use.Tag-Toggle") then 
			TriggerClientEvent("ID:Tags-Toggle", source, false, false)
		end
	end
	local src = source
	for k, v in ipairs(GetPlayerIdentifiers(src)) do
			if string.sub(v, 1, string.len("discord:")) == "discord:" then
				identifierDiscord = v
			end
	end
	local roleAccess = {}
	local defaultRole = roleList[1][2]
	if identifierDiscord then
		local roleIDs = exports.Badger_Discord_API:GetDiscordRoles(src)
		if not (roleIDs == false) then
			table.insert(roleAccess, defaultRole)
			activeTagTracker[src] = roleAccess[1];
			for i = 1, #roleList do
				for j = 1, #roleIDs do
					if exports.Badger_Discord_API:CheckEqual(roleList[i][1], roleIDs[j]) then
						local roleGive = roleList[i][2]
						print(GetPlayerName(src) .. " has ID tag for: " .. roleList[i][2])
						table.insert(roleAccess, roleGive)
						activeTagTracker[src] = roleGive;
					end
				end
			end
			prefixes[src] = roleAccess; 
		else
			table.insert(roleAccess, defaultRole)
			prefixes[src] = roleAccess;
			activeTagTracker[src] = roleAccess[1];
			print(GetPlayerName(src) .. " has not gotten their permissions cause roleIDs == false")
		end
	else
		table.insert(roleAccess, defaultRole)
		prefixes[src] = roleAccess;
		activeTagTracker[src] = roleAccess[1];
	end
	TriggerClientEvent("GetStaffID:StaffStr:Return", -1, prefixes, activeTagTracker, false)
end)