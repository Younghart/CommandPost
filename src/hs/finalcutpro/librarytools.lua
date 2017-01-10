--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--          F I N A L    C U T    P R O    L I B R A R Y    T O O L S  		  --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--
-- Module created by Chris Hocking (https://latenitefilms.com).
--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- THE MODULE:
--------------------------------------------------------------------------------

local mod = {}

local fs										= require("hs.fs")
local sqlite3									= require("hs.sqlite3")
local plist										= require("hs.plist")

--------------------------------------------------------------------------------
-- CONSTANTS:
--------------------------------------------------------------------------------

local tables = { "ZCATALOGROOT", "ZCATALOGROOTMD", "ZCOLLECTION", "ZCOLLECTIONMD", "Z_3CHILDCOLLECTIONS", "Z_METADATA", "Z_MODELCACHE", "Z_PRIMARYKEY" }

--------------------------------------------------------------------------------
-- LOCAL VARIABLES:
--------------------------------------------------------------------------------

function mod.test()

	print("Database Test")

	local absoluteFilename = fs.pathToAbsolute("~/.hammerspoon/hs/finalcutpro/test.fcpbundle/CurrentVersion.flexolibrary")
	local fcpLibrary = sqlite3.open(absoluteFilename)

	--[[
	for a, b in pairs(tables) do
		print(b)
		for row in fcpLibrary:rows("SELECT * FROM " .. b) do
			print(row)
		end
		print("------")
	end
	--]]

	for row in fcpLibrary:nrows("SELECT * FROM ZCOLLECTIONMD") do
		local result = plist.binaryToTable(row["ZDICTIONARYDATA"])
		print(result)
	end

end

-------------------------------------------------------------------------------
-- FUNCTIONS:
-------------------------------------------------------------------------------

return mod