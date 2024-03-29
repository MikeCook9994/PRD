local PRD = PRD

function PRD:InitializeCache(configuration, runeIndex)
    local cache = {
        powerType = 0,
        currentPower = 0,
        maxPower = 0
    }

    if runeIndex then
        cache.runeIndex = runeIndex
    end

    cache.powerType = (type(configuration.powerType) == "function" and select(2, configuration.powerType(cache, "INITIAL"))) or configuration.powerType
    cache.currentPower = select(2, configuration.currentPower(cache, "INITIAL"))
    cache.maxPower = (type(configuration.maxPower) == "function" and select(2, configuration.maxPower(cache, "INITIAL"))) or configuration.maxPower
    return cache
end

function PRD:InitializeBarContainer(barPriority, parent, width, height, isShown, xOffset, yOffset)
    local frameName = "prd_" .. barPriority .. "_bar_container"
    local barContainer = _G[frameName] or CreateFrame("Frame", frameName, parent)

    barContainer:SetParent(parent)
    barContainer:SetWidth(width)
    barContainer:SetHeight(height)
    barContainer:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", xOffset, yOffset)

    if isShown then
        barContainer:Show()
    else
        barContainer:Hide()
    end

    return barContainer
end

function PRD:InitializeStatusBar(barPriority, parent, width, height, frameStrata, texture, color, resourceRatio, isShown)
    local frameName = "prd_" .. barPriority
    local statusBar = _G[frameName] or CreateFrame("StatusBar", frameName, parent)
    
    statusBar:SetParent(parent)
    statusBar:SetWidth(width)
    statusBar:SetHeight(height)
    statusBar:SetMinMaxValues(0, 1)
    statusBar:SetValue(resourceRatio)
    statusBar:SetPoint("CENTER", parent, "CENTER", 0, 0)
    statusBar:SetFrameStrata(frameStrata)
    statusBar:SetStatusBarTexture(texture)
    statusBar:SetStatusBarColor(color.r, color.g, color.b, 1.0)

    if isShown then
        statusBar:Show()
    else
        statusBar:Hide()
    end

    return statusBar
end

function PRD:InitializeBackground(barPriority, parent, width, height)
    local frameName = "prd_" .. barPriority .. "_background_bar"
    local backgroundFrame =  _G[frameName] or CreateFrame("Frame", frameName, parent)
    
    backgroundFrame:SetParent(parent)
    backgroundFrame:SetWidth(width)
    backgroundFrame:SetHeight(height)
    backgroundFrame:SetPoint("CENTER", parent, "CENTER", 0, 0)
    backgroundFrame:SetFrameStrata("BACKGROUND")
    backgroundFrame:Show()
    
    backgroundFrame.texture = _G[frameName .. "_texture"] or backgroundFrame:CreateTexture(frameName .. "_texture")
    backgroundFrame.texture:SetAllPoints(backgroundFrame)
    backgroundFrame.texture:SetColorTexture(0.0, 0.0, 0.0, 1.0)

    return backgroundFrame
end

function PRD:InitializeText(barPriority, parent, width, height, font, size, flags, xOffset, yOffset, value, color, isShown)
    local frameName = "prd_" .. barPriority .. "_text_container"
    local textContainer = _G[frameName] or CreateFrame("Frame", frameName, parent)

    textContainer:SetParent(parent)
    textContainer:SetFrameStrata("DIALOG")
    textContainer:SetWidth(width)
    textContainer:SetHeight(height)
    textContainer:SetPoint("CENTER", parent, "CENTER", 0, 0)
    textContainer:Show()

    if isShown then
        textContainer:Show()
    else
        textContainer:Hide()
    end
    
    local textFrameName = "prd_" .. barPriority .. "_text"
    local textFrame = _G[textFrameName] or textContainer:CreateFontString(textFrameName)
    textContainer.text = textFrame

    textFrame:SetParent(textContainer)
    textFrame:SetFont(font, size, flags)
    textFrame:SetTextColor(color.r, color.g, color.b, 1.0)
    textFrame:SetPoint("CENTER", textContainer, "CENTER", xOffset, yOffset)
    textFrame:SetText(value)
    textFrame:Show()
    return textContainer
