require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::PageBoxSize do

  it "should pass files with a correctly sized MediaBox defined by Float points" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxSize.new(:MediaBox,
                                                 :width  => 595.276,
                                                 :height => 841.89,
                                                 :units  => :pts)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should pass files with a correctly sized MediaBox defined by Range points" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxSize.new(:MediaBox,
                                                 :width => 595..596,
                                                 :height => 841..842,
                                                 :units => :pts)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should fail files with an incorrectly sized MediaBox defined by Float points" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxSize.new(:MediaBox,
                                                 :width => 590,
                                                 :height => 841.89,
                                                 :units => :pts)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end

  it "should fail files with an incorrectly sized MediaBox defined by Range points" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxSize.new(:MediaBox,
                                                 :width => 590..591,
                                                 :height => 841.89,
                                                 :units => :pts)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end

  it "should pass files with a correctly sized MediaBox defined by Float mm" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxSize.new(:MediaBox,
                                                 :width => 210,
                                                 :height => 297,
                                                 :units => :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should pass files with a correctly sized MediaBox defined by Range mm" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxSize.new(:MediaBox,
                                                 :width => 209..211,
                                                 :height => 296..298,
                                                 :units => :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should fail files with an incorrectly sized MediaBox defined by Float mm" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxSize.new(:MediaBox,
                                                 :width => 209,
                                                 :height => 297,
                                                 :units => :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end

  it "should fail files with an incorrectly sized MediaBox defined by Range mm" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxSize.new(:MediaBox,
                                                 :width => 200..201,
                                                 :height => 295..297,
                                                 :units => :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end

  it "should pass files with multiple MediaBoxes, defined by Float mm, one of which is valid" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxSize.new(:MediaBox, [
      { :width => 210, :height => 297, :units => :mm },
      { :width => 297, :height => 420, :units => :mm }
    ])

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "should pass files with a box that isn't present" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::PageBoxSize.new(:ArtBox,
                                                 :width => 10, 
                                                 :height => 10, 
                                                 :units => :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

end
