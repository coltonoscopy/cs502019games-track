--[[
    Contains tile data and necessary code for rendering a tile map to the
    screen.
]]

require 'Util'

Map = Class{}

TILE_BRICK = 1
TILE_EMPTY = -1

-- a speed to multiply delta time to scroll map; smooth value
local SCROLL_SPEED = 62

-- constructor for our map object
function Map:init()

    self.spritesheet = love.graphics.newImage('graphics/spritesheet.png')
    self.tileWidth = 16
    self.tileHeight = 16
    self.mapWidth = 30
    self.mapHeight = 28
    self.tiles = {}

    -- camera offsets
    self.camX = 0
    self.camY = -3

    -- generate a quad (individual frame/sprite) for each tile
    self.tileSprites = generateQuads(self.spritesheet, 16, 16)

    -- cache width and height of map in pixels
    self.mapWidthPixels = self.mapWidth * self.tileWidth
    self.mapHeightPixels = self.mapHeight * self.tileHeight

    -- first, fill map with empty tiles
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_EMPTY)
        end
    end

    -- fill bottom half of map with tiles
    for y = self.mapHeight / 2, self.mapHeight do
        for x = 1, self.mapWidth do
            self:setTile(x, y, TILE_BRICK)
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
function Map:setTile(x, y, tile)
    self.tiles[(y - 1) * self.mapWidth + x] = tile
end

-- renders our map to the screen, to be called by main's render
function Map:render()
    for y = 1, self.mapHeight do
        for x = 1, self.mapWidth do
            if self:getTile(x, y) ~= TILE_EMPTY then
                love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)],
                    (x - 1) * self.tileWidth, (y - 1) * self.tileHeight)
            end
        end
    end
end
