require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::NoPageRotation do

  it "pass files with no page Rotate entry" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::NoPageRotation.new

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "fail files with a page Rotate entry" do
    filename = pdf_spec_file("rotate")
    rule     = Preflight::Rules::NoPageRotation.new

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end

end
