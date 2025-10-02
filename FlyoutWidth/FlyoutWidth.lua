-- MADE BY HUGO OTTH - 2025

-- Flyout Width Plugin cuz grandma2 macros are stupid
gma.feedback("Flyout Width Plugin Loaded :DD")

-- Local Variables
local width = 0
local effect = "Flyout"


-- GrandMA Shortcuts
local text = gma.textinput
local cmd = gma.cmd
local fb = gma.feedback
local getHandle = gma.show.getobj.handle

function sleep(s)
  gma.sleep(s)
end

function clear()
  cmd('ClearAll')
end

------------------
-- PLUGIN START --
------------------

function setWidth()
    width = tonumber(text('Flyout Width? (Default = 0)', width))
    cmd("Assign Effect \""..effect.."\" /width = "..width)
    cmd("Assign Effect 1.\""..effect.."\".8 /width ="..width/2)
    cmd("Appearance Macro \"fly width 25\" /r=100")
    cmd("Appearance Macro \"fly width 50\" /r=100")
    cmd("Appearance Macro \"fly width 100\" /r=100")
    cmd("Label Macro 2338 "..width.." /o")
end

-- Plugin Function Selection --
function PulseGen_Start()
    clear()
    setWidth()
    clear()
end

return PulseGen_Start