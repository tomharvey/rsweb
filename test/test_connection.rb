require 'minitest/autorun'
require 'rsweb'

class ConnectionTest < MiniTest::Unit::TestCase
   def setup
    @conx = Connection.new
    @test_container_name = self.generate_container_name
    @index_filename = "release001/test_index.html"
    @updated_index_filename = "release002/test_index.html"
  end

  def teardown
    # delete the container
  end

  def test_container_upload
    directory = self.create_container
    assert_equal @conx.container, directory
    assert_equal @test_container_name, directory.key
    assert_equal true, directory.public?
    assert_equal true, directory.persisted?
    assert_equal @metadata, directory.metadata.data

    uploaded_file = self.upload_index(@index_filename)
    assert_equal @index_filename, uploaded_file.key
    
    response = self.get_html_content(directory.public_url)
    assert_equal "200", response.code
    assert_equal response.body, self.file_contents(@index_filename)

    updated_file = self.upload_index(@updated_index_filename)
    assert_equal @updated_index_filename, updated_file.key

    directory = self.update_container
    refute_equal @metadata, directory.metadata.data
    assert_equal @updated_index_filename, directory.metadata.data[:web_index]
    
    response = self.get_html_content(directory.public_url)
    assert_equal "200", response.code
    assert_equal response.body, self.file_contents(@updated_index_filename)
  end

  protected

  def generate_container_name
    dt = Time.now
    "rsweb-test-#{dt.strftime('%Y-%m-%dT%H:%M:%S')}"
  end

  def create_container
    @metadata = {:web_index           => @index_filename,
                 :web_error           => "foo/error.html",
                 :access_log_delivery => "true"}
    @conx.get_create_container(@test_container_name, @metadata)
  end

  def update_container
    @conx.get_create_container(@test_container_name, {:web_index => @updated_index_filename})
  end

  def upload_index(index_file)
    @conx.upload_file(index_file, [Dir.pwd, "test/fixtures/"].join("/"))
  end

  def get_html_content(public_url)
    uri = URI.parse(public_url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new("/")
    response = http.request(request)
  end

  def file_contents(index_file)
    filepath = [Dir.pwd, "test/fixtures/", index_file].join("/")
    File.open(filepath).read
  end

end
