PRD.configurations.warrior = {
    primary = {
        tickMarks = {
            offsets = {
                fury_rampage = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED" },
                    enabled = function(cache, event, ...)
                        return true, select(1, GetSpecializationInfo(GetSpecialization())) == 72
                    end,
                    resourceValue_events = { "PLAYER_TALENT_UPDATE" },
                    resourceValue = function(cache, event, ...) 
                        return true, (select(4, GetTalentInfo(5, 1, 1)) and 75) or (select(4, GetTalentInfo(5, 3, 1)) and 95) or 85
                    end
                },
                arms_slam = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED" },
                    enabled = function(cache, event, ...)
                        return true, select(1, GetSpecializationInfo(GetSpecialization())) == 71
                    end,
                    resourceValue = 20
                },
                arms_mortal_strike = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED" },
                    enabled = function(cache, event, ...)
                        return true, select(1, GetSpecializationInfo(GetSpecialization())) == 71
                    end,
                    resourceValue = 30
                },
                arms_execute = {
                    enabled_events = { "PLAYER_SPECIALIZATION_CHANGED" },
                    enabled = function(cache, event, ...)
                        return true, select(1, GetSpecializationInfo(GetSpecialization())) == 71
                    end,
                    resourceValue = 40
                }
            }
        },
        text = {
            enabled_dependencies = { "currentPower" },
            enabled = function(cache, event, ...)
                return true, cache.currentPower > 0 or UnitAffectingCombat("player")
            end
        }
    },
    bottom = {
        currentPower_events = { "UNIT_HEALTH" },
        currentPower = function(cache, event, ...) 
            if event == "UNIT_HEALTH" and select(1, ...) ~= "player" then
                return false
            end

            cache.currentPower = UnitHealth("player")

            return true, cache.currentPower
        end,
        maxPower_events = { "UNIT_MAXHEALTH" },
        maxPower = function(cache, event, ...) 
            if event == "UNIT_MAXHEALTH" and select(1, ...) ~= "player" then
                return false
            end

            cache.maxPower = UnitHealthMax("player")

            return true, cache.maxPower
        end,
        texture = "Interface\\Addons\\SharedMedia\\statusbar\\Cloud",
        text = {
            value_dependencies = { "currentPower", "maxPower" },
            value = function(cache, event, ...)
                return true, string.format("%.0f%%", (cache.currentPower / cache.maxPower) * 100)
            end,
            xOffset = 100,
            yOffset = 5,
            size = 15
        },
        color_dependencies = { "currentPower", "maxPower" },
        color = function(cache, event, ...)
            local healthRatio = cache.currentPower / cache.maxPower
            return true, { r = 1.0 - healthRatio, g = healthRatio, b = 0.0 }
        end
    }
}