--- The 'Preferences' menu section

local PRIORITY = 8888888

--- The Plugin
local plugin = {}

plugin.dependencies = {
	["cp.plugins.menu.bottom"] = "bottom"
}

function plugin.init(dependencies)
	local section = dependencies.bottom:addSection(PRIORITY)

	return section
		:addMenu(0, function() return i18n("preferences") end)
end

return plugin