end

function PRD:InitializeTickMarkContainer(barPriority, parent, width, height, isShown, yOffset)
    local frameName = "prd_" .. barPriority .. "_tick_mark_container"
    local tickMarkContainer = _G[frameName] or CreateFrame("Frame", frameName, parent)

    tickMarkContainer:SetParent(parent)
    tickMarkContainer:SetWidth(width)
    tickMarkContainer:SetHeight(height)
    tickMarkContainer:SetPoint("LEFT", parent, "LEFT", 0, 0)
    tickMarkContainer:SetFrameStrata("HIGH")
    
    if isShown then
        tickMarkContainer:Show()
    else
        tickMarkContainer:Hide()
    end

    return tickMarkContainer
end

function PRD:InitializeTickMark(barPriority, tickId, parent, tickWidth, texture, color, resourceRatio, isShown)
    local frameName = "prd_" .. barPriority .. "_tick_mark_" .. tickId
    local tickFrame = _G[frameName] or CreateFrame("Frame", frameName, parent)
    
    tickFrame:SetParent(parent)
    tickFrame:SetWidth(tickWidth)
    tickFrame:SetHeight(parent:GetHeight())
    tickFrame:SetPoint("CENTER", parent, "LEFT", resourceRatio * parent:GetWidth(), 0)
    tickFrame:SetFrameStrata("HIGH")
    
    tickFrame.texture = _G[frameName .. "_texture"] or tickFrame:CreateTexture(frameName .. "_texture")
    tickFrame.texture:SetAllPoints(tickFrame)
    tickFrame.texture:SetTexture(texture)
    tickFrame.texture:SetVertexColor(color.r, color.g, color.b, 1.0)

    if isShown then
        tickFrame:Show()
    else
        tickFrame:Hide()
    end

    return tickFrame
end

