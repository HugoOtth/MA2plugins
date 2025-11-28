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
local updateMode = 0

-- Amount of Colors
local colNb = 11

--local colSwatchBook = {"White", "Red", "Orange", "Yellow", "Green", "Sea Green", "Cyan", "Lavender", "Blue", "Violet", "Magenta", "Pink", "Warm White"}
local colSwatchBook = {"White", "Red", "Orange", "Yellow", "Green", "Cyan", "Lavender", "Blue", "Violet", "Magenta", "Pink"}
local colSwatchIndex = {1, 2, 3, 4, 6, 8, 9, 10, 11, 12, 13}

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
  for d=0, #groups-1 do
    local presetCurrent = presetStart + ((d)* presetWidth)
    cmd("Delete Preset "..presetCurrent.." Thru "..(presetCurrent+colNb-1).." /nc")
  end
  clear()
end

function deleteSequence()
  --Delete old Sequences and Cues
  cmd("Delete Sequence "..(seqStart).." Thru "..(seqStart+#groups-1).." /nc")
end

function createPresets()
  -- Create All Presets and Group Presets
  for group=grpStart, #groups do
    local presetCurrent = presetStart + ((group-1)* presetWidth)

    for start=1,colNb do
      local preset = presetCurrent+start-1
      cmd("Group "..group.." At Gel 1."..colSwatchIndex[start])
      cmd("Store Preset 4."..preset)
      cmd("Label Preset 4."..preset.." \""..groups[group].." "..colSwatchBook[start].."\"")
    end
    clear()
  end
  clear()
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

function resetValues()
  updateMode = 0
end

-- Plugin Function Selection --
function ColorPickerUpdate_Start()
  fb("---Color Picker Started :DDD---")
  -- updateMode = tonumber(text('Update Mode? (0 = All, 1 = Colormatch All Group)', updateMode)) -- to be finished
  cmd("BlindEdit On")
  deletePresets()
  fb("--- Presets Deleted ---")
  deleteSequence()
  fb("--- Sequences Deleted ---")
  sleep(0.1)
  createPresets()
  fb("--- Presets Created ---")
  createSequences()
  fb("--- Sequences Created ---")
  createCues()
  fb("--- Cues Created ---")
  assignSequences()
  cmd("BlindEdit Off")
  fb("--- Color Picker Update Done---")
  sleep(0.5)
  cmd("Go Macro 787; Go Macro 704; Go Macro 711")
  cmd("Go Macro ALLWHITE")
  sleep(0.5)
  cmd("Go Macro ALLRED")
  sleep(0.5)
  cmd("Go Macro ALLYELLOW")
  sleep(0.5)
  cmd("Go Macro ALLGREEN")
  sleep(0.5)
  cmd("Go Macro ALLBLUE")
  sleep(0.5)
  cmd("Go Macro ALLPINK")
  sleep(0.5)
  cmd("Go Macro ALLRED")
  sleep(0.5)
  resetValues()
end

return ColorPickerUpdate_Start