require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::OnlyEmbeddedFonts do

  it "should pass a PDF/X-1a file with a no subsetting" do
    filename = pdf_spec_file("pdfx-1a-no-subsetting")
    rule     = Preflight::Rules::OnlyEmbeddedFonts.new

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should pass a PDF/X-1a file that uses subsetting" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::OnlyEmbeddedFonts.new

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should pass a file that only uses Type 3 fonts"

  it "should pass a file that has no text"

  it "fail a file that uses one of the base-14 fonts without embedding" do
    filename = pdf_spec_file("standard_14_font")
    rule     = Preflight::Rules::OnlyEmbeddedFonts.new

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end
end
