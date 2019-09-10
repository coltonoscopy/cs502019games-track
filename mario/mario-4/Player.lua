--[[
    Represents our player in the game, with its own sprite.
]]

Player = Class{}

function Player:init(map)
    
    self.x = 0
    self.y = 0
    self.width = 16
    self.height = 20

    -- offset from top left to center to support sprite flipping
    self.xOffset = 8
    self.yOffset = 16

    -- reference to map for checking tiles
    self.map = map
    self.texture = love.graphics.newImage('graphics/blue_alien.png')

    -- animation frames
    self.frames = {}

    -- current animation frame
    self.currentFrame = nil

    -- used to determine behavior and animations
    self.state = 'idle'

    -- determines sprite flipping
    self.direction = 'left'

    -- x and y velocity
    self.dx = 0
    self.dy = 0

    -- position on top of map tiles
    self.y = map.tileHeight * ((map.mapHeight - 2) / 2) - self.height
    self.x = map.tileWidth * 10

    self.frames = {
        -- first frame in the sheet, idle pose
        love.graphics.newQuad(0, 0, 16, 20, self.texture:getDimensions())
    }

    self.currentFrame = self.frames[1]

    -- behavior map we can call based on player state
    self.behaviors = {
        ['idle'] = function(dt)
            
            -- basic sprite flipping example
            if love.keyboard.wasPressed('left') then
                direction = 'left'
            end
            if love.keyboard.wasPressed('right') then
                direction = 'right'
            end
        end
    }
end

function Player:update(dt)
    self.behaviors[self.state](dt)
end

function Player:render()
    local scaleX

    -- set negative x scale factor if facing left, which will flip the sprite
    -- when applied
    if self.direction == 'right' then
        scaleX = 1
    else
        scaleX = -1
    end

    -- draw sprite with scale factor and offsets
    love.graphics.draw(self.texture, self.currentFrame, self.x + self.xOffset,
        self.y + self.yOffset, 0, scaleX, 1, self.xOffset, self.yOffset)
end
