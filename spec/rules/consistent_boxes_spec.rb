require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::ConsistentBoxes do

  it "pass files with identical MediaBox on each page" do
    filename = pdf_spec_file("two_pages")
    rule     = Preflight::Rules::ConsistentBoxes.new

    PDF::Reader.open(filename) do |reader|
      reader.pages.each do |page|
        page.walk(rule)
      end
      rule.issues.should be_empty
    end
  end

  it "fail files with mismatched MediaBox on each page" do
    filename = pdf_spec_file("two_mismatched_pages")
    rule     = Preflight::Rules::ConsistentBoxes.new

    PDF::Reader.open(filename) do |reader|
      reader.pages.each do |page|
        page.walk(rule)
      end
      rule.issues.should_not be_empty
    end
  end

  it "pass files with mismatched MediaBox on each page within the defined tolerance" do
    filename  = pdf_spec_file("two_mismatched_pages")
    tolerance =(BigDecimal.new(-300)..BigDecimal.new(300))
    rule      = Preflight::Rules::ConsistentBoxes.new(tolerance)

    PDF::Reader.open(filename) do |reader|
      reader.pages.each do |page|
        page.walk(rule)
      end
      rule.issues.should be_empty
    end
  end

end
