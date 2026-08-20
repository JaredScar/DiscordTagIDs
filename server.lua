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

function GetActiveUserTag(src)
	if activeTagTracker[tonumber(src)] ~= nil then
		return activeTagTracker[tonumber(src)]
	end
	return nil
end
function GetUserTags(src)
	if prefixes[tonumber(src)] ~= nil then
		return prefixes[tonumber(src)]
	end
	return nil
end
function SetUserTag(src, ind)
	src = tonumber(src)
	if prefixes[src] ~= nil and prefixes[src][ind] ~= nil then
		activeTagTracker[src] = prefixes[src][ind]
		TriggerClientEvent("GetStaffID:StaffStr:Return", -1, prefixes, activeTagTracker, false)
		TriggerClientEvent('chatMessage', src, prefix .. 'Your Head-Tag has been changed to: ^1' .. prefixes[src][ind]);
		return true 
	end
	return false
end

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

	-- Cache the player's custom-tag slot count now that we have their Discord roles
	if Config.CustomTags.Enabled then
		CT_CacheSlotCount(src, identifierDiscord)
	end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Custom Player Headtag System
-- ─────────────────────────────────────────────────────────────────────────────
if Config.CustomTags.Enabled then

-- In-memory store: customTagsData[identifier] = { {text, color}, ... }
local customTagsData = {}
-- Cached slot counts  per server ID: ctSlotCache[src] = number
local ctSlotCache    = {}
-- Cached allowed pattern tokens per server ID: ctPatternCache[src] = {string,...}
local ctPatternCache = {}

-- Base solid colors always available to any custom-tag slot holder
local BASE_COLORS = {"~r~", "~g~", "~b~", "~y~", "~o~", "~p~", "~w~"}

local function isBaseColor(c)
	for _, v in ipairs(BASE_COLORS) do
		if v == c then return true end
	end
	return false
end

-- Returns true if `color` is a valid base color OR a pattern token the player has unlocked
local function isColorAllowedForPlayer(color, src)
	if isBaseColor(color) then return true end
	local patterns = ctPatternCache[src] or {}
	for _, p in ipairs(patterns) do
		if p == color then return true end
	end
	return false
end

-- Bad word filter
local function containsBadWord(text)
	if not Config.CustomTags.BadWordFilter.Enabled then return false end
	local lower = string.lower(text)
	for _, word in ipairs(Config.CustomTags.BadWordFilter.Words) do
		if string.find(lower, string.lower(word), 1, true) then
			return true
		end
	end
	return false
end

-- Retrieve a player's persistent identifier (discord preferred, license fallback)
local function getPlayerIdentifier(src)
	local discord, license
	for _, v in ipairs(GetPlayerIdentifiers(src)) do
		if string.sub(v, 1, 8) == "discord:" then discord = v end
		if string.sub(v, 1, 8) == "license:" then license = v end
	end
	return discord or license
end

-- ── Flat-file helpers ────────────────────────────────────────────────────────
local function CT_LoadFlatFile()
	local raw = LoadResourceFile(GetCurrentResourceName(), "custom_tags.json")
	if raw and raw ~= "" then
		local ok, decoded = pcall(json.decode, raw)
		if ok and type(decoded) == "table" then
			customTagsData = decoded
		end
	end
end

local function CT_SaveFlatFile()
	local ok, encoded = pcall(json.encode, customTagsData)
	if ok then
		SaveResourceFile(GetCurrentResourceName(), "custom_tags.json", encoded, -1)
	end
end

-- ── Database helpers (oxmysql) ───────────────────────────────────────────────
local function CT_EnsureTable()
	exports.oxmysql:execute([[
		CREATE TABLE IF NOT EXISTS `discordtagids_custom_tags` (
			`identifier` VARCHAR(100) NOT NULL PRIMARY KEY,
			`tags`       LONGTEXT    NOT NULL
		)
	]], {})
end

