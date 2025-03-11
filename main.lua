HC = require 'HC'

--object creation
Object = {}
Object.__index = Object

function Object:init()
end
--hello

function Object:new(table)
    table = table or {}
    local obj = setmetatable({}, self)

    local tables = GetAllTables(self)
    
    for key, value in pairs(tables) do
        if key and value and key ~= "table" and key ~= "__index" and key ~= "super" then
            -- Copy the table to the child object
            obj[key] = DeepCopy(value)
            print(key)  -- Just to see which key is being copied
        end
    end

    if obj.init then obj:init() end
    if type(table) == "table" then 
        if next(table) then 
            for key, var in pairs(table) do 
                obj[key] = var
            end 
        else
            obj["table"] = table
        end
    end
    return obj
end

function Object:extend()
    local subclass = {} 
    for k, v in pairs(self) do
        if v and k and k ~= "table" and k ~= "__index" and k ~= "super" then
            subclass[k] = DeepCopy(v)
        else
            subclass[k] = v
        end
    end
    subclass.__index = subclass 
    subclass.super = self 
    return subclass
end

function Object:is(class)
    local mt = getmetatable(self) 
    while mt do
        if mt == class then
            return true  
        end
        mt = mt.super
    end
    return false
end

function Object:StoreVars(name, vars, values)
    name = name or nil
    vars = vars or nil
    values = values or nil
    self.vars = self.vars or {}
    self[name] = self[name] or {}
    if name == "" then
        name = "vars"
    end
    if vars then
        if name == "self" then
            if vars then
                if not (type(vars) == "table") then
                    if values then
                        self[vars] = values
                    else
                        self[vars] = nil
                    end
                elseif not (next(vars) == nil) then
                    if values then
                        if #vars == #values then
                            for i = 1, #vars do
                                self[vars[i]] = values[i]
                            end
                        else
                            if values then
                                print("vars and values mismatch, setting values nil")
                            end
                            for i = 1, #vars do
                                self[vars[i]] = nil
                            end
                        end
                    end
                end
            end
        else 
            if not (type(vars) == "table") then
                if values then
                    self[name][vars] = values
                else
                    self[name][vars] = nil
                end
            elseif not (next(vars) == nil) then
                if values then
                    if #vars == #values then
                        for i = 1, #vars do
                            self[name][vars[i]] = values[i]
                        end
                    else
                        if values then
                            print("vars and values mismatch, setting values nil")
                        end
                        for i = 1, #vars do
                            self[name][vars[i]] = nil
                        end
                    end
                end
            end
        end
    end
end

function DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for key, value in next, orig, nil do
            copy[DeepCopy(key)] = DeepCopy(value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function GetAllTables(obj)
    local tables = {}
    local current = obj
    
    while current do
        for key, value in pairs(current) do
            -- Check if the value is a table
            if type(value) == "table" then
                tables[key] = value
            end
        end
        -- Move up to the parent (via metatable)
        current = getmetatable(current)
    end
    
    return tables
end

------------------------------------------------------
--main logic
love.window.setMode(800,800)

Base = Object:extend()

Draw = Base:new()

Mouse = Base:new()


--called upon loading
function love.load()
    local mouseState  = {
        down = false,
        left = false,
        right = false,
        x = nil,
        y = nil
    }

    Base:StoreVars("self", "mouse", mouseState)
    Base:StoreVars("self", "tables", {state = true})

end

--called every frame
function love.draw()
end

function love.update()
    
end

function love.mousepressed(button)
    if button == 1 then
        Base.mouse["down"], Base.mouse["left"],  Base.mouse["x"], Base.mouse["y"] = true, true, love.mouse.getPosition() 
    elseif button == 2 then
        Base.mouse["down"], Base.mouse["right"],  Base.mouse["x"], Base.mouse["y"] = true, true, love.mouse.getPosition() 
    end

end

function love.mousereleased(x, y, button)
    if button == 1 then
        Base.mouse["down"], Base.mouse["left"],  Base.mouse["x"], Base.mouse["y"] = false, false, nil, nil
    elseif button == 2 then
        Base.mouse["down"], Base.mouse["right"],  Base.mouse["x"], Base.mouse["y"] = false, false, nil, nil
    end
end


function Mouse:WhileDown()

    local mouseState = Base.mouse
    local x, y = love.mouse.getPosition()
    
end

function Mouse:Action(right, left, x, y)
    
end

--draw specific methods

function Draw:init() 
    self.loadedImages = {}
    self.canvases = {}
end
function Draw:Clear(canvas)
    love.graphics.setCanvas(self.canvases[canvas])
    love.graphics.clear()
    love.graphics.setCanvas()
end

function Draw:Rgb(r, g, b, a)
    return r/255, g/255, b/255, (a or 255)/255
end

function Draw:DrawImage(canvas, image, x, y, mode)
    x = x or 0
    y = y or 0
    mode = mode or "default"

    love.graphics.setCanvas(self.canvases[canvas])
    local imageX, imageY = self.loadedImages[image]:getDimensions()

    if mode == "default" then 
        love.graphics.draw(self.loadedImages[image], x , y)
    elseif mode == "center" then
        love.graphics.draw(self.loadedImages[image], (x - (imageX / 2)), (y - (imageY / 2)))
    end
    love.graphics.setCanvas()
end

function Draw:StoreImages(image, ext)
    image = image or {}
    self.loadedImages = self.loadedImages or {}
    if image then
        if not (type(image) == "table") then
            self.loadedImages[image] = love.graphics.newImage(image..ext)
        elseif not (next(image) == nil) then
            for _, i in pairs(image) do
                self.loadedImages[i] = love.graphics.newImage(i..ext)
            end
        end
    end
end

function Draw:CreateCanvas(canvas)
    canvas = canvas or {}
    self.canvases = self.canvases or {}
    if canvas then 
        if not (type(canvas) == "table") then
            self.canvases[canvas] = love.graphics.newCanvas()
        elseif not (next(canvas) == nil) then 
            print("table")
            for _, i in pairs(canvas) do
                self.canvases[i] = love.graphics.newCanvas()
            end
        end
    end
end