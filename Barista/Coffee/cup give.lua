local prox = script.parent
local rep = game.Getservice(Replicatedtorage):WaitForChild("cup")

prox.PromptTriggered:Connect(funtion(player))
  local new = rep.Cup:Clone
  new.Parent = player:Waitforchild("Backpack")
end
