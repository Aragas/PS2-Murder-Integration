local MurderSetting = function(id)
	return Pointshop2.GetSetting("Murder Integration", id)
end
	
local delayedRewards = { }
local function delayReward(ply, points, message, small)
	if MurderSetting("Kills.DelayReward") then
		table.insert(delayedRewards, { ply = ply, points = points, message = message, small = small })
	else
		ply:PS2_AddStandardPoints(points, message, small)
	end
end

local function applyDelayedRewards()
	for k, v in ipairs(delayedRewards)  do
		v.ply:PS2_AddStandardPoints(v.points, v.message, v.small)
	end
	delayedRewards = { }
end

local playersInRound = { }
hook.Add("OnStartRound", "PS2_MUBeginRound", function()
	for k, v in pairs(player.GetAll()) do
		if v:Alive() then
			playersInRound[k] = v
		end
	end
end)

hook.Add("PlayerPickupLoot", "PS2_PlayerPickupLoot", function(ply, ent)
	ply:PS2_AddStandardPoints( MurderSetting("PickupLoot"), "Found Loot", true)
end)

// Only if the hook is defined. Not defined by default. Be aware.
// 1 Murderer wins
// 2 Murderer loses
// 3 Murderer rage quit
hook.Add("OnEndRoundResult", "PS2_MUEndRound", function(result)
	applyDelayedRewards()
	
	if result == 2 then
		for k, v in pairs(player.GetAll()) do
			if not table.HasValue(playersInRound, v) then
				continue
			end
			
			if v:GetMurderer() then
				continue
			end
		
			if v:Alive() and MurderSetting("RoundWin.BystanderAlive") then
				v:PS2_AddStandardPoints(MurderSetting("RoundWin.BystanderAlive"), "Bonus for survival", true)
			end
			if MurderSetting("RoundWin.Bystander") then
				v:PS2_AddStandardPoints(MurderSetting("RoundWin.Bystander"), "Won the round")
			end
			
		end
	elseif result == 1 then
		for k, v in pairs( player.GetAll()) do
			if not v:GetMurderer() then
				continue
			end			
		end
	end
	playersInRound = { }
	
	hook.Call("Pointshop2GmIntegration_RoundEnded")
end)

hook.Add("PlayerDeath", "PS2_PlayerDeath", function(victim, inflictor, attacker)
	if victim == attacker then
		return
	end

	if attacker:GetMurderer() then			
		attacker:PS2_AddStandardPoints(MurderSetting("Kills.MurderKillsBystander"), "Killed Bystander")
		
	else -- Bystander		
		if victim:GetMurderer() and MurderSetting("Kills.BystanderKillsMurderer") then
			attacker:PS2_AddStandardPoints(MurderSetting("Kills.BystanderKillsMurderer"), "Killed the Murderer")
			
		else -- Bystander 
			attacker:PS2_AddStandardPoints(MurderSetting("Kills.BystanderKillsBystander"), "Killed Bystander")
		end	
		
	end

end)

