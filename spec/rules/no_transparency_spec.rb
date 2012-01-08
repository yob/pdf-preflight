require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::NoTransparency do

  it "should fail files that use transparency" do
    filename = pdf_spec_file("transparency") # page 2 has transparency
    rule     = Preflight::Rules::NoTransparency.new

    PDF::Reader.open(filename) do |reader|
      reader.page(2).walk(rule)
      rule.issues.should have(1).item
      issue = rule.issues.first
      issue.rule.should == :"Preflight::Rules::NoTransparency"
      issue.attributes[:page].should == 2
    end
  end

  it "should pass files that have no transparency" do
    filename = pdf_spec_file("transparency") # page 1 has no transparency
    rule     = Preflight::Rules::NoTransparency.new

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

end
