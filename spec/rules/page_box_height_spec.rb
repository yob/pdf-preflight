require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::PageBoxHeight do

  it "should pass files with a correctly sized MediaBox defined by Float points" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxHeight.new(:MediaBox, 841.89, :pts)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should pass files with a correctly sized MediaBox defined by Range points" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxHeight.new(:MediaBox, 841..842, :pts)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should fail files with an incorrectly sized MediaBox defined by Float points" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxHeight.new(:MediaBox, 841, :pts)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end

  it "should fail files with an incorrectly sized MediaBox defined by Range points" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxHeight.new(:MediaBox, 800..801, :pts)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end


  it "should pass files with a correctly sized MediaBox defined by Float mm" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxHeight.new(:MediaBox, 297, :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should pass files with a correctly sized MediaBox defined by Range mm" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxHeight.new(:MediaBox, 296..298, :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should fail files with an incorrectly sized MediaBox defined by Float mm" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxHeight.new(:MediaBox, 296, :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end

  it "should fail files with an incorrectly sized MediaBox defined by Range mm" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxHeight.new(:MediaBox, 290..291, :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end



  it "should pass files with a correctly sized MediaBox defined by Float inches" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxHeight.new(:MediaBox, 11.69, :in)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should pass files with a correctly sized MediaBox defined by Range inches" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxHeight.new(:MediaBox, 11..12, :in)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should fail files with an incorrectly sized MediaBox defined by Float inches" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxHeight.new(:MediaBox, 11, :in)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end

  it "should fail files with an incorrectly sized MediaBox defined by Range inches" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxHeight.new(:MediaBox, 10..11, :in)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end
end
