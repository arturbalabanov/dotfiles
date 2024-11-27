on run argv
    tell application "BetterTouchTool"
        set profileName to (item 1 of argv)
        set destinationDir to (item 2 of argv)
        set profileOutputPath to destinationDir & "/" & profileName & ".bttpreset"

        export_preset profileName outputPath profileOutputPath
    end tell
end run
