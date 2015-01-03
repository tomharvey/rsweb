require 'fog'

class Connection
  include Logging
  attr_reader :container

  def initialize
    @conx = Fog::Storage.new(Settings.connection)
  end

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

  def upload_file(filepath, project_path)
    data = File.open([project_path, filepath].join("/")).read
    md5 = Digest::MD5.hexdigest(data)
    filename = self.clean_name(filepath)
    uploaded_file = @container.files.create(:key  => filename,
                                            :body => data,
                                            :etag => md5)
  end

  protected

  def clean_name(filepath)
    return filepath
  end

end
