require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::NoTransparency do

  context "a page with transparent xobjects" do
    let!(:filename) { pdf_spec_file("transparency") }

    it "should fail with an issue" do
      rule     = Preflight::Rules::NoTransparency.new

      PDF::Reader.open(filename) do |reader|
        reader.page(2).walk(rule)

        rule.issues.should have(1).item

        issue = rule.issues.first
        issue.rule.should         == :"Preflight::Rules::NoTransparency"
        issue.page.should         == 2
        issue.top_left.should     == [99.0, 540.89]
        issue.bottom_left.should  == [99.0, 742.89]
        issue.bottom_right.should == [301.0, 742.89]
        issue.top_right.should    == [301.0, 540.89]
      end
    end
  end

  context "a page without transparent xobjects" do
    let!(:filename) { pdf_spec_file("transparency") }

    it "should pass with no issues" do
      rule     = Preflight::Rules::NoTransparency.new

      PDF::Reader.open(filename) do |reader|
        reader.page(1).walk(rule)
        rule.issues.should be_empty
      end
    end
  end

end
