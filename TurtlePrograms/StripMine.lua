--Name: StripMine
--Version: 4.0
--Author: DasGerippe

--[[
+-----------+
| VARIABLES |
+-----------+
--]]

configName = "configs/"..shell.getRunningProgram()..".cfg"

length = 0
blength = 0
bspacing = 0
placeTorches = false
returnAfterFinish = false

rotation = 0

chest = false

--[[
+-----+
| API |
+-----+
--]]

--Converts a string or number into a boolean. ("true" and 1 = true, rest = false)
local function toBoolean(x)
  if type(x)=="boolean" then
    return x
  elseif type(x)=="string" then
    return x=="true"
  elseif type(x)=="number" then
    return x==1
  end
  return false
end

--[[
+----------------+
| CONFIG-METHODS |
+----------------+
--]]

--Creates config with the default or given values.
local function createConfig(newlength, newblength, newbspacing, newPlaceTorches, newReturnAfterFinish)
  newlength = newlength or 32
  newblength = newblength or 6
  newbspacing = newbspacing or 2
  newPlaceTorches = newPlaceTorches or false
  newReturnAfterFinish = newReturnAfterFinish or false

  local config = fs.open(configName, "w")
  config.writeLine("Length: "..newlength)
  config.writeLine("Branch-length: "..newblength)
  config.writeLine("Branch-distance: "..newbspacing)
  config.writeLine("Place torches: "..tostring(newPlaceTorches))
  config.writeLine("Return after finish: "..tostring(newReturnAfterFinish))
  config.close()
end

--Check whether config exists or not.
local function checkForConfig()
  if fs.exists(configName)==false then
    createConfig()
  end
end

--Reads values out of the config.
local function readConfig()
  local config = fs.open(configName, "r")

  local line
  local i

  line = config.readLine()
  i = string.find(line,":")+2
  length = tonumber(string.sub(line,i,i+3))
  length = length or 32

  line = config.readLine()
  i = string.find(line,":")+2
  blength = tonumber(string.sub(line,i,i+3))
  blength = blength or 6

  line = config.readLine()
  i = string.find(line,":")+2
  bspacing = tonumber(string.sub(line,i,i+3))
  bspacing = bspacing or 2

  line = config.readLine()
  i = string.find(line,":")+2
  placeTorches = toBoolean(string.sub(line,i,i+3))

  line = config.readLine()
  i = string.find(line,":")+2
  returnAfterFinish = toBoolean(string.sub(line,i,i+3))

  config.close()
end

--[[
+----------------+
| SCREEN-METHODS |
+----------------+
--]]

--Displays the main screen.
local function displayMainScreen()
  term.clear()
  term.setCursorPos(1,1)
  print("Length: "..length)
  print("Branch-length: "..blength)
  print("Branch-distance: "..bspacing)
  print("Place torches: "..tostring(placeTorches))
  print("Return after finish: "..tostring(returnAfterFinish))
  print("---------------------------------------")
  print("Fuel-Level: "..turtle.getFuelLevel().."/"..turtle.getFuelLimit())
  print("---------------------------------------")
  print("[1] Start Turtle")
  print("[2] Change Settings")
  print("[3] Reset Settings")
  print("[4] Refuel from Slot 16")
  write("[0] Cancel")
end

--Displays the settings screen.
local function displaySettingsScreen()
  for i=7,13 do
    term.setCursorPos(1,i)
    term.clearLine()
  end
  term.setCursorPos(1,7)
  print("Note:")
end

--Writes the given description.
local function writeDescription(description)
  term.setCursorPos(1,8)
  term.clearLine()
  write(description)
end

--Writes the value range with the given min-/max-values.
local function writeValueRange(min,max)
  term.setCursorPos(1,9)
  term.clearLine()
  if min and max then
    write("Value has to be between "..min.." and "..max..".")
  end
end

--Displays the start screen.
local function displayStartScreen()
  term.clear()
  term.setCursorPos(1,1)
  print("Optional:")
  print("Torches into turtle-inventory")
  print("Chest behind Turtle")
  print("---------------------------------------")
  print("Start turtle with ENTER")
  print("---------------------------------------")
  repeat
    local e,b = os.pullEvent("key")
  until b==keys.enter
  print("Turtle started! Working...")
end

--Displays the end screen.
local function displayFinishScreen()
  print("---------------------------------------")
  print("Turtle finished successfully!!!")
  print("Stop program with ENTER")
  repeat
    local e,b = os.pullEvent("key")
  until b==keys.enter
  term.clear()
  term.setCursorPos(1,1)
end

--[[
+----------------+
| LOOP-METHODS |
+----------------+
--]]

--Loops turtle.dig() until there is no block in front.
local function lDig()
  while turtle.detect() do
    turtle.dig()
  end
end

--Loops turtle.digUp() until there is no block above.
local function lDigUp()
  while turtle.detectUp() do
    turtle.digUp()
    sleep(0.5)
  end
