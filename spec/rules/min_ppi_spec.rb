require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::MinPpi do

  it "pass files with a no raster images" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::MinPpi.new(300)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "pass files with only 300 ppi raster images" do
    filename = pdf_spec_file("300ppi")
    rule     = Preflight::Rules::MinPpi.new(300)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "fail files with a 75ppi raster image" do
    filename = pdf_spec_file("72ppi")
    rule     = Preflight::Rules::MinPpi.new(300)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should have(1).item

      issue = rule.issues.first
      issue.horizontal_ppi.should == 72.0
      issue.vertical_ppi.should   == 72.0
      issue.top_left.should       == [36.0, 586.0]
      issue.bottom_left.should    == [36, 133]
      issue.bottom_right.should   == [640,133]
      issue.top_right.should      == [640, 586]
    end
  end

  it "fail files with a 150ppi raster image within a Form XObject" do
    filename = pdf_spec_file("low_ppi_image_within_form_xobject")
    rule     = Preflight::Rules::MinPpi.new(200)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.size.should == 1

      issue = rule.issues.first
      issue.horizontal_ppi.should == 148.151
      issue.vertical_ppi.should   == 148.151
      issue.top_left.should       == [250.24502999999999, 492.52378999999996]
      issue.bottom_left.should    == [250.24502999999999, 401.64329]
      issue.bottom_right.should   == [323.14383999999995, 401.64329]
      issue.top_right.should      == [323.14383999999995, 492.52378999999996]
    end
  end

  it "pass files with no raster images that use a Form XObject" do
    filename = pdf_spec_file("form_xobject")
    rule     = Preflight::Rules::MinPpi.new(300)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

end
