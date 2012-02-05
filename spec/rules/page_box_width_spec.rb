require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::PageBoxWidth do

  it "should pass files with a correctly sized MediaBox defined by Float points" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxWidth.new(:MediaBox, 595.276, :pts)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should pass files with a correctly sized MediaBox defined by Range points" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxWidth.new(:MediaBox, 595..596, :pts)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should fail files with an incorrectly sized MediaBox defined by Float points" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxWidth.new(:MediaBox, 590, :pts)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end

  it "should fail files with an incorrectly sized MediaBox defined by Range points" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxWidth.new(:MediaBox, 590..591, :pts)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end


  it "should pass files with a correctly sized MediaBox defined by Float mm" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxWidth.new(:MediaBox, 210, :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should pass files with a correctly sized MediaBox defined by Range mm" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxWidth.new(:MediaBox, 209..211, :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should fail files with an incorrectly sized MediaBox defined by Float mm" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxWidth.new(:MediaBox, 209, :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end

  it "should fail files with an incorrectly sized MediaBox defined by Range mm" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxWidth.new(:MediaBox, 200..201, :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end



  it "should pass files with a correctly sized MediaBox defined by Float inches" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxWidth.new(:MediaBox, 8.26, :in)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should pass files with a correctly sized MediaBox defined by Range inches" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxWidth.new(:MediaBox, 8..9, :in)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should fail files with an incorrectly sized MediaBox defined by Float inches" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxWidth.new(:MediaBox, 9, :in)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end

  it "should fail files with an incorrectly sized MediaBox defined by Range inches" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxWidth.new(:MediaBox, 10..11, :in)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end
end