end

--Loops turtle.digDown() until there is no block below.
local function lDigDown()
  while turtle.detectDown() do
    turtle.digDown()
  end
end

--Loops lDig() and turtle.forward() until the turtle moves one block.
local function lForward()
  repeat
    lDig()
    local b = turtle.forward()
  until b
end

--Loops lDigUp() and turtle.up() until the turtle moves one block up.
local function lUp()
  repeat
    lDigUp()
    local b = turtle.up()
  until b
end

--Loops lDigDown() and turtle.down() until the turtle moves one block down.
local function lDown()
  repeat
    lDigDown()
    local b = turtle.down()
  until b
end

--[[
+----------------+
| TURTLE-METHODS |
+----------------+
--]]

--Turns right and calculates rotation.
local function turnRight()
  turtle.turnRight()
  rotation = rotation+1
  if rotation<0 then rotation = rotation+4 end
  if rotation>3 then rotation = rotation-4 end
end

--Turns left and calculates rotation.
local function turnLeft()
  turtle.turnLeft()
  rotation = rotation-1
  if rotation<0 then rotation = rotation+4 end
  if rotation>3 then rotation = rotation-4 end
end

--Checks whether a chest is behind the turtle
local function checkForChest()
  turnRight()
  turnRight()
  local b,block = turtle.inspect()
  if b then
    local material = string.lower(block.name)
    if string.match(material,"chest") then
      chest = true
      print("Chest detected, do not break it!")
    end
  end
  turnRight()
  turnRight()
end

--Places cobble-/stone or netherrack below the turtle
local function placePathBlock()
  for i=1,16 do
    turtle.select(i)
    local item = turtle.getItemDetail()
    if item and (item.name=="minecraft:stone" or item.name=="minecraft:cobblestone" or item.name=="minecraft:netherrack") then
      turtle.placeDown()
      break
    end
  end
  turtle.select(1)
end

--Detects and maybe replaces air/fluid below the turtle.
local function detectAirAndFluid()
  local b,block = turtle.inspectDown()
  if b then
    if block.name=="minecraft:water" or block.name=="minecraft:flowing_water" or block.name=="minecraft:lava" or block.name=="minecraft:flowing_lava" then
      placePathBlock()
    end
  else
    placePathBlock()
  end
end

--Places a torch behind the turtle.
local function placeTorchBehind()
  for i=16,1,-1 do
    turtle.select(i)
    local item = turtle.getItemDetail()
    if item and item.name=="minecraft:torch" then
      turnRight()
      turnRight()
      turtle.place()
      turnRight()
      turnRight()
      turtle.select(1)
      return
    end
  end
end

--Places a torch below the turtle.
local function placeTorchBelow()
  for i=16,1,-1 do
    turtle.select(i)
    local item = turtle.getItemDetail()
    if item and item.name=="minecraft:torch" then
      turtle.placeDown()
      turtle.select(1)
      return
    end
  end
end

--Drops the inventory of the turtle
local function dropInv()
  for i=1,16 do
    turtle.select(i)
    local item = turtle.getItemDetail()
    if item then
      if item.name~="minecraft:torch" then
        turtle.drop()
      end
    end
  end
  turtle.select(1)
end

--Checks whether the inventory of the turtle is full
local function checkForFullInv()
  local emptySlots = 16
  for i=1,16 do
    if turtle.getItemDetail(i) then
      emptySlots = emptySlots-1
    end
  end
  return emptySlots<=1
end

--Turtle returns to start.
local function returnToStart(clength,cblength)
  lUp()
  if placeTorches and clength==length and clength%(bspacing+1)==0 then
    placeTorchBelow()
  end
  turnRight()
  turnRight()
  while cblength>0 do
    lForward()
    cblength = cblength-1
  end
  if rotation==0 then
    turnRight()
    turnRight()
  end
  if rotation==1 then
    turnRight()
  end
  if rotation==3 then
    turnLeft()
  end
  while clength>0 do
    lForward()
    clength = clength-1
  end
  lDown()
end

--Turtle returns to the last position.
local function returnToLastPos(lastlength, lastblength, lastrotation)
  local clength = 0
  local cblength = 0

  turnRight()
  turnRight()
  lUp()
  while clength<lastlength do
    lForward()
    clength = clength+1
  end
  if lastrotation==1 then
    turnRight()
  end
  if lastrotation==3 then
    turnLeft()
  end
  while cblength<lastblength do
    lForward()
    cblength = cblength+1
  end
  lDown()
end

