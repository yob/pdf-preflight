require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::NoMissingGlyphs do

  context "The current font is TrueType" do
    context "the page contains a glyph code that isn't in the font" do
      let!(:filename) { pdf_spec_file("missing_glyph") }

      it "should have one an issue" do
        rule     = Preflight::Rules::NoMissingGlyphs.new

        PDF::Reader.open(filename) do |reader|
          reader.page(1).walk(rule)
        end

        rule.issues.should have(1).item
      end
    end

    context "the page contains only glyphs that are in the font" do
      let!(:filename) { pdf_spec_file("pdfa-1a") }

      it "should have no issues" do
        rule     = Preflight::Rules::NoMissingGlyphs.new

        PDF::Reader.open(filename) do |reader|
          reader.page(1).walk(rule)
        end

        rule.issues.should be_empty
      end
    end
  end

end
