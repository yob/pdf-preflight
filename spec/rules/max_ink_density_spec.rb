require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::MaxInkDensity do

  it "pass files with a no CYMK colors" do
    filename = pdf_spec_file("rgb-hexagon")
    rule     = Preflight::Rules::MaxInkDensity.new(100)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "pass files with a CYMK color that has a suitable ink density" do
    filename = pdf_spec_file("pdfx-1a-no-subsetting")
    rule     = Preflight::Rules::MaxInkDensity.new(300)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "fail files with a CYMK color that has a high ink density" do
    filename = pdf_spec_file("pdfx-1a-no-subsetting")
    rule     = Preflight::Rules::MaxInkDensity.new(50)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end


end
