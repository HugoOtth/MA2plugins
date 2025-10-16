-- MADE BY HUGO OTTH - 2025

-- Color Picker Update Plugin
gma.feedback("Pulse Wave Generator Plugin Loaded :DD")

-- Local Variables
local groups = {}
local directions = {"left", "right", "in", "out", "rnd"}
local grpRnd = false
local dirRnd = false
local seq = 0
local exec = 0
local amount = 0
local trigTime = 0.1
local fade = 0.05

local cue = 1
local grpCollect = true

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
    while grpCollect do
        local grpInput = text('Enter Group '..(#groups + 1)..' (Leave empty to finish)', '')
        if grpInput == '' then
            grpCollect = false
        else
            table.insert(groups, grpInput)
        end
    end
    fb("Collected groups: "..table.concat(groups, ", "))
    dir = text('Direction? (left, right, in, out, rnd)', dir)
    seq = text('Enter Sequence Number',seq)
    exec = text('Enter Exec Number',exec)
    wing = text('Wings?',wing)
    rnd = text('Random order?',rnd)
    amount = tonumber(text('Pulse Amount?',amount))
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

local function getExecutorFromUser()
    Printf("Click on an executor in any executor view...")
    -- You can specify what type of objects to select
    local selection = ObjectList("Select Executor", "Executor")
    
    if selection and #selection > 0 then
        local exec = selection[1]
        local execId = exec:Number()
        local execName = exec:Name()
        
        Printf("Selected: Exec " .. execId .. " (" .. execName .. ")")
        return execId
    end
    
    return nil
end

-- Plugin Function Selection --
function PulseWaveGen_Start()
    setup()
    fb("setup done")
    exec = getExecutorFromUser()
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