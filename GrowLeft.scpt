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
		set {width, height} to size of window 1
		set {x, y} to position of window 1
		
		-- Calculate the percentage width to increase
		if percentageMode is equal to 0 then
			set newWidth to width + (width * percentageIncrease)
		else
			set newWidth to width + (screenWidth * percentageIncrease)
		end if
		
		-- Resize the application window by increasing the width to the left.
		tell window 1
			set position to {x - (newWidth - width), y}
			set size to {newWidth, height}
		end tell
	end tell
end tell
