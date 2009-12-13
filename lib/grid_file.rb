# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)
require(File.dirname(__FILE__) + "/../../config/initializers/database")

require 'mongo/gridfs'
require "image_science"
require 'fileutils'

include Mongo
include GridFS

class GridFile
    
  def self.test_for_resize path
    path.match(GridImage::RESIZE_REGEXP)
  end
  
  def self.call(env)
    request = Rack::Request.new(env)
    if request.path_info =~ /^\/images\/grid_file\/(.+)$/ 
      matches = GridFile.test_for_resize request.path_info
      unless matches      
        if GridStore.exist?(MongoMapper.database,$1)
          GridStore.open(MongoMapper.database, $1, 'r') do |file|
            [200, {"Content-Type" => file.content_type}, [file.read]]
          end
        else
          [404, {"Content-Type" => "text/html"}, ["Not Found"]]
        end
      else        
        width,height  = matches.captures
        img           = GridImage.new(request.path_info)
        if img.exists?
          resized_image = img.resize(width,height)
          [200, {"Content-Type" => MIME::Types.type_for(resized_image.path).first.content_type}, [resized_image.read]]
        else
          [404, {"Content-Type" => "text/html"}, ["#{grid_file_path} Not Found"]]
        end
      end
    else
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    end
  end
end
