
tell application "Finder" to set parentFolder to (container of (path to me)) as text
set configFile to (parentFolder & "ResizeConfig.cfg")

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

		-- Resize the application window by increasing the height to the top.
		tell theWindow
			set position to {(screenWidth - width) / 2, 0}
		end tell
	end tell
end tell
