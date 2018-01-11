local pairs, ipairs, tonumber, tostring = pairs, ipairs, tonumber, tostring

local tAllSkill = {}
local tNpcList = {}
local bProtectChannelSkill = true
local szBeforeCmd = ""
local bAttackState = false
local szLastOTA = nil
local tSkillBox = {}

local dwCurrentTargetID = 0
local dwTargetRank = 0
local dwMyHatred = 0

local dwLastSunTime = 0
local dwLastMoonTime = 0
local nNextMoonLevel = 1
local nNextSunLevel = 1
local tMoonSkill = {[4024] = 1,[4025] = 2,[4026] = 3}
local tSunSkill =  {[4028] = 1,[4029] = 2,[4030] = 3}

local tChannelSkill = {[3110] = true, [5268] = true,}

local tmount = {
	[10145] = "Sơn Cư Kiếm Ý",
	[10144] = "Vấn Thủy Quyết",
	[10028] = "Ly Kinh Dịch Đạo",
	[10021] = "Hoa Gian Du",
	[10225] = "Thiên La Ngụy Đạo",
	[10224] = "Kinh Vũ Quyết",	
	[10002] = "Dịch Cân Kinh",
	[10003] = "Tẩy Tủy Kinh",	
	[10080] = "Vân Thường Tâm Kinh",
	[10081] = "Băng Tâm Quyết",		
	[10242] = "Phần Ảnh Thánh Quyết",
	[10243] = "Minh Tôn Lưu Ly Thể",		
}

local tPet = {
	[9956] = "Thánh Hạt",
	[9996] = "Phong Ngô Hoàng",
	[9997] = "Thiên Thù",
	[9998] = "Linh Xà",
	[9999] = "Ngọc Thiềm Vương",
}

local tPuppet = {
	[16174] = "Thiên Cơ Nỏ",
	[16175] = "Liên Nỏ",
	[16176] = "Trọng Nỏ",
	[16177] = "Độc Sát",
}

local tPuppetSkill = {
	["Liên Nỏ"] = {3368, 1},
	["Trọng Nỏ"] = {3369, 1},
	["Độc Sát"] = {3370, 1},
	["Tấn công"] = {3360, 1},
	["Dừng"] = {3382, 1}
}

local tAuraList = {
	[4982] = 8, 	--Trấn Sơn Hà
	[3080] = 24,	--Hóa Tam Thanh
	[4976] = 24, 	--Sinh Thái Cực
	[4981] = 24, 	--Thôn Nhật Nguyệt
	[4977] = 24, 	--Phá Thương Khung
	[4978] = 8, 	--Xung Âm Dương
	[4979] = 24, 	--Lăng Thái Hư
	[4980] = 24, 	--Toái Tinh Thần
}

local tDetachType = {
	["btype"] = {
		[1] = "Ngoại công",
		[3] = "Dương tính",
		[5] = "Hỗn nguyên",
		[7] = "Âm tính",
		[11] = "Độc tính",
		[13] = "Nội"
	},
	["detype"] = {
		[2] = "Ngoại công",
		[4] = "Dương tính",
		[6] = "Hỗn nguyên",
		[8] = "Âm tính",
		[10] = "Điểm huyệt",
		[12] = "Độc tính",
		[14] = "Nội"
	}
}

local tStatus = {
	["stand"]	= MOVE_STATE.ON_STAND,
	["walk"] 	= MOVE_STATE.ON_WALK,
	["run"]		= MOVE_STATE.ON_RUN,
	["jump"]	= MOVE_STATE.ON_JUMP,
	["swim"]	= MOVE_STATE.ON_SWIM,
	["swimjump"]= MOVE_STATE.ON_SWIM_JUMP,
	["float"]	= MOVE_STATE.ON_FLOAT,
	["sit"]		= MOVE_STATE.ON_SIT,
	["down"]	= MOVE_STATE.ON_KNOCKED_DOWN,
	["bacl"]	= MOVE_STATE.ON_KNOCKED_BACK,
	["off"]		= MOVE_STATE.ON_KNOCKED_OFF,
	["halt"]	= MOVE_STATE.ON_HALT,
	["freeze"]	= MOVE_STATE.ON_FREEZE,
	["entrap"]	= MOVE_STATE.ON_ENTRAP,
	["autofly"]	= MOVE_STATE.ON_AUTO_FLY,
	["death"]	= MOVE_STATE.ON_DEATH,
	["dash"]	= MOVE_STATE.ON_DASH,
	["pull"]	= MOVE_STATE.ON_PULL,
	["repulsed"]= MOVE_STATE.ON_REPULSED,
	["rise"]	= MOVE_STATE.ON_RISE,
	["skid"]	= MOVE_STATE.ON_SKID,
}

local tEquipmentPos = {
	EQUIPMENT_INVENTORY.MELEE_WEAPON,
	EQUIPMENT_INVENTORY.BIG_SWORD,
	EQUIPMENT_INVENTORY.RANGE_WEAPON,
	EQUIPMENT_INVENTORY.CHEST,
	EQUIPMENT_INVENTORY.HELM,
	EQUIPMENT_INVENTORY.AMULET,
	EQUIPMENT_INVENTORY.LEFT_RING,
	EQUIPMENT_INVENTORY.RIGHT_RING,
	EQUIPMENT_INVENTORY.WAIST,
	EQUIPMENT_INVENTORY.PENDANT,
	EQUIPMENT_INVENTORY.PANTS,
	EQUIPMENT_INVENTORY.BOOTS,
	EQUIPMENT_INVENTORY.BANGLE,
}

--------------------------------------------------------

