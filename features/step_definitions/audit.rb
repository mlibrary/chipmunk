When("I initiate an audit") do
  api_post("/v1/audits")
end

Then("I learn where the audit is being tracked") do
  expect(last_response.status).to eql(201)
  expect(last_response["Location"]).to eql("/v1/audits/#{Audit.first.id}")
end

When("I ask for the status of the audit") do
  api_get("/v1/audits/#{@audit.id}")
end

Then(/I see that (\d+) packages were audited/) do |quantity|
  expect(JSON.parse(last_response.body)["packages"]).to eql(Integer(quantity))
end

Then("I see how many have failed") do
  expect(JSON.parse(last_response.body)["failures"]).to eql(0)
end

Given("I have initiated an audit") do
  @audit = Fabricate(:audit)
end

