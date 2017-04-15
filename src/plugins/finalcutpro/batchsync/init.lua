--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                             B A T C H    S Y N C                           --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--- === finalcutpro.batchsync ===
---
--- Batch Sync Proof of Concept
---
--- See:
--- https://github.com/CommandPost/CommandPost/issues/467

--------------------------------------------------------------------------------
--
-- EXTENSIONS:
--
--------------------------------------------------------------------------------
local log								= require("hs.logger").new("batchsync")

local fcp								= require("cp.finalcutpro")
local dialog							= require("cp.dialog")

--------------------------------------------------------------------------------
--
-- THE MODULE:
--
--------------------------------------------------------------------------------
local mod = {}

function mod.batchSync()

	dialog.displayMessage("test")

	--[[
	local content = fcp:timeline():contents()
	local playheadX = content:playhead():getPosition()

	local clips = content:clipsUI(false, function(clip)
		local frame = clip:frame()
		if forwards then
			return playheadX <= frame.x
		else
			return playheadX >= frame.x
		end
	end)

	if clips then
		content:selectClips(clips)
		return true
	else
		log.df("No clips to select")
		return false
	end
	--]]

end

--------------------------------------------------------------------------------
--
-- THE PLUGIN:
--
--------------------------------------------------------------------------------
local plugin = {
	id = "finalcutpro.timeline.selectalltimelineclips",
	group = "finalcutpro",
	dependencies = {
		["finalcutpro.commands"]	= "fcpxCmds",
	}
}

function plugin.init(deps)

	deps.fcpxCmds:add("cpBatchSync")
		:activatedBy():ctrl():option():cmd("r")
		:whenActivated(mod.batchSync)

	return mod

end

return plugin