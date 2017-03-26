-- Extensions
local chooser				= require("hs.chooser")
local screen				= require("hs.screen")

-- The Module
local mod = {}

-- Selectors display a chooser with the option to select an action.
local selector = {}
selector.__index = selector

function mod.init(actionManager)
	mod.actionManager = actionManager
end

function mod.new(action)
	local o = {
		action = action,
	}
	setmetatable(o, selector)
	return o
end

function mod.isReducedTransparency()
	return screen.accessibilitySettings()["ReduceTransparency"]
end


-- Selector Methods
function selector:create()
	-- Clean up the old version
	if self.chooser then
		self.chooser:delete()
	end
	
	--------------------------------------------------------------------------------
	-- Setup Chooser:
	--------------------------------------------------------------------------------
	self.chooser = chooser.new(self.action):bgDark(true)
					:rightClickCallback(function() self.rightClickAction() end)
					:choices(mod.choices)

	--------------------------------------------------------------------------------
	-- Allow for Reduce Transparency:
	--------------------------------------------------------------------------------
	mod.lastReducedTransparency = mod.isReducedTransparency()
	if mod.lastReducedTransparency then
		mod.mainChooser:fgColor(nil)
								 :subTextColor(nil)
	else
		mod.mainChooser:fgColor(drawing.color.x11.snow)
								 :subTextColor(drawing.color.x11.snow)

	end	
end

-- The Plugin
local plugin = {
	id				= "core.action.selector",
	group			= "core",
	dependencies	= {
		["core.action.manager"]		= "manager",
	}
}

function plugin.init(deps)
	return mod
end

return plugin