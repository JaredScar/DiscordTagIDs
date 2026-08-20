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
		-- type "ace"     → FiveM ACE permission checked with IsPlayerAceAllowed
		-- type "discord" → Discord role ID (number) checked via Badger_Discord_API
		-- Add/remove entries as needed; the list is evaluated top-to-bottom and
		-- the highest slots value the player qualifies for is used.
		SlotPermissions = {
			{type = "ace",     perm   = "DiscordTagIDs.CustomTags.5", slots = 5},
			{type = "ace",     perm   = "DiscordTagIDs.CustomTags.3", slots = 3},
			{type = "ace",     perm   = "DiscordTagIDs.CustomTags.1", slots = 1},
			-- {type = "discord", roleId = 123456789012345678,           slots = 3},
		},
	},
}