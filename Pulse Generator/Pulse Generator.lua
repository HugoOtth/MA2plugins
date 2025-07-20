-- MADE BY HUGO OTTH - 2025

-- Color Picker Update Plugin
gma.feedback("Pulse Generator Plugin Loaded :DD")

-- Local Variables
local grp = 0
local seq = 0
local amount = 0
local wing = 0
local trigTime = 0.1
local fade = 0.05
local rnd = 'false'

local cue = 1

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

function setup()
    grp = text('Enter Group Number', grp)
    seq = text('Enter Sequence Number',seq)
    wing = text('Wings?',wing)
    rnd = text('Random order?',rnd)
    amount = tonumber(text('Pulse Amount?',amount))
    trigTime = tonumber(text('Trig time? (Default = 0.10s)',trigTime))
    fade = tonumber(text('Fade time? (Default = 0.05s)',fade))
end

function create()
    cmd('BlindEdit On')

    -- MAtricks
    cmd('Group '..grp)
    cmd('MAtricksWings '..wing)
    if(rnd == 'true') then
        cmd('ShuffleSelection')
    end
    cmd('MAtricksInterleave '..amount)

    -- Storing to Sequence
    while cue <= amount * 2 do
        cmd('Next')
        cmd('At 100')
        cmd('Store Sequence '..seq..' Cue '..cue)
        cmd('At 0')
        cmd('Store Sequence '..seq..' Cue '..(cue + 1))
        cmd('Assign Sequence '..seq..' Cue '..(cue + 1)..' /trig=time /trigtime='..trigTime..' /fade='..fade)
        cue = cue + 2
    end
    cmd('BlindEdit Off')
    cmd('Appearance Sequence '..seq..' /b=100 /r=50')
end

function resetValues()
    grp = 0
    seq = 0
    amount = 0
    wing = 0
    trigTime = 0.1
    fade = 0.05
    rnd = 'false'
    cue = 1
end

-- Plugin Function Selection --
function PulseGen_Start()
    setup()
    fb(grp..seq..amount..wing..trigTime..fade)
    create()
    clear()
    resetValues()
end

return PulseGen_Start