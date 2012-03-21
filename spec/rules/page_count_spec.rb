require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::PageCount do

  it "should pass files with correct page count specified by Fixnum" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    ohash    = PDF::Reader::ObjectHash.new(filename)
    rule     = Preflight::Rules::PageCount.new(1)

    rule.check_hash(ohash).should be_empty
  end

  it "should fail files with incorrect page count specified by Fixnum" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    ohash    = PDF::Reader::ObjectHash.new(filename)
    rule     = Preflight::Rules::PageCount.new(2)

    rule.check_hash(ohash).should_not be_empty
  end

  it "should pass files with correct page count specified by range" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    ohash    = PDF::Reader::ObjectHash.new(filename)
    rule     = Preflight::Rules::PageCount.new(1..2)

    rule.check_hash(ohash).should be_empty
  end

  it "should fail files with incorrect page count specified by range" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    ohash    = PDF::Reader::ObjectHash.new(filename)
    rule     = Preflight::Rules::PageCount.new(2..3)

    rule.check_hash(ohash).should_not be_empty
  end

  it "should pass files with correct page count specified by array" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    ohash    = PDF::Reader::ObjectHash.new(filename)
    rule     = Preflight::Rules::PageCount.new([1, 2])

    rule.check_hash(ohash).should be_empty
  end

  it "should fail files with incorrect page count specified by array" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    ohash    = PDF::Reader::ObjectHash.new(filename)
    rule     = Preflight::Rules::PageCount.new([2, 3])

    rule.check_hash(ohash).should_not be_empty
  end

  it "should pass files with correct page count specified by :odd" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    ohash    = PDF::Reader::ObjectHash.new(filename)
    rule     = Preflight::Rules::PageCount.new(:odd)

    rule.check_hash(ohash).should be_empty
  end

  it "should fail files with correct page count specified by :odd" do
    filename = pdf_spec_file("two_pages")
    ohash    = PDF::Reader::ObjectHash.new(filename)
    rule     = Preflight::Rules::PageCount.new(:odd)

    rule.check_hash(ohash).should_not be_empty
  end

  it "should pass files with correct page count specified by :even" do
    filename = pdf_spec_file("two_pages")
    ohash    = PDF::Reader::ObjectHash.new(filename)
    rule     = Preflight::Rules::PageCount.new(:even)

    rule.check_hash(ohash).should be_empty
  end

  it "should fail files with correct page count specified by :even" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    ohash    = PDF::Reader::ObjectHash.new(filename)
    rule     = Preflight::Rules::PageCount.new(:even)

    rule.check_hash(ohash).should_not be_empty
  end

end
