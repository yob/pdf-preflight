require "spec_helper"

class MutatingProfile
  include Preflight::Profile

  rule Preflight::Rules::PageBoxSize, :MediaBox, [
    { :width => 216, :height => 279.5, :units => :mm }
  ]
end

describe "A profile with a rule that mutates it's arguments" do

  it "passes a valid file 2 consequtive times" do
    filename  = pdf_spec_file("version_1_3")
    preflight = MutatingProfile.new
    preflight.check(filename).should be_empty

    preflight = MutatingProfile.new
    preflight.check(filename).should be_empty
  end
end
