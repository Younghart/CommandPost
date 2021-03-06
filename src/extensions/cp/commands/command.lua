--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                               C O M M A N D S                              --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

--- === cp.commands.command ===
---
--- Commands Module.

--------------------------------------------------------------------------------
--
-- EXTENSIONS:
--
--------------------------------------------------------------------------------
local log					= require("hs.logger").new("command")

local shortcut				= require("cp.commands.shortcut")
local prop					= require("cp.prop")

--------------------------------------------------------------------------------
--
-- THE MODULE:
--
--------------------------------------------------------------------------------
local command = {}

--- cp.commands.command:new() -> command
--- Method
--- Creates a new command, which can have keyboard shortcuts assigned to it.
---
--- Parameters:
---  * `id`	= the unique identifier for the command. E.g. 'cpCustomCommand'
---
--- Returns:
---  * command - The command that was created.
---
function command:new(id, parent)
	local o = {
		_id = id,
		_parent = parent,
		_shortcuts = {},
	}
	prop.extend(o, command)
	
--- cp.commands.command.isEnabled <cp.prop: boolean>
--- Field
--- If set to `true`, the command is enabled.
	o.isEnabled = prop.TRUE():bind(o)
	
--- cp.commands.command.isActive <cp.prop: boolean; read-only>
--- Field
--- Indicates if the command is active. To be active, both the command and the group it belongs to must be enabled.
	o.isActive = o.isEnabled:AND(parent.isEnabled):bind(o):watch(function(active)
		for _,shortcut in ipairs(o._shortcuts) do
			shortcut:isEnabled(active)
		end
	end, true)
	
	return o
end

function command:id()
	return self._id
end

function command:parent()
	return self._parent
end

--- cp.commands.command:titled(title) -> command
--- Method
--- Applies the provided human-readable title to the command.
---
--- Parameters:
---  * `id`	= the unique identifier for the command. E.g. 'FCPXHacksCustomCommand'
---
--- Returns:
---  * command - The command that was created.
---
function command:titled(title)
	self._title = title
	return self
end

function command:getTitle()
	if self._title then
		return self._title
	else
		return i18n(self:id() .. "_title", {default = self:id()})
	end
end

function command:subtitled(subtitle)
	self._subtitle = subtitle
	return self
end

function command:getSubtitle()
	if self._subtitle then
		return self._subtitle
	else
		return i18n(self:id() .. "_subtitle")
	end
end

function command:groupedBy(group)
	self._group = group
	return self
end

function command:getGroup()
	return self._group
end

--- cp.commands.command:activatedBy([modifiers,] [keyCode]) -> command/modifier
--- Method
--- Specifies that the command is activated by pressing a key combination.
--- This method can be called multiple times, and multiple key combinations will be registered for the command.
--- To remove existing key combinations, call the `command:deleteShortcuts()` method.
---
--- * If the `keyCode` is provided, no modifiers need to be pressed to activate and the `command` is returned.
--- * If the `modifiers` and `keyCode` are provided, the combination is created and the `command` is returned.
--- * If no `keyCode` is provided, a `modifier` is returned, which lets you specify keyboard combinations.
---
--- For example:
---
--- ```
--- local global    	= commands.collection("global")
--- local pressA 		= global:add("commandA"):activatedBy("a")
--- local pressShiftA	= global:add("commandShiftA"):activatedBy({"shift"}, "a")
--- local pressCmdA		= global:add("commandCmdA"):activatedBy():command("a")
--- local pressOptCmdA	= global:add("commandOptCmdA"):activatedBy():option():command("a")
--- global:enable()
--- ```
---
--- Parameters:
---  * `modifiers`	- (optional) The table containing names of required modifiers.
---  * `keyCode`	- (optional) The key code that will activate the command, with no modifiers.
---
--- Returns:
---  * `command` if a `keyCode` was provided, or `modifier` if not.
function command:activatedBy(modifiers, keyCode)
	if keyCode and not modifiers then
		modifiers = {}
	elseif modifiers and not keyCode then
		keyCode = modifiers
		modifiers = {}
	end

	if keyCode then
		self:addShortcut(shortcut:new(modifiers, keyCode))
		return self
	else
		return shortcut:build(
			function(newShortcut)
				return self:addShortcut(newShortcut)
			end
		)
	end
end

--- cp.commands.command:deleteShortcuts() -> command
--- Method
--- Sets the function that will be called when the command key combo is pressed.
---
--- Parameters:
---  * None
---
--- Returns:
---  * command - The current command
---
function command:deleteShortcuts()
	for i,shortcut in ipairs(self._shortcuts) do
		shortcut:delete()
	end
	self._shortcuts = {}
	return self
end

