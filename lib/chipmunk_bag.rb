# frozen_string_literal: true

require "bagit"

class ChipmunkBag < BagIt::Bag
  def chipmunk_info_txt_file
    File.join bag_dir, "chipmunk-info.txt"
  end

  def chipmunk_info
    return {} unless File.exist?(chipmunk_info_txt_file)
    read_info_file chipmunk_info_txt_file
  end

  def relative_data_files
    bag_files.map {|f| Pathname.new(f).relative_path_from(data_dir) }
  end
end
