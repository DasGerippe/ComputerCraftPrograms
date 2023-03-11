local function readNumber(prompt, minValue, maxValue)
    local number
    repeat
        write(prompt)
        number = tonumber(read())
    until number and ((not minValue or minValue <= number) and (not maxValue or maxValue >= number) or (minValue and maxValue and minValue > maxValue and (minValue >= number or maxValue <= number)))

    return number
end

local function readDirection(prompt)
    local direction
    repeat
        write(prompt)
        direction = read()
    until direction == "left" or direction == "right"
    return direction
end

local function readVerticalDirection(prompt)
    local direction
    repeat
        write(prompt)
        direction = read()
    until direction == "up" or direction == "down"
    return direction
end

local function dig(direction)
    if direction == "forward" then
        turtle.dig()
    elseif direction == "up" then
        turtle.digUp()
    elseif direction == "down" then
        turtle.digDown()
    end
end

local function move(direction)
    if direction == "forward" then
        turtle.forward()
    elseif direction == "back" then
        turtle.back()
    elseif direction == "up" then
        turtle.up()
    elseif direction == "down" then
        turtle.down()
    end
end

local function turn(direction)
    if direction == "left" then
        turtle.turnLeft()
    elseif direction == "right" then
        turtle.turnRight()
    end
end

local function opposite(direction)
    if direction == "left" then
        return "right"
    elseif direction == "right" then
        return "left"
    end
end

local function digAndForward()
    while turtle.detect() do
        turtle.dig()
    end
    turtle.forward()
end

local function digLane(length)
    for currentLength = 1, length do
        digAndForward()
    end
end

local function prepareNextLane(direction)
    turn(direction)
    digAndForward()
    turn(direction)
end

local function digLayer(width, length, direction)
    for currentWidth = 1, width do
        digLane(length - 1)

        if currentWidth ~= width then
            if currentWidth % 2 == 0 then
                prepareNextLane(opposite(direction))
            else
                prepareNextLane(direction)
            end
        end
    end
end

local function prepareNextLayer(verticalDirection)
    dig(verticalDirection)
    move(verticalDirection)
    turtle.turnRight()
    turtle.turnRight()
end

local function optimizeParameters(length, width, direction)
    if length >= width then
        return length, width, direction
    else
        turn(direction)
        return width, length, opposite(direction)
    end
end

--[[
Start of program
]]--

local length = readNumber("Length: ", 1)
local width = readNumber("Width: ", 1)
local height = readNumber("Height: ", 1)
local direction = readDirection("Direction (left/right): ")
local verticalDirection = readVerticalDirection("Vertical direction (up/down): ")

length, width, direction = optimizeParameters(length, width, direction)

for currentHeight = 1, height do
    digLayer(width, length, direction)

    if currentHeight ~= height then
        prepareNextLayer(verticalDirection)
    
        if width % 2 == 0 then
            direction = opposite(direction)
        end
    end
end

print("Finished digging!")
