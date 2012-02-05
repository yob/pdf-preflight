require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::MinBleed do

  it "pass files with an image that doesn't require bleed" do
    filename = pdf_spec_file("image_no_bleed_5mm_gap")

    # objects within 1mm of the TrimBox must have at least 4mm bleed
    rule     = Preflight::Rules::MinBleed.new(1, 4, :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "pass files with an image that has 5mm bleed" do
    filename = pdf_spec_file("image_5mm_bleed")

    # objects within 1mm of the TrimBox must have at least 4mm bleed
    rule     = Preflight::Rules::MinBleed.new(1, 4, :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "fail files with an image that touches the TrimBox but doesn't bleed" do
    filename = pdf_spec_file("image_no_bleed")
    rule     = Preflight::Rules::MinBleed.new(1, 4, :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end

  it "pass files with a rectangle that doesn't require bleed" do
    filename = pdf_spec_file("rectangle_no_bleed_5mm_gap")

    # objects within 1mm of the TrimBox must have at least 4mm bleed
    rule     = Preflight::Rules::MinBleed.new(1, 4, :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "pass files with a rectangle that has 5mm bleed" do
    filename = pdf_spec_file("rectangle_5mm_bleed")

    # objects within 1mm of the TrimBox must have at least 4mm bleed
    rule     = Preflight::Rules::MinBleed.new(1, 4, :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "fail files with a rectangle that touches the TrimBox but doesn't bleed" do
    filename = pdf_spec_file("rectangle_no_bleed")
    rule     = Preflight::Rules::MinBleed.new(1, 4, :mm)

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end

end
