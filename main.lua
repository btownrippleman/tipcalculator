
    --++(10) Start with the blank app template and name your app, for example, "Parker Tip Calculator"
    --+(15) Make a text field using textedit.newTextField where the user can enter the bill billAmountField. This field should be set to accept a decimal number --(for dollars and cents).
    --+(15) Make another text field for the number of people to split the bill by. This field should default to "1" and be set to accept an integer number.
    --(10) Make a segmented control for the tip billAmountField with 5 choices --(e.g. 0%, 10%, 15%, 18%, and 20%).
    --(5) Use text display objects --(display.newText) to label the two text fields and the segmented control.
    --(5) Compute the tip billAmountField and display it using a text object --(display.newText)
    --(5) Compute the total bill billAmountField --(bill billAmountField entered plus tip) and display it.
    --(5) Calculate the billAmountField due per person and display it.
    --(5) Display your output billAmountFields using a good dollars and cents format --(e.g. "$123.45").
    --(5) Recalculate and re-display the outputs after every input value change.
    --(5) Position all of the input control on the top half of the screen to make room for the on-screen keyboard.
    --(5) Make it so that tapping the background of the app dismisses the on-screen keyboard and accepts any number entered.
    --(10) Include good code quality including comments, proper indentation, and function structure.

    -- Need to load the widget library before using it ----
    local widget = require( "widget" )
    local textedit = require( "textedit" )
    local billAmount
    local numberOfPayeesFieldWidget
  --  local billIncludingTip

    -- Get the screen size
    local WIDTH = display.contentWidth
    local HEIGHT = display.contentHeight
    local dollarText

    -- File local variables
    local fontSize = 15
    local billAmountField
    local tipPercent = 0
    local numberOfPayeesField
    local billAmountFieldText


 -- Create all the controls and do other initialization
 function initApp()
 	-- Hide the status bar
 	display.setStatusBar( display.HiddenStatusBar )

 	-- Make a background object and set a tap handler for it to hide the keyboard
 	local bg = display.newRect(WIDTH/2, HEIGHT/2, WIDTH, HEIGHT)
 	bg:setFillColor(0)  -- black

 	bg:addEventListener( "tap", hideKeyboard )
   segmentedControl = widget.newSegmentedControl
  {
      left = 10,
      top = 220,
      segments = { "0%","5%","10%","15%","20%","25%" },
      defaultSegment = 1,
      onPress = onSegmentPress
  }
 	-- Create a text input field to enter the degrees Farenheit
 	billAmountField = textedit.newTextField( WIDTH/2+75, 40, 150, 30, textInputEvent,
 			{ inputType = "decimal", size = fontSize, placeholder = "0"} )

 	-- Make a label for the billAmountField field
 	dollarText = display.newText("Bill Before Tip: ", 100, billAmountField.y, native.systemFont, fontSize )


 	-- Create a text input field for tip percentage
 	numberOfPayeesField = textedit.newTextField( WIDTH/2+75, 90, 150, 30, textInputEvent,
 			{ inputType = "number", size = fontSize, text = "1", placeholder = "1"} )

 	-- Make a label for the chill field
 	display.newText("# Of Payees:", numberOfPayeesField.x -numberOfPayeesField.width+20, numberOfPayeesField.y, native.systemFont, fontSize )

 	-- Create a text label for the Total Payment result


   tipPercentText = display.newText("Tip Percentage", WIDTH / 2, 200, native.systemFont, fontSize)
 	 amountDueFromEachPerson = display.newText("", WIDTH / 2, tipPercentText.y-2*fontSize, native.systemFont, fontSize)
   tipAmount = display.newText("", WIDTH / 2, amountDueFromEachPerson.y-fontSize, native.systemFont, fontSize)
   billIncludingTip = display.newText("", WIDTH / 2, tipAmount.y-fontSize, native.systemFont, fontSize)


   tipPercentText:setFillColor(0,.5,1)
   amountDueFromEachPerson:setFillColor(0, 1, 0)
   tipAmount:setFillColor(0,1,0)
   billIncludingTip:setFillColor(0,1,0)

end

 -- Update the calculations based on the text in the edit fields
 function calcUpdate()
  	-- Get bill Amount
 	local billAmount = tonumber(billAmountField.text)

 	-- Is the bill Amount field non-blank?
 	if billAmount then
 		-- Get current number Of Payees value and default it to 1 if blank
 		local numberOfPayees = tonumber(numberOfPayeesField.text)
 		if not numberOfPayees then
 			numberOfPayees = 1
 		end


     --find the total amount of tip, then the bill including tip, and lastly how it divides out
     tipAmount.amount = billAmount*(tipPercent)
     billIncludingTipAmount = billAmount*(1+tipPercent)
     amountDueFromEachPerson.amount = (billIncludingTipAmount / numberOfPayees )

     tipAmount.text = string.format("Tip Amount = " .. "%.2f ", tipAmount.amount)
     billIncludingTip.text = string.format("Total Bill = " .. "%.2f ",  billIncludingTipAmount)
     -- divide the bill by the number of payees

 		amountDueFromEachPerson.text = string.format("Total Due from Each Payee = $" .. "%.2f ", amountDueFromEachPerson.amount)
 	else
 		amountDueFromEachPerson.text = ""  -- Erase values if bill amount is blank
     tipAmount.text = ""
     billIncludingTip.text = ""

 	end
 end

 -- Process input events for the text fields
 function textInputEvent( event )
 	calcUpdate()
     if event.phase == "submitted" then
     	hideKeyboard()  -- pressing Enter hides the keyboard
     end
 end

 -- Listen for segmented control events
  function onSegmentPress( event )
     local target = event.target
       tipPercent = (target.segmentNumber -1 ) * 0.05

   calcUpdate()
 end
 -- Hide the on-screen keyboard
 function hideKeyboard()
 	textedit.setKeyboardFocus( nil )  -- hide system or simulated keyboard
 end

 -- Init the app
 initApp()
