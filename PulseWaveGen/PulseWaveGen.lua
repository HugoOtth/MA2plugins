-- MADE BY HUGO OTTH - 2025

-- Pulse Wave Generator Plugin
gma.feedback("Pulse Wave Generator Plugin Loaded :DD")

-- Local Variables
local batch = false
local groups = {}
local dir = "left"
local seq = 0
local exec = 0
local amount = 1
local delay = 0.2
local trigTime = 0.1
local fade = 0.05

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

-- Direction short names for labeling
local dirShortNames = {
    left = "L",
    right = "R",
    ["in"] = "I",
    out = "O"
}

-- Get delay string based on direction
-- left = delay thru 0, right = 0 thru delay
-- in = 0 thru delay, out = delay thru 0
function getDelayString(direction, delayVal)
    if direction == "left" or direction == "out" then
        return delayVal.." Thru 0"
    else -- right or in
        return "0 Thru "..delayVal
    end
end

-- Get wing value based on direction
function getWing(direction)
    if direction == "in" or direction == "out" then
        return 2
    else
        return 0
    end
end

-- Pick random item from list, avoiding lastPick
function pickRandomAvoid(list, lastPick)
    if #list == 0 then return nil end
    if #list == 1 then return list[1] end
    
    local available = {}
    for _, item in ipairs(list) do
        if item ~= lastPick then
            table.insert(available, item)
        end
    end
    
    if #available == 0 then
        available = list
    end
    
    return available[math.random(1, #available)]
end

-- Get random directions ensuring no same direction back-to-back
function getRandomDirections(count)
    local baseDirections = {"left", "right", "in", "out"}
    local result = {}
    local lastDir = nil
    
    for i = 1, count do
        local newDir = pickRandomAvoid(baseDirections, lastDir)
        table.insert(result, newDir)
        lastDir = newDir
    end
    
    return result
end

-- Get random group order ensuring no same group back-to-back
function getRandomGroups(groupList, count)
    local result = {}
    local lastGrp = nil
    
    for i = 1, count do
        local newGrp = pickRandomAvoid(groupList, lastGrp)
        table.insert(result, newGrp)
        lastGrp = newGrp
    end
    
    return result
end

------------------
-- PLUGIN START --
------------------

function setup()
    -- Reset groups
    groups = {}
    
    -- Ask for batch mode
    local batchInput = text('Batch mode? (true/false)', 'false')
    batch = (batchInput == 'true')
    
    if batch then
        -- Collect multiple groups
        local grpCollect = true
        while grpCollect do
            local grpInput = text('Enter Group '..(#groups + 1)..' (Leave empty to finish)', '')
            if grpInput == nil or grpInput == '' then
                grpCollect = false
            else
                table.insert(groups, grpInput)
            end
        end
    else
        -- Single group
        local grpInput = text('Enter Group Number', '0')
        if grpInput and grpInput ~= '' then
            table.insert(groups, grpInput)
        end
    end
    
    if #groups == 0 then
        fb("No groups entered, exiting.")
        return false
    end
    
    fb("Collected groups: "..table.concat(groups, ", "))
    
    -- Ask for direction
    dir = text('Direction? (left, right, in, out, rnd)', 'left')
    
    -- If random, ask for amount
    if dir == 'rnd' then
        amount = tonumber(text('How many random wave cue pairs?', '4'))
        if not amount or amount < 1 then
            amount = 1
        end
    else
        amount = 1
    end
    
    -- Ask for delay
    delay = tonumber(text('Wave Delay? (seconds)', '0.2'))
    if not delay then delay = 0.2 end
    
    -- Ask for trig time and fade
    trigTime = tonumber(text('Trig time? (Default = 0.10s)', '0.1'))
    if not trigTime then trigTime = 0.1 end
    
    fade = tonumber(text('Fade time? (Default = 0.05s)', '0.05'))
    if not fade then fade = 0.05 end
    
    -- Open Seq and Exec View
    cmd('View 278 /screen=6')
    
    seq = text('Enter Sequence Number', '1')
    exec = text('Enter Exec Number', '1')
    
    return true
end

function createCuePair(grp, direction, cueNum)
    local wing = getWing(direction)
    local delayStr = getDelayString(direction, delay)
    
    -- Select group and apply MAtricks
    cmd('Group '..grp)
    if wing > 0 then
        cmd('MAtricksWings '..wing)
    else
        cmd('MAtricksWings 0')
    end
    
    -- Cue 1: Full (At 100)
    cmd('At 100')
    cmd('At Delay '..delayStr)
    cmd('Store Sequence '..seq..' Cue '..cueNum)
    cmd('Label Sequence '..seq..' Cue '..cueNum..' "Full '..dirShortNames[direction]..'"')
    
    -- Cue 2: Off (At 0)
    cmd('At 0')
    cmd('At Delay '..delayStr)
    cmd('Store Sequence '..seq..' Cue '..(cueNum + 1))
    cmd('Label Sequence '..seq..' Cue '..(cueNum + 1)..' "Off '..dirShortNames[direction]..'"')
    cmd('Assign Sequence '..seq..' Cue '..(cueNum + 1)..' /trig=time /trigtime='..trigTime..' /fade='..fade..' /mode=release')
    
    clear()
end

function create()
    cmd('BlindEdit On')
    
    -- Seed random
    math.randomseed(os.time())
    
    local cueNum = 1
    local dirList = {}
    local grpList = {}
    
    -- Determine total cue pairs needed
    local totalPairs = amount
    if #groups > 1 then
        totalPairs = amount * #groups
    end
    
    -- Build direction list
    if dir == 'rnd' then
        dirList = getRandomDirections(totalPairs)
    else
        for i = 1, totalPairs do
            table.insert(dirList, dir)
        end
    end
    
    -- Build group list (randomized if multiple groups, no same group back-to-back)
    if #groups > 1 then
        grpList = getRandomGroups(groups, totalPairs)
    else
        for i = 1, totalPairs do
            table.insert(grpList, groups[1])
        end
    end
    
    -- Create cue pairs
    for i = 1, totalPairs do
        createCuePair(grpList[i], dirList[i], cueNum)
        cueNum = cueNum + 2
    end
    
    cmd('BlindEdit Off')
    
    -- Build sequence/exec name
    local grpName = ""
    if #groups == 1 then
        grpName = "G"..groups[1]
    else
        grpName = "G"..groups[1].."-"..groups[#groups]
    end
    
    local dirName = ""
    if dir == 'rnd' then
        dirName = "Rnd"..amount
    else
        dirName = dirShortNames[dir] or dir
    end
    
    local seqName = "Wave "..grpName.." "..dirName
    
    -- Apply appearance and assign
    cmd('Appearance Sequence '..seq..' /b=100 /r=50')
    cmd('Assign Sequence '..seq..' Executor '..exec)
    cmd('Assign Sequence '..seq..' /track=off')
    cmd('Assign Exec '..exec..' /restart=next /priority=htp /offtime=0.2')
    cmd('Label Sequence '..seq..' "'..seqName..'"')
    cmd('Label Exec '..exec..' "'..seqName..'"')
end

function resetValues()
    batch = false
    groups = {}
    dir = "left"
    seq = 0
    exec = 0
    amount = 1
    delay = 0.2
    trigTime = 0.1
    fade = 0.05
end

-- Plugin Function Selection --
function PulseWaveGen_Start()
    local success = setup()
    if not success then
        fb("Setup cancelled or failed.")
        clear()
        resetValues()
        return
    end
    
    fb("Setup done - creating wave sequence...")
    
    if exec == nil or exec == '' then
        fb("No executor selected, exiting.")
        clear()
        resetValues()
        return
    end
    
    create()
    fb("Wave sequence created on Exec "..exec)
    clear()
    resetValues()
end

return PulseWaveGen_Start