--Dig one branch.
local function digBranch(clength)
  local cblength = 0

  while cblength<blength do
    lDig()
    lForward()
    lDigUp()
    cblength = cblength+1

    detectAirAndFluid()

    if placeTorches and cblength-1~=0 and (cblength-1)%13==0 then
      placeTorchBehind()
    end
    if chest then
      if checkForFullInv() then
        local lastlength = clength
        local lastblength = cblength
        local lastrotation = rotation

        returnToStart(clength,cblength)
        dropInv()
        returnToLastPos(lastlength,lastblength,lastrotation)
      end
    end
  end
  lUp()
  if cblength%13>6 then
    placeTorchBelow()
  end
  turnRight()
  turnRight()
  while cblength>0 do
    lForward()
    cblength = cblength-1
  end
  lDown()
end

--Starts the turtle.
local function startTurtle()
  checkForChest()
  local clength = 0
  local frequency = bspacing+1

  while clength<length do
    lDig()
    lForward()
    lDigUp()
    clength = clength+1

    detectAirAndFluid()

    if placeTorches and clength-1~=0 and (clength-1)%frequency==0 then
      placeTorchBehind()
    end
    if chest then
      if checkForFullInv() then
        local lastlength = clength
        local lastrotation = rotation

        returnToStart(clength,0)
        dropInv()
        returnToLastPos(lastlength,0,lastrotation)
      end
    end
    if clength%frequency==0 then
      turnRight()
      digBranch(clength)
      digBranch(clength)
      turnLeft()
    end
  end

  if returnAfterFinish then
    returnToStart(clength,0)
  elseif placeTorches and clength%frequency==0 then
    lUp()
    placeTorchBelow()
  end
  return displayFinishScreen()
end

--[[
+----------------+
| ACTION-METHODS |
+----------------+
--]]

--Change the settings inside the turtle.
local function changeSettings()
  sleep(0.05)

  local newlength = 0
  local newblength = 0
  local newbspacing = 0
  local newPlaceTorches = placeTorches
  local newReturnAfterFinish = returnAfterFinish

  writeDescription("Length of the main-branch.")
  writeValueRange(1,512)
  while newlength==nil or newlength<1 or newlength>512 do
    term.setCursorPos(9,1)
    write("   ")
    term.setCursorPos(9,1)
    newlength = tonumber(read())
  end

  writeDescription("Length of each side-branch.")
  writeValueRange(1,128)
  while newblength==nil or newblength<1 or newblength>128 do
    term.setCursorPos(16,2)
    write("   ")
    term.setCursorPos(16,2)
    newblength = tonumber(read())
  end

  writeDescription("Distance between the side-branches.")
  writeValueRange(1,5)
  while newbspacing==nil or newbspacing<1 or newbspacing>5 do
    term.setCursorPos(18,3)
    write("   ")
    term.setCursorPos(18,3)
    newbspacing = tonumber(read())
  end

  writeDescription("Shall the turtle place torches.")
  writeValueRange()
  while true do
    term.setCursorPos(16,4)
    if newPlaceTorches then
      write("<true> |  false ")
    else
      write(" true  | <false>")
    end
    local e,b = os.pullEvent("key")
    if b==keys.enter then
      term.setCursorPos(16,4)
      write(tostring(newPlaceTorches).."            ")
      break
    elseif b==keys.left or b==keys.right then
      newPlaceTorches = not newPlaceTorches
    end
  end

  writeDescription("Shall the turtle return when finished.")
  writeValueRange()
  while true do
    term.setCursorPos(22,5)
    if newReturnAfterFinish then
      write("<true> |  false ")
    else
      write(" true  | <false>")
    end
    term.setCursorPos(22,5)
    local e,b = os.pullEvent("key")
    if b==keys.enter then
      term.setCursorPos(16,4)
      write(tostring(newReturnAfterFinish).."            ")
      break
    elseif b==keys.left or b==keys.right then
      newReturnAfterFinish = not newReturnAfterFinish
    end
  end

  createConfig(newlength,newblength,newbspacing,newPlaceTorches,newReturnAfterFinish)
end

--Resets all settings to their default values.
local function resetSettings()
  createConfig()
  readConfig()
end

--Refuels from slot 16.
local function refuel()
  turtle.select(16)
  turtle.refuel()
  turtle.select(1)
end

--Cancels the Program.
local function cancel()
  term.clear()
  term.setCursorPos(1,1)
  sleep(0.05)
end

--[[
+---------------+
| INPUT-METHODS |
+---------------+
--]]

--Waits for an pull-event and handles it.
local function waitForAction()
  while true do
    local e,b = os.pullEvent("key")
    if b==keys.one then
      displayStartScreen()
      return startTurtle()
    end
    if b==keys.two then
      displaySettingsScreen()
      changeSettings()
      readConfig()
      displayMainScreen()
      return waitForAction()
    end
    if b==keys.three then
      resetSettings()
      displayMainScreen()
      return waitForAction()
    end
    if b==keys.four then
      refuel()
      displayMainScreen()
      return waitForAction()
    end
    if b==keys.zero then
      return cancel()
    end
  end
end

--[[
+------------------+
| Start of program |
+------------------+
--]]

checkForConfig()
readConfig()

displayMainScreen()
waitForAction()