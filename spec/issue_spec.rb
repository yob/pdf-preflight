require File.dirname(__FILE__) + "/spec_helper"

describe Preflight::Issue do
  describe "initialisation" do

    let!(:issue) do
      Preflight::Issue.new("Transparency detected",
                           Preflight::Rules::NoTransparency,
                           {:page => 1}
                          )
    end

    it "should return the description" do
      issue.description.should == "Transparency detected"
    end

    it "should return the rule as a symbol" do
      issue.rule.should == :"Preflight::Rules::NoTransparency"
    end

    it "should return the attributes" do
      issue.attributes.should == {:page => 1}
    end

    it "should return the attributes via methods" do
      issue.page.should == 1
    end

    it "should return true to a respond_to? call" do
      issue.respond_to?(:page).should be_true
    end

  end
end
