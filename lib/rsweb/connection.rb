require 'fog'

# == Handle the connection to the object storage service
#
class Connection
  include Logging

  # The Fog::Directory container which we will be uploading to
  attr_reader :container

  # Create a conneciton
  #
  def initialize
    @conx = Fog::Storage.new(Settings.connection)
  end

  # === Manages the container used for the static website
  #
  # If no container exists with that name, a new one is created
  #
  # If a container exists with that name it is returned.
  #
  # <b>If a container exists with that name, but the metadata differs,
  # the metadata will be updated with the metadata argued here.</b>
  #
  # The container becomes an attr of this instance.
  # 
  # * *Args*    :
  #   - +container_name+ -> String name of the container
  #   - +metadata+ -> Hash of metadata about the container
  # * *Returns* :
  #   - A Fog::Directory object aka a rackfiles container
  #
  def get_create_container(container_name, metadata)
    unless metadata
      metadata = {:web_index=>"index.html",
                  :web_error=>"error.html",
                  :access_log_delivery=>"true"}
    end

    options = {:key => container_name,
               :public => true,
               :metadata => metadata}

    @container = @conx.directories.create(options)
  end

  # === Uploads a file
  #
  # Targets the container attr of this instance
  #
  # <b>self.get_create_container must be ran first to setup the traget container.</b>
  # 
  # * *Args*    :
  #   - +filepath+ -> String path to the file within the project
  #   - +project_path+ -> String absolute path to the project
  # * *Returns* :
  #   - A Fog::File object representing the now remote file
  #
  def upload_file(filepath, project_path)
    data = File.open([project_path, filepath].join("/")).read
    md5 = Digest::MD5.hexdigest(data)
    filename = self.clean_name(filepath)
    uploaded_file = @container.files.create(:key  => filename,
                                            :body => data,
                                            :etag => md5)
  end

  protected

  # === Clean the name of the file, ready for upload
  #
  # * *Args*    :
  #   - +filepath+ -> String path to the file within the project
  # * *Returns* :
  #   - A String representing a filepath, suitable for upload
  #
  def clean_name(filepath)
    return filepath
  end

end
