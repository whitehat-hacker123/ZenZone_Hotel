-- 장식구 지급기 내부의 Script
local ServerStorage = game:GetService("ServerStorage")

-- [설정]
local ACCESSORY_NAME = "ChefHat" -- ServerStorage에 있는 장식구 모델 이름
local ATTACH_PART = "Head"      -- 붙일 신체 부위 (Head, UpperTorso, Back 등)

local prompt = script.Parent

prompt.Triggered:Connect(function(player)
	local character = player.Character
	if not character then return end
	
	-- 1. 이미 해당 장식구를 착용 중인지 확인 (중복 방지)
	if character:FindFirstChild(ACCESSORY_NAME) then
		print("이미 장식구를 착용하고 있습니다.")
		return
	end

	-- 2. ServerStorage에서 모델 가져오기
	local originalModel = ServerStorage:FindFirstChild(ACCESSORY_NAME)
	if not originalModel then
		warn(ACCESSORY_NAME .. " 모델을 ServerStorage에서 찾을 수 없습니다.")
		return
	end

	-- 3. 모델 복제 및 배치
	local clonedModel = originalModel:Clone()
	clonedModel.Name = ACCESSORY_NAME
	
	-- 모델의 기본 위치를 캐릭터 부위로 이동
	local targetPart = character:FindFirstChild(ATTACH_PART)
	if targetPart then
		-- 모델 내부의 모든 파트 처리 (PrimaryPart 기준 권장)
		if clonedModel:IsA("Model") then
			if not clonedModel.PrimaryPart then
				warn("장식구 모델에 PrimaryPart가 설정되어 있어야 정확하게 붙습니다!")
				clonedModel.Parent = character -- 일단 넣기
				return
			end
			
			clonedModel.Parent = character
			clonedModel:SetPrimaryPartCFrame(targetPart.CFrame)
			
			-- 4. 용접(Weld) 생성: 캐릭터가 움직여도 떨어지지 않게 함
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = clonedModel.PrimaryPart
			weld.Part1 = targetPart
			weld.Parent = clonedModel.PrimaryPart
			
			print(ACCESSORY_NAME .. " 장착 완료!")
		end
	end
end)