function command:setShortcuts(shortcuts)
	self:deleteShortcuts()
	for _,newShortcut in ipairs(shortcuts) do
		self:addShortcut(newShortcut)
	end
	return self
end

--- cp.commands.command:addShortcut() -> command
--- Method
--- Adds the specified shortcut to the command.
--- If the command is enabled, the shortcut will also be enabled.
---
--- Parameters:
---  * `newShortcut`	- the shortcut
---
--- Returns:
---  * `self`
function command:addShortcut(newShortcut)
	newShortcut:bind(
		function() return self:pressed() end,
		function() return self:released() end,
		function() return self:repeated() end
	)
	-- mark it as a 'command' hotkey
	local shortcuts = self._shortcuts
	shortcuts[#shortcuts + 1] = newShortcut
	newShortcut:isEnabled(self:isEnabled())
	return self
end

--- cp.commands.command:getShortcuts() -> command
--- Method
--- Returns the set of shortcuts assigned to this command.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The associated shortcuts.
function command:getShortcuts()
	return self._shortcuts
end

--- cp.commands.command:getFirstShortcut() -> command
--- Method
--- Returns the first shortcut, or `nil` if none have been registered.
---
--- Parameters:
---  * None
---
--- Returns:
---  * The first shortcut, or `nil`.
function command:getFirstShortcut()
	return self._shortcuts and #self._shortcuts > 0 and self._shortcuts[1] or nil
end

--- cp.commands.command:whenActivated(function) -> command
--- Method
--- Sets the function that will be called when the command is activated.
---
--- NOTE: This is a shortcut for calling `whenPressed(...)`
---
--- Parameters:
---  * `activatedFn`	- the function to call when activated.
---
--- Returns:
---  * command - The current command
---
function command:whenActivated(activatedFn)
	return self:whenPressed(activatedFn)
end

--- cp.commands.command:whenPressed(function) -> command
--- Method
--- Sets the function that will be called when the command key combo is pressed.
---
--- Parameters:
---  * `pressedFn`	- the function to call when pressed.
---
--- Returns:
---  * command - The current command
---
function command:whenPressed(pressedFn)
	self.pressedFn = pressedFn
	return self
end

--- cp.commands.command:whenReleased(function) -> command
--- Method
--- Sets the function that will be called when the command key combo is released.
---
--- Parameters:
---  * `releasedFn`	- the function to call when released.
---
--- Returns:
---  * command - The current command
---
function command:whenReleased(releasedFn)
	self.releasedFn = releasedFn
	return self
end

--- cp.commands.command:whenRepeated(function) -> command
--- Method
--- Sets the function that will be called when the command key combo is repeated.
---
--- Parameters:
---  * `repeatedFn`	- the function to call when repeated.
---
--- Returns:
---  * command - The current command
---
function command:whenRepeated(repeatedFn)
	self.repeatedFn = repeatedFn
	return self
end

--- cp.commands.command:pressed() -> command
--- Method
--- Executes the 'pressed' function, if present.
---
--- Parameters:
---  * None
---
--- Returns:
---  * the result of the function, or `nil` if none is present.
---
function command:pressed()
	if self:isEnabled() and self.pressedFn then return self.pressedFn() end
	return nil
end

--- cp.commands.command:released() -> command
--- Method
--- Executes the 'released' function, if present.
---
--- Parameters:
---  * None
---
--- Returns:
---  * the result of the function, or `nil` if none is present.
---
function command:released()
	if self:isEnabled() and self.releasedFn then return self.releasedFn() end
	return nil
end

--- cp.commands.command:repeated(repeats) -> command
--- Method
--- Executes the 'repeated' function, if present.
---
--- Parameters:
---  * `repeats`	- the number of times to repeat. Defaults to 1.
---
--- Returns:
---  * the last result.
---
function command:repeated(repeats)
	if not self:isEnabled() then return nil end

	if repeats == nil then
		repeats = 1
	end
	local result = nil
	if self.repeatedFn then
		for i = 1, repeats do
			result = self.repeatedFn()
		end
	end
	return result
end

--- cp.commands.command:activated(repeats) -> command
--- Method
--- Executes the 'pressed', then 'repeated', then 'released' functions, if present.
---
--- Parameters:
---  * `repeats`	- the number of times to repeat the 'repeated' function. Defaults to 1.
---
--- Returns:
---  * the last 'truthy' result (non-nil/false).
---
function command:activated(repeats)
	if not self:isEnabled() then return nil end

	local result = nil
	result = self:pressed()
	result = self:repeated(repeats) or result
	result = self:released() or result
	return result
end

function command:enable()
	self:isEnabled(true)
	return self
end

function command:disable()
	self:isEnabled(false)
	return self
end

function command:__tostring()
	local result = string.format("command: %s (enabled: %s)", self:id(), self:isEnabled())
end

return command