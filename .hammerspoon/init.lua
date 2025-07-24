-- docs: https://www.hammerspoon.org/docs/index.html

-- hs.hotkey.bind({ "cmd", "option", "ctrl" }, "W", function()
--     local win = hs.window.focusedWindow()
--     local screen = win:screen()
--     win:centerOnScreen(screen, true) -- true: ensureInScreenBounds
-- end)
--
-- for _, key in ipairs({ "1", "2", "3", "4", "5" }) do
--     hs.hotkey.bind({ "option", }, key, function()
--         -- local win = hs.window.focusedWindow()
--         -- if win then
--         --     win:moveToScreen(hs.screen.allScreens()[tonumber(key)])
--         -- end
--         --
--         hs.spaces.gotoSpace(tonumber(key))
--     end)
-- end

vagrant_menubar = hs.menubar.new()
-- identifier for MacOS, so that it can remember its position after restarts
vagrant_menubar:autosaveName("Vagrant")

-- false: template - An optional boolean value which defaults to true. If it's true, the provided image will be treated as a "template" image, which allows it to automatically support OS X 10.10's Dark Mode. If it's false, the image will be used as is, supporting colour.
vagrant_icon = hs.image.imageFromPath("assets/vagrant-icon.svg")
vagrant_icon = vagrant_icon:setSize({ w = 16, h = 16 })
vagrant_menubar:setIcon(vagrant_icon, false)
vagrant_menubar:imagePosition(hs.menubar.imagePositions.imageLeft)

vagrant_menubar:setMenu(function(modifier_keys_pressed)
    -- modifier_keys_pressed: list of booleans corresponding to these keys: cmd alt shift ctrl fn

    return {
        {
            title = "Vagrant",
            disabled = true,
        },
        { title = "-" }, -- separator
        {
            title = "Vagrant",
            disabled = false,
        },
    }
end)

kittyWindowCreatedWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
    if eventType == hs.application.watcher.launched then
        if appName == "kitty" then
            hs.timer.doAfter(0.01, function()
                local newWindow = appObject:focusedWindow()

                if
                    newWindow == nil
                    or newWindow:isFullScreen()
                    or newWindow:isMinimized()
                    or not newWindow:isStandard()
                    or not newWindow:isVisible()
                then
                    return
                end

                -- TODO: Check that the window is not maximized / "zoomed" / fullscreen
                newWindow:centerOnScreen(newWindow:screen(), true) -- true: ensureInScreenBounds
            end)
        end
    end
end)
kittyWindowCreatedWatcher:start()

-- Bring all Finder etc. windows forward when one gets activated
activateAllAppWinsTogether = hs.application.watcher.new(function(appName, eventType, appObject)
    if eventType == hs.application.watcher.activated then
        if appName == "Finder" or appName == "Stickies" then
            appObject:selectMenuItem({ "Window", "Bring All to Front" })
        end
    end
end)
activateAllAppWinsTogether:start()

-- TODO: Move this to the neovim's autoreload config to keep it all in one place
function reloadConfig(files)
    local doReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        -- TODO: Investigate if this is needed (i.e. will the old watcher be stopped automatically on reload)
        -- kittyWindowCreatedWatcher:stop()
        -- activateAllFinderWinsTogether:stop()
        hs.reload()
    end
end

-- IMPORTANT: the assignment bellow is intentional to avoid it being automatically garbage collected.
-- ref: https://www.hammerspoon.org/go/#a-quick-aside-about-variable-lifecycles
hsConfigWatcher = hs.pathwatcher.new(hs.configdir, reloadConfig)
hsConfigWatcher:start()

-- NOTE: as soon as hs.reload() is called, the lua interpreter will be restarted,
-- so any code after that will not be executed, thus the notification being here
-- Also if we put it just before the call, the notification will be immediately dismissed after
-- creation, so fast it won't be noticable
hs.notify.show("Hammerspoon", "", "Successfully reloaded the config")