--------------------------------------------------------
local RoleCache = {}
function RoleCache:New()
	local o = {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function RoleCache:Set(data)
	self.data = data
end

function RoleCache:Get()
	return self.data
end

local MeCache, TarCache = RoleCache:New(), RoleCache:New()

--------------------------------------------------------

--------------------------------------------------------
local function print(...)
	local a = {...}
	for i, v in ipairs(a) do
		a[i] = tostring(v)
	end
	OutputMessage("MSG_SYS", "[xMacro]" .. table.concat(a, "\t") .. "\n" )
end


local function Compare(szCmp, szRes, szTar)
	local nRes, nTar = tonumber(szRes), tonumber(szTar)
	local tCompare = {
		["="] = nRes == nTar,
		[">"] = nRes > nTar,
		["<"] = nRes < nTar,
		[">="] = nRes >= nTar,
		["<="] = nRes <= nTar,
	}
	if tCompare[szCmp] then
		return tCompare[szCmp]
	end
	return false
end


local function GetPlayerSkillInfo(szName)
	for k, v in pairs(tAllSkill) do
		local szSkillName = Table_GetSkillName(k, v)
		if szSkillName == szName then
			return k, v
		end
	end
	return nil
end


local function GetSkillCD(szText)
	local me = GetClientPlayer()
	local dwSkillID, dwLevel = GetPlayerSkillInfo(szText)
	if dwSkillID then
		local bCool, nLeft, nTotal = me.GetSkillCDProgress(dwSkillID, dwLevel)
		return nLeft / GLOBAL.GAME_FPS
	end
	return 0
end


local function GetItemPos(szText)
	local me = GetClientPlayer()
	for dwBox = 1, 6 do
		local dwSize = me.GetBoxSize(dwBox)
		if dwSize > 0 then
			for dwX = 0, dwSize - 1 do
				local item = me.GetItem(dwBox, dwX)
				if item and item.szName == szText then
					return dwBox, dwX
				end
			end
		end
	end
	return nil
end


local function GetBagFreeBoxList()
	local me = GetClientPlayer()
	local tBoxTable = {}
	for nIndex = 6, 1, -1 do
		local dwBox = INVENTORY_INDEX.PACKAGE + nIndex - 1
		local dwSize = me.GetBoxSize(dwBox)
		if dwSize > 0 then
			for dwX = dwSize, 1, -1 do
				local item = me.GetItem(dwBox, dwX - 1)
				if not item then
					local i, j = dwBox, dwX - 1
					table.insert(tBoxTable, {i, j})
				end
			end
		end
	end
	return tBoxTable
end

local function IsBuffExist(tCache, szText, bSrc)
	szText = tonumber(szText) or szText
	for k, v in pairs(tCache) do
		local szBuffName = Table_GetBuffName(v.dwID, v.nLevel)
		if not bSrc or (bSrc and v.dwSkillSrcID == UI_GetClientPlayerID()) then
			if type(szText) == "number" and v.dwID  == szText then
				return v
			elseif type(szText) == "string" and szBuffName == szText then
				return v
			end
		end
	end
	return nil
end


local function IsAuraExist(szText)
	for k, v in pairs(tNpcList) do
		local npc = GetNpc(k)
		if npc and StringFindW(npc.szName, szText) then
			if v[2] == UI_GetClientPlayerID() then
				return v
			end
		end
	end
	return nil
end


local function GetDistanceByTarget(res, tar)
	if not res or not tar then
		return false
	end
	local nDist = math.floor(((res.nX - tar.nX) ^ 2 + (res.nY - tar.nY) ^ 2 + (res.nZ/8 - tar.nZ/8) ^ 2) ^ 0.5) / 64
	return tonumber(string.format("%.1f", nDist))
end


local function GetAngle(me, tar)
	if not tar then return nil end
	local nX, nY = tar.nX - me.nX, tar.nY - me.nY
	local nFace, nDeg = me.nFaceDirection / 256 * 360, 0
	if nY == 0 then
		if nX < 0 then
			nDeg = 180
		end
	elseif nX == 0 then
		if nY > 0 then
			nDeg = 90
		else
			nDeg = 270
		end
	else
		nDeg = math.deg(math.atan(nY / nX))
		if nX < 0 then
			nDeg = 180 + nDeg
		elseif nY < 0 then
			nDeg = 360 + nDeg
		end
	end
	local nAngle = nFace - nDeg
	if nAngle < -180 then
		nAngle = nAngle + 360
	elseif nAngle > 180 then
		nAngle = nAngle - 360
	end
	return math.abs(nAngle)
end

--------------------------------------------------------
-- Kiểm tra điều kiện
--------------------------------------------------------

local function CheckTarget(tar, szText)
	if not tar then return false end
	local tTypes, bRet = SplitString(szText, "|"), false
	for _, szType in ipairs(tTypes) do
		if szType == "player" and IsPlayer(tar.dwID) then
			bRet = true
		elseif szType == "npc" and not IsPlayer(tar.dwID) then
			bRet = true
		elseif szType == "boss" and (GetNpcIntensity(tar) == 4) then
			bRet = true
		elseif szType == "cọc gỗ" and StringFindW(tar.szName, szType) then
			bRet = true
		end
	end
	return bRet
end

local function CheckForce(tar, szText)
	if not tar then return false end
	local tForce = SplitString(szText, "|")
	for _, szForce in ipairs(tForce) do
		if GetForceTitle(tar.dwForceID) == szForce then
			return true
		end
	end
	return false
end

local function CheckStatus(tar, szText)
	if not tar then return false end
	local tState = SplitString(szText, "|")
	for _, szState in ipairs(tState) do
		if tar.nMoveState == tStatus[szState] then
			return true
		end
	end
	return false
end

local function CheckName(tar, szText)
	if not tar then return false end
	local tName = SplitString(szText, "|")
	for _, szName in ipairs(tName) do
		if tar.szName == szName then
			return true
		end
	end
	return false
end

local function CheckMount(tar, szText)
	if not tar then return false end
	local tMount = SplitString(szText, "|")
	for _, szMount in ipairs(tMount) do
		local szSkill = tar.GetKungfuMount().dwSkillID
		if tmount[szSkill] == szMount then
			return true
		end
	end
	return false
end

local function CheckPet(szText)
	local frame = Station.Lookup("Normal/PetActionBar")
	if frame and frame:IsVisible() then
		if szText then
			local tName = SplitString(szText, "|")
			for _, szName in ipairs(tName) do
				if szName == tPet[frame.dwNpcTemplateID] then
					return true
				end
			end
			return false
		end
		return true
	end
	return false
end

local function CheckPuppet(szText)
	local frame = Station.Lookup("Normal/PuppetActionBar")
	if frame and frame:IsVisible() then
		if szText then
			local tName = SplitString(szText, "|")
			for _, v in ipairs(tName) do
				local szName, szCmp, szVal = v:match("(.-)([<>=]+)(.+)")
				if szName and szCmp and szVal then
					if frame.dwNpcTemplateID == 16174 then
						return true
					else
						if szName == tPuppet[frame.dwNpcTemplateID] then
							for kk, vv in pairs(tNpcList) do
								if vv[1] == frame.dwNpcTemplateID and vv[2] == UI_GetClientPlayerID() then
									local nTime = math.floor(tPuppetList[frame.dwNpcTemplateID] - (GetTime() - vv[3]) / 1000)
									Output(nTime)
									return Compare(szCmp, nTime, szVal)
								end
							end
						end
					end
				else
					if v == tPuppet[frame.dwNpcTemplateID] then
						return true
					end
				end
			end
			return false
		end
		return true
	end
	return false
end


local function CheckSkillCD(szText, bCool)
	local szOper, bAnd = "|", false
	if StringFindW(szText, "-") then
		szOper, bAnd = "-", true
	end
	local tText = SplitString(szText, szOper)
	for _, szSkillName in ipairs(tText) do
		local nLeft = GetSkillCD(szSkillName)
		if bCool then
			if nLeft > 0 and szOper == "|" then
				return true
			elseif nLeft <= 0 and szOper == "-" then
				return false
			end
		else
			if nLeft <= 0 and szOper == "|" then
				return true
			elseif nLeft > 0 and szOper == "-" then
				return false
			end
		end
	end
	return bAnd
end


local function CheckCDTime(szText)
	local szOper, bAnd = "|", false
	if StringFindW(szText, "-") then
		szOper, bAnd = "-", true
	end
	local tText = SplitString(szText, szOper)
	for _, v in ipairs(tText) do
		local szName, szCmp, szVal = v:match("(.-)([<>=]+)(.+)")
		if szName and szCmp and szVal then
			local nLeft = GetSkillCD(szName)
			if Compare(szCmp, nLeft, szVal) and szOper == "|" then
				return true
			elseif not Compare(szCmp, nLeft, szVal) and szOper == "-" then
				return false
			end
		end
	end
	return bAnd
end


local function CheckBuff(tar, szText, bTime, bSrc)
	if not tar then return false end
	local szOper, bAnd = "|", false
	if StringFindW(szText, "-") then
		szOper, bAnd = "-", true
	end
	local tText = SplitString(szText, szOper)
	local tCache = GetBuffList(tar) or {}
	for _, szCmd in ipairs(tText) do
		local szName, szCmp, szVal = szCmd:match("(.-)([<>=]+)(.+)")
		if szName and szCmp and szVal then
			local tBuff = IsBuffExist(tCache, szName, bSrc)
			if tBuff then
				if bTime then
					local nTime = (tBuff.nEndFrame - GetLogicFrameCount()) / GLOBAL.GAME_FPS
					if Compare(szCmp, nTime, szVal) and szOper == "|" then
						return true
					elseif not Compare(szCmp, nTime, szVal) and szOper == "-" then
						return false
					end
				else
					local nStack = tBuff.nStackNum
					if Compare(szCmp, nStack, szVal) and szOper == "|" then
						return true
					elseif not Compare(szCmp, nStack, szVal) and szOper == "-" then
						return false
					end
				end
			end
		else
			local tBuff = IsBuffExist(tCache, szCmd, bSrc)
			if tBuff and szOper == "|" then
				return true
			elseif not tBuff and szOper == "-" then
				return false
			end
		end
	end
	return bAnd
end


local function CheckNoBuff(tar, szText, bSrc)
	if not tar then return false end
	local szOper, bAnd = "-", true
	if StringFindW(szText, "|") then
		szOper, bAnd = "|", false
	end
	local tText = SplitString(szText, szOper)
	local tCache = GetBuffList(tar) or {}
	for _, szCmd in ipairs(tText) do
		local tBuff = IsBuffExist(tCache, szCmd, bSrc)
		if tBuff and szOper == "-" then
			return false
		elseif not tBuff and szOper == "|" then
			return true
		end
	end
	return bAnd
end


local function CheckAura(szText)
	local szOper, bAnd = "|", false
	if StringFindW(szText, "-") then
		szOper, bAnd = "-", true
	end
	local tText = SplitString(szText, szOper)
	for _, szCmd in ipairs(tText) do
		local szName, szCmp, szVal = szCmd:match("(.-)([<>=]+)(.+)")
		if szName and szCmp and szVal then
			local tNpc = IsAuraExist(szName)
			if tNpc then
				local nTime = math.floor(tAuraList[tNpc[1]] - (GetTime() - tNpc[3]) / 1000)
				if Compare(szCmp, nTime, szVal) and szOper == "|" then
					return true
				elseif not Compare(szCmp, nTime, szVal) and szOper == "-" then
					return false
				end
			end
		else
			local tNpc = IsAuraExist(szCmd)
			if tNpc and szOper == "|" then
				return true
			elseif not tNpc and szOper == "-" then
				return false
			end
		end
	end
	return bAnd
end


local function CheckNoAura(szText)
	local szOper, bAnd = "-", true
	if StringFindW(szText, "|") then
		szOper, bAnd = "|", false
	end
	local tText = SplitString(szText, szOper)
	for _, szCmd in ipairs(tText) do
		local tNpc = IsAuraExist(szCmd)
		if tNpc and szOper == "-" then
			return false
		elseif not tNpc and szOper == "|" then
			return true
		end
	end
	return bAnd
end


local function CheckDetach(tar, szType, szText)
	if not tar then return false end
	local tCache = GetBuffList(tar) or {}
	szText = StringReplaceW(szText, "-", "|")
	local tText = SplitString(szText, "|")
	for _, szBuff in ipairs(tText) do
		for _, v in pairs(tCache) do
			local szBuffName = Table_GetBuffName(v.dwID, v.nLevel)
			if Table_BuffIsVisible(v.dwID, v.nLevel) then
				local nType = GetBuffInfo(v.dwID, v.nLevel, {}).nDetachType
				if nType ~= 0 then
					local szDetype = tDetachType[szType][nType]
					if szDetype and v == szDetype then
						return true
					end
				end
			end
		end
	end
	return false
end


local function CheckPrepare(tar, szText)
	if not tar then return false end
	local bPre, dwID, dwLevel, fP = tar.GetSkillPrepareState()
	local szSkillName = Table_GetSkillName(dwID, dwLevel)
	if bPre then
		if szText then
			local tSkill = SplitString(szText, "|")
			for _, szSkill in ipairs(tSkill) do
				local szName, szCmp, szVal = szSkill:match("(.-)([<>=]+)(.+)")
				if szName and szCmp and szVal then
					if szSkillName == szName then
						if Compare(szCmp, fP, szVal) then
							return true
						end
					end
				else
					if szSkillName == szSkill then
						return true
					end
				end
			end
			return false
		end
		return true
	end
	return false
end
--------------------------------------------------------

--------------------------------------------------------
local tOptions = {

	["distance"] = function(szCmp, szVal, me, tar)
		if not tar then
			return false
		end
		local nDist = GetDistanceByTarget(me, tar)
		return Compare(szCmp, nDist, szVal)
	end,

	["mounted"] = function(szCmp, szVal, me, tar)
		return me.bOnHorse
	end,

	["horse"] = function(szCmp, szVal, me, tar)
		return me.bOnHorse
	end,

	["unmounted"] = function(szCmp, szVal, me, tar)
		return not me.bOnHorse
	end,

	["nomounted"] = function(szCmp, szVal, me, tar)
		return not me.bOnHorse
	end,

	["nohorse"] = function(szCmp, szVal, me, tar)
		return not me.bOnHorse
	end,

	["combat"] = function(szCmp, szVal, me, tar)
		return me.bFightState
	end,

	["fight"] = function(szCmp, szVal, me, tar)
		return me.bFightState
	end,

	["nocombat"] = function(szCmp, szVal, me, tar)
		return not me.bFightState
	end,

	["nofight"] = function(szCmp, szVal, me, tar)
		return not me.bFightState
	end,

	["otaction"] = function(szCmp, szVal, me, tar)
		if szVal == "0" or szVal == "1" or szVal == "2" then
			return me.GetOTActionState() == tonumber(szVal)
		end
		return CheckPrepare(me, szVal)
	end,

	["ota"] = function(szCmp, szVal, me, tar)
		if szVal == "0" or szVal == "1" or szVal == "2" then
			return me.GetOTActionState() == tonumber(szVal)
		end
		return CheckPrepare(me, szVal)
	end,

	["nootaction"] = function(szCmp, szVal, me, tar)
		return not CheckPrepare(me, szVal)
	end,

	["noota"] = function(szCmp, szVal, me, tar)
		return not CheckPrepare(me, szVal)
	end,

	["exists"] = function(szCmp, szVal, me, tar)
		if tar then
			return true
		end
		return false
	end,

	["noexists"] = function(szCmp, szVal, me, tar)
		if not tar then
			return true
		end
		return false
	end,

	["dead"] = function(szCmp, szVal, me, tar)
		if tar and tar.nMoveState == MOVE_STATE.ON_DEATH then
			return true
		end
		return false
	end,

	["nodead"] = function(szCmp, szVal, me, tar)
		if tar and tar.nMoveState ~= MOVE_STATE.ON_DEATH then
			return true
		end
		return false
	end,

	["rage"] = function(szCmp, szVal, me, tar)
		local nRage = me.nCurrentRage
		return Compare(szCmp, nRage, szVal)
	end,

	["qidian"] = function(szCmp, szVal, me, tar)
		local nAte = me.nAccumulateValue
		if me.dwForceID == 1 then
			if nAte > 3 then
				nAte = 3
			end
		end
		return Compare(szCmp, nAte, szVal)
	end,

	["sun"] = function(szCmp, szVal, me, tar)
		if szVal == "moon" then
			return Compare(szCmp, me.nCurrentSunEnergy, me.nCurrentMoonEnergy)
		end
		nPer = me.nCurrentSunEnergy / me.nMaxSunEnergy * 100
		return Compare(szCmp, nPer, szVal)
	end,

	["moon"] = function(szCmp, szVal, me, tar)
		if szVal == "sun" then
			return Compare(szCmp, me.nCurrentMoonEnergy, me.nCurrentSunEnergy)
		end
		nPer = me.nCurrentMoonEnergy / me.nMaxMoonEnergy * 100
		return Compare(szCmp, nPer, szVal)
	end,

	["fullsun"] = function(szCmp, szVal, me, tar)
		return me.nSunPowerValue == 1
	end,

	["fullmoon"] = function(szCmp, szVal, me, tar)
		return me.nMoonPowerValue == 1
	end,

	["nofullsun"] = function(szCmp, szVal, me, tar)
		return me.nSunPowerValue ~= 1
	end,

	["nofullmoon"] = function(szCmp, szVal, me, tar)
		return me.nMoonPowerValue ~= 1
	end,

	["sunhit"] = function(szCmp, szVal, me, tar)
		return Compare(szCmp, nNextSunLevel, szVal)
	end,

	["moonhit"] = function(szCmp, szVal, me, tar)
		return Compare(szCmp, nNextMoonLevel, szVal)
	end,

	["life"] = function(szCmp, szVal, me, tar)
		local nPer = me.nCurrentLife / me.nMaxLife
		return Compare(szCmp, nPer, szVal)
	end,

	["mana"] = function(szCmp, szVal, me, tar)
		local nPer = me.nCurrentMana / me.nMaxMana
		return Compare(szCmp, nPer, szVal)
	end,

	["tlife"] = function(szCmp, szVal, me, tar)
		if not tar then
			return false
		end
		if tonumber(szVal) > 1 then
			return Compare(szCmp, tar.nCurrentLife, szVal)
		end
		local nPer = tar.nCurrentLife / tar.nMaxLife
		return Compare(szCmp, nPer, szVal)
	end,

	["tmaxlife"] = function(szCmp, szVal, me, tar)
		if not tar then
			return false
		end
		return Compare(szCmp, tar.nMaxLife, szVal)
	end,

	["ttlife"] = function(szCmp, szVal, me, tar)
		local ttar = GetTargetHandle(tar.GetTarget())
		if not ttar then
			return false
		end
		local nPer = ttar.nCurrentLife / ttar.nMaxLife
		return Compare(szCmp, nPer, szVal)
	end,

	["tmana"] = function(szCmp, szVal, me, tar)
		if not tar then
			return false
		end
		local nPer = tar.nCurrentMana / tar.nMaxMana
		return Compare(szCmp, nPer, szVal)
	end,

	["energy"] = function(szCmp, szVal, me, tar)
		local nEgy = me.nCurrentEnergy
		return Compare(szCmp, nEgy, szVal)
	end,

	["tm"] = function(szCmp, szVal, me, tar)
		local nEgy = me.nCurrentEnergy
		return Compare(szCmp, nEgy, szVal)
	end,

	["bomb"] = function(szCmp, szVal, me, tar)
		local nBmb = 0
		for z, x in pairs(tNpcList) do
			local npc = GetNpc(z)
			if npc and npc.dwTemplateID == 16000 and npc.dwEmployer == me.dwID then
				nBmb = nBmb + 1
			end
		end
		return Compare(szCmp, nBmb, szVal)
	end,

	["psd"] = function(szCmp, szVal, me, tar)
		local frame = Station.Lookup("Normal/PuppetActionBar")
		if frame and frame:IsVisible() then
			for k, v in pairs(tNpcList) do
				if v[1] == frame.dwNpcTemplateID and v[2] == me.dwID then
					local npc = GetNpc(k)
					if npc then
						local nDist = GetDistanceByTarget(me, npc)
						return Compare(szCmp, nDist, szVal)
					end
					return false
				end
			end
		end
		return false
	end,

	["ptd"] = function(szCmp, szVal, me, tar)
		local frame = Station.Lookup("Normal/PuppetActionBar")
		if frame and frame:IsVisible() then
			for k, v in pairs(tNpcList) do
				if v[1] == frame.dwNpcTemplateID and v[2] == me.dwID then
					local npc = GetNpc(k)
					if npc then
						local nDist = GetDistanceByTarget(tar, npc)
						return Compare(szCmp, nDist, szVal)
					end
					return false
				end
			end
		end
		return false
	end,

	["puppet"] = function(szCmp, szVal, me, tar)
		return CheckPuppet(szVal)
	end,

	["nopuppet"] = function(szCmp, szVal, me, tar)
		return not CheckPuppet(szVal)
	end,

	["prepare"] = function(szCmp, szVal, me, tar)
		return CheckPrepare(tar, szVal)
	end,

	["target"] = function(szCmp, szVal, me, tar)
		return CheckTarget(tar, szVal)
	end,

	["mount"] = function(szCmp, szVal, me, tar)
		return CheckMount(me, szVal)
	end,

	["nomount"] = function(szCmp, szVal, me, tar)
		return not CheckMount(me, szVal)
	end,

	["tname"] = function(szCmp, szVal, me, tar)
		return CheckName(tar, szVal)
	end,

	["tnoname"] = function(szCmp, szVal, me, tar)
		return not CheckName(tar, szVal)
	end,

	["tforce"] = function(szCmp, szVal, me, tar)
		return CheckForce(tar, szVal)
	end,

	["ttforce"] = function(szCmp, szVal, me, tar)
		local ttar = GetTargetHandle(tar.GetTarget())
		return CheckForce(ttar, szVal)
	end,

	["status"] = function(szCmp, szVal, me, tar)
		return CheckStatus(me, szVal)
	end,

	["nostatus"] = function(szCmp, szVal, me, tar)
		return not CheckStatus(me, szVal)
	end,

	["tstatus"] = function(szCmp, szVal, me, tar)
		return CheckStatus(tar, szVal)
	end,

	["tnostatus"] = function(szCmp, szVal, me, tar)
		return not CheckStatus(tar, szVal)
	end,

	["cd"] = function(szCmp, szVal, me, tar)
		return CheckSkillCD(szVal, true)
	end,

	["nocd"] = function(szCmp, szVal, me, tar)
		return CheckSkillCD(szVal, false)
	end,

	["cdtime"] = function(szCmp, szVal, me, tar)
		return CheckCDTime(szVal)
	end,

	["pet"] = function(szCmp, szVal, me, tar)
		return CheckPet(szVal)
	end,

	["nopet"] = function(szCmp, szVal, me, tar)
		return not CheckPet(szVal)
	end,

	["buff"] = function(szCmp, szVal, me, tar)
		return CheckBuff(me, szVal, false, false)
	end,

	["tbuff"] = function(szCmp, szVal, me, tar)
		return CheckBuff(tar, szVal, false, false)
	end,

	["mbuff"] = function(szCmp, szVal, me, tar)
		return CheckBuff(tar, szVal, false, true)
	end,

	["bufftime"] = function(szCmp, szVal, me, tar)
		return CheckBuff(me, szVal, true, false)
	end,

	["bt"] = function(szCmp, szVal, me, tar)
		return CheckBuff(me, szVal, true, false)
	end,

	["tbufftime"] = function(szCmp, szVal, me, tar)
		return CheckBuff(tar, szVal, true, true)
	end,

	["tbt"] = function(szCmp, szVal, me, tar)
		return CheckBuff(tar, szVal, true, false)
	end,

	["mbufftime"] = function(szCmp, szVal, me, tar)
		return CheckBuff(tar, szVal, true, false)
	end,

	["mbt"] = function(szCmp, szVal, me, tar)
		return CheckBuff(tar, szVal, true, true)
	end,

	["nobuff"] = function(szCmp, szVal, me, tar)
		return CheckNoBuff(me, szVal, false)
	end,

	["tnobuff"] = function(szCmp, szVal, me, tar)
		return CheckNoBuff(tar, szVal, false)
	end,

	["nombuff"] = function(szCmp, szVal, me, tar)
		return CheckNoBuff(tar, szVal, true)
	end,

	["mnobuff"] = function(szCmp, szVal, me, tar)
		return CheckNoBuff(tar, szVal, true)
	end,

	["btype"] = function(szCmp, szVal, me, tar)
		return CheckDetach(me, "btype", szVal)
	end,

	["detype"] = function(szCmp, szVal, me, tar)
		return CheckDetach(me, "detype", szVal)
	end,

	["tbtype"] = function(szCmp, szVal, me, tar)
		return CheckDetach(tar, "btype", szVal)
	end,

	["tdetype"] = function(szCmp, szVal, me, tar)
		return CheckDetach(tar, "btype", szVal)
	end,

	["threat"] = function(szCmp, szVal, me, tar)
		if tar then
			ApplyCharacterThreatRankList(tar.dwID)
			if dwCurrentTargetID ~= tar.dwID then
				dwCurrentTargetID = tar.dwID
			end
			return Compare(szCmp, dwMyHatred, szVal)
		end
		return false
	end,

	["aura"] = function(szCmp, szVal, me, tar)
		return CheckAura(szVal)
	end,

	["qichang"] = function(szCmp, szVal, me, tar)
		return CheckAura(szVal)
	end,

	["noaura"] = function(szCmp, szVal, me, tar)
		return CheckNoAura(szVal)
	end,

	["noqichang"] = function(szCmp, szVal, me, tar)
		return CheckNoAura(szVal)
	end,

	["angle"] = function(szCmp, szVal, me, tar)
		if not tar then
			return false
		end
		local nAngle = GetAngle(me, tar)
		if nAngle then
			return Compare(szCmp, nAngle, szVal)
		end
		return false
	end,
	
	--Xử lý Thiên Cơ Biến và Pet
	["pstate"] = function(szCmp, szVal, me, tar)
		if szVal == "attack" then
			return bAttackState
		elseif szVal == "stop" then
			return not bAttackState
		end
		return false
	end,

	["gcd"] = function(szCmp, szVal, me, tar)
		local bCool, nLeft, nTotal = me.GetSkillCDProgress(53, 1)
		local nTime = nLeft / GLOBAL.GAME_FPS
		return Compare(szCmp, nTime, szVal)
	end,

	["npcs"] = function(szCmp, szVal, me, tar)
		local nNum = 0
		local a, b, c = szVal:match("(%d+)([<>=]+)(%d+)")
		for k, v in pairs(tNpcList) do
			local npc = GetNpc(k)
			if npc and IsEnemy(me.dwID, k) and GetDistanceByTarget(me, npc) <= tonumber(a) then
				nNum = nNum + 1
			end
		end
		return Compare(b, nNum, c)
	end,

	["tnpcs"] = function(szCmp, szVal, me, tar)
		local nNum = 0
		local a, b, c = szVal:match("(%d+)([<>=]+)(%d+)")
		for k, v in pairs(tNpcList) do
			local npc = GetNpc(k)
			if npc and IsEnemy(tar.dwID, k) and GetDistanceByTarget(tar, npc) <= tonumber(a) then
				nNum = nNum + 1
			end
		end
		return Compare(b, nNum, c)
	end,

	["lastota"] = function(szCmp, szVal, me, tar)
		return szLastOTA == szVal
	end,

	["nolastota"] = function(szCmp, szVal, me, tar)
		return szLastOTA ~= szVal
	end,
}
setmetatable(tOptions, {__index = function(t, k)
	local function callback(...)
		if k == "true" then
			return true
		elseif k == "false" then
			return false
		else
			if string.sub(k, 1, 1) == "!" then
				if string.sub(k, 2, 2) == "t" then
					k = "tno" .. string.sub(k, 3, -1)
				else
					k = "no" .. string.sub(k, 2, -1)
				end
				return t[k](...)
			else
				print("Tham số [" .. k .. "] sai!")
				return false
			end
		end
	end
	return callback
end})


local function UITestCast(dwSkillID, dwLevel, index)
	local me, box = MeCache:Get(), tSkillBox[index]
	box:SetObject(UI_OBJECT_SKILL, dwSkillID, dwLevel)
	UpdataSkillCDProgress(me, box)
	if box:IsObjectEnable() and not box:IsObjectCoolDown() then
		return true
	end
	return false
end


local function GetPetSkill(szSkill)
	local frame = Station.Lookup("Normal/PetActionBar")
	if frame then
		local tSkill = Table_GetPetSkill(frame.dwNpcTemplateID)
		for v, k in pairs(tSkill) do
			local szSkillName = Table_GetSkillName(k[1], k[2])
			if szSkill == szSkillName then
				return k[1], k[2]
			end
		end
	end
	return nil
end


local function ProcessCondition(szText)
	if not szText then return end
	local function fnBracket(szText)
		while string.find(szText, "%b()") do
			szText = string.sub(szText:match("%b()"), 2, -2)
		end
		return szText
	end
	local function ProcessOperation(szText)
		local function fnOpt(szText)
			local me, tar = MeCache:Get(), TarCache:Get()
			local tText = SplitString(szText, ",")
			for _, v in ipairs(tText) do
				local nStart, nEnd, szCmp = string.find(v, "([:<>=]+)")
				if nStart then
					local szOpt, szVal = string.sub(v, 1, nStart - 1), string.sub(v, nEnd + 1, -1)
					if not tOptions[szOpt](szCmp, szVal, me, tar) then
						return false
					end
				else
					if not tOptions[v](nil, nil, me, tar) then
						return false
					end
				end
			end
			return true
		end
		if StringFindW(szText, ";") then
			local tText = SplitString(szText, ";")
			for _, v in ipairs(tText) do
				if fnOpt(v) then
					return true
				end
			end
		else
			if fnOpt(szText) then
				return true
			end
		end
		return false
	end
	local szRet, bRet = nil, nil
	while string.find(szText, "%b()") do
		szRet = fnBracket(szText)
		bRet = ProcessOperation(szRet)
		szText = string.gsub(szText, "%(" .. szRet .. "%)", tostring(bRet), 1)
	end
	return ProcessOperation(szText)
end


local function OnCastPlayerSkill(me, dwSkillID, dwLevel)
	if not (me.GetOTActionState() == 2 and bProtectChannelSkill) then
		OnAddOnUseSkill(dwSkillID, dwLevel)
		local skill = GetSkill(dwSkillID, dwLevel)
		if ((skill and skill.bIsChannelSkill) or tChannelSkill[dwSkillID]) and bProtectChannelSkill then
			return false
		end
		return true
	end
	return true
end


RegisterEvent("UPDATE_SELECT_TARGET", function()
	local me, tar = MeCache:Get(), TarCache:Get()
	if me then
		tar = GetTargetHandle(me.GetTarget())
	end
	MeCache:Set(me)
	TarCache:Set(tar)
end)

RegisterEvent("CUSTOM_DATA_LOADED", function()
	if arg0 == "Role" then
		local frame = Wnd.OpenWindow("Interface\\xMacro\\xMacro.ini", "xMacro")
		local hBox = frame:Lookup("",""):Lookup("Handle_Box")
		tSkillBox[1] = hBox:Lookup("Box")
		tSkillBox[2] = hBox:Lookup("Box_P")
	end
end)


RegisterEvent("DO_SKILL_CAST", function()
	local me = GetClientPlayer()
	if arg0 == me.dwID then
		if me.dwForceID == 10 then
			if GetLogicFrameCount() - dwLastMoonTime >= 32 then
				nNextMoonLevel, dwLastMoonTime = 1, 0
			end
			if GetLogicFrameCount() - dwLastSunTime >= 32 then
				nNextSunLevel, dwLastSunTime = 1, 0
			end
			if tMoonSkill[arg1] then
				nNextMoonLevel, dwLastMoonTime = tMoonSkill[arg1] + 1, GetLogicFrameCount()
				if nNextMoonLevel > 3 then
					nNextMoonLevel, dwLastMoonTime = 1, 0
				end
			elseif tSunSkill[arg1] then
				nNextSunLevel, dwLastSunTime = tSunSkill[arg1] + 1, GetLogicFrameCount()
				if nNextSunLevel > 3 then
					nNextSunLevel, dwLastSunTime = 1, 0
				end
			end
		elseif me.dwForceID == 7 then
			if arg1 == 3360 then
				bAttackState = true
			elseif arg1 == 3382 or arg1 == 3368 or arg1 == 3369 then
				bAttackState = false
			end
		end
	end
end)


do
	for k, v in ipairs({"DO_SKILL_PREPARE_PROGRESS", "DO_SKILL_CHANNEL_PROGRESS"}) do
		RegisterEvent(v, function()
			szLastOTA = Table_GetSkillName(arg1, arg2)
		end)
	end
end


RegisterEvent("OT_ACTION_PROGRESS_BREAK", function()
	if arg0 == UI_GetClientPlayerID() and szLastOTA then
		szLastOTA = nil
	end
end)


RegisterEvent("CHARACTER_THREAT_RANKLIST", function()
	if arg0 == dwCurrentTargetID then
		if arg2 and arg1[arg2] then
			dwTargetRank = arg1[arg2]
			if dwTargetRank == 0 then
				dwTargetRank = 65535
			end
			local nHatred = arg1[UI_GetClientPlayerID()] or 0
			dwMyHatred = (nHatred / dwTargetRank) * 100
		else
			dwTargetRank = 65535
		end
	end
end)


RegisterEvent("NPC_ENTER_SCENE", function()
	local npc = GetNpc(arg0)
	if npc then
		if not tNpcList[arg0] then
			tNpcList[arg0] = {}
		end
		tNpcList[arg0] = {npc.dwTemplateID, npc.dwEmployer, GetTime()}
	end
end)


RegisterEvent("NPC_LEAVE_SCENE", function()
	local t = tNpcList[arg0]
	if t then
		if (t[1] == 16175 or t[1] == 16176 or t[1] == 16177) and t[2] == UI_GetClientPlayerID() then
			bAttackState = false
		end
		t = nil
	end
end)


RegisterEvent("SKILL_UPDATE", function()
	local me = GetClientPlayer()
	MeCache:Set(me)
	tAllSkill = me.GetAllSkillList()
end)


RegisterEvent("SYNC_ROLE_DATA_END", function()
	local me = GetClientPlayer()
	if arg0 == me.dwID then
		MeCache:Set(me)
		tAllSkill = me.GetAllSkillList()
	end
end)

AppendCommand("skill", function(szText)
	local szCondition, szContent = szText:match("%s*[%[](.+)[%]]%s*(.+)")
	szText = szContent or szText
	local tSkills = SplitString(szText, ",")
	if (szBeforeCmd == "" or ProcessCondition(szBeforeCmd)) and (not szCondition or ProcessCondition(szCondition)) then
		local me = MeCache:Get()
		for _, v in ipairs(tSkills) do
			if v == "Nhảy lùi" then
				local bCool, nLeft, nTotal = me.GetSkillCDProgress(9007, 1)
				if not bCool or nLeft == 0 and nTotal == 0 then
					OnAddOnUseSkill(9007, 1)
				end
			elseif v == "Rút lui" then
				if UITestCast(9004, 1, 1) then
					return OnCastPlayerSkill(me, 9004, 1)
				end
			elseif v == "Ngồi thiền" or v == "Điều tức" then
				if me.nMoveState == MOVE_STATE.ON_STAND then
					OnAddOnUseSkill(17, 1)
				end
			elseif v == "stopota" or v == "dừng" then
				if me.GetOTActionState() ~= 0 then
					me.StopCurrentAction()
				end
			else
				local dwSkillID, dwLevel = GetPlayerSkillInfo(v)
				if dwSkillID then
					if UITestCast(dwSkillID, dwLevel, 1) then
						return OnCastPlayerSkill(me, dwSkillID, dwLevel)
					end
				else
					local dwForceID = me.dwForceID
					if dwForceID == 7 then
						dwSkillID, dwLevel = unpack(tPuppetSkill[v])
						if dwSkillID and UITestCast(dwSkillID, dwLevel, 2) and me.GetOTActionState() ~= 2 then
							OnAddOnUseSkill(dwSkillID, dwLevel)
						end
					elseif dwForceID == 6 then
						dwSkillID, dwLevel = GetPetSkill(v)
						if dwSkillID and UITestCast(dwSkillID, dwLevel, 2) then
							OnAddOnUseSkill(dwSkillID, dwLevel)
						end
					end
				end
			end
		end
	end
end)

AppendCommand("config", function(szText)
		if szText == "channel-on" then
		bProtectChannelSkill = true
	elseif szText == "channel-off" then
		bProtectChannelSkill = false
	end
	local nPos = string.find(szText, ":")
	if nPos then
		local szBefore = string.sub(szText, 1, nPos - 1)
		local szCmd = string.sub(szText, nPos + 1, -1)
		if szBefore == "before" then
			if szCmd == "null" then
				szBeforeCmd = ""
			else
				szBeforeCmd = szCmd:sub(2, -2)
			end
		end
	end
end)

AppendCommand("if", function(szText)

	if szText == "" then
		return
	end
	szBeforeCmd = szText:sub(2, -2)
end)

AppendCommand("elseif", function(szText)

	if szText == "" then
		return
	end
	szBeforeCmd = szText:sub(2, -2)
end)

AppendCommand("else", function()
	szBeforeCmd = ""
end)

AppendCommand("end", function(szText)

	local szCondition = szText:match("%s*[%[](.+)[%]]%s*(.+)")
	if not szCondition then
		szBeforeCmd = ""
	else
		if (szBeforeCmd == "" or ProcessCondition(szBeforeCmd)) and ProcessCondition(szCondition) then
			return false
		end
	end
end)

AppendCommand("return", function(szText)

	if szBeforeCmd == "" or ProcessCondition(szBeforeCmd) then
		local szCondition = szText:match("%s*[%[](.+)[%]]%s*(.+)")
		if szCondition and ProcessCondition(szCondition) then
			return false
		end
	end
end)

AppendCommand("umwp", function(szText)

	local szCondition = szText:match("%s*[%[](.+)[%]]%s*(.+)")
	if ProcessCondition(szCondition) then
		local me = MeCache:Get()
		local tEquip = {EQUIPMENT_INVENTORY.MELEE_WEAPON, EQUIPMENT_INVENTORY.BIG_SWORD}
		local tFreeBoxList = GetBagFreeBoxList()
		for k, v in ipairs(tEquip) do
			local item = me.GetItem(INVENTORY_INDEX.EQUIP, v)
			if item then
				local dwBox, dwX = tFreeBoxList[k][1], tFreeBoxList[k][2]
				OnExchangeItem(INVENTORY_INDEX.EQUIP, v, dwBox, dwX)
				OutputWarningMessage("MSG_WARNING_GREEN", "[" .. item.szName .. "] đã tháo gỡ!", 1)
			end
		end
	end
end)

AppendCommand("omwp", function(szText)

	local szCondition, szContent = szText:match("[[](.+)[]]%s*(.+)")
	if not szContent then print("") return end
	if ProcessCondition(szCondition) then
		local me = MeCache:Get()
		local dwBox, dwX = GetItemPos(szContent)
		local item = GetPlayerItem(me, dwBox, dwX)
		if item then
			local eRetCode, nEquipPos = me.GetEquipPos(dwBox, dwX)
			if eRetCode == 1 then
				OnExchangeItem(dwBox, dwX, INVENTORY_INDEX.EQUIP, nEquipPos)
				OutputWarningMessage("MSG_WARNING_GREEN", "[" .. item.szName .. "] đã trang bị!", 1)
			end
		end
	end
end)

AppendCommand("use", function(szText)

	local szCondition, szContent = szText:match("%s*[%[](.+)[%]]%s*(.+)")
	if not szContent then print("Tham số sai") return end
	if ProcessCondition(szCondition) then
		local me = MeCache:Get()
		for k, v in ipairs(tEquipmentPos) do
			local item = me.GetItem(INVENTORY_INDEX.EQUIP, v)
			if item and item.szName == szContent then
				local bCool, nLeft, nTotal, bBroken = me.GetItemCDProgress(item.dwID)
				if nLeft == 0 then
					OnUseItem(INVENTORY_INDEX.EQUIP ,v)
				end
			end
		end
	end
end)

AppendCommand("item", function(szText)
	local szCondition, szContent = szText:match("%s*[%[](.+)[%]]%s*(.+)")
	if not szContent then print("Tham số sai") return end
	if ProcessCondition(szCondition) then
		local me = MeCache:Get()
		local dwBox, dwX = GetItemPos(szContent)
		local item = GetPlayerItem(me, dwBox, dwX)
		if item then
			local bCool, nLeft, nTotal, bBroken = me.GetItemCDProgress(item.dwID)
			if nLeft == 0 then
				OnUseItem(dwBox, dwX)
				OutputWarningMessage("MSG_WARNING_GREEN", "Sử dụng [" .. item.szName .. "]!", 1)
			end
		end
	end
end)

AppendCommand("cbuff", function(szText)
	local szCondition, szContent = szText:match("%s*[%[](.+)[%]]%s*(.+)")
	szText = szContent or szText
	if not szCondition or ProcessCondition(szCondition) then
		local me = MeCache:Get()
		local tName = SplitString(szText, ",")
		for _, szName in ipairs(tName) do
			local tCache = GetBuffList(me) or {}
			for _, v in pairs(tCache) do
				local szBuffName = Table_GetBuffName(v.dwID, v.nLevel)
				if szBuffName == szName then
					me.CancelBuff(v.nIndex)
				end
			end
		end
	end
end)

AppendCommand("talk", function(szText)
	local szCondition, szContent = szText:match("%s*[%[](.+)[%]]%s*(.+)")
	szText = szContent or szText
	if not szCondition or ProcessCondition(szCondition) then
		local me = MeCache:Get()
		me.Talk(PLAYER_TALK_CHANNEL.NEARBY, "", {{type = "text", text = szText}})
	end
end)

AppendCommand("print", function(szText)
	local szCondition, szContent = szText:match("%s*[%[](.+)[%]]%s*(.+)")
	szText = szContent or szText
	if not szCondition or ProcessCondition(szCondition) then
		Output(szCondition, szText)
	end
end)

GetBuffList = function(obj)
	local aBuffTable = {}
	local nCount = obj.GetBuffCount()
	for i=1,nCount,1 do
		local dwID, nLevel, bCanCancel, nEndFrame, nIndex, nStackNum, dwSkillSrcID, bValid = obj.GetBuff(i - 1)
		if dwID then
			table.insert(aBuffTable,{dwID = dwID, nLevel = nLevel, bCanCancel = bCanCancel, nEndFrame = nEndFrame, nIndex = nIndex, nStackNum = nStackNum, dwSkillSrcID = dwSkillSrcID, bValid = bValid})
		end
	end
	return aBuffTable
end

xMacro = {}

function xMacro.OnFrameBreathe()
  local frame = Station.Lookup("Topmost/MacroSettingPanel")
  if frame then
    local handle = frame:Lookup("Edit_Content")
    handle:SetLimit(4096)
    local nUse = handle:GetTextLength()
    frame:Lookup("", "Text_MaxByte"):SetText(FormatString(g_tStrings.MACRO_INPUT_LIMIT, nUse, 4096))
  end
end

Wnd.OpenWindow("Interface/xMacro/xMacro.ini", "xMacro")