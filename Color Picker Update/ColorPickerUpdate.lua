-- MADE BY HUGO OTTH - 2025

-- Color Picker Update Plugin
gma.feedback("Color Picker Update Plugin Loaded :DD")

-- Local Variables
local groups = {"A", "B", "C", "D", "E", "F", "G"}
local grpStart = 1
local presetStart = 1
local presetWidth = 16
local execPage = 100
local execStart = 101
local seqStart = 300

-- Amount of Colors
local colNb = 11

--local colSwatchBook = {"White", "Red", "Orange", "Yellow", "Green", "Sea Green", "Cyan", "Lavender", "Blue", "Violet", "Magenta", "Pink", "Warm White"}
local colSwatchBook = {"White", "Red", "Orange", "Yellow", "Fern Green", "Green", "Cyan", "Blue", "Violet", "Magenta", "Pink"}

-- GrandMA Shortcuts
local text = gma.textinput
local cmd = gma.cmd
local fb = gma.feedback
local getHandle = gma.show.getobj.handle

function sleep(s)
  gma.sleep(s)
end

function clear()
  cmd("ClearAll")
end

------------------
-- PLUGIN START --
------------------

function deletePresets()
  --Delete Old Presets, Cues and Sequences.
  for d=1, #groups-1 do
    local presetCurrent = presetStart + ((d)* presetWidth)
    cmd("Delete Preset "..presetCurrent.." Thru "..(presetCurrent+colNb-1).." /nc")
  end
  clear()
end

function createPresets()
  -- Create Group Presets *** KEEPS FIRST GROUP ***
  for group=grpStart+1, #groups do
    local presetCurrent = presetStart + ((group-1)* presetWidth)

    for start=1,colNb do
      local preset = presetCurrent+start-1
      cmd("Group "..group.." At Preset 4."..start)
      cmd("Store Preset 4."..preset)
      cmd("Label Preset 4."..preset.." \""..groups[group].." "..colSwatchBook[start].."\"")
    end
    clear()
  end
  clear()
end

function deleteSequence()
  --Delete old Sequences and Cues
  cmd("Delete Sequence "..(seqStart).." Thru "..(seqStart+#groups-1).." /nc")
end

function createSequences()
  --Create New Sequences
  for seq=0, #groups-1 do
    local seqCurrent = seqStart + seq
    cmd("Store Sequence "..seqCurrent.." /o")
    cmd("Label Sequence "..seqCurrent.." \""..groups[seq+1].."\"")
  end
end

function createCues()
  fb("--- Creating Cues")
  for group=grpStart, #groups do
    local presetCurrent = presetStart + ((group-1)* presetWidth)
    for start=1, colNb do
      local preset = presetCurrent + start - 1
      local seqCurrent = seqStart + group - 1
      cmd("Group "..group.." At Preset 4."..preset)
      cmd("Store Cue "..start.." Sequence "..seqCurrent)
      cmd("Label Sequence "..seqCurrent.." Cue "..start.." \""..groups[group].." "..colSwatchBook[start].."\"")
    end
  end
  clear()
end


function assignSequences()
  --Ajout verif si old exec etais link aux sequences
  --cmd("Delete Executor "..execPage.."."..(execStart+1).." Thru "..execPage.."."..(execStart+#groups-1).." /nc")
  for seq = seqStart, seqStart + #groups - 1 do
    local executor = execPage.."."..(execStart + seq - seqStart)
    cmd("Assign Sequence "..seq.." At Executor "..executor)
  end
end

-- Plugin Function Selection --
function ColorPickerUpdate_Start()
  fb("---Color Picker Started :DDD---")
  cmd("BlindEdit On")
  deletePresets()
  createPresets()
  deleteSequence()
  sleep(0.1)
  createSequences()
  createCues()
  assignSequences()
  cmd("BlindEdit Off")
  fb("--- Color Picker Update Done---")
  sleep(0.5)
  cmd("Go Macro COLFADE05")
  cmd("Go Macro ALLRED")
end

return ColorPickerUpdate_Start