PRD.configurations.mage_frost = {
    primary = {
        currentPower_events = { "UNIT_AURA" },
        currentPower = function(cache, event, ...)
            if event == "UNIT_AURA" and select(1, ...) ~= "player" then  
                return false
            end

            local name, _, count, _, duration, expirationTime = PRD:GetUnitBuff("player", 205473)
        
            if name == nil then
                cache.currentPower = 0
                return true, 0, false
            end

            cache.currentPower = count

            return true, cache.currentPower
        end,
        maxPower = 5,
        color = { r = 0.0, g = 0.75, b = 1.0 },
        tickMarks = {
            offsets = { 1, 2, 3, 4 }
        }
    },
    bottom = {
        powerType = Enum.PowerType.Mana,
        tickMarks = {
            color = { r = 0.5, g = 0.5, b = 0.5 },
            offsets = function(cache, event, ...)
                local resourceValues = {}
                
                local healingSpellCost = GetSpellPowerCost(30449)[1].cost
                local currentMaxTick = 0
                
                while currentMaxTick + healingSpellCost < cache.maxPower do
                    currentMaxTick = currentMaxTick + healingSpellCost
                    table.insert(resourceValues, currentMaxTick)
                end
                
                return true, resourceValues
            end
        },
        text = {
            value_dependencies = { "currentPower", "maxPower" },
            value = function(cache, event, ...)
                local castCost = GetSpellPowerCost(30449)[1].cost
                return true, math.floor(cache.currentPower / castCost)
            end,
            xOffset = -65,
            yOffset = 3,
            size = 8
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local r, g, b = GetClassColor("MAGE")
            local percent = cache.currentPower / cache.maxPower
            return true, { r = r * (1 - percent), g = g, b = b * percent }
        end
    }
}