local function CT_LoadDatabase()
	exports.oxmysql:fetch("SELECT `identifier`, `tags` FROM `discordtagids_custom_tags`", {}, function(rows)
		if rows then
			for _, row in ipairs(rows) do
				local ok, decoded = pcall(json.decode, row.tags)
				if ok and type(decoded) == "table" then
					customTagsData[row.identifier] = decoded
				end
			end
		end
	end)
end

local function CT_SaveIdentifierToDatabase(identifier)
	local ok, encoded = pcall(json.encode, customTagsData[identifier] or {})
	if ok then
		exports.oxmysql:execute([[
			INSERT INTO `discordtagids_custom_tags` (`identifier`, `tags`)
			VALUES (?, ?)
			ON DUPLICATE KEY UPDATE `tags` = VALUES(`tags`)
		]], {identifier, encoded})
	end
end

-- ── Init ─────────────────────────────────────────────────────────────────────
if Config.CustomTags.Storage == "database" then
	CT_EnsureTable()
	CT_LoadDatabase()
else
	CT_LoadFlatFile()
end

-- ── Slot count & pattern permissions ─────────────────────────────────────────
-- Returns (maxSlots, allowedPatterns[]).
-- maxSlots    = highest slots value among all qualifying permission entries.
-- allowedPatterns = union of all `patterns` lists from qualifying entries.
local function CT_GetPermissions(src)
	local maxSlots = 0
	local patterns = {}
	local roleIDs  = nil

	local function addPattern(p)
		for _, existing in ipairs(patterns) do
			if existing == p then return end
		end
		table.insert(patterns, p)
	end

	for _, perm in ipairs(Config.CustomTags.SlotPermissions) do
		local qualifies = false

		if perm.type == "ace" then
			qualifies = IsPlayerAceAllowed(src, perm.perm)
		elseif perm.type == "discord" then
			if roleIDs == nil then
				roleIDs = exports.Badger_Discord_API:GetDiscordRoles(src) or {}
			end
			for _, rid in ipairs(roleIDs) do
				if exports.Badger_Discord_API:CheckEqual(perm.roleId, rid) then
					qualifies = true; break
				end
			end
		end

		if qualifies then
			if perm.slots > maxSlots then maxSlots = perm.slots end
			if perm.patterns then
				for _, p in ipairs(perm.patterns) do addPattern(p) end
			end
		end
	end

	return maxSlots, patterns
end

function CT_CachePermissions(src)
	local slots, patterns = CT_GetPermissions(src)
	ctSlotCache[src]    = slots
	ctPatternCache[src] = patterns
end

-- Keep old name as alias so the GetTag handler still compiles
CT_CacheSlotCount = CT_CachePermissions

AddEventHandler('playerDropped', function()
	ctSlotCache[source]    = nil
	ctPatternCache[source] = nil
end)

-- ── Net events ───────────────────────────────────────────────────────────────

-- Client requests the NUI open: returns their custom tags, slot count, and allowed patterns
RegisterNetEvent('DiscordTag:CustomTag:Open')
AddEventHandler('DiscordTag:CustomTag:Open', function()
	local src = source
	local identifier = getPlayerIdentifier(src)
	if not identifier then
		TriggerClientEvent('DiscordTag:CustomTag:OpenReturn', src, {}, 0, {})
		return
	end
	if not ctSlotCache[src] then
		CT_CachePermissions(src)
	end
	local slots    = ctSlotCache[src]
	local patterns = ctPatternCache[src] or {}
	local tags     = customTagsData[identifier] or {}
	TriggerClientEvent('DiscordTag:CustomTag:OpenReturn', src, tags, slots, patterns)
end)

