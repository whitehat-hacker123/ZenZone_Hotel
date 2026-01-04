local prox = script.parent
local rep = game.Getservice(Replicatedtorage):WaitForChild("cup")

prox.PromptTriggered:Connect(funtion(player))
  rep.parent = player.backpack
end