if myHero.charName ~= "Kayle" then return end

require "DamageLib"

-- Spell

local Q = myHero:GetSpellData(_Q);
local W = myHero:GetSpellData(_W);
local E = myHero:GetSpellData(_E);
local R = myHero:GetSpellData(_R);

--Menu

local GameMenu = MenuElement({type = MENU, id = "GameMenu", name = "Jackie's Kayle"})
GameMenu:MenuElement({type = MENU, id = "Settings", name = "Spell usage settings"})
GameMenu.Settings:MenuElement({id = "useQ", name = "Use Q in combo", value = true})
GameMenu.Settings:MenuElement({id = "useW", name = "Use W to chase in combo", value = true})
GameMenu.Settings:MenuElement({id = "autoW", name = "Auto W if health is below %", value = 20, min = 0, max = 100, step = 1})
GameMenu.Settings:MenuElement({id = "useE", name = "Use E in combo", value = true})
GameMenu.Settings:MenuElement({id = "autoR", name = "Auto R if health is below %", value = 10, min = 0, max = 100, step = 1})


function ReadyToCast()
end 

Callback.Add("Tick", function()
--Combo
	--Q 
	if Game.CanUseSpell(_Q) == READY and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and GameMenu.Settings.useQ:Value() then
		local t = _G.SDK.TargetSelector:GetTarget(Q.range)
		if t then
			Control.CastSpell(HK_Q,t)
		end
	end
	--W 
	if Game.CanUseSpell(_W) == READY and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and GameMenu.Settings.useW:Value() then
		local t = _G.SDK.TargetSelector:GetTarget(W.range+200)
		if t and t.distance > 525 then
			Control.CastSpell(HK_W,myHero)
		end
	end
	--E 
	if Game.CanUseSpell(_E) == READY and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and GameMenu.Settings.useE:Value() then
		if _G.SDK.TargetSelector:GetTarget(525) then
			Control.CastSpell(HK_E)
		end
	end
--Auto R 
	if Game.CanUseSpell(_R) == READY and myHero.health/myHero.maxHealth < GameMenu.Settings.autoR:Value()/100 then
		Control.CastSpell(HK_R,myHero)
	end
--Auto W 
	if Game.CanUseSpell(_W) == READY and myHero.health/myHero.maxHealth < GameMenu.Settings.autoW:Value()/100 then
		Control.CastSpell(HK_W,myHero)
	end
	
end)

