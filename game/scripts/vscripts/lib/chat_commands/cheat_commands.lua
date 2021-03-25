--[[
Cheat lobby commands
 -spawnCreeps, -sc      	-- spawn creeps on map. 
 -enableCreepSpawn			-- enable creep spawning 
 -disableCreepSpawn			-- disable creep spawning 
 -is_cheats 				-- is cheats enabled 
 -addmod modifier_name 10 	-- adding modifier with name 'modifier_name' and duration '10'sec
 -remmod modifier_name		-- removing modifier with name 'modifier_name'
 -str 100					-- set base hero strength to 100
 -agi 100					-- set base hero agility to 100
 -int 100					-- set base hero intellect to 100 
 -restoreObelisk [team]		-- restore obelisks
]]

Commands = Commands or class({})

require('lib/attentions')
require('lib/utils')
require('lib/duel/duel_controller')
require("lib/spawners/creep_spawner")

function Commands:is_cheats( player, arg )
	force_print("Cheats enable state is:", GameRules:IsCheatMode())
end 

------------------------------------------------------------------------------------------------------------

if not GameRules:IsCheatMode() then 
	return 
end 

function Commands:duel_start(player, arg)
	DuelController:StartDuel()
end

function Commands:duel_end(player, arg)
	DuelController:StopDuel()
end

function Commands:duel_toggle(player, arg)
	DuelController:ToggleDuel()
end

function Commands:duel_freeze( player, arg )
	local val = arg[1]

	if val == nil then
		val = not DuelController:GetFreezeTimer()
	else
		val = val == "1"
	end

	DuelController:SetFreezeTimer( val )
end

function Commands:duel_time( player, arg )
	local time = arg[1]

	if not time then
		Attentions:SendChatMessage( "Time until duel event: " .. tostring(DuelController:GetTime()) )
	else
		DuelController:SetTime( tonumber(time) )
	end
end

function Commands:spawn_creeps( player, arg )
	CreepSpawner:SpawnCreeps() 
end

function Commands:sc( player, arg ) self:spawn_creeps( player, arg ); end 


function Commands:disable_creeps_spawn(player, arg)
	CreepSpawner:SetEnable(false) 
end 

function Commands:enable_creeps_spawn(player, arg)
	CreepSpawner:SetEnable(true) 
end 

function Commands:addmod(player, arg)
	local hero 			= player:GetAssignedHero() 
	local modifierName 	= arg[1]
	local duration 		= arg[2]

	hero:AddNewModifier(hero, nil, modifierName, { duration = duration }) 
end

function Commands:dev(player, arg)
	local hero 			= player:GetAssignedHero()
	hero:SetBaseIntellect( 10000 )
	hero:SetBaseAgility( 10000 )
	hero:SetBaseStrength( 10000 )
	hero:CalculateStatBonus( true )
	hero:AddItemByName("item_lightning_flash")
	hero:AddItemByName("item_rubick_dagon")
	hero:AddItemByName("item_polar_spear")
end

function Commands:remmod(player, arg)
	local hero 			= player:GetAssignedHero() 
	local modifierName 	= arg[1]
	hero:RemoveModifierByName(modifierName)
end 

local function get_hero_under_cursor(player)
	local hero = player:GetAssignedHero()

	if hero then
        local pos = hero:GetPlayerCursorPosition()

        local newHero = _GetNearestUnitUnderPoint(pos, 100)
        
        if newHero then 
        	hero = newHero 
        end
    end

    return hero
end

function Commands:create_dummy(player, arg)
	local hero = player:GetAssignedHero()
	local target = CreateUnitByName( "npc_dota_hero_target_dummy", hero:GetPlayerCursorPosition(), true, nil, nil, hero:GetOpposingTeamNumber() )
	target:SetAbilityPoints( 0 )
	target:SetControllableByPlayer( hero:GetPlayerOwnerID(), false )
	target:Hold()
	target:SetIdleAcquire( false )
	target:SetAcquisitionRange( 0 )
end


function Commands:str(player, arg)
	if not player then return end
	local hero = player:GetAssignedHero()

	if hero then
		local pos = hero:GetPlayerCursorPosition()
		local focus = _GetNearestUnitUnderPoint(pos, 100)

		if focus then
			hero = focus
		end
	end

	if not hero then return end

	hero:SetBaseStrength( tonumber(arg[1]) )
	hero:CalculateStatBonus( true )
end 

function Commands:agi(player, arg)
	if not player then return end
	local hero = player:GetAssignedHero()

	if hero then
		local pos = hero:GetPlayerCursorPosition()
		local focus = _GetNearestUnitUnderPoint(pos, 100)

		if focus then
			hero = focus
		end
	end

	if not hero then return end

	hero:SetBaseAgility( tonumber(arg[1]) )
	hero:CalculateStatBonus( true )
end 

function Commands:int(player, arg)
	if not player then return end
	local hero = player:GetAssignedHero()

	if hero then
		local pos = hero:GetPlayerCursorPosition()
		local focus = _GetNearestUnitUnderPoint(pos, 100)

		if focus then
			hero = focus
		end
	end

	if not hero then return end

	hero:SetBaseIntellect( tonumber(arg[1]) )
	hero:CalculateStatBonus( true )
end 

function Commands:rmana(player, arg)
	local hero 			= get_hero_under_cursor(player) 
	if not hero then return end
	
	hero:ReduceMana( tonumber(arg[1]) )
end

function Commands:nofog(player, arg)
	local GameMode = GameRules:GetGameModeEntity()
	GameMode:SetFogOfWarDisabled(true)
end

function Commands:switchhero(player, arg)
	PlayerResource:ReplaceHeroWith( player:GetPlayerID(), "npc_dota_hero_" .. arg[1], player:GetAssignedHero():GetGold(), 0 )
end

function Commands:fog(player, arg)
	local GameMode = GameRules:GetGameModeEntity()
	GameMode:SetFogOfWarDisabled(false)
end

function Commands:q(player, arg)
	local hero 			= player:GetAssignedHero()
	hero:AddItemByName("item_angels_sword")
	hero:AddItemByName("item_angels_sword")
	hero:AddItemByName("item_angels_sword")
	hero:AddItemByName("item_angels_sword")
	hero:AddItemByName("item_angels_sword")
	hero:AddItemByName("item_angels_sword")
end

function Commands:restore_obelisk(player, arg)
	local buildings = Entities:FindAllByClassname('npc_dota_building')

	for _, building in pairs(buildings) do

		local unitName = building:GetUnitName() 

		if unitName == "npc_aa_bulding_obelisk_dire" or unitName == "npc_aa_bulding_obelisk_radiant" then
			if not arg[1] or ( building.initial_team == tonumber( arg[1] ) ) then 
				building:GetAbilityByIndex(0):OnStateChanged( false, nil )
			end 
		end 
	end 
end

require('lib/game_modes/captains_mode')

function Commands:cm_pick(player,arg)
	local playerid = tonumber(arg[1])
	local heroName = arg[2]

	CaptainsMode:_OnHeroPicked( { playerID = playerid, heroName = heroName })
end

function Commands:cm_be_captain(player, arg)
	local playerid = tonumber(arg)

	CaptainsMode:_OnCaptainSelected( { playerID = playerid })
end

function Commands:cm_ban(player, arg)
	local playerid = tonumber(arg[1])
	local heroName = arg[2]

	CaptainsMode:_OnHeroBanned( { playerID = playerid, heroName = heroName })
end