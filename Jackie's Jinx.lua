
if myHero.charName ~= "Jinx" then return end

print("Welcome to Jackie's Jinx")



require "DamageLib"
require "Collision"

-- Spell

local Q = myHero:GetSpellData(_Q);
--local W = myHero:GetSpellData(_W);
local W = {range = 1500, delay = 600, minionCollisionWidth = 60, speed = 3300}
local E = myHero:GetSpellData(_E);
local R = myHero:GetSpellData(_R);


--Menu

local GameMenu = MenuElement({type = MENU, id = "GameMenu", name = "Jackie's Jinx"})
GameMenu:MenuElement({type = MENU, id = "Settings", name = "Spell Usage"})
GameMenu.Settings:MenuElement({id = "autoQ", name = "Auto Q switch", value = true})
GameMenu.Settings:MenuElement({id = "useW", name = "Use W in combo", value = true})
GameMenu.Settings:MenuElement({id = "autoE", name = "Auto E on CCed enemy", value = true})
GameMenu:MenuElement({type = MENU, id = "ManaManager", name = "Mana Manager"})
GameMenu.ManaManager:MenuElement({id = "Wmana", name = "Do not use W if mana is below %", value = 20, min = 0, max = 100, step = 1})
GameMenu:MenuElement({type = MENU, id = "ks", name = "Kill Stealing"})
--GameMenu.ks:MenuElement({id = "wKS", name = "Kill Steal with W", value = true})
GameMenu:MenuElement({type = SPACE, id = "ver", name = "v 1.0"})
GameMenu:MenuElement({type = SPACE, id = "about", name = "by Jackie099"})


function QOn()
	-- On == 2, Off ==1
	return myHero:GetSpellData(_Q).toggleState
end

function calcRange()
	local qlv = myHero:GetSpellData(_Q).level
	return qlv*25 + 525 + myHero.boundingRadius + 50
end

function dCast(k,t)
	DelayAction(function() Control.CastSpell(k,t) end,0.2)
end

function buffStunned(hero)
	for i = 0, hero.buffCount do
		local buff = myHero:GetBuff(i)
		if buff and (buff.type == 5 or buff.type == 8 or buff.type == 11 or buff.type == 24 or buff.type == 22 or buff.type == 24 or buff.type == 29) and buff.duration > 0.3 then
			return true
		end
	end
	return false
end

-- function onRecall()
-- 	for i = 0, myHero.buffCount do
-- 		local buff = myHero:GetBuff(i)
-- 		if buff and buff.name == "recall" and buff.duration > 0 then
-- 			return true
-- 		end
-- 	end
-- 	return false
-- end



 local subOnPostAttack = false
 
 local W_Collision = Collision:SetSpell(W.range, W.speed, 0.6, W.minionCollisionWidth, true)

Callback.Add("Tick", function()


	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
		local maxRange = calcRange()
		if Game.CanUseSpell(_Q) == READY and GameMenu.Settings.autoQ:Value()  then
			local QOn = QOn()
			local t = _G.SDK.TargetSelector:GetTarget(maxRange+200)
			if t and t.distance > 525 and QOn == 1 then
				Control.CastSpell(HK_Q)
			-- elseif t and t.distance < 525 and QOn == 2 then
			-- 	Control.CastSpell(HK_Q)
			end
		end

		if Game.CanUseSpell(_W) == READY and GameMenu.Settings.useW:Value() and GameMenu.ManaManager.Wmana:Value()/100 < myHero.mana/myHero.maxMana then
			local t = _G.SDK.TargetSelector:GetTarget(W.range)
			if t and t.distance < W.range then
				local predpos = t:GetPrediction(W.speed,W.delay/1000)
				local block, list = W_Collision:__GetCollision(myHero, predpos, 5)
				local dis = predpos:DistanceTo()
				if dis < W.range and dis > maxRange + 60 and not block then
					--_G.SDK.Orbwalker:SetMovement(false)
					dCast(HK_W,predpos)
					--_G.SDK.Orbwalker:SetMovement(true)
				end
			end
		end
	end

	if subOnPostAttack == false then
		_G.SDK.Orbwalker:OnPostAttack(function()
			local maxRange = calcRange()
			local QOn = QOn()
			if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
				--W in Combo
				if Game.CanUseSpell(_W) == READY and GameMenu.Settings.useW:Value() and GameMenu.ManaManager.Wmana:Value()/100 < myHero.mana/myHero.maxMana then
					local t = _G.SDK.TargetSelector:GetTarget(W.range)
					if t and t.distance < W.range then
						local predpos = t:GetPrediction(W.speed,W.delay/1000)
						local block, list = W_Collision:__GetCollision(myHero, predpos, 5)
						local dis = predpos:DistanceTo()
						if dis < W.range and not block then
							_G.SDK.Orbwalker:SetMovement(false)
							dCast(HK_W,predpos)
							_G.SDK.Orbwalker:SetMovement(true)
						end
					end
				end

				--Auto Q
				if Game.CanUseSpell(_Q) == READY and GameMenu.Settings.autoQ:Value()  then
					local t = _G.SDK.TargetSelector:GetTarget(maxRange)
					if t and t.distance > 525 and t.distance < maxRange and QOn == 1 then
						Control.CastSpell(HK_Q)
					elseif t and t.distance < 525 and QOn == 2 then
						Control.CastSpell(HK_Q)
					end
				end
			end

		end)
		subOnPostAttack = true
	 end

--Auto E on stunned
	local enemy = _G.SDK.ObjectManager:GetEnemyHeroes(E.range)
	if Game.CanUseSpell(_E) == READY and next(enemy) ~= nil and GameMenu.Settings.autoE:Value() then
		for k, v in pairs(enemy) do
			local stun = buffStunned(v)
			print(stun)
			if v.distance <= E.range and stun then
				dCast(HK_E,v)
			end
		end
	end

end)

Callback.Add("Draw", function()
	if myHero.dead then return end



end)

