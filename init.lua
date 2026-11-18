-- HIRO hub - Final Anti-Pull & Clean Script (No Left Drag, No Death)
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

if CoreGui:FindFirstChild("HIROHubGui") then
	CoreGui.HIROHubGui:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HIROHubGui"
screenGui.Parent = CoreGui

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 210, 0, 130)
mainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.75, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "  HIRO hub"
title.TextColor3 = Color3.fromRGB(0, 200, 255)
title.TextSize = 16
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = mainFrame

-- زر التصغير/التكبير (-)
local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
minimizeBtn.Position = UDim2.new(0.82, 0, 0.05, 0)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
minimizeBtn.Text = "-"
minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minimizeBtn.TextSize = 18
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = mainFrame

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 6)
minCorner.Parent = minimizeBtn

-- زر التفعيل
local dropBtn = Instance.new("TextButton")
dropBtn.Size = UDim2.new(0.9, 0, 0, 50)
dropBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
dropBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
dropBtn.Text = "Drop Brainrot: OFF"
dropBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
dropBtn.TextSize = 15
dropBtn.Font = Enum.Font.GothamSemibold
dropBtn.Parent = mainFrame

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = dropBtn

local isOpen = true
minimizeBtn.Activated:Connect(function()
	isOpen = not isOpen
	dropBtn.Visible = isOpen
	if isOpen then
		mainFrame.Size = UDim2.new(0, 210, 0, 130)
		minimizeBtn.Text = "-"
	else
		mainFrame.Size = UDim2.new(0, 210, 0, 40)
		minimizeBtn.Text = "+"
	end
end)

local dropActive = false
local dropConnection = nil
local offsetDepth = 2.2 -- العمق المثالي للبرينروت تحت قدميك

dropBtn.Activated:Connect(function()
	dropActive = not dropActive
	if dropActive then
		dropBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
		dropBtn.Text = "Drop Brainrot: ON"
		
		dropConnection = RunService.RenderStepped:Connect(function()
			local char = player.Character
			if not char then return end
			
			local rootPart = char:FindFirstChild("HumanoidRootPart")
			if rootPart then
				local playerPos = rootPart.Position
				
				for _, obj in ipairs(workspace:GetChildren()) do
					if obj ~= char and not obj:IsDescendantOf(char) then
						local targetPart = nil
						if obj:IsA("Model") then
							targetPart = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChildWhichIsA("BasePart")
						elseif obj:IsA("BasePart") then
							targetPart = obj
						end
						
						if targetPart then
							local dist = (targetPart.Position - playerPos).Magnitude
							if dist < 40 then
								-- قطع أي روابط سحب (Welds/Constraints) لكي لا يسحبك لليسار
								for _, descendant in ipairs(obj:GetDescendants()) do
									if descendant:IsA("Weld") or descendant:IsA("WeldConstraint") or descendant:IsA("Motor6D") then
										if descendant.Part0 == rootPart or descendant.Part1 == rootPart then
											descendant:Destroy()
										end
									end
									if descendant:IsA("BasePart") then
										descendant.CanCollide = false
									end
								end
								
								targetPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
								targetPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
								
								-- تثبيت البرينروت تحت قدميك مباشرة وبشكل مستقل تماماً عن اللاعب
								targetPart.CFrame = CFrame.new(playerPos.X, playerPos.Y - offsetDepth, playerPos.Z)
							end
						end
					end
				end
			end
		end)
	else
		dropBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		dropBtn.Text = "Drop Brainrot: OFF"
		if dropConnection then
			dropConnection:Disconnect()
			dropConnection = nil
		end
	end
end)
