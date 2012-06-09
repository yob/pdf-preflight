require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::NoSeparation do

  context "a page with a CMYK fill colour defined in the page resources" do
    let!(:filename) { pdf_spec_file("spot") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoSeparation.new

      PDF::Reader.open(filename) do |reader|
        reader.page(1).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

  context "a page with a Separation stroke colour defined in the page resources" do
    let!(:filename) { pdf_spec_file("spot") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoSeparation.new

      PDF::Reader.open(filename) do |reader|
        reader.page(2).walk(rule)
      end

      rule.issues.should have(1).item
    end

    it "should return the separation name in the issue" do
      rule     = Preflight::Rules::NoSeparation.new

      PDF::Reader.open(filename) do |reader|
        reader.page(2).walk(rule)
      end

      issue = rule.issues.first
      issue.name.should == :"PANTONE 1788 M"
    end
  end

  context "a page with a Indexed Separation fill colour" do
    let!(:filename) { pdf_spec_file("spot") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoSeparation.new

      PDF::Reader.open(filename) do |reader|
        reader.page(3).walk(rule)
      end

      rule.issues.should have(1).item
    end

    it "should return the separation name in the issue" do
      rule     = Preflight::Rules::NoSeparation.new

      PDF::Reader.open(filename) do |reader|
        reader.page(3).walk(rule)
      end

      issue = rule.issues.first
      issue.name.should == :Orange
    end
  end

  context "a page with a Indexed Separation stroke colour" do
    let!(:filename) { pdf_spec_file("spot") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoSeparation.new

      PDF::Reader.open(filename) do |reader|
        reader.page(4).walk(rule)
      end

      rule.issues.should have(1).item
    end

    it "should return the separation name in the issue" do
      rule     = Preflight::Rules::NoSeparation.new

      PDF::Reader.open(filename) do |reader|
        reader.page(4).walk(rule)
      end

      issue = rule.issues.first
      issue.name.should == :Orange
    end
  end

  context "a page with an image in a Separation colour" do
    let!(:filename) { pdf_spec_file("spot") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoSeparation.new

      PDF::Reader.open(filename) do |reader|
        reader.page(5).walk(rule)
      end

      rule.issues.should have(1).item
    end

    it "should return the separation name in the issue" do
      rule     = Preflight::Rules::NoSeparation.new

      PDF::Reader.open(filename) do |reader|
        reader.page(5).walk(rule)
      end

      issue = rule.issues.first
      issue.name.should == :Yellow
    end
  end

  context "a page with an RGB fill colour" do
    let!(:filename) { pdf_spec_file("rgb") }

    it "should have no issues" do
      rule     = Preflight::Rules::NoCmyk.new

      PDF::Reader.open(filename) do |reader|
        reader.page(1).walk(rule)
      end

      rule.issues.should be_empty
    end
  end

  context "a page with an RGB stroke colour" do
    let!(:filename) { pdf_spec_file("rgb") }

    it "should have no issues" do
      rule     = Preflight::Rules::NoCmyk.new

      PDF::Reader.open(filename) do |reader|
        reader.page(2).walk(rule)
      end

      rule.issues.should be_empty
    end
  end

  context "a page with an RGB fill colour defined in the page resources" do
    let!(:filename) { pdf_spec_file("rgb") }

    it "should have no issues" do
      rule     = Preflight::Rules::NoCmyk.new

      PDF::Reader.open(filename) do |reader|
        reader.page(3).walk(rule)
      end

      rule.issues.should be_empty
    end
  end

  context "a page with an RGB stroke colour defined in the page resources" do
    let!(:filename) { pdf_spec_file("rgb") }

    it "should have no issues" do
      rule     = Preflight::Rules::NoCmyk.new

      PDF::Reader.open(filename) do |reader|
        reader.page(4).walk(rule)
      end

      rule.issues.should be_empty
    end
  end

  context "a page with an RGB image" do
    let!(:filename) { pdf_spec_file("rgb") }

    it "should have no issues" do
      rule     = Preflight::Rules::NoCmyk.new

      PDF::Reader.open(filename) do |reader|
        reader.page(5).walk(rule)
      end

      rule.issues.should be_empty
    end
  end

  context "a page with a spot colour that has an RGB alternate" do
    let!(:filename) { pdf_spec_file("rgb") }

    it "should have no issues" do
      rule     = Preflight::Rules::NoCmyk.new

      PDF::Reader.open(filename) do |reader|
        reader.page(6).walk(rule)
      end

      rule.issues.should be_empty
    end
  end

end
