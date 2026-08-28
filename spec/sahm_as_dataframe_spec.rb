require "spec_helper"

RSpec.describe SahmAsDataframe do
  it "has a version number" do
    expect(SahmAsDataframe::VERSION).not_to be nil
  end

  it "loads the Client class" do
    expect(defined?(SahmAsDataframe::Client)).to eq("constant")
  end
end
