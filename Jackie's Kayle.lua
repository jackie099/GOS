if myHero.charName ~= "Kayle" then return end

require "DamageLib"

-- Spell

local Q = myHero:GetSpellData(_Q);
local W = myHero:GetSpellData(_W);
local E = myHero:GetSpellData(_E);
local R = myHero:GetSpellData(_R);

--Menu

local GameMenu = MenuElement({type = MENU, id = "GameMenu", name = "Jackie's Kayle"})
GameMenu:MenuElement({type = MENU, id = "Settings", name = "Spell Usage"})
GameMenu.Settings:MenuElement({id = "useQ", name = "Use Q in combo", value = true})
GameMenu.Settings:MenuElement({id = "useW", name = "Use W to chase in combo", value = true})
GameMenu.Settings:MenuElement({id = "autoW", name = "Auto W if health is below %", value = 20, min = 0, max = 100, step = 1})
GameMenu.Settings:MenuElement({id = "useE", name = "Use E in combo", value = true})
GameMenu.Settings:MenuElement({id = "autoR", name = "Auto R if health is below %", value = 10, min = 0, max = 100, step = 1})
GameMenu.Settings:MenuElement({id = "autoRA", name = "Auto R on ally if health is below %", value = 10, min = 0, max = 100, step = 1})
GameMenu:MenuElement({type = MENU, id = "ManaManager", name = "Mana Manager"})
GameMenu.ManaManager:MenuElement({id = "saveForE", name = "Always save mana for E", value = true})
--GameMenu.ManaManager:MenuElement({id = "Wmana", name = "Do not Auto W if mana is below %", value = 20, min = 0, max = 100, step = 1})


function manaCalc()
	local ManatoSave =0;
	if GameMenu.ManaManager.saveForE:Value() then
		ManatoSave = E.mana
	end
	return ManatoSave
end

Callback.Add("Tick", function()
--Combo
	--Q 
	if Game.CanUseSpell(_Q) == READY and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and GameMenu.Settings.useQ:Value() and myHero.mana - Q.mana > manaCalc() then
		local t = _G.SDK.TargetSelector:GetTarget(Q.range)
		if t then
			Control.CastSpell(HK_Q,t)
		end
	end
	--W 
	if Game.CanUseSpell(_W) == READY and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and GameMenu.Settings.useW:Value() and myHero.mana - W.mana > manaCalc() then
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


	
--Auto RA
	local enemy = _G.SDK.ObjectManager.GetEnemyHeroes(math.huge)
	local ally = _G.SDK.ObjectManager.GetAllyHeroes(math.huge)
	local dangerousAlly = {}
	if next(ally) ~= nil and next(enemy) ~= nil then
		for k, v in pairs(ally) do
			local danger = false
			for x, y in pairs(enemy) do
				if v.health/v.maxHealth*100 < GameMenu.Settings.autoRA:Value() and not v.isMe and v.pos:DistanceTo(y.pos) < 600 then
					danger = true
					print(v.pos:DistanceTo(y.pos))
				end
			end
			if danger == true and Game.CanUseSpell(_R) == READY and v.pos:DistanceTo(myHero.pos) < R.range then
				Control.CastSpell(HK_R,v)
			end
		end
	end

--Auto W 
	if Game.CanUseSpell(_W) == READY and myHero.health/myHero.maxHealth < GameMenu.Settings.autoW:Value()/100 and myHero.mana > manaCalc() then
		Control.CastSpell(HK_W,myHero)
	end

end)

