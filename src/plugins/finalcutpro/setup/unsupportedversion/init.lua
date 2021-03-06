local fcp			= require("cp.apple.finalcutpro")
local config		= require("cp.config")
local prop			= require("cp.prop")

local mod = {}

mod.notifiedVersion = config.prop("finalcutproUnsupportedVersionNotified", nil)

local plugin = {
	id				= "finalcutpro.setup.unsupportedversion",
	group			= "finalcutpro",
	dependencies	= {
		["core.setup"]			= "setup",
	}
}

function plugin.init(deps, env)
	-- The last version we notified about
	local notified = mod.notifiedVersion
	local notNotified = notified:EQUALS(fcp.getVersion):NOT()

	-- Require setup if FCP is unsupported and we have not notified about this version.
	fcp.isUnsupported:AND(notNotified):watch(function(unsupported)
		if unsupported then
			local setup = deps.setup
			local minVersion = fcp.EARLIEST_SUPPORTED_VERSION

			local iconPath = config.application():path() .. "/Contents/Resources/AppIcon.icns"

			setup.addPanel(
				setup.panel.new("fcpunsupported", 20)
					:addIcon(iconPath)
					:addHeading(i18n("finalcutproUnsupportedVersionTitle"))
					:addParagraph(i18n("finalcutproUnsupportedVersionText", {
						thisVersion = fcp:getVersion(), minVersion = minVersion
					}), true)
					:addButton({
						label		= i18n("continue"),
						onclick		= function()
							notified(fcp:getVersion())
							setup.nextPanel()
						end
					})
			)

			setup.show()
		end
	end, true)

	return mod
end


return plugin