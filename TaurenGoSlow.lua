local addonName = ...

-- Name of the aura to cancel
local AURA_NAME = "Plainsrunning"

-- Whether auto-cancel is on (resets to off each session)
local enabled = false

-- Keybinding labels
BINDING_HEADER_TAURENGOSLOW = "Tauren-Go-Slow"
BINDING_NAME_TAURENGOSLOW_TOGGLE = "Toggle Tauren-Go-Slow"

-- Spell IDs seen with the aura's name (learned at runtime)
local knownSpellIDs = {}

local function canAccess(value)
  return value ~= nil and (not canaccessvalue or canaccessvalue(value))
end

local function aurasSecret()
  return C_Secrets and C_Secrets.ShouldAurasBeSecret and C_Secrets.ShouldAurasBeSecret()
end

local function inCombat()
  return InCombatLockdown() or UnitAffectingCombat("player")
end

local function isTargetAura(aura)
  if not aura then return false end
  local spellID, name = aura.spellId, aura.name
  if canAccess(spellID) and knownSpellIDs[spellID] then return true end
  if canAccess(name) and name == AURA_NAME then
    if canAccess(spellID) then knownSpellIDs[spellID] = true end
    return true
  end
  return false
end

-- Cancel the aura if present. Returns true if it was found.
-- CancelUnitBuff only works out of combat; in combat we wait for
-- PLAYER_REGEN_ENABLED and try again.
local function cancelAura()
  if not enabled or inCombat() or aurasSecret() then return end
  for i = 1, 40 do
    local aura = C_UnitAuras.GetBuffDataByIndex("player", i)
    if not aura then break end
    if isTargetAura(aura) then
      CancelUnitBuff("player", i)
      return true
    end
  end
end

-- Print a chat message prefixed with the addon name in pink
local function say(text)
  print("|cffff69b4Tauren-Go-Slow|r |cffffffff" .. text .. "|r")
end

local function setEnabled(value)
  enabled = value
  say((enabled and "enabled. Plainsrunning aura will be auto-canceled." or "disabled. Enjoy Plainsrunning!"))
  cancelAura()
end

function TaurenGoSlow_Toggle()
  setEnabled(not enabled)
end

SLASH_TAURENGOSLOW1 = "/taurengoslow"
SLASH_TAURENGOSLOW2 = "/tgs"
SlashCmdList.TAURENGOSLOW = function(msg)
  msg = strlower(strtrim(msg or ""))
  if msg == "on" then
    setEnabled(true)
  elseif msg == "off" then
    setEnabled(false)
  elseif msg == "" then
    TaurenGoSlow_Toggle()
  else
    say("usage: /taurengoslow [on||off]")
  end
end

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, arg1, updateInfo)
  if event == "ADDON_LOADED" then
    if arg1 ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")
    self:RegisterUnitEvent("UNIT_AURA", "player")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    setEnabled(false)
  elseif event == "UNIT_AURA" then
    if not enabled then return end
    if not updateInfo or (canAccess(updateInfo.isFullUpdate) and updateInfo.isFullUpdate) then
      cancelAura()
    elseif canAccess(updateInfo.addedAuras) and updateInfo.addedAuras then
      for _, aura in ipairs(updateInfo.addedAuras) do
        if isTargetAura(aura) then
          cancelAura()
          return
        end
      end
    end
  else
    -- PLAYER_REGEN_ENABLED / PLAYER_ENTERING_WORLD: catch anything gained in
    -- combat or before login
    cancelAura()
  end
end)
