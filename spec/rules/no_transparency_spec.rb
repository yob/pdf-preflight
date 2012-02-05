require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::NoTransparency do

  # TODO find sample PDFs with transparency that aren't commercially sensitive
  it "should fail files that use transparency"

  it "should pass files that are vlaid PDF/X-1a" do
    filename = pdf_spec_file("pdfx-1a-no-subsetting")
    rule     = Preflight::Rules::NoTransparency.new

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

end
