Fabricator(:artifact) do
  id { SecureRandom.uuid }
  user { Fabricate(:user) }
  format { ["bag", "bag:versioned"].sample }
  content_type { ["digital", "audio"].sample }
  revisions []
end