function PRD:InitializeProgressBar(barPriority, specBarConfig, processedWeight, totalWeight)
    PRD.bars[barPriority] = {}

    local container = PRD.container
    local cache = PRD:InitializeCache(specBarConfig)
    local height = PRD.height * (specBarConfig.heightWeight / totalWeight)
    local width = PRD.width

    local isShown = specBarConfig.enabled
    if type(specBarConfig.enabled) == "function" then
        isShown = select(2, specBarConfig.enabled(cache, "INITIAL"))
    end

    local yOffset = PRD.height * (processedWeight / totalWeight)

    local barContainer = PRD:InitializeBarContainer(barPriority, container, width, height, isShown, 0, yOffset)
    barContainer.cache = cache
    PRD.bars[barPriority][barContainer:GetName()] = barContainer

    -- initialize status bar
    local statusBarColor = type(specBarConfig.color) == "function" and select(2, specBarConfig.color(cache, "INITIAL")) or specBarConfig.color
    local statusBar = PRD:InitializeStatusBar(barPriority .. "_main_bar", barContainer, width, height, "MEDIUM", specBarConfig.texture, statusBarColor, cache.currentPower / cache.maxPower, true)
    statusBar.cache = cache
    PRD.bars[barPriority][statusBar:GetName()] = statusBar

    local backgroundBar = PRD:InitializeBackground(barPriority, barContainer, width, height)
    PRD.bars[barPriority][backgroundBar:GetName()] = backgroundBar

    local predictionBar = specBarConfig.prediction
    if predictionBar.enabled ~= false then
        local isShown = true
        if type(predictionBar.enabled) == "function" then
            isShown = select(2, predictionBar.enabled(cache, "INITIAL"))
        end

        local predictionBarResourceRatio = select(2, predictionBar.next(cache, "INITIAL")) / cache.maxPower
        local predictionBarColor = type(predictionBar.color) == "function" and select(2, predictionBar.color(cache, "INITIAL")) or predictionBar.color
        local predictionBar = PRD:InitializeStatusBar(barPriority .. "_prediction_bar", barContainer, width, height, "LOW", specBarConfig.texture, predictionBarColor, predictionBarResourceRatio, isShown)
        predictionBar:SetAlpha(0.75)
        predictionBar.cache = cache
        PRD.bars[barPriority][predictionBar:GetName()] = predictionBar
    end

    local text = specBarConfig.text

    if text.enabled ~= false then
        local isShown = text.enabled
        if type(text.enabled) == "function" then
            isShown = select(2, text.enabled(cache, "INITIAL"))
        end

        local value = select(2, text.value(cache, "INITIAL"))
        local textColor = type(text.color) == "function" and select(2, text.color(cache, "INITIAL")) or text.color
        local textFrame = PRD:InitializeText(barPriority, barContainer, width, height, text.font, text.size, text.flags, text.xOffset, text.yOffset, value, textColor, isShown)
        textFrame.cache = cache
        PRD.bars[barPriority][textFrame:GetName()] = textFrame
    end

    if specBarConfig.tickMarks.enabled ~= false then
        local isShown = specBarConfig.tickMarks.enabled
        if type(specBarConfig.tickMarks.enabled) == "function" then
            isShown = select(2, specBarConfig.tickMarks.enabled(cache, "INITIAL"))
        end

        local tickMarkContainer = PRD:InitializeTickMarkContainer(barPriority, barContainer, width, height, isShown)
        tickMarkContainer.barPriority = barPriority
        tickMarkContainer.cache = cache
        PRD.bars[barPriority][tickMarkContainer:GetName()] = tickMarkContainer
        
        local texture = specBarConfig.tickMarks.texture
        local tickMarks = (type(specBarConfig.tickMarks.offsets) == "function" and PRD:NormalizeTickMarkOffsets(select(2, specBarConfig.tickMarks.offsets(cache, "INITIAL")), specBarConfig.tickMarks.color)) or specBarConfig.tickMarks.offsets

        for tickId, tickConfig in pairs(tickMarks) do
            if tickConfig.enabled ~= false then
                local isShown = tickConfig.enabled
                if type(tickConfig.enabled) == "function" then
                    isShown = select(2, tickConfig.enabled(cache, "INITIAL"))
                end

                local color = (tickConfig.color ~= nil and ((type(tickConfig.color) == "function" and tickConfig.color(cache, "INITIAL")) or tickConfig.color)) or ((type(specBarConfig.tickMarks.color) == "function" and specBarConfig.tickMarks.color(cache, "INITIAL")) or specBarConfig.tickMarks.color)
                local resourceRatio = (((type(tickConfig.resourceValue) == "function" and select(2, tickConfig.resourceValue(cache, "INITIAL"))) or tickConfig.resourceValue) / cache.maxPower)

                local tickMark = PRD:InitializeTickMark(barPriority, tickId, tickMarkContainer, specBarConfig.tickMarks.width, texture, color, resourceRatio, isShown)
                tickMark.cache = cache
                PRD.bars[barPriority][tickMark:GetName()] = tickMark
            end
        end
    end
end

