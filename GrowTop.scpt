set defaultPercentageIncrease to 0.25
set defaultScreenPercentageMode to 0

tell application "Finder" to set parentFolder to (container of (path to me)) as text
set configFile to (parentFolder & "ResizeConfig.cfg")

try
	set theFileContents to paragraphs of (read file configFile)

	-- Percentage increase value from file with error checks.
	set percentageIncrease to item 1 of theFileContents as text
	try
		set percentageIncrease to percentageIncrease as number
	on error
		set percentageIncrease to defaultPercentageIncrease
	end try

	-- Percentage increase mode value from file with error checks.
	set percentageMode to item 2 of theFileContents as text
	try
		if percentageMode contains "screen" then
			set percentageMode to 1
		else
			set percentageMode to 0
		end if
	on error
		set percentageMode to defaultScreenPercentageMode
	end try
on error
	set percentageIncrease to defaultPercentageIncrease
	set percentageMode to defaultScreenPercentageMode
end try

-- Get the desktop size.
tell application "Finder"
	set {screenTop, screenLeft, screenWidth, screenHeight} to bounds of window of desktop
end tell

-- Get the frontmost application window and get its size.
tell application "System Events"
	set myFrontMost to name of first item of (processes whose frontmost is true)
	tell application process myFrontMost

		-- The trick here is that you can't rely on "window 1" to be the one you're after,
		-- So let's filter the UI elements list by subroles.
		-- Emacs return a a total bogus AXTextField:AXStandardWindow, but we can stil work with it

		set theWindows to (every UI element whose subrole is "AXStandardWindow")

		-- For Activity Monitor (others?)
		if theWindows is {} then set theWindows to (every UI element whose subrole is "AXDialog")
		if theWindows is {} then
			beep
			return
		end if
		set theWindow to (first item of theWindows)

		set {width, height} to size of theWindow
		set {x, y} to position of theWindow

		-- Calculate the percentage height to increase
		if percentageMode is equal to 0 then
			set newHeight to height + (height * percentageIncrease)
		else
			set newHeight to height + (screenHeight * percentageIncrease)
		end if

		-- Resize the application window by increasing the height to the top.
		tell theWindow
			set position to {x, y - (newHeight - height)}
			set size to {width, newHeight}
		end tell
	end tell
end tell
