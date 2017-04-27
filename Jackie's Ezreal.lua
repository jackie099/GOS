
if myHero.charName ~= "Ezreal" then return end

print("Welcome to Jackie's Jinx")



require "DamageLib"
require "Collision"

-- Spell

local Q = myHero:GetSpellData(_Q);
local W = myHero:GetSpellData(_W);
--local W = {range = 1500, delay = 600, minionCollisionWidth = 60, speed = 3200}
local E = myHero:GetSpellData(_E);
local R = myHero:GetSpellData(_R);
local tick = 0

--Menu

local GameMenu = MenuElement({type = MENU, id = "GameMenu", name = "Jackie's Ezreal"})

GameMenu:MenuElement({type = SPACE, id = "ver", name = "v 1.0"})
GameMenu:MenuElement({type = SPACE, id = "about", name = "by Jackie099"})




function dCast(k,t,d)

	local new_tick = GetTickCount() - tick
	if new_tick > 1000 then	
		local ping = Game.Latency()/1000
		_G.SDK.Orbwalker:SetMovement(false)
		_G.SDK.Orbwalker:SetAttack(false)
		DelayAction(function()		
			local m = mousePos
			print("got curse")
			DelayAction(function()		
				Control.SetCursorPos(t)
				Control.KeyDown(k)
				Control.KeyUp(k)
				print("finished cast")

				DelayAction(function()
					Control.SetCursorPos(m)
					print("reset curse")
					_G.SDK.Orbwalker:SetMovement(true)
					_G.SDK.Orbwalker:SetAttack(true)  

				end,ping)
			end,0.025)
		end,ping)
		tick = GetTickCount()

	end
	
end




 
local Q_Collision = Collision:SetSpell(Q.range, Q.speed, 2, 60, true)

--local firstAttack = true

local tick = 0

Callback.Add("Tick", function()
	--print(Game.Latency())

	if _G.SDK.Orbwalker.Modes[_G.SDK.ORBWALKER_MODE_COMBO] then
		if myHero.attackData.state == STATE_WINDUP then
			return
		end

		if Game.CanUseSpell(_Q) == READY then
			local t = _G.SDK.TargetSelector:GetTarget(Q.range)
			if t and t.distance < Q.range then
				local predpos = t:GetPrediction(Q.speed,250/1000)
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