function PRD:InitializeRuneProgressBar(barPriority, specBarConfig, runeIndex, processedWeight, totalWeight)
    if PRD.bars[barPriority] == nil then 
        PRD.bars[barPriority] = {}
    end

    PRD.bars[barPriority][runeIndex] = {}

    local container = PRD.container
    local cache = PRD:InitializeCache(specBarConfig, runeIndex)

    local height = PRD.height * (specBarConfig.heightWeight / totalWeight)
    local width = PRD.width / 6

    local isShown = specBarConfig.enabled
    if type(specBarConfig.enabled) == "function" then
        isShown = select(2, specBarConfig.enabled(cache, "INITIAL"))
    end

    local xOffset = (runeIndex - 1) * width
    local yOffset = PRD.height * (processedWeight / totalWeight)

    local barContainer = PRD:InitializeBarContainer(barPriority .. "_" .. runeIndex, container, width, height, isShown, xOffset, yOffset)
    barContainer.cache = cache
    PRD.bars[barPriority][runeIndex][barContainer:GetName()] = barContainer

    -- initialize status bar
    local statusBarColor = type(specBarConfig.color) == "function" and select(2, specBarConfig.color(cache, "INITIAL")) or specBarConfig.color
    local statusBar = PRD:InitializeStatusBar(barPriority .. "_" .. runeIndex .. "_main_bar", barContainer, width, height, "MEDIUM", specBarConfig.texture, statusBarColor, cache.currentPower / cache.maxPower, true)
    statusBar.cache = cache
    PRD.bars[barPriority][runeIndex][statusBar:GetName()] = statusBar

    local backgroundBar = PRD:InitializeBackground(barPriority .. "_" .. runeIndex, barContainer, width, height)
    PRD.bars[barPriority][runeIndex][backgroundBar:GetName()] = backgroundBar


    local text = specBarConfig.text

    if text.enabled ~= false then
        local isShown = text.enabled
        if type(text.enabled) == "function" then
            isShown = select(2, text.enabled(cache, "INITIAL"))
        end

        local value = select(2, text.value(cache, "INITIAL"))
        local textColor = type(text.color) == "function" and select(2, text.color(cache, "INITIAL")) or text.color
        local textFrame = PRD:InitializeText(barPriority .. "_" .. runeIndex, barContainer, width, height, text.font, text.size, text.flags, text.xOffset, text.yOffset, value, textColor, isShown)
        textFrame.cache = cache
        PRD.bars[barPriority][runeIndex][textFrame:GetName()] = textFrame
    end

    local tickMarkContainer = PRD:InitializeTickMarkContainer(barPriority .. "_" .. runeIndex, barContainer, width, height, isShown)
    tickMarkContainer.barPriority = barPriority
    tickMarkContainer.cache = cache
    PRD.bars[barPriority][runeIndex][tickMarkContainer:GetName()] = tickMarkContainer
    
    local texture = specBarConfig.tickMarks.texture
    local color = (type(specBarConfig.tickMarks.color) == "function" and specBarConfig.tickMarks.color(cache, "INITIAL")) or specBarConfig.tickMarks.color
    
    local tickMark = PRD:InitializeTickMark(barPriority .. "_" .. runeIndex, "marker", tickMarkContainer, specBarConfig.tickMarks.width, texture, color, 1, runeIndex ~= 6)
    tickMark.cache = cache
    PRD.bars[barPriority][runeIndex][tickMark:GetName()] = tickMark
end

function PRD:BuildEventAndDependencyConfigs(events, dependencies, frame, property, eventHandler, updater, barPriority, runeIndex)
    if events ~= nil then
        frame:SetScript("OnEvent", function(self, event, ...)
            if self.eventHandlers[event] == nil then return end
            
            if event == "COMBAT_LOG_EVENT_UNFILTERED" then
                PRD:HandleEvent(self.eventHandlers[event], event, CombatLogGetCurrentEventInfo()) 
            end

            PRD:HandleEvent(self.eventHandlers[event], event, ...)
        end)

        if frame.eventHandlers == nil then frame.eventHandlers = {} end

        for _, event in ipairs(events) do
            if not frame:IsEventRegistered(event) then
                frame:RegisterEvent(event)
            end

            if frame.eventHandlers[event] == nil then
                frame.eventHandlers[event] = {}
            end

            table.insert(frame.eventHandlers[event], {
                property = property,
                eventHandler = eventHandler, 
                updater = updater,
                self = frame
            })
        end
    end 

    if dependencies ~= nil then 
        local bar = PRD.bars[barPriority]
        local barId = barPriority
        if runeIndex then
            bar = PRD.bars[barPriority][runeIndex]
            barId = barPriority .. "_" .. runeIndex
        end

        local mainBarFrame = bar["prd_" .. barId .. "_main_bar"]

        local sourceFrameMap = {
            powerType = mainBarFrame,
            currentPower = mainBarFrame,
            maxPower = mainBarFrame,
            enabled = bar["prd_" .. barId .. "_bar_container"],
            next = bar["prd_" .. barId .. "_prediction_bar"]
        }
    
        for _, dependency in ipairs(dependencies) do
            local targetFrame = sourceFrameMap[dependency]
    
            if targetFrame.dependencyHandlers == nil then targetFrame.dependencyHandlers = {} end
    
            if targetFrame.dependencyHandlers[dependency] == nil then
                targetFrame.dependencyHandlers[dependency] = {}
            end
    
            table.insert(targetFrame.dependencyHandlers[dependency], {
                property = property,
                eventHandler = eventHandler, 
                updater = updater,
                self = frame
            })
        end
    end 
