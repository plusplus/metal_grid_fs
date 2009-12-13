
class GridImage 
  BASE_URI      = "http://localhost:3000"
  RESIZE_REGEXP = /resize_(\d*)x(\d*)_/
  BASE_FS_PATH  = "#{RAILS_ROOT}/public"
  attr_accessor :incoming_path
  def initialize path
    @incoming_path = path[1,path.length]
  end
  def dest_file_path
    [BASE_FS_PATH,incoming_path].join("/")
  end
  
  def path_parts
    @incoming_path.split("/")
  end
  
  def dir_path
    [BASE_FS_PATH, path_parts[0,path_parts.length-1]].join("/")
  end
  
  def grid_store_path
    @incoming_path.gsub(RESIZE_REGEXP,"").gsub("images/grid_file/","")
  end
  
  def redirect_path
    "#{BASE_URI}/images/grid_file/#{grid_store_path}"
  end
  
  def resize width,height
    ImageScience.with_image_from_memory(file_data.read) do |img_file|
      img_file.resize(width.to_i,height.to_i) do |f|
        FileUtils.mkdir_p dir_path
        f.save(dest_file_path)
      end
    end
    File.open(dest_file_path,'r')
  end
  
  def exists?
    GridStore.exist?(MongoMapper.database,grid_store_path)
  end
  
  def file_data
    GridStore.open(MongoMapper.database, grid_store_path, 'r') {|file| file}
  end
  
end