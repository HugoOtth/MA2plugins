-- MADE BY HUGO OTTH - 2025

-- Color Picker Update Plugin
gma.feedback("Pulse Generator Plugin Loaded :DD")

-- Local Variables
local grp = 0
local seq = 0
local exec = 0
local amount = 0
local wing = 0
local trigTime = 0.1
local fade = 0.05
local rnd = 'false'
local white = 'false'

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
    white = text('White Bump Mode?',white)
    grp = text('Enter Group Number', grp)
    seq = text('Enter Sequence Number',seq)
    exec = text('Enter Exec Number',exec)
    wing = text('Wings?',wing)
    rnd = text('Random order?',rnd)
    amount = tonumber(text('Pulse Amount?',amount))
    if(white == 'false') then
        trigTime = tonumber(text('Trig time? (Default = 0.10s)',trigTime))
        fade = tonumber(text('Fade time? (Default = 0.05s)',fade))
    else
        trigTime = 0
        fade = 0
    end
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
        if(white == 'true') then
            cmd('At Gel 1.1')
        end
        cmd('Store Sequence '..seq..' Cue '..cue)
        cmd('Label Sequence '..seq..' Cue '..cue..' "ON"')
        if(white == 'true') then
            cmd('At 100')
        else
            cmd('At 0')
        end
        cmd('Store Sequence '..seq..' Cue '..(cue + 1))
        cmd('Label Sequence '..seq..' Cue '..(cue + 1)..' "OFF"')
        cmd('Assign Sequence '..seq..' Cue '..(cue + 1)..' /trig=time /trigtime='..trigTime..' /fade='..fade..' /mode=release')
        cue = cue + 2
    end
    cmd('BlindEdit Off')
    cmd('Appearance Sequence '..seq..' /b=100 /r=50')
    cmd('Assign Sequence '..seq..' Executor '..exec)
    cmd('Assign Sequence '..seq..' /track=off')
    cmd('Assign Exec '..exec..' /restart=next /priority=htp /offtime=0.2')
end

function resetValues()
    grp = 0
    seq = 0
    exec = 0
    amount = 0
    wing = 0
    trigTime = 0.1
    fade = 0.05
    rnd = 'false'
    cue = 1
    white = 'false'
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