require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::NoDevicen do

  context "a page with a DeviceN fill colour" do
    let!(:filename) { pdf_spec_file("devicen") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoDevicen.new

      PDF::Reader.open(filename) do |reader|
        reader.page(1).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

  context "a page with a DeviceN stroke colour" do
    let!(:filename) { pdf_spec_file("devicen") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoDevicen.new

      PDF::Reader.open(filename) do |reader|
        reader.page(2).walk(rule)
      end

      rule.issues.should have(1).item
    end

    it "should return the colourant names in the issue" do
      rule     = Preflight::Rules::NoDevicen.new

      PDF::Reader.open(filename) do |reader|
        reader.page(2).walk(rule)
      end

      issue = rule.issues.first
      issue.names.should == [:Orange]
    end
  end

  context "a page with a Indexed DeviceN fill colour" do
    let!(:filename) { pdf_spec_file("devicen") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoDevicen.new

      PDF::Reader.open(filename) do |reader|
        reader.page(3).walk(rule)
      end

      rule.issues.should have(1).item
    end

    it "should return the colourant names in the issue" do
      rule     = Preflight::Rules::NoDevicen.new

      PDF::Reader.open(filename) do |reader|
        reader.page(3).walk(rule)
      end

      issue = rule.issues.first
      issue.names.should == [:Orange]
    end
  end

  context "a page with a Indexed DeviceN stroke colour" do
    let!(:filename) { pdf_spec_file("devicen") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoDevicen.new

      PDF::Reader.open(filename) do |reader|
        reader.page(4).walk(rule)
      end

      rule.issues.should have(1).item
    end

    it "should return the colourant names in the issue" do
      rule     = Preflight::Rules::NoDevicen.new

      PDF::Reader.open(filename) do |reader|
        reader.page(4).walk(rule)
      end

      issue = rule.issues.first
      issue.names.should == [:Orange]
    end
  end

  context "a page with a DeviceN raster image" do
    let!(:filename) { pdf_spec_file("devicen") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoDevicen.new

      PDF::Reader.open(filename) do |reader|
        reader.page(5).walk(rule)
      end

      rule.issues.should have(1).item
    end

    it "should return the colourant names in the issue" do
      rule     = Preflight::Rules::NoDevicen.new

      PDF::Reader.open(filename) do |reader|
        reader.page(5).walk(rule)
      end

      issue = rule.issues.first
      issue.names.should == [:Orange]
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

  context "a page with a devicen colour that has an RGB alternate" do
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
