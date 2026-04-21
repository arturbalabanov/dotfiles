-- docs: https://www.hammerspoon.org/docs/index.html
---@diagnostic disable: lowercase-global

kittyWindowCreatedWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
    -- TODO: this only works for the first window -- launching subsequent windows won't trigger the launched event
    --       and there doesn't seem to be a seperate event for opening a new OS window (only activated is triggered
    --       but that will also trigger when switching between apps)
    --       Maybe handle this in the kitty config if avaiable?

    if eventType == hs.application.watcher.launched then
        if appName == "kitty" then
            hs.notify.show("Hammerspoon", "kitty", "outside timer")
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
