------------------------------------------------------------------------------------
--
-- keyboard.lua
--
-- This module implements a simple on-screen keyboard with Qwerty and Numeric modes,
-- designed for use by the textedit module.
--
------------------------------------------------------------------------------------


-- The object table for the keyboard module
local kb = {}

-- Height of the input keys
-- Both the Qwerty and the Numeric keyboard have 4 rows of keys of the same height.
local nRows = 4
local dyKey = 35
local keyMargin = 4  -- margin between keys (x and y)
local dyKeySpacing = dyKey + keyMargin


-- Create a display group for the given keys array and key width
local function createKeyGroup( keys, dxKey )
	local group = display.newGroup()
	local dxKeySpacing = dxKey + keyMargin
	local y = 0
	for row = 1, #keys do
		local nCols = #keys[row]
		local x = -dxKeySpacing * ((nCols - 1) / 2) -- center of first key
		for col = 1, nCols do
			-- Rectangle with event listeners
			local r = display.newRoundedRect( group, x, y, dxKey, dyKey, 3 )
			r.anchorY = 0
			r:setFillColor( .7 )
			r:addEventListener( "touch", kb )  -- send touches to kb:touch
			r:addEventListener( "tap", function() return true end ) -- eat taps

			-- Text label
			local s = keys[row][col]
			r.label = display.newText( group, s, x, y, native.systemFont, 24 )
			r.label.anchorY = 0
			r.label:setFillColor( 0 )
			if s == "." then
				group.decimalKey = r
			end
			x = x + dxKeySpacing
		end
		y = y + dyKeySpacing
	end
	return group
end	

-- Create a display group for the numeric modes of the keyboard
local function numericKeyGroup()
	local keys = { 
		{ "1", "2", "3" }, 
		{ "4", "5", "6" }, 
		{ "7", "8", "9" }, 
		{ ".", "0", "<" }   -- "<" is special value for Backspace
	}
	return createKeyGroup( keys, 80 )
end

-- Create a display group for the qwerty mode of the keyboard
local function qwertyKeyGroup()
	local keys = { 
		{ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }, 
		{ "q", "u", "e", "r", "t", "y", "u", "i", "o", "p" }, 
		{ "a", "s", "d", "f", "g", "h", "j", "k", "l", "@" }, 
		{ " ", "z", "x", "c", "v", "b", "n", "m", ".", "<" }   -- "<" is Backspace
	}
	return createKeyGroup( keys, 28 )
end

-- Init the keyboard for use with the given textedit module
function kb:init( textedit )
	-- Create the keyboard as a display group, initially off-screen.
	-- Objects in the group are positioned relative to the top center of the group.
	local group = display.newGroup()
	group.x = display.contentWidth / 2
	kb.yHidden = display.contentHeight - display.screenOriginY  -- just off the physical screen
	group.y = kb.yHidden
	kb.group = group
	kb.textedit = textedit
	kb.height = dyKeySpacing * nRows  -- total keyboard height

	-- Make the numeric mode as a sub-group
	kb.numKeyGroup = numericKeyGroup()
	group:insert( kb.numKeyGroup )

	-- Make the qwerty mode as a sub-group
	kb.qwertyKeyGroup = qwertyKeyGroup()
	group:insert( kb.qwertyKeyGroup )
end

-- Handle taps on the key objects
function kb:touch( event )
	if event.phase == "began" then
		-- Get the key text corresponding to this key
		local keyText = event.target.label.text

		-- Modify the text in the focused text field
		local focusField = kb.textedit.focusField
		if focusField then
			local text = focusField.text or ""
			if keyText == "<" then
				-- Backspace: Remove one char from end if possible
				local len = string.len( text )
				if len > 0 then
					text = string.sub( text, 1, len - 1 )
				end
			else
				-- Normal key: Append char to end of text
				text = text .. keyText
			end
			focusField:setText( text )

			-- Send a fake input event to the focused listener function, if any
			if focusField.listener then
				local event = { phase = "editing", target = focusField }
				focusField.listener( event )
			end
		end
	end
	return true
end

-- Show the keyboard with the given inputType
function kb:show( inputType )
	-- Show the correct keyboard sub-group based on the input type
	if inputType == "number" or inputType == "decimal" or inputType == "phone" then
		-- Numeric keyboard
		kb.numKeyGroup.isVisible = true
		kb.qwertyKeyGroup.isVisible = false
		local decimalKey = kb.numKeyGroup.decimalKey
		if inputType == "decimal" then
			decimalKey.label.text = "."
		else
			decimalKey.label.text = ""   -- disable decimal key if type number or phone
		end
	else
		-- Default/qwerty keyboard
		kb.numKeyGroup.isVisible = false
		kb.qwertyKeyGroup.isVisible = true
	end
	
	-- Slide the keyboard on screen if not already showing
	if not kb.showing then
		kb.group:toFront()
		transition.to( kb.group, { time = 200, y = kb.yHidden - kb.height } )  -- slide up from bottom
		kb.showing = true
	end
end

-- Hide the keyboard if showing
function kb:hide()
	if kb.showing then
		transition.to( kb.group, { time = 200, y = kb.yHidden } )   -- slide down off screen
		kb.showing = false
	end
end

-- Return the keyboard (caller must init it)
return kb
