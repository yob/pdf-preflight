require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::NoRgb do

  context "a page with an RGB fill colour" do
    let!(:filename) { pdf_spec_file("rgb") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoRgb.new

      PDF::Reader.open(filename) do |reader|
        reader.page(1).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

  context "a page with an RGB stroke colour" do
    let!(:filename) { pdf_spec_file("rgb") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoRgb.new

      PDF::Reader.open(filename) do |reader|
        reader.page(2).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

  context "a page with an RGB fill colour defined in the page resources" do
    let!(:filename) { pdf_spec_file("rgb") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoRgb.new

      PDF::Reader.open(filename) do |reader|
        reader.page(3).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

  context "a page with an RGB stroke colour defined in the page resources" do
    let!(:filename) { pdf_spec_file("rgb") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoRgb.new

      PDF::Reader.open(filename) do |reader|
        reader.page(4).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

  context "a page with an RGB image" do
    let!(:filename) { pdf_spec_file("rgb") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoRgb.new

      PDF::Reader.open(filename) do |reader|
        reader.page(5).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

  context "a page with a spot colour that has an RGB alternate" do
    let!(:filename) { pdf_spec_file("rgb") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoRgb.new

      PDF::Reader.open(filename) do |reader|
        reader.page(6).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

  context "a page with indexed RGB fill colour" do
    let!(:filename) { pdf_spec_file("rgb") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoRgb.new

      PDF::Reader.open(filename) do |reader|
        reader.page(7).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

  context "a page with indexed RGB stroke colour" do
    let!(:filename) { pdf_spec_file("rgb") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoRgb.new

      PDF::Reader.open(filename) do |reader|
        reader.page(8).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

  context "a page with a CMYK fill colour" do
    let!(:filename) { pdf_spec_file("cmyk") }

    it "should have no issues" do
      rule     = Preflight::Rules::NoRgb.new

      PDF::Reader.open(filename) do |reader|
        reader.page(1).walk(rule)
      end

      rule.issues.should be_empty
    end
  end

  context "a page with a CMYK stroke colour" do
    let!(:filename) { pdf_spec_file("cmyk") }

    it "should have no issues" do
      rule     = Preflight::Rules::NoRgb.new

      PDF::Reader.open(filename) do |reader|
        reader.page(2).walk(rule)
      end

      rule.issues.should be_empty
    end
  end

  context "a page with a CMYK fill colour defined in the page resources" do
    let!(:filename) { pdf_spec_file("cmyk") }

    it "should have no issues" do
      rule     = Preflight::Rules::NoRgb.new

      PDF::Reader.open(filename) do |reader|
        reader.page(3).walk(rule)
      end

      rule.issues.should be_empty
    end
  end

  context "a page with a CMYK stroke colour defined in the page resources" do
    let!(:filename) { pdf_spec_file("cmyk") }

    it "should have no issues" do
      rule     = Preflight::Rules::NoRgb.new

      PDF::Reader.open(filename) do |reader|
        reader.page(4).walk(rule)
      end

      rule.issues.should be_empty
    end
  end

  context "a page with a CMYK image" do
    let!(:filename) { pdf_spec_file("cmyk") }

    it "should have no issues" do
      rule     = Preflight::Rules::NoRgb.new

      PDF::Reader.open(filename) do |reader|
        reader.page(5).walk(rule)
      end

      rule.issues.should be_empty
    end
  end

  context "a page with a spot colour that has a CMYK alternate" do
    let!(:filename) { pdf_spec_file("cmyk") }

    it "should have no issues" do
      rule     = Preflight::Rules::NoRgb.new

      PDF::Reader.open(filename) do |reader|
        reader.page(6).walk(rule)
      end

      rule.issues.should be_empty
    end
  end

end