-- Client saves (create or update) a custom tag
-- payload: { index = number|nil, text = string, color = string }
RegisterNetEvent('DiscordTag:CustomTag:Save')
AddEventHandler('DiscordTag:CustomTag:Save', function(payload)
	local src = source
	local identifier = getPlayerIdentifier(src)
	if not identifier then return end

	if not ctSlotCache[src] then CT_CachePermissions(src) end
	local slots = ctSlotCache[src]

	-- Validate text
	local text = tostring(payload.text or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if #text == 0 or #text > Config.CustomTags.MaxTextLength then
		TriggerClientEvent('DiscordTag:CustomTag:Error', src, "Tag text must be 1–" .. Config.CustomTags.MaxTextLength .. " characters.")
		return
	end
	if containsBadWord(text) then
		TriggerClientEvent('DiscordTag:CustomTag:Error', src, "Your tag contains a disallowed word.")
		return
	end

	-- Validate color (base color OR an unlocked pattern token)
	local color = tostring(payload.color or "~w~")
	if not isColorAllowedForPlayer(color, src) then
		TriggerClientEvent('DiscordTag:CustomTag:Error', src, "That color or pattern is not available to you.")
		return
	end

	local tags = customTagsData[identifier] or {}
	local index = tonumber(payload.index)

	if index then
		-- Update existing slot
		if not tags[index] then
			TriggerClientEvent('DiscordTag:CustomTag:Error', src, "No tag exists at that slot.")
			return
		end
		tags[index] = {text = text, color = color}
	else
		-- New tag
		if #tags >= slots then
			TriggerClientEvent('DiscordTag:CustomTag:Error', src, "You have reached your custom tag slot limit (" .. slots .. ").")
			return
		end
		table.insert(tags, {text = text, color = color})
	end

	customTagsData[identifier] = tags
	if Config.CustomTags.Storage == "database" then
		CT_SaveIdentifierToDatabase(identifier)
	else
		CT_SaveFlatFile()
	end

	TriggerClientEvent('DiscordTag:CustomTag:SaveReturn', src, tags, slots)
	print(GetPlayerName(src) .. " saved custom tag: " .. color .. text)
end)

-- Client deletes a custom tag
-- payload: { index = number }
RegisterNetEvent('DiscordTag:CustomTag:Delete')
AddEventHandler('DiscordTag:CustomTag:Delete', function(payload)
	local src = source
	local identifier = getPlayerIdentifier(src)
	if not identifier then return end

	local tags = customTagsData[identifier] or {}
	local index = tonumber(payload.index)

	if not index or not tags[index] then
		TriggerClientEvent('DiscordTag:CustomTag:Error', src, "No tag exists at that slot.")
		return
	end

	table.remove(tags, index)
	customTagsData[identifier] = tags

	if Config.CustomTags.Storage == "database" then
		CT_SaveIdentifierToDatabase(identifier)
	else
		CT_SaveFlatFile()
	end

	local slots = ctSlotCache[src] or 0
	TriggerClientEvent('DiscordTag:CustomTag:SaveReturn', src, tags, slots)
end)

-- Client activates a custom tag as their headtag
-- payload: { index = number }
RegisterNetEvent('DiscordTag:CustomTag:Activate')
AddEventHandler('DiscordTag:CustomTag:Activate', function(payload)
	local src = source
	local identifier = getPlayerIdentifier(src)
	if not identifier then return end

	local tags = customTagsData[identifier] or {}
	local index = tonumber(payload.index)

	if not index or not tags[index] then
		TriggerClientEvent('DiscordTag:CustomTag:Error', src, "No tag exists at that slot.")
		return
	end

	local tag = tags[index]
	local fullTag = tag.color .. tag.text .. " ~w~"

	activeTagTracker[src] = fullTag
	TriggerClientEvent("GetStaffID:StaffStr:Return", -1, prefixes, activeTagTracker, false)
	TriggerClientEvent('chatMessage', src, prefix .. 'Your Head-Tag has been set to your custom tag: ^5' .. tag.text)
	TriggerClientEvent('DiscordTag:CustomTag:ActivateReturn', src, index)
end)

end -- Config.CustomTags.Enabled