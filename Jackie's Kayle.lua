
if myHero.charName ~= "Kayle" then return end

print("Welcome to Jackie's Kayle")



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
GameMenu.Settings:MenuElement({id = "autoWA", name = "Auto W on ally if health is below %", value = 15, min = 0, max = 100, step = 1})
GameMenu.Settings:MenuElement({id = "useE", name = "Use E in combo", value = true})
GameMenu.Settings:MenuElement({id = "autoR", name = "Auto R if health is below %", value = 10, min = 0, max = 100, step = 1})
GameMenu.Settings:MenuElement({id = "autoRA", name = "Auto R on ally if health is below %", value = 5, min = 0, max = 100, step = 1})
GameMenu:MenuElement({type = MENU, id = "ManaManager", name = "Mana Manager"})
GameMenu.ManaManager:MenuElement({id = "saveForE", name = "Always save mana for E", value = true})
GameMenu:MenuElement({type = MENU, id = "ks", name = "Kill Stealing"})
GameMenu.ks:MenuElement({id = "qKS", name = "Kill Steal with Q", value = true})
GameMenu:MenuElement({type = SPACE, id = "ver", name = "v 1.2"})
GameMenu:MenuElement({type = SPACE, id = "about", name = "by Jackie099"})
--GameMenu.ManaManager:MenuElement({id = "Wmana", name = "Do not Auto W if mana is below %", value = 20, min = 0, max = 100, step = 1})




function manaCalc()
	local ManatoSave =0;
	if GameMenu.ManaManager.saveForE:Value() then
		ManatoSave = E.mana
	end
	return ManatoSave
end

function castQ(t)
	DelayAction(function() Control.CastSpell(HK_Q,t) end,0.2)
end

function onRecall()
	for i = 0, myHero.buffCount do
		local buff = myHero:GetBuff(i)
		if buff and buff.name == "recall" and buff.duration > 0 then
			return true
		end
	end
	return false
end

-- Q in combo and harass
_G.SDK.Orbwalker:OnPostAttack(function()
	if Game.CanUseSpell(_Q) == READY and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and GameMenu.Settings.useQ:Value() and myHero.mana - Q.mana > manaCalc() then
		local t = _G.SDK.TargetSelector:GetTarget(Q.range)
		if t then
			castQ(t) 
		end
	end
 end)

Callback.Add("Tick", function()

--Combo

	--Q 
	if Game.CanUseSpell(_Q) == READY and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and GameMenu.Settings.useQ:Value() and myHero.mana - Q.mana > manaCalc() then
		local t = _G.SDK.TargetSelector:GetTarget(Q.range)
		if t and t.distance >= 525 and t.distance <= Q.range then
			
			_G.SDK.Orbwalker:SetMovement(false)
			Control.CastSpell(HK_Q,t)
			_G.SDK.Orbwalker:SetMovement(true)
		end
	end
	
	--W 
	if Game.CanUseSpell(_W) == READY and _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] and GameMenu.Settings.useW:Value() and myHero.mana - W.mana > manaCalc() then
		local t = _G.SDK.TargetSelector:GetTarget(W.range+200)
		if t and t.distance > 300 then
			Control.CastSpell(HK_W,myHero)
		end
	end
	--E 
	if Game.CanUseSpell(_E) == READY and (_G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] or _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_HARASS]) and GameMenu.Settings.useE:Value() then
		local t = _G.SDK.TargetSelector:GetTarget(1000)
		if t and t.distance < 580 then
			Control.CastSpell(HK_E)
		end
	end
--Auto R 
	if Game.CanUseSpell(_R) == READY and myHero.health/myHero.maxHealth < GameMenu.Settings.autoR:Value()/100 then
		Control.CastSpell(HK_R,myHero)
	end


	
--Auto RA
	local enemy = _G.SDK.ObjectManager:GetEnemyHeroes(R.range+600)
	local ally = _G.SDK.ObjectManager:GetAllyHeroes(R.range)
	local dangerousAlly = {}
	if next(ally) ~= nil and next(enemy) ~= nil then
		for k, v in pairs(ally) do
			local danger = false
			for x, y in pairs(enemy) do
				if v.health/v.maxHealth*100 < GameMenu.Settings.autoRA:Value() and not v.isMe and v.pos:DistanceTo(y.pos) < 600 then
					danger = true
				end
			end
			if danger == true and Game.CanUseSpell(_R) == READY and v.pos:DistanceTo(myHero.pos) < R.range then
				Control.CastSpell(HK_R,v)
			end
		end
	end

--Auto Q KS
	if Game.CanUseSpell(_Q) == READY and next(enemy) ~= nil and GameMenu.ks.qKS:Value() then
		for k, v in pairs(enemy) do
			if v.distance <= Q.range and getdmg("Q",v,myHero) >= v.health  then
				castQ(v)
			end
		end
	end

--Auto W Ally
	if Game.CanUseSpell(_W) == READY and next(ally) ~= nil then
		for k, v in pairs(ally) do
			if v.distance <= W.range and v.health/v.maxHealth*100 < GameMenu.Settings.autoWA:Value() and not v.isMe then
				Control.CastSpell(HK_W,v)
			end
		end
	end
	
--Auto W 
	if Game.CanUseSpell(_W) == READY and myHero.health/myHero.maxHealth < GameMenu.Settings.autoW:Value()/100 and myHero.mana > manaCalc() and not onRecall() then
		Control.CastSpell(HK_W,myHero)
	end

end)

Callback.Add("Draw", function()
	if myHero.dead then return end

	Draw.Circle(Vector(myHero.pos),525,1,Draw.Color(189, 183, 107, 255))

end)

