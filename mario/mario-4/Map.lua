--[[
    Contains tile data and necessary code for rendering a tile map to the
    screen.
]]

require 'Util'

Map = Class{}

TILE_BRICK = 31
TILE_EMPTY = -1

-- cloud tiles
CLOUD_LEFT = 17
CLOUD_RIGHT = 18

-- bush tiles
BUSH_LEFT = 3
BUSH_RIGHT = 4

-- mushroom tiles
MUSHROOM_TOP = 4
MUSHROOM_BOTTOM = 5

-- jump block
JUMP_BLOCK = 7

-- a speed to multiply delta time to scroll map; smooth value
local SCROLL_SPEED = 62

-- constructor for our map object
function Map:init()

    self.spritesheets = {
        ['doors_and_windows'] = love.graphics.newImage('graphics/doors_and_windows.png'),
        ['bushes_and_cacti'] = love.graphics.newImage('graphics/bushes_and_cacti.png'),
        ['mushrooms'] = love.graphics.newImage('graphics/mushrooms.png'),
        ['jump_blocks'] = love.graphics.newImage('graphics/jump_blocks.png')
    }
    
    self.spriteLists = {
        ['doors_and_windows'] = generateQuads(self.spritesheets['doors_and_windows'], 16, 16),
        ['bushes_and_cacti'] = generateQuads(self.spritesheets['bushes_and_cacti'], 16, 16),
        ['mushrooms'] = generateQuads(self.spritesheets['mushrooms'], 16, 16),
        ['jump_blocks'] = generateQuads(self.spritesheets['jump_blocks'], 16, 16)
    }

    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 30
    self.mapHeight = 28
    self.tiles = {}

    -- camera offsets
    self.camX = 0
    self.camY = -3

    -- cache width and height of map in pixels
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    -- first, fill map with empty tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            
            -- support for multiple sheets per tile; storing tiles as tables 
            self:setTile(x, y, nil, TILE_EMPTY)
        end
    end

    -- begin generating the terrain using vertical scan lines
    local x = 1
    while x < self.mapWidth do
        
        -- 2% chance to generate a cloud
        -- make sure we're 2 tiles from edge at least
        if x < self.mapWidth - 2 then
            if math.random(20) == 1 then
                
                -- choose a random vertical spot above where blocks/pipes generate
                local cloudStart = math.random(self.mapHeight / 2 - 6)

                self:setTile(x, cloudStart, 'bushes_and_cacti', CLOUD_LEFT)
                self:setTile(x + 1, cloudStart, 'bushes_and_cacti', CLOUD_RIGHT)
            end
        end

        -- 5% chance to generate a mushroom
        if math.random(20) == 1 then
            -- left side of pipe
            self:setTile(x, self.mapHeight / 2 - 2, 'mushrooms', MUSHROOM_TOP)
            self:setTile(x, self.mapHeight / 2 - 1, 'mushrooms', MUSHROOM_BOTTOM)

            -- creates column of tiles going to bottom of map
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, 'doors_and_windows', TILE_BRICK)
            end

            -- next vertical scan line
            x = x + 1

        -- 10% chance to generate bush, being sure to generate away from edge
        elseif math.random(10) == 1 and x < self.mapWidth - 3 then
            local bushLevel = self.mapHeight / 2 - 1

            -- place bush component and then column of bricks
            self:setTile(x, bushLevel, 'bushes_and_cacti', BUSH_LEFT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, 'doors_and_windows', TILE_BRICK)
            end
            x = x + 1

            self:setTile(x, bushLevel, 'bushes_and_cacti', BUSH_RIGHT)
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, 'doors_and_windows', TILE_BRICK)
            end
            x = x + 1

        -- 10% chance to not generate anything, creating a gap
        elseif math.random(10) ~= 1 then
            
            -- creates column of tiles going to bottom of map
            for y = self.mapHeight / 2, self.mapHeight do
                self:setTile(x, y, 'doors_and_windows', TILE_BRICK)
            end

            -- chance to create a block for Mario to hit
            if math.random(15) == 1 then
                self:setTile(x, self.mapHeight / 2 - 4, 'jump_blocks', JUMP_BLOCK)
            end

            -- next vertical scan line
            x = x + 1
        else
            -- increment X so we skip two scanlines, creating a 2-tile gap
            x = x + 2
        end
    end
end

-- function to update camera offset with delta time
function Map:update(dt)
    if love.keyboard.isDown('left') then
        self.camX = math.max(0, self.camX - dt * SCROLL_SPEED)
    elseif love.keyboard.isDown('right') then
        self.camX = math.min(self.camX + dt * SCROLL_SPEED, self.mapWidthPixels - VIRTUAL_WIDTH)
    end

    if love.keyboard.isDown('up') then
        self.camY = math.max(0, self.camY - dt * SCROLL_SPEED)
    elseif love.keyboard.isDown('down') then
        self.camY = math.min(self.camY + dt * SCROLL_SPEED, self.mapHeightPixels - VIRTUAL_HEIGHT)
    end
end

-- returns an integer value for the tile at a given x-y coordinate
function Map:getTile(x, y)
    return self.tiles[(y - 1) * self.mapWidth + x]
end

-- sets a tile at a given x-y coordinate to an integer value
function Map:setTile(x, y, sheet, id)
    self.tiles[(y - 1) * self.mapWidth + x] = {
        x = x, y = y, sheet = sheet, id = id
    }
end

-- renders our map to the screen, to be called by main's render
function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            local tile = self:getTile(x, y)
            if tile.id ~= TILE_EMPTY then
                love.graphics.draw(self.spritesheets[tile.sheet], self.spriteLists[tile.sheet][tile.id],
                    (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
            end
        end
    end
end
