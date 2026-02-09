-- ServerScriptService > ChefSystemScript
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService") -- 필요시 사용

-- [1] 레시피 설정 (기존과 동일)
local RECIPES = {
	{ Name = "Beef Steak", Ingredients = {"Steak", "Asparagus"}, Base = "Steak" },
	{ Name = "Salmon Meuniere", Ingredients = {"Salmon", "Lemon"}, Base = "Salmon" },
	{ Name = "Pasta Carbonara", Ingredients = {"Pasta", "Bacon"}, Base = "Bacon" },
	{ Name = "Tomato Soup", Ingredients = {"Tomato", "Bread"}, Base = "Tomato" }
}

local FoodStorage = ServerStorage:WaitForChild("FinishedFood")

-- [가스레인지 설정 - 경로 확인하세요!]
local STOVE_PART = workspace:WaitForChild("CookingStation"):WaitForChild("StovePart")
local START_PROMPT = STOVE_PART:WaitForChild("StartCookPrompt")
local DONE_SOUND = STOVE_PART:FindFirstChild("DoneSound") -- '띵' 소리

-------------------------------------------------------------
-- [2] 조리 로직 (가스레인지에서 실행됨)
-------------------------------------------------------------
local function startCooking(tool)
	if tool:GetAttribute("IsCooking") then return end
	tool:SetAttribute("IsCooking", true)

	print("🔥🔥 조리 시작! 가스레인지 가동.")

	-- 경로 수정: tool.GrillPart.Handle -> 구조에 맞게 확인 필요
	local grillPart = tool:FindFirstChild("GrillPart")
	local smoke = grillPart and grillPart:FindFirstChild("Smoke")

	-- 30초 후 연기
	task.delay(30, function()
		if tool and tool.Parent then
			if smoke then smoke.Enabled = true end
			print("💨 연기 발생!")
		end
	end)

	-- 60초 후 완료
	task.delay(60, function()
		if tool and tool.Parent then
			tool:SetAttribute("Status", "Cooked")
			if smoke then smoke.Enabled = false end

			-- 띵! 소리 재생
			if DONE_SOUND then DONE_SOUND:Play() end

			-- 팬 집기 프롬프트 활성화
			local pickup = tool:FindFirstChild("PickupPrompt", true)
			if pickup then
				pickup.Enabled = true
				pickup.ActionText = "요리 완료! 집기"
			end
			print("✅ 요리 완성!")
		end
	end)
end

-------------------------------------------------------------
-- [3] 상호작용 로직
-------------------------------------------------------------

-- A. 재료 담기 (기존 로직에서 startCooking 호출만 제거)
for _, dispenser in pairs(workspace.hellno:GetChildren()) do
	local prompt = dispenser:FindFirstChild("ProximityPrompt")
	if prompt then
		prompt.Triggered:Connect(function(player)
			local tool = player.Character and player.Character:FindFirstChild("PortableGrill")
			if tool then
				local ingredientName = dispenser.Name
				if tool:GetAttribute("Has_"..ingredientName) then return end

				tool:SetAttribute("Has_"..ingredientName, true)
				print("재료 추가됨: " .. ingredientName)
				-- 여기서 자동으로 startCooking을 하지 않습니다! 가스레인지로 가야 해요.
			else
				warn("그릴을 손에 들어주세요.")
			end
		end)
	end
end

-- B. 가스레인지에 팬 놓기 (새로 추가된 로직)
START_PROMPT.Triggered:Connect(function(player)
	local tool = player.Character and player.Character:FindFirstChild("PortableGrill")
	if tool then
		-- 재료가 다 찼는지 검사 (선택 사항, 여기선 바로 놓기 가능하게 설정)
		START_PROMPT.Enabled = false
		tool.Parent = workspace

		local handle = tool:FindFirstChild("Handle")
		if handle then
			handle.CFrame = STOVE_PART.CFrame * CFrame.new(0, 0.5, 0)
			handle.Anchored = true
		end

		-- 가스레인지에 놓는 순간 조리 시작!
		startCooking(tool)
	end
end)

-- C. 팬 회수 (PickupPrompt 트리거)
-- 이 부분은 각 팬에 들어있는 PickupPrompt가 담당합니다.

-- D. 플레이팅 (기존 로직 유지)
local plateStation = workspace:WaitForChild("PlatingStation")
local platePrompt = plateStation:FindFirstChild("ProximityPrompt")

if platePrompt then
	platePrompt.Triggered:Connect(function(player)
		-- D. 플레이팅 스테이션 (접시)
		local plateStation = workspace:WaitForChild("PlatingStation")
		local platePrompt = plateStation:FindFirstChild("ProximityPrompt")

		if platePrompt then
			platePrompt.Triggered:Connect(function(player)
				local character = player.Character
				-- 현재 손에 들고 있는 팬을 찾음
				local tool = character and character:FindFirstChild("PortableGrill")

				if tool then
					-- 1. 요리가 다 익었는지(가스레인지 과정을 거쳤는지) 확인
					if tool:GetAttribute("Status") ~= "Cooked" then
						warn("요리가 아직 덜 익었거나 조리되지 않았습니다!")
						return
					end

					-- 2. 레시피 대조 (무슨 요리인지 판별)
					local foundRecipe = nil

					for _, recipe in pairs(RECIPES) do
						local match = true
						-- 레시피에 적힌 모든 재료가 팬의 Attribute에 담겨 있는지 체크
						for _, ing in pairs(recipe.Ingredients) do
							if not tool:GetAttribute("Has_" .. ing) then
								match = false
								break
							end
						end

						if match then
							foundRecipe = recipe.Name
							break
						end
					end

					-- 3. 결과물 지급
					if foundRecipe then
						print("🍽️ 서빙 준비 완료: " .. foundRecipe)

						-- 사용한 그릴(팬) 삭제
						tool:Destroy()

						-- ServerStorage에서 진짜 요리 모델 가져오기
						local foodTool = FoodStorage:FindFirstChild(foundRecipe)
						if foodTool then
							local clone = foodTool:Clone()
							clone.Parent = player.Backpack
							-- 플레이어가 바로 손에 들도록 설정
							character.Humanoid:EquipTool(clone) 
							print("✅ " .. foundRecipe .. "가 인벤토리에 지급되었습니다.")
						else
							warn("오류: ServerStorage.FinishedFood에 '" .. foundRecipe .. "' 모델이 없습니다!")
						end
					else
						warn("알 수 없는 요리입니다. 재료 조합을 확인하세요.")
					end

				else
					warn("완성된 요리가 담긴 그릴(PortableGrill)을 손
	end)
end

