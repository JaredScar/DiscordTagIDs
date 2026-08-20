Config = {
	Prefix = '^9[^1Badger-Tags^9] ^3',
	TagsForStaffOnly = false, -- "DiscordTagIDs.Use.Tag-Toggle"
	ShowOwnTag = true, -- Should the tag also be shown for own user?
	UseDiscordName = true,
	ShowDiscordDescrim = false, -- Should it show Badger#0002 ?
	RequiresLineOfSight = true, -- Requires the player be in their line of sight for tags to be shown
	FormatDisplayName = "{PLAYER_NAME} [{SERVER_ID}]",
	UseKeyBind = true, -- It will only show on keybind pressed or toggled
	UseKeyBindToggle = true, -- It will only show when the keybind is toggled, turning this to false will make the tags only shown when the keybind is held down
	KeyBindToggleDefaultShow = true, -- By default, the tags will be shown unless toggled off if this is true
	KeyBind = 10, -- Pageup -- USE https://docs.fivem.net/docs/game-references/controls/ for keycodes
	roleList = {
		{0, "~g~Member ~w~"},  
		{597449475547463681, "~b~Developer ~w~"},
		{597450498060058624, "~r~STAFF ~w~"},  
		{"Founder", "~RGB~FOUNDER ~w~"}, 
	},

	-- Milliseconds between each step when cycling through a color pattern.
	-- Lower = faster cycling.  Ported from BadgerTools-Revamped.
	ColorChangeSpeed = 500,

	-- Color pattern tokens that can be used in role tags AND custom tags.
	-- Each key is the token you embed in a tag string (e.g. "~RGB~VIP ~w~").
	-- The value is an ordered list of GTA color codes that cycle at ColorChangeSpeed.
	-- You can add your own tokens here — just reference them in roleList or SlotPermissions.patterns.
	ColorPatterns = {
		['~RGB~']       = {'~g~', '~b~', '~y~', '~o~', '~r~', '~p~', '~w~'},
		['~CHRISTMAS~'] = {'~r~', '~g~'},
		['~AMERICA~']   = {'~r~', '~w~', '~b~'},
		['~HALLOWEEN~'] = {'~o~', '~w~'},
		['~DEVIL~']     = {'~r~', '~c~', '~m~'},
	},

	HUD = {
		Display = true,
		Format = '~p~Active Headtag: {HEADTAG}',
		x = .75,
		y = .50,
		Scale = .55
	},

	-- ─────────────────────────────────────────────────────────────────
	-- Custom Player Headtags
	-- ─────────────────────────────────────────────────────────────────
	CustomTags = {
		Enabled = false, -- Set to true to enable the custom headtag system

		-- "flatfile" stores tags in custom_tags.json inside the resource folder.
		-- "database" requires oxmysql to be installed and running.
		Storage = "flatfile",

		-- Maximum characters a player may use for a custom tag label
		MaxTextLength = 20,

		BadWordFilter = {
			Enabled = false,
			-- Words are matched case-insensitively anywhere in the tag text
			Words = {"example_bad_word", "another_bad_word"},
		},

		-- Players receive the HIGHEST matching slot count from this list.
		-- The UNION of all matching `patterns` lists is what they can use in custom tags.
		-- Base solid colors (~r~ ~g~ ~b~ ~y~ ~o~ ~p~ ~w~) are always available.
		-- type "ace"     → FiveM ACE permission checked with IsPlayerAceAllowed
		-- type "discord" → Discord role ID (number) checked via Badger_Discord_API
		SlotPermissions = {
			{type = "ace",     perm   = "DiscordTagIDs.CustomTags.5", slots = 5,
			 patterns = {"~RGB~", "~CHRISTMAS~", "~AMERICA~", "~HALLOWEEN~", "~DEVIL~"}},

			{type = "ace",     perm   = "DiscordTagIDs.CustomTags.3", slots = 3,
			 patterns = {"~RGB~"}},

			{type = "ace",     perm   = "DiscordTagIDs.CustomTags.1", slots = 1,
			 patterns = {}},

			-- {type = "discord", roleId = 123456789012345678, slots = 3,
			--  patterns = {"~RGB~", "~CHRISTMAS~"}},
		},
	},
}
