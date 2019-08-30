Fabricator(:deposit) do
  user
  artifact
  status { Deposit.statuses[:started] }
end
