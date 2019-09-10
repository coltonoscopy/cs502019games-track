--[[
    Holds a collection of frames that switch depending on how much time has
    passed.
]]

Animation = Class{}

function Animation:init(params)

    self.texture = params.texture

    -- quads defining this animation
    self.frames = params.frames or {}

    -- time in seconds each frame takes (1/20 by default)
    self.interval = params.interval or 0.05

    -- stores amount of time that has elapsed
    self.timer = 0

    self.currentFrame = 1
end

function Animation:getCurrentFrame()
    return self.frames[self.currentFrame]
end

function Animation:restart()
    self.timer = 0
    self.currentFrame = 1
end

function Animation:update(dt)
    self.timer = self.timer + dt

    -- iteratively subtract interval from timer to proceed in the animation,
    -- in case we skipped more than one frame
    while self.timer > self.interval do
        self.timer = self.timer - self.interval
        self.currentFrame = (self.currentFrame + 1) % #self.frames
        if self.currentFrame == 0 then self.currentFrame = 1 end
    end
end
