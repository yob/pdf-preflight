require File.dirname(__FILE__) + "/../spec_helper"

describe Preflight::Rules::NoPrivateData do

  it "pass files with no page level PieceInfo entry" do
    filename = pdf_spec_file("pdfx-1a-subsetting")
    rule     = Preflight::Rules::NoPrivateData.new

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should be_empty
    end
  end

  it "fail files with a page level PieceInfo entry" do
    filename = pdf_spec_file("piece_info")
    rule     = Preflight::Rules::NoPrivateData.new

    PDF::Reader.open(filename) do |reader|
      reader.page(1).walk(rule)
      rule.issues.should_not be_empty
    end
  end

  it "fail files with a Form XObject PieceInfo entry"

end
