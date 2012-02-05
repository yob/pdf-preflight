require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::CropboxMatchesMediabox do

  it "should pass files with a CrobBox that matches the MediaBox" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::CropboxMatchesMediabox.new

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should fail files with a CrobBox that doesn't match the MediaBox" do
    filename = pdf_spec_file("cropbox_doesnt_match_mediabox")
    rule     = Preflight::Rules::CropboxMatchesMediabox.new

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end

end
