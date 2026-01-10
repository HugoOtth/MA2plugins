-- MADE BY HUGO OTTH - 2025
-- Pulse Wave Generator Plugin

gma.feedback("Pulse Wave Generator Plugin Loaded :DD")

local PWG_batch = false
local PWG_singleStack = false
local PWG_groups = {}
local PWG_dir = "left"
local PWG_seq = 0
local PWG_exec = 0
local PWG_amount = 1
local PWG_delay = 0.2
local PWG_trigTime = 0.1
local PWG_fade = 0.05
local PWG_progressHandle = nil

local text = gma.textinput
local cmd = gma.cmd
local fb = gma.feedback

local PWG_dirShortNames = {
    left = "L",
    right = "R",
    ["in"] = "I",
    out = "O"
}

local function PWG_sleep(s)
    gma.sleep(s)
end

local function PWG_clear()
    cmd("ClearAll")
end

local function PWG_getDelayString(direction, delayVal)
    if direction == "left" or direction == "out" then
        return delayVal .. " Thru 0"
    else
        return "0 Thru " .. delayVal
    end
end

local function PWG_getWing(direction)
    if direction == "in" or direction == "out" then
        return 2
    else
        return 0
    end
end

local function PWG_pickRandomAvoid(list, lastPick)
    if #list == 0 then
        return nil
    end
    if #list == 1 then
        return list[1]
    end
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

local function PWG_getRandomDirections(count)
    local baseDirections = {"left", "right", "in", "out"}
    local result = {}
    local lastDir = nil
    for i = 1, count do
        local newDir = PWG_pickRandomAvoid(baseDirections, lastDir)
        table.insert(result, newDir)
        lastDir = newDir
    end
    return result
end

local function PWG_getRandomGroups(groupList, count)
    local result = {}
    local lastGrp = nil
    for i = 1, count do
        local newGrp = PWG_pickRandomAvoid(groupList, lastGrp)
        table.insert(result, newGrp)
        lastGrp = newGrp
    end
    return result
end

