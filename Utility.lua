local PRD = PRD
local UnitAura = UnitAura

function PRD:GetPlayerAura(unitspell, filter)
  if filter and not filter:upper():find("FUL") then
      filter = filter.."|HELPFUL"
  end
  for i = 1, 255 do
    local name, _, _, _, _, _, _, _, _, spellId = UnitAura("player", i, filter)
    if not name then return end
    if spell == spellId or spell == name then
      return UnitAura("player", i, filter)
    end
  end
end

function PRD:GetPlayerBuff(spell, filter)
  filter = filter and filter.."|HELPFUL" or "HELPFUL"
  return PRD:GetUnitAura(spell, filter)
end

function PRD:GetPlayerDebuff(spell, filter)
  filter = filter and filter.."|HARMFUL" or "HARMFUL"
  return PRD:GetUnitAura(spell, filter)
end

function PRD:ConvertPowerTypeStringToEnumValue(powerType)
  return Enum.PowerType[((" " .. string.lower(powerType)):gsub("%W%l", string.upper):sub(2)):gsub("_", "")]
end

function PRD:DebugPrint(strName, data) 
  if ViragDevTool.AddData and PRD.debugEnabled then 
      ViragDevTool:AddData(data, strName)
  end 
end

function PRD:ArrayRemove(t, fnKeep)
  local j, n = 1, #t;

  for i=1,n do
      if (fnKeep(t, i)) then
          -- Move i's kept value to j's position, if it's not already there.
          if (i ~= j) then
              t[j] = t[i];
              t[i] = nil;
          end
          j = j + 1; -- Increment position of where we'll place the next kept value.
      else
          t[i] = nil;
      end
  end

  return t;
end