end

function PRD:GatherEventAndDependencyHandlers(barPriority, barConfig, runeIndex)
    local bar = PRD.bars[barPriority]
    local barId = barPriority
    if runeIndex then
        bar = PRD.bars[barPriority][runeIndex]
        barId = barPriority .. "_" .. runeIndex
    end

    local mainStatusBarFrame = bar["prd_" .. barId .. "_main_bar"]
    local mainBarContainer = bar["prd_" .. barId .. "_bar_container"]
    local predictionBarFrame = bar["prd_" .. barId .. "_prediction_bar"]
    local textContainerFrame = bar["prd_" .. barId .. "_text_container"]
    local tickMarkOffsetsFrame = bar["prd_" .. barId .. "_tick_mark_container"]

    -- Main
    if type(barConfig.enabled) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.enabled_events, barConfig.enabled_dependencies, mainBarContainer, 'enabled', barConfig.enabled, PRD.RefreshEnabled, barPriority, runeIndex)
    end

    if type(barConfig.powerType) == "function" then
        -- power type will never have dependencies
        PRD:BuildEventAndDependencyConfigs(barConfig.powerType_events, barConfig.powerType_dependencies, mainStatusBarFrame, 'powerType', barConfig.powerType, PRD.RefreshPowerType, barPriority, runeIndex)
    end

    if type(barConfig.currentPower) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.currentPower_events, barConfig.currentPower_dependencies, mainStatusBarFrame, 'currentPower', barConfig.currentPower, PRD.RefreshCurrentPowerValue, barPriority, runeIndex)
    end

    if type(barConfig.maxPower) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.maxPower_events, barConfig.maxPower_dependencies, mainStatusBarFrame, 'maxPower', barConfig.maxPower, PRD.RefreshMaxPowerValue, barPriority, runeIndex)
    end

    if type(barConfig.color) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.color_events, barConfig.color_dependencies, mainStatusBarFrame, 'mainColor', barConfig.color, PRD.RefreshBarColor, barPriority, runeIndex)
    end

    -- prediction
    if type(barConfig.prediction.enabled) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.prediction.enabled_events, barConfig.prediction.enabled_dependencies, predictionBarFrame, 'predictionEnabled', barConfig.prediction.enabled, PRD.RefreshEnabled, barPriority, runeIndex)
    end

    if type(barConfig.prediction.color) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.prediction.color_events, barConfig.prediction.color_dependencies, predictionBarFrame, 'predictionColor', barConfig.prediction.color, PRD.RefreshBarColor, barPriority, runeIndex)
    end

    if type(barConfig.prediction.next) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.prediction.next_events, barConfig.prediction.next_dependencies, predictionBarFrame, 'next', barConfig.prediction.next, PRD.RefreshCurrentPowerValue, barPriority, runeIndex)
    end

    -- text
    if type(barConfig.text.enabled) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.text.enabled_events, barConfig.text.enabled_dependencies, textContainerFrame, 'textEnabled', barConfig.text.enabled, PRD.RefreshEnabled, barPriority, runeIndex)
    end

    if type(barConfig.text.value) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.text.value_events, barConfig.text.value_dependencies, textContainerFrame, 'textValue', barConfig.text.value, PRD.RefreshText, barPriority, runeIndex)
    end

    if type(barConfig.text.color) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.text.color_events, barConfig.text.color_dependencies, textContainerFrame, 'textColor', barConfig.text.color, PRD.RefreshTextColor, barPriority, runeIndex)
    end

    -- generic tick mark
    if type(barConfig.tickMarks.enabled) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.tickMarks.enabled_events, barConfig.tickMarks.enabled_dependencies, tickMarkOffsetsFrame, 'tickMarksEnabled', barConfig.tickMarks.enabled, PRD.RefreshEnabled, barPriority, runeIndex)
    end

    if type(barConfig.tickMarks.color) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.tickMarks.color_events, barConfig.tickMarks.color_dependencies, tickMarkOffsetsFrame, 'tickMarksColor', barConfig.tickMarks.color, PRD.RefreshTickMarksColor, barPriority, runeIndex)
    end

    if type(barConfig.tickMarks.offsets) == "function" then
        PRD:BuildEventAndDependencyConfigs(barConfig.tickMarks.offsets_events, barConfig.tickMarks.offsets_dependencies, tickMarkOffsetsFrame, 'tickMarksOffsets', barConfig.tickMarks.offsets, PRD.RefreshTickMarkOffsets, barPriority, runeIndex)
    elseif type(barConfig.tickMarks.offsets) == "table" then
        for tickId, tickConfig in pairs(barConfig.tickMarks.offsets) do
            local tickMarkFrame = PRD.bars[barPriority]["prd_" .. barPriority .. "_tick_mark_" .. tickId]

            -- all tick marks have a dependency on maxPower even if they are a static value
            PRD:BuildEventAndDependencyConfigs(tickConfig.resourceValue_events, tickConfig.resourceValue_dependencies, tickMarkFrame, tickId .. "ResourceValue", tickConfig.resourceValue, PRD.RefreshTickMarkXOffset, barPriority, runeIndex)

            -- individual tick marks
            if type(tickConfig.enabled) == "function" then
                PRD:BuildEventAndDependencyConfigs(tickConfig.enabled_events, tickConfig.enabled_dependencies, tickMarkFrame, tickId .. "Enabled", tickConfig.enabled, PRD.RefreshEnabled, barPriority, runeIndex)
            end

            if type(tickConfig.color) == "function" then
                PRD:BuildEventAndDependencyConfigs(tickConfig.color_events, tickConfig.color_dependencies, tickMarkFrame, tickId .. "Color", tickConfig.color, PRD.RefreshTickMarkColor, barPriority, runeIndex)
            end
        end
    end
