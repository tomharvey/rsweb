require 'minitest/autorun'
require 'rsweb'

# == Testing the management of remote resources
#
class ConnectionTest < MiniTest::Unit::TestCase

  # === Setup the connection
  #
  # Along with some repeatedly used variables
  # * *Vars*    :
  #   - +test_container_name+ -> String container name to use for testing
  #   - +index_filename+ -> String path to an HTML page for initial upload
  #   - +updated_index_filename+ -> String path to an updated versiont of the index page
  #
   def setup
    @conx = Connection.new
    @test_container_name = self.generate_container_name
    @index_filename = "release001/test_index.html"
    @updated_index_filename = "release002/test_index.html"
  end

  # === Teardown the test
  #
  # Delete the files created and the container created
  #
  #
  def teardown
    # TODO - Delete the container and files within
    # TODO - Check that the files within the container are only
    #        the files which were uplaoded as part of the test
  end

  # === Testing the connection
  #
  # Check that we can create a container successfully
  #
  # * *Assert*    :
  #   - the container returned is a readable attr
  #   - the name of the container is as expected
  #   - the container is publically available
  #   - the container was saved
  #   - the metadata of the created container matches that requested
  #
  #
  # Check that we can upload an index HTML to the new container
  #
  # * *Assert*    :
  #   - that the file saved has the correct name
  #   - that we can get the file using HTTP request with a 200 response
  #   - that the body of the file matches that of the file uploaded
  #
  #
  # Check that we can upload a new index HTML to the container
  #
  # * *Assert*    :
  #   - that the file saved has the correct name
  #   - that the metadata of the container no longer matches the original
  #   - the metadata of the container indexes the new HTML page
  #   - that we can get the file using HTTP request with a 200 response
  #   - that the body of the file matches that of the new file uploaded
  #
  def test_container_upload
    # Check that we can create a container successfully
    directory = self.create_container
    assert_equal @conx.container, directory
    assert_equal @test_container_name, directory.key
    assert_equal true, directory.public?
    assert_equal true, directory.persisted?
    assert_equal @metadata, directory.metadata.data

    # Check that we can upload an index HTML to the new container
    uploaded_file = self.upload_index(@index_filename)
    assert_equal @index_filename, uploaded_file.key

    response = self.get_html_content(directory.public_url)
    assert_equal "200", response.code
    assert_equal response.body, self.file_contents(@index_filename)

    # Check that we can upload a new index HTML to the container
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

  # Creates a name for the container testing
  #
  # Based on the current date and namespaced with this project
  #
  # <i>Ensure that this doens't match anything on your account</i>
  # 
  # * *Returns* :
  #   - A String name
  #
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
    # Point the index file to the newly uploaded file
    @conx.get_create_container(@test_container_name, {:web_index => @updated_index_filename})
  end

  def upload_index(index_file)
    @conx.upload_file(index_file, [Dir.pwd, "test/fixtures/"].join("/"))
  end

  def get_html_content(public_url)
    # Make a GET request for the / of the container - return the index file
    uri = URI.parse(public_url)
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new("/")
    response = http.request(request)
  end

  def file_contents(index_file)
    # Read the fixtures to compare with the HTTP response bodies
    filepath = [Dir.pwd, "test/fixtures/", index_file].join("/")
    File.open(filepath).read
  end

end
