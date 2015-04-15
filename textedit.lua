------------------------------------------------------------------------------------
--
-- textedit.lua
--
-- This module implements a text edit control that uses a native text field on
-- real devices and a simulated text field with a simple on-screen keyboard on 
-- the Corona simulators. 
-- 
-- Instructions for use:
--    1. Copy the files textedit.lua and keyboard.lua to your project folder.
--
--    2. At the top of files that need text input fields, put:
--           textedit = require( "textedit" )
--       
--    3. To create a text edit field (instead of native.newTextField):
--           field = textedit.newTextField( x, y, width, height, listener [, options] )
--       where the parameters are:
--           x, y: center point of the text field
--           width, height: size of the text field
--           listener: the "userInput" listener function (see native.newTextField)
--           options: optional table that can have the following fields:
--               inputType: (see native TextField for all choices)
--                    "default" (or nil): String entry with QWERTY keyboard
--                    "decimal": Number entry with numeric keyboard with decimal point 
--                    "number":  Integer entry with numeric keyboard 
--               size: font size in points
--               text: initial text string
--               placeholder: placeholder text to show when field is empty
--       Note that the resulting field object will not pick up properties set 
--       later, such as object.inputType, so make sure you specify them up front
--       in the parameters above.
--
--    4. To set the keyboard focus from code (instead of native.setKeyboardFocus):
--           textedit.setKeyboardFocus( field )    -- or pass nil to hide keyboard
--
--    5. If you need to change the text in a textedit field from code, use:
--           field:setText( string )
--       (Don't just assign textedit.text as with a native text field.)
--
--    6. To destroy a text edit created with this module call:
--           field:destroy( )
--       (Do this before changing composer scenes, for example)
--
------------------------------------------------------------------------------------


-- The object table for the textedit module
local textedit = {
	focusField = nil  -- The field with the simulated focus, or nil if native or none
}

-- Set flag to true if we are running on a simulator, then create keyboard if needed
local simulator = (system.getInfo("environment") == "simulator")
local kb = nil
if simulator then
	kb = require( "keyboard" )
	kb:init( textedit )
end


-- Sync the field's label text to match the field's current text 
local function syncFieldText( field )
	-- If field has non-blank text then label gets black normal text
	if field.text and field.text ~= "" then
		field.label.text = field.text or ""
		field.label:setFillColor( 0 )
	else
		-- Label gets gray placeholder text
		field.label.text = field.placeholder or ""
		field.label:setFillColor( 0.5 )
	end
end

-- Set the keyboard focus to the given simulated field
local function setSimFocus( field )
	-- Don't do anything if focus didn't change
	local oldFocusField = textedit.focusField
	if field == oldFocusField then
		return
	end

	-- Move focus highlight to new field and update both fields' appearance
	textedit.focusField = field
	if oldFocusField then
		oldFocusField.focusRect.isVisible = false
		syncFieldText( oldFocusField )
	end
	if field then
		field.focusRect.isVisible = true
		syncFieldText( field )
	end

	-- Show or hide the keyboard
	if field then
		kb:show( field.inputType )
	else
		kb:hide()
	end
end

-- Create a native text field that works like a textedit field
local function createNativeTextField( x, y, width, height, listener, options )
	local field = native.newTextField( x, y, width, height )
	if listener then
		field:addEventListener( "userInput", listener )
	end
	if options then
		field.inputType = options.inputType
		field.size = options.size or 16
		field.text = options.text
		field.placeholder = options.placeholder
	end

	-- Assign the setText method for this native field
	function field:setText(s)
		self.text = s
	end

	-- Assign the destroy method for this native field
	function field:destroy()
		self:removeSelf()
	end

	-- Return the native field
	return field
end

-- Create a new text field (native or simulated as appropriate)
function textedit.newTextField( x, y, width, height, listener, options )
	-- Use a native text field on real devices
	if not simulator then
		return createNativeTextField( x, y, width, height, listener, options )
	end

	-- Create a display group to hold the simulated text edit
	local field = display.newGroup()
	field.x = x
	field.y = y
	field.anchorChildren = true

	-- Make a blue focus rect and light gray background rect
	field.focusRect = display.newRect( field, 0, 0, width + 4, height + 4 )
	field.focusRect:setFillColor( 0.3, 0.3, 1 )  -- medium blue
	field.focusRect.isVisible = false
	field.bgRect = display.newRect( field, 0, 0, width, height )
	field.bgRect:setFillColor( 0.9 )

	-- Make a text label to display the text
	field.label = display.newText{ 
		parent = field,
		x = 5, 
		y = 2, 
		width = width, 
		height = height,
		text = "",
		font = native.systemFont,
		fontSize = (options and options.size) or 16,
	}

	-- Set listener, initial text, placeholder text, and other options
	field.listener = listener
	field.text = ""
	if options then
		field.inputType = options.inputType
		field.placeholder = options.placeholder
		field.text = options.text
	end
	syncFieldText( field )

	-- Make and add a tap listener to get focus to this field
	function field:tap() 
		setSimFocus( self )
		return true
	end 
	field.bgRect:addEventListener( "tap", field )

	-- Assign the setText method for this field
	function field:setText( s )
		field.text = s
		syncFieldText( self )
	end

	-- Assign the destroy method for this field
	function field:destroy()
		if self == textedit.focusField then
			textedit.setKeyboardFocus( nil )  -- take focus away from it first
		end
		self:removeSelf()  -- removes the display group and its contents
	end

	-- Return the field
	return field
end

-- Set the keyboard focus to the given text field (real or simulated)
function textedit.setKeyboardFocus( textField )
	if simulator then
		setSimFocus( textField )
	else
		native.setKeyboardFocus( textField )
	end
end

-- Return the textedit class
return textedit