end

function PRD:InitializePersonalResourceDisplay()
    local config = PRD:GetConfiguration()
    local totalWeight = 0
    local barPriorities = {}
    
    for barPriority, progressBarConfig in pairs(config) do
        table.insert(barPriorities, barPriority)
        if type(progressBarConfig.enabled) == "function" or progressBarConfig.enabled then
            totalWeight = totalWeight + progressBarConfig.heightWeight
        end
    end

    table.sort(barPriorities)

    local processedWeight = 0
    for _, progressBarPriority in ipairs(barPriorities) do
        local progressBarConfig = config[progressBarPriority]

        if type(progressBarConfig.enabled) == "function" or progressBarConfig.enabled then
            if progressBarConfig.powerType == Enum.PowerType.Runes then
                for runeIndex=1, 6 do
                    PRD:InitializeRuneProgressBar(progressBarPriority, progressBarConfig, runeIndex, processedWeight, totalWeight)
                    PRD:GatherEventAndDependencyHandlers(progressBarPriority, progressBarConfig, runeIndex)
                end
            else
                PRD:InitializeProgressBar(progressBarPriority, progressBarConfig, processedWeight, totalWeight)
                PRD:GatherEventAndDependencyHandlers(progressBarPriority, progressBarConfig)
            end

            processedWeight = processedWeight + progressBarConfig.heightWeight

            PRD:HandleCombatStateChangeEvent(UnitAffectingCombat("player") and "PLAYER_REGEN_DISABLED" or "PLAYER_REGEN_ENABLED" )
        end
    end
end
