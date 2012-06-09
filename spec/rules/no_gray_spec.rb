require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::NoGray do

  context "a page with a Gray fill colour" do
    let!(:filename) { pdf_spec_file("gray") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoGray.new

      PDF::Reader.open(filename) do |reader|
        reader.page(1).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

  context "a page with a Gray stroke colour" do
    let!(:filename) { pdf_spec_file("gray") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoGray.new

      PDF::Reader.open(filename) do |reader|
        reader.page(2).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

  context "a page with a Gray fill colour defined in the page resources" do
    let!(:filename) { pdf_spec_file("gray") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoGray.new

      PDF::Reader.open(filename) do |reader|
        reader.page(3).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

  context "a page with a Gray stroke colour defined in the page resources" do
    let!(:filename) { pdf_spec_file("gray") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoGray.new

      PDF::Reader.open(filename) do |reader|
        reader.page(4).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

  context "a page with a Gray image" do
    let!(:filename) { pdf_spec_file("gray") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoGray.new

      PDF::Reader.open(filename) do |reader|
        reader.page(5).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

  context "a page with an Indexed Gray fill colour" do
    let!(:filename) { pdf_spec_file("gray") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoGray.new

      PDF::Reader.open(filename) do |reader|
        reader.page(6).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

  context "a page with an Indexed Gray stroke colour" do
    let!(:filename) { pdf_spec_file("gray") }

    it "should have one an issue" do
      rule     = Preflight::Rules::NoGray.new

      PDF::Reader.open(filename) do |reader|
        reader.page(7).walk(rule)
      end

      rule.issues.should have(1).item
    end
  end

end
