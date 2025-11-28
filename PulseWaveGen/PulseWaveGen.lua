-- MADE BY HUGO OTTH - 2025

-- Color Picker Update Plugin
gma.feedback("Pulse Wave Generator Plugin Loaded :DD")

-- Local Variables
local batch = false
local groups = {}
local directions = {"left", "right", "in", "out", "circle", "rnd"}
local grpRnd = false
local dirRnd = false
local seq = 0
local exec = 0
local amount = 0
local delay = 0
local trigTime = 0.1
local fade = 0.05

local cue = 1
local grpCollect = true

-- GrandMA Shortcuts
local text = gma.textinput
local cmd = gma.cmd
local fb = gma.feedback

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
    if batch then
        while grpCollect do
            local grpInput = text('Enter Group '..(#groups + 1)..' (Leave empty to finish)', '')
            if grpInput == '' then
                grpCollect = false
            else
                table.insert(groups, grpInput)
            end
        end
    end
    if not batch then
        groups = text('Enter single Group', groups)
    end
    fb("Collected groups: "..table.concat(groups, ", "))
    dir = text('Direction? (left, right, in, out, circle, rnd)', dir)
    -- Open Seq and Exec View
    cmd('View 278 /screen=5')
    seq = text('Enter Sequence Number',seq)
    exec = text('Enter Exec Number',exec)
    wing = text('Wings?',wing)
    rnd = text('Random order?',rnd)
    amount = tonumber(text('Wave Amount?',amount))
    delay = tonumber(text('Wave Delay?',delay))
end

function create()
    cmd('BlindEdit On')
    local cue = 1

    -- MAtricks
    cmd('Group '..grp)
    cmd('MAtricksWings '..wing)
    cmd('At 100')
    cmd('At Delay 0 Thru '..delay)

    -- Store to Sequence
    cmd('Store Sequence '..seq..' Cue '..cue)
    cmd('Label Sequence '..seq..' Cue '..cue..' "ON"')

    cmd('At 0')
    cmd('At Delay 0 Thru '..delay)

    cmd('Store Sequence '..seq..' Cue '..(cue + 1))
    cmd('Label Sequence '..seq..' Cue '..(cue + 1)..' "OFF"')
    cmd('Assign Sequence '..seq..' Cue '..(cue + 1)..' /trig=time /trigtime='..trigTime..' /fade='..fade..' /mode=release')
        
    
    end
    cmd('BlindEdit Off')
    cmd('Appearance Sequence '..seq..' /b=100 /r=50')
    cmd('Assign Sequence '..seq..' Executor '..exec)
    cmd('Assign Sequence '..seq..' /track=off')
    cmd('Assign Exec '..exec..' /restart=next /priority=htp /offtime=0.2')
end

function resetValues()
    groups = {}
    directions = {"left", "right", "in", "out", "rnd"}
    grpRnd = false
    dirRnd = false
    seq = 0
    exec = 0
    amount = 0
    wing = 0
    trigTime = 0.1
    fade = 0.05
    rnd = 'false'
    cue = 1

    grpCollect = true
end

-- Plugin Function Selection --
function PulseWaveGen_Start()
    setup()
    fb("setup done")
    if exec == nil then
        fb("No executor selected, exiting.")
        return
    end
    fb("selected exec: "..exec)
    --create()
    clear()
    resetValues()
end

return PulseWaveGen_Start