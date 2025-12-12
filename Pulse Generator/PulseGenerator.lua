-- MADE BY HUGO OTTH - 2025
---@diagnostic disable: undefined-global

-- Pulse Generator Plugin
gma.feedback("Pulse Generator Plugin Loaded :DD")

-- Local Variables
local PG_grp = 0
local PG_seq = 0
local PG_exec = 0
local PG_amount = 0
local PG_wing = 0
local PG_trigTime = 0.1
local PG_fade = 0.05
local PG_rnd = 'false'
local PG_white = 'false'

local PG_cue = 1

-- GrandMA Shortcuts
local text = gma.textinput
local cmd = gma.cmd
local fb = gma.feedback
local getHandle = gma.show.getobj.handle

local function PG_sleep(s)
  gma.sleep(s)
end

local function PG_clear()
  cmd('ClearAll')
end

------------------
-- PLUGIN START --
------------------

local function PG_setup()
    PG_white = text('White Bump Mode?', PG_white)
    PG_grp = text('Enter Group Number', PG_grp)
    PG_seq = text('Enter Sequence Number', PG_seq)
    PG_exec = text('Enter Exec Number', PG_exec)
    PG_wing = text('Wings?', PG_wing)
    PG_rnd = text('Random order?', PG_rnd)
    PG_amount = tonumber(text('Pulse Amount?', PG_amount))
    if(PG_white == 'false') then
        PG_trigTime = tonumber(text('Trig time? (Default = 0.10s)', PG_trigTime))
        PG_fade = tonumber(text('Fade time? (Default = 0.05s)', PG_fade))
    else
        PG_trigTime = 0
        PG_fade = 0
    end
end

local function PG_create()
    cmd('BlindEdit On')

    -- MAtricks
    cmd('Group '..PG_grp)
    cmd('MAtricksWings '..PG_wing)
    if(PG_rnd == 'true') then
        cmd('ShuffleSelection')
    end
    cmd('MAtricksInterleave '..PG_amount)

    -- Storing to Sequence
    while PG_cue <= PG_amount * 2 do
        cmd('Next')
        cmd('At 100')
        if(PG_white == 'true') then
            cmd('At Gel 1.1')
        end
        cmd('Store Sequence '..PG_seq..' Cue '..PG_cue)
        cmd('Label Sequence '..PG_seq..' Cue '..PG_cue..' "ON"')
        if(PG_white == 'true') then
            cmd('At 100')
        else
            cmd('At 0')
        end
        cmd('Store Sequence '..PG_seq..' Cue '..(PG_cue + 1))
        cmd('Label Sequence '..PG_seq..' Cue '..(PG_cue + 1)..' "OFF"')
        cmd('Assign Sequence '..PG_seq..' Cue '..(PG_cue + 1)..' /trig=time /trigtime='..PG_trigTime..' /fade='..PG_fade..' /mode=release')
        PG_cue = PG_cue + 2
    end
    cmd('BlindEdit Off')
    cmd('Appearance Sequence '..PG_seq..' /b=100 /r=50')
    cmd('Assign Sequence '..PG_seq..' Executor '..PG_exec)
    cmd('Assign Sequence '..PG_seq..' /track=off')
    cmd('Assign Exec '..PG_exec..' /restart=next /priority=htp /offtime=0.2')
end

local function PG_resetValues()
    PG_grp = 0
    PG_seq = 0
    PG_exec = 0
    PG_amount = 0
    PG_wing = 0
    PG_trigTime = 0.1
    PG_fade = 0.05
    PG_rnd = 'false'
    PG_cue = 1
    PG_white = 'false'
end

-- Plugin Function Selection --
local function PulseGen_Start()
    PG_setup()
    fb(PG_grp..PG_seq..PG_amount..PG_wing..PG_trigTime..PG_fade)
    PG_create()
    PG_clear()
    PG_resetValues()
end

return PulseGen_Start