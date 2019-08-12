# TODO: these were moved over from package_storage_spec
# before(:each) do
#   allow(FileUtils).to receive(:mkdir_p).with("/bags/ab/cd/ef/abcdef-123456")
#   allow(File).to receive(:rename).with(
#     "/uploaded/abcdef-123456",
#     "/bags/ab/cd/ef/abcdef-123456"
#   )
# end
# it "ensures the destination directory exists" do
#   expect(FileUtils).to receive(:mkdir_p)
#   storage.write(package, disk_bag)
# end
# it "moves the source bag to the destination directory" do
#   expect(File).to receive(:rename)
#   storage.write(package, disk_bag)
# end


