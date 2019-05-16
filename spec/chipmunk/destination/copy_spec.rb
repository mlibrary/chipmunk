require "chipmunk/destination/copy"
require "fileutils"
require "pathname"

RSpec.describe Chipmunk::Destination::Copy do
  around(:each) do |example|
    Dir.mktmpdir do |tmp_dir|
      @src_path = Pathname.new(tmp_dir)/"src"
      @dest_path = Pathname.new(tmp_dir)/"dest"
      @file = @src_path/"foo"/"bar.txt"
      FileUtils.mkdir_p @src_path
      FileUtils.mkdir_p @file.parent
      FileUtils.mkdir_p @dest_path
      File.write(@file, "baz")
      example.run
    end
  end

  let(:src_path) { @src_path }
  let(:dest_path) { @dest_path }
  let(:relative_file) { @file.relative_path_from(@src_path) }
  let(:relative_files) { [relative_file] }
  let(:dest) { described_class.new(dest_path) }

  describe "#write" do
    it "writes each file" do
      dest.write(src_path, relative_files)
      expect(File.read(dest_path/relative_file)).to eql("baz")
    end

    it "leaves the source in place" do
      dest.write(src_path, relative_files)
      expect((src_path/relative_file).exist?).to be true
    end
  end

end
