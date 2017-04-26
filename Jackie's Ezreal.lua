
if myHero.charName ~= "Ezreal" then return end

print("Welcome to Jackie's Ezreal")



require "DamageLib"
require "Collision"

-- Spell

local Q = {range = 1150, delay = 250, minionCollisionWidth = 60, speed = 2000}
local W = myHero:GetSpellData(_W);
local E = myHero:GetSpellData(_E);
local R = myHero:GetSpellData(_R);
local tick = 0

--Menu

local GameMenu = MenuElement({type = MENU, id = "GameMenu", name = "Jackie's Ezreal"})
GameMenu:MenuElement({type = MENU, id = "Settings", name = "Spell Usage"})
GameMenu.Settings:MenuElement({id = "autoQ", name = "Auto Q", value = true})
-- GameMenu.Settings:MenuElement({id = "useW", name = "Use W in combo", value = true})
-- GameMenu.Settings:MenuElement({id = "minW", name = "Min range to cast W", value = 200, min = 0, max = 600, step = 10})
-- GameMenu.Settings:MenuElement({id = "autoE", name = "Auto E on CCed enemy", value = true})
-- GameMenu:MenuElement({type = MENU, id = "ManaManager", name = "Mana Manager"})
-- GameMenu.ManaManager:MenuElement({id = "Wmana", name = "Do not use W if mana is below %", value = 20, min = 0, max = 100, step = 1})
-- GameMenu:MenuElement({type = MENU, id = "ks", name = "Kill Stealing"})
-- --GameMenu.ks:MenuElement({id = "wKS", name = "Kill Steal with W", value = true})
GameMenu:MenuElement({type = SPACE, id = "ver", name = "v 1.0"})
GameMenu:MenuElement({type = SPACE, id = "about", name = "by Jackie099"})



function dCast(k,t,d)

	local new_tick = GetTickCount() - tick
	if new_tick > 30*d then	
		--_G.SDK.Orbwalker:SetMovement(false)
		_G.SDK.Orbwalker:SetAttack(false)
		Control.CastSpell(k,t)
		DelayAction(function()
		--_G.SDK.Orbwalker:SetMovement(true)
		_G.SDK.Orbwalker:SetAttack(true)  end,d)
		tick = GetTickCount()

	end
	
end


-- local subOnPostAttack = false
 
local Q_Collision = Collision:SetSpell(Q.range, Q.speed, 0.25, Q.minionCollisionWidth, true)

--local firstAttack = true

local tick = 0

Callback.Add("Tick", function()


	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
		if myHero.attackData.state == STATE_WINDUP then
			return
		end


		if Game.CanUseSpell(_Q) == READY and GameMenu.Settings.autoQ:Value() then
			local t = _G.SDK.TargetSelector:GetTarget(Q.range)
			if t and t.distance < Q.range then
				local predpos = t:GetPrediction(Q.speed,Q.delay/1000)
				local block, list = Q_Collision:__GetCollision(myHero, predpos, 5)
				local dis = predpos:DistanceTo()
				if dis < Q.range and not block then
					dCast(HK_Q,predpos,0.25)
				end
			end
		end
	end
end)


Callback.Add("Draw", function()
	if myHero.dead then return end



end)

