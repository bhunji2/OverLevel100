ExperienceManager.LEVEL_CAP = Application:digest_value(10000, true)

OL1_EM_UP = OL1_EM_UP or ExperienceManager.update_progress
function ExperienceManager:update_progress() --log("// update_progress")
	OL1_EM_UP(self)
	self:SyncXpData()
end

OL1_EM_GE = OL1_EM_GE or ExperienceManager.give_experience
function ExperienceManager:give_experience(xp, force_or_debug) --log("// give_experience")
	local data = OL1_EM_GE(self,xp, force_or_debug)
	self:SyncXpData()
	return data
end

local OverLevel = { level = 99 , rank = 0 , points = 0 , xp = 0 }
function SyncXpDataLoad()
	local  file = io.open(SavePath .. "OverLevel100.json", "r")
	if not file   then return false end
	local  fileT= file:read("*all"):gsub("%[%]","{}") 
		   file : close()
	if 	   fileT == "" then return end
	
	OverLevel = json.decode(fileT)
end
SyncXpDataLoad()

function SyncXpDataSave()
	local  file = io.open(SavePath .. "OverLevel100.json", "w")
	if not file then return false end
		   file:write(json.encode( OverLevel ))
		   file:close()
end
-- https://sites.google.com/site/etondum/mush/script
function ExperienceManager:SyncXpData() --log("// SyncXpData")
	local xp 	= self:xp_gained()
	local total	= self:total()
	local level = self:current_level()
	local rank	= self:current_rank()
	local points= self:next_level_data_current_points()
	local pointt= self:next_level_data_points()
	local levels_gained = self:get_levels_gained_from_xp(total)
	--[[
	log("/total     / " .. tostring( total 	))
	log("/xp_gained / " .. tostring( xp 	))
	log("/level     / "	.. tostring( level 	))
	log("/levels_gained / "	.. tostring( levels_gained 	))
	log("/rank      / " .. tostring( rank 	))
	log("/next_level_current_points / " 	.. tostring( points ))
	log("/next_level_points         / " 	.. tostring( pointt ))
	--]]
	if level < 100 then return end
	--[[
	local true_level = math.floor( total / rank / pointt )
	log("/true_level / " .. tostring( true_level	))
	--]]
	if   OverLevel.level > level 
	and  OverLevel.rank == rank then 
		--self:_set_xp_gained(OverLevel.xp)
		self:_set_current_level(OverLevel.level)
		self:_set_next_level_data_current_points(OverLevel.points)
		OL1_EM_UP(self)
	else 
		OverLevel = { xp = xp , rank = rank , level = level , points = points }
		SyncXpDataSave()
	end
	
	--[[
	log("/ levels / " .. tostring(
		tweak_data:get_value("experience_manager", "levels", 100, "points")
	))
	--]]
	--[[
	for i = 1, 100 do
		log(tostring( tweak_data:get_value("experience_manager", "levels", i, "points") ))
	end
	--]]
end
--[[
OL1_EM_GLGFX = OL1_EM_GLGFX or ExperienceManager.get_levels_gained_from_xp
function ExperienceManager:get_levels_gained_from_xp(xp)
	local levels_gained = OL1_EM_GLGFX(self,xp)
	log("/OL1_EM_GLGFX levels_gained / "	.. tostring( levels_gained 	))
	return levels_gained
end
--]]