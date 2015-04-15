-----------------------------------------------------------------------------------------
--
-- main.lua
--
-- Demo of using the textedit module to simulate/use native text edit fields.
-----------------------------------------------------------------------------------------

-- Load ability to simulate text fields
local textedit = require( "textedit" )

-- Get the screen size
local WIDTH = display.contentWidth
local HEIGHT = display.contentHeight

-- File local variables
local fontSize = 20
local farenheitField
local chillField
local celciusText


-- Create all the controls and do other initialization
function initApp()
	-- Hide the status bar
	display.setStatusBar( display.HiddenStatusBar )

	-- Make a background object and set a tap handler for it to hide the keyboard
	local bg = display.newRect(WIDTH/2, HEIGHT/2, WIDTH, HEIGHT)
	bg:setFillColor(0)  -- black
	bg:addEventListener( "tap", hideKeyboard )

	-- Create a text input field to enter the degrees Farenheit
	farenheitField = textedit.newTextField( 200, 40, 150, 30, textInputEvent, 
			{ inputType = "decimal", size = fontSize, placeholder = "Temperature"} )

	-- Make a label for the Farenheit field
	display.newText("Farenheit:", 70, farenheitField.y, native.systemFont, fontSize )

	-- Create a text input field for the chill amount (not real wind chill, just subtracted)
	chillField = textedit.newTextField( 200, 90, 150, 30, textInputEvent, 
			{ inputType = "number", size = fontSize, text = "0", placeholder = "Degrees"} )

	-- Make a label for the chill field
	display.newText("Chill:", 90, chillField.y, native.systemFont, fontSize )

	-- Create a text label for the Celcius result
	celciusText = display.newText("", WIDTH / 2, 150, native.systemFont, fontSize)
	celciusText:setFillColor(0, 1, 0)
end

-- Update the calculations based on the text in the edit fields
function calcUpdate()
	-- Get current Farenheit value from the edit control
	local fValue = tonumber(farenheitField.text)

	-- Is the Farenheit field non-blank?
	if fValue then
		-- Get current chill value and default it to 0 if blank
		local chillValue = tonumber(chillField.text)
		if not chillValue then
			chillValue = 0
		end

		-- Subtract chill value, convert to Celcius and display
		local cValue = (fValue - chillValue - 32) * 5 / 9
		celciusText.text = string.format("%.2f degrees Celcius", cValue)
	else
		celciusText.text = ""  -- Erase Celcius answer if Farenheit is blank
	end
end

-- Process input events for the text fields
function textInputEvent( event )
	calcUpdate()
    if event.phase == "submitted" then
    	hideKeyboard()  -- pressing Enter hides the keyboard
    end   
end

-- Hide the on-screen keyboard
function hideKeyboard()
	textedit.setKeyboardFocus( nil )  -- hide system or simulated keyboard
end

-- Init the app
initApp()