local function PWG_setup()
    PWG_groups = {}
    PWG_singleStack = false
    
    local batchInput = text("Batch mode? (true/false)", "false")
    PWG_batch = (batchInput == "true")
    
    if not PWG_batch then
        local singleStackInput = text("Single cue stack? (merge groups) (true/false)", "false")
        PWG_singleStack = (singleStackInput == "true")
    end
    
    if PWG_batch or PWG_singleStack then
        local grpCollect = true
        while grpCollect do
            local grpInput = text("Enter Group " .. (#PWG_groups + 1) .. " (empty to finish)", "")
            if grpInput == nil or grpInput == "" then
                grpCollect = false
            else
                table.insert(PWG_groups, grpInput)
            end
        end
    else
        local grpInput = text("Enter Group Number", "0")
        if grpInput and grpInput ~= "" then
            table.insert(PWG_groups, grpInput)
        end
    end
    
    if #PWG_groups == 0 then
        fb("No groups entered, exiting.")
        return false
    end
    
    fb("Collected groups: " .. table.concat(PWG_groups, ", "))
    
    if PWG_singleStack then
        PWG_dir = text("Direction? (left, right, in, out)", "left")
        if PWG_dir == "rnd" then
            fb("Random not allowed in single stack mode")
            PWG_dir = "left"
        end
        PWG_amount = 1
    else
        PWG_dir = text("Direction? (left, right, in, out, rnd)", "left")
        if PWG_dir == "rnd" then
            PWG_amount = tonumber(text("How many random wave cue pairs?", "4"))
            if not PWG_amount or PWG_amount < 1 then
                PWG_amount = 1
            end
        elseif PWG_batch then
            PWG_amount = tonumber(text("How many repeats per group?", "1"))
            if not PWG_amount or PWG_amount < 1 then
                PWG_amount = 1
            end
        else
            PWG_amount = 1
        end
    end
    
    PWG_delay = tonumber(text("Wave Delay? (seconds)", "0.2"))
    if not PWG_delay then
        PWG_delay = 0.2
    end
    
    PWG_trigTime = tonumber(text("Trig time? (Default = 0.10s)", "0.1"))
    if not PWG_trigTime then
        PWG_trigTime = 0.1
    end
    
    PWG_fade = tonumber(text("Fade time? (Default = 0.05s)", "0.05"))
    if not PWG_fade then
        PWG_fade = 0.05
    end
    
    cmd("View 278 /screen=5")
    
    PWG_seq = text("Enter Sequence Number", "1")
    PWG_exec = text("Enter Exec Number", "1")
    
    return true
end

local function PWG_createCuePair(grp, direction, cueNum)
    local wing = PWG_getWing(direction)
    local delayStr = PWG_getDelayString(direction, PWG_delay)
    
    PWG_clear()
    
    cmd("Group " .. grp)
    if wing > 0 then
        cmd("MAtricksWings " .. wing)
    end
    
    cmd("At 100")
    PWG_sleep(0.05)
    cmd("Delay " .. delayStr)
    PWG_sleep(0.05)
    cmd("Store Sequence " .. PWG_seq .. " Cue " .. cueNum)
    cmd("Label Sequence " .. PWG_seq .. " Cue " .. cueNum .. " \"Full " .. PWG_dirShortNames[direction] .. "\"")
    
    cmd("At 0")
    PWG_sleep(0.05)
    cmd("Delay " .. delayStr)
    PWG_sleep(0.05)
    cmd("Store Sequence " .. PWG_seq .. " Cue " .. (cueNum + 1))
    cmd("Label Sequence " .. PWG_seq .. " Cue " .. (cueNum + 1) .. " \"Off " .. PWG_dirShortNames[direction] .. "\"")
    cmd("Assign Sequence " .. PWG_seq .. " Cue " .. (cueNum + 1) .. " /trig=time /trigtime=" .. PWG_trigTime .. " /fade=" .. PWG_fade .. " /mode=release")
end

local function PWG_createSingleStack()
    cmd("BlindEdit On")
    
    local wing = PWG_getWing(PWG_dir)
    local delayStr = PWG_getDelayString(PWG_dir, PWG_delay)
    
    if #PWG_groups > 1 then
        PWG_progressHandle = gma.gui.progress.start("Creating Single Stack")
        gma.gui.progress.setrange(PWG_progressHandle, 1, #PWG_groups * 2)
    end
    
    local progressStep = 0
    
    PWG_clear()
    
    for i, grp in ipairs(PWG_groups) do
        progressStep = progressStep + 1
        if PWG_progressHandle then
            gma.gui.progress.set(PWG_progressHandle, progressStep)
            gma.gui.progress.settext(PWG_progressHandle, "Adding G" .. grp .. " to Full cue")
        end
        cmd("Group " .. grp)
        if wing > 0 then
            cmd("MAtricksWings " .. wing)
        end
        cmd("At 100")
        PWG_sleep(0.05)
        cmd("Delay " .. delayStr)
        PWG_sleep(0.05)
    end
    
    cmd("Store Sequence " .. PWG_seq .. " Cue 1")
    cmd("Label Sequence " .. PWG_seq .. " Cue 1 \"Full " .. PWG_dirShortNames[PWG_dir] .. "\"")
    
    PWG_clear()
    
    for i, grp in ipairs(PWG_groups) do
        progressStep = progressStep + 1
        if PWG_progressHandle then
            gma.gui.progress.set(PWG_progressHandle, progressStep)
            gma.gui.progress.settext(PWG_progressHandle, "Adding G" .. grp .. " to Off cue")
        end
        cmd("Group " .. grp)
        if wing > 0 then
            cmd("MAtricksWings " .. wing)
        end
        cmd("At 0")
        PWG_sleep(0.05)
        cmd("Delay " .. delayStr)
        PWG_sleep(0.05)
    end
    
    cmd("Store Sequence " .. PWG_seq .. " Cue 2")
    cmd("Label Sequence " .. PWG_seq .. " Cue 2 \"Off " .. PWG_dirShortNames[PWG_dir] .. "\"")
    cmd("Assign Sequence " .. PWG_seq .. " Cue 2 /trig=time /trigtime=" .. PWG_trigTime .. " /fade=" .. PWG_fade .. " /mode=release")
    
    if PWG_progressHandle then
        gma.gui.progress.stop(PWG_progressHandle)
        PWG_progressHandle = nil
    end
    
    cmd("BlindEdit Off")
    
    local grpName = ""
    if #PWG_groups == 1 then
        grpName = "G" .. PWG_groups[1]
    else
        grpName = "G" .. PWG_groups[1] .. "-" .. PWG_groups[#PWG_groups]
    end
    
    local seqName = "Wave " .. grpName .. " " .. PWG_dirShortNames[PWG_dir] .. " Merged"
    
    cmd("Appearance Sequence " .. PWG_seq .. " /b=100 /r=50")
    cmd("Assign Sequence " .. PWG_seq .. " Executor " .. PWG_exec)
    cmd("Assign Sequence " .. PWG_seq .. " /track=off")
    cmd("Assign Exec " .. PWG_exec .. " /restart=next /priority=htp /offtime=0.2")
    cmd("Label Sequence " .. PWG_seq .. " \"" .. seqName .. "\"")
    cmd("Label Exec " .. PWG_exec .. " \"" .. seqName .. "\"")
end

local function PWG_create()
    cmd("BlindEdit On")
    
    math.randomseed(os.time())
    
    local cueNum = 1
    local dirList = {}
    local grpList = {}
    
    local totalPairs = PWG_amount
    if #PWG_groups > 1 then
        totalPairs = PWG_amount * #PWG_groups
    end
    
    if PWG_dir == "rnd" then
        dirList = PWG_getRandomDirections(totalPairs)
    else
        for i = 1, totalPairs do
            table.insert(dirList, PWG_dir)
        end
    end
    
    if #PWG_groups > 1 then
        grpList = PWG_getRandomGroups(PWG_groups, totalPairs)
    else
        for i = 1, totalPairs do
            table.insert(grpList, PWG_groups[1])
        end
    end
    
    if totalPairs > 1 then
        PWG_progressHandle = gma.gui.progress.start("Creating Wave Sequence")
        gma.gui.progress.setrange(PWG_progressHandle, 1, totalPairs)
    end
    
    for i = 1, totalPairs do
        if PWG_progressHandle then
            gma.gui.progress.set(PWG_progressHandle, i)
            gma.gui.progress.settext(PWG_progressHandle, "Cue pair " .. i .. " of " .. totalPairs)
        end
        PWG_createCuePair(grpList[i], dirList[i], cueNum)
        cueNum = cueNum + 2
    end
    
    if PWG_progressHandle then
        gma.gui.progress.stop(PWG_progressHandle)
        PWG_progressHandle = nil
    end
    
    cmd("BlindEdit Off")
    
    local grpName = ""
    if #PWG_groups == 1 then
        grpName = "G" .. PWG_groups[1]
    else
        grpName = "G" .. PWG_groups[1] .. "-" .. PWG_groups[#PWG_groups]
    end
    
    local dirName = ""
    if PWG_dir == "rnd" then
        dirName = "Rnd" .. PWG_amount
    else
        dirName = PWG_dirShortNames[PWG_dir] or PWG_dir
    end
    
    local seqName = "Wave " .. grpName .. " " .. dirName
    
    cmd("Appearance Sequence " .. PWG_seq .. " /b=100 /r=50")
    cmd("Assign Sequence " .. PWG_seq .. " Executor " .. PWG_exec)
    
    if PWG_batch then
        cmd("Assign Sequence " .. PWG_seq .. " /track=on")
    else
        cmd("Assign Sequence " .. PWG_seq .. " /track=off")
    end
    
    cmd("Assign Exec " .. PWG_exec .. " /restart=next /priority=htp /offtime=0.2")
    cmd("Label Sequence " .. PWG_seq .. " \"" .. seqName .. "\"")
    cmd("Label Exec " .. PWG_exec .. " \"" .. seqName .. "\"")
end

local function PWG_resetValues()
    PWG_batch = false
    PWG_singleStack = false
    PWG_groups = {}
    PWG_dir = "left"
    PWG_seq = 0
    PWG_exec = 0
    PWG_amount = 1
    PWG_delay = 0.2
    PWG_trigTime = 0.1
    PWG_fade = 0.05
end

local function PulseWaveGen_Start()
    local success = PWG_setup()
    if not success then
        fb("Setup cancelled or failed.")
        PWG_clear()
        PWG_resetValues()
        return
    end
    
    fb("Setup done - creating wave sequence...")
    
    if PWG_exec == nil or PWG_exec == "" then
        fb("No executor selected, exiting.")
        PWG_clear()
        PWG_resetValues()
        return
    end
    
    if PWG_singleStack then
        PWG_createSingleStack()
        fb("Single stack wave sequence created on Exec " .. PWG_exec)
    else
        PWG_create()
        fb("Wave sequence created on Exec " .. PWG_exec)
    end
    
    PWG_clear()
    PWG_resetValues()
end

local function PWG_Cleanup()
    if PWG_progressHandle then
        gma.gui.progress.stop(PWG_progressHandle)
        PWG_progressHandle = nil
    end
    fb("Plugin cleanup called")
end

return PulseWaveGen_Start, PWG_Cleanup
