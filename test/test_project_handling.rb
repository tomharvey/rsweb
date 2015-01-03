require 'minitest/autorun'
require 'rsweb'

# == Testing the management of local resources
#
class ProjectTest < MiniTest::Unit::TestCase
  # === Setu the project
  #
   def setup
    @project = Project.new
  end

  # === Testing the project name config
  #
  # Check that we can get the configuration of the project
  #
  # * *Assert*    :
  #   - the name of the porject matches that of the .rsweb file
  #
  def test_get_project_name
    assert_equal "RS Web", @project.name
  end

  # === Testing the file listing
  #
  # Get the list of files which would be uploaded if this project was a website
  # to be hosted statically
  #
  # * *Assert*    :
  #   - that the README file in the root level is found
  #   - that the main rsweb.rb file in the lib folder is foudn
  #   - that the the project file is found - 2 levels of recursion deep
  #   - that a file removed from the repo is not found
  #
  def test_get_repo_files
    project_files = @project.checked_in_files
    for inc_file in ["/lib/rsweb.rb", "/lib/rsweb/project.rb", "/README.markdown"]
      assert_includes project_files, inc_file
    end
    refute_includes project_files, "test/test_rsweb.rbb"
  end


end
