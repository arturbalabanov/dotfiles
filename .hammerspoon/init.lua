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

-- vagrant_menubar = hs.menubar.new()
-- -- identifier for MacOS, so that it can remember its position after restarts
-- vagrant_menubar:autosaveName("Vagrant")
--
-- -- false: template - An optional boolean value which defaults to true. If it's true, the provided image will be treated as a "template" image, which allows it to automatically support OS X 10.10's Dark Mode. If it's false, the image will be used as is, supporting colour.
-- vagrant_icon = hs.image.imageFromPath("assets/vagrant-icon.svg")
-- vagrant_icon = vagrant_icon:setSize({ w = 16, h = 16 })
-- vagrant_menubar:setIcon(vagrant_icon, false)
-- vagrant_menubar:imagePosition(hs.menubar.imagePositions.imageLeft)
--
-- vagrant_menubar:setMenu(function(modifier_keys_pressed)
--     -- modifier_keys_pressed: list of booleans corresponding to these keys: cmd alt shift ctrl fn
--
--     -- use `vagrant global-status --prune --machine-readable`
--     --
--     -- number of running machines: vagrant global-status --prune --machine-readable | grep -i metadata | grep -i machine\-count | awk -F ',' '{print $NF}'
--
--     local vagrant_global_status, success, _, rc = hs.execute("vagrant global-status --prune --machine-readable", true)
--
--     if not success then
--         hs.notify.show("Vagrant", "", "Failed to get the global status, return code: " .. rc)
--         return {}
--     end
--
--     -- Example vagrant global status output:
--     -- 1753710243,,metadata,machine-count,1
--     -- 1753710243,,machine-id,f201666
--     -- 1753710243,,provider-name,qemu
--     -- 1753710243,,machine-home,/Users/artur.balabanov/dev/software-one/optscale/optscale-deploy
--     -- 1753710243,,state,running
--     -- 1753710243,,ui,info,id
--     -- 1753710243,,ui,info,name
--     -- 1753710243,,ui,info,provider
--     -- 1753710243,,ui,info,state
--     -- 1753710243,,ui,info,directory
--     -- 1753710243,,ui,info,
--     -- 1753710243,,ui,info,--------------------------------------------------------------------------------------------------------------
--     -- 1753710243,,ui,info,f201666
--     -- 1753710243,,ui,info,ubuntu-2404-arm-64
--     -- 1753710243,,ui,info,qemu
--     -- 1753710243,,ui,info,running
--     -- 1753710243,,ui,info,/Users/artur.balabanov/dev/software-one/optscale/optscale-deploy
--     -- 1753710243,,ui,info,
--     -- 1753710243,,ui,info, \nThe above shows information about all known Vagrant environments\non this machine. This data is cached and may not be completely\nup-to-date (use "vagrant global-status --prune" to prune invalid\nentries). To interact with any of the machines%!(VAGRANT_COMMA) you can go to that\ndirectory and run Vagrant%!(VAGRANT_COMMA) or you can use the ID directly with\nVagrant commands from any directory. For example:\n"vagrant destroy 1a2b3c4d"
--
--     local lines = hs.fnutils.split(vagrant_global_status, "\n")
--     local machine_count = 0
--     local machines = {}
--
--     for _, line in ipairs(lines) do
--         local parts = hs.fnutils.split(line, ",")
--         if #parts > 0 then
--             if parts[3] == "metadata" and parts[4] == "machine-count" then
--                 machine_count = tonumber(parts[5])
--             elseif parts[3] == "ui" and parts[4] == "info" then
--                 local machine_id = parts[5]
--                 local machine_name = ""
--                 local machine_provider = ""
--                 local machine_state = ""
--                 local machine_directory = ""
--
--                 -- Find the next lines with the same ID to get the rest of the info
--                 for i = _, #lines do
--                     if lines[i]:find(machine_id) then
--                         local info_parts = hs.fnutils.split(lines[i], ",")
--                         if info_parts[3] == "ui" and info_parts[4] == "info" then
--                             if info_parts[5] == "name" then
--                                 machine_name = info_parts[6]
--                             elseif info_parts[5] == "provider" then
--                                 machine_provider = info_parts[6]
--                             elseif info_parts[5] == "state" then
--                                 machine_state = info_parts[6]
--                             elseif info_parts[5] == "directory" then
--                                 machine_directory = info_parts[6]
--                             end
--                         end
--                     end
--                 end
--
--                 machines = table.insert(machines, {
--                     id = machine_id,
--                     name = machine_name,
--                     provider = machine_provider,
--                     state = machine_state,
--                     directory = machine_directory,
--                 })
--             end
--         end
--     end
--
--     if machine_count == 0 then
--         return {
--             {
--                 title = "No Vagrant machines found",
--                 disabled = true,
--             },
--         }
--     else
--         local menu_items = {
--             {
--                 title = "Vagrant machines: " .. machine_count,
--                 disabled = true,
--             },
--             { title = "-" }, -- separator
--         }
--
--         print(hs.inspect(machines))
--
--         for _, machine in ipairs(machines) do
--             local item = {
--                 title = machine.name .. " (" .. machine.provider .. ")",
--                 -- fn = function()
--                 --     hs.execute("cd '" .. machine.directory .. "' && vagrant ssh", true)
--                 -- end,
--             }
--
--             -- if machine.state == "running" then
--             --     item.title = item.title .. " (running)"
--             -- else
--             --     item.title = item.title .. " (not running)"
--             --     item.disabled = true
--             -- end
--
--             menu_items = table.insert(menu_items, item)
--         end
--
--         return menu_items
--     end
--
--     -- return {
--     --     {
--     --         title = "Vagrant",
--     --         disabled = true,
--     --     },
--     --     { title = "-" }, -- separator
--     --     {
--     --         title = "Vagrant",
--     --         disabled = false,
--     --     },
--     -- }
-- end)

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
