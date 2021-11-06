FPSCounter = {
    currentIndex = 1,
    dtList = {},
    samples = 0,
    total = 0
}

FPSCounter.new = function(samples)
    local instance = {}
    setmetatable(instance, {__index = FPSCounter})
    instance.samples = samples
    for i = 1, samples do
        --instance.dtList:insert(0)
        table.insert(instance.dtList, 0)
    end
    return instance
end

FPSCounter.update = function(s, dt)
    s.total = s.total - s.dtList[s.currentIndex]
    s.total = s.total + dt
    s.dtList[s.currentIndex] = dt
    if s.currentIndex > 100 then
        s.currentIndex = 1
    end
    return s.total / s.samples
end
