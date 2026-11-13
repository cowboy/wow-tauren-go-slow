std = "lua51"
max_line_length = false
exclude_files = { ".luacheckrc" }

-- Globals this addon defines
globals = {
  "BINDING_HEADER_TAURENGOSLOW",
  "BINDING_NAME_TAURENGOSLOW_TOGGLE",
  "SLASH_TAURENGOSLOW1",
  "SLASH_TAURENGOSLOW2",
  "SlashCmdList",
  "TaurenGoSlow_Toggle",
}

-- WoW API globals this addon reads
read_globals = {
  "C_Secrets",
  "C_UnitAuras",
  "CancelUnitBuff",
  "CreateFrame",
  "InCombatLockdown",
  "UnitAffectingCombat",
  "canaccessvalue",
  "strlower",
  "strtrim",
}
