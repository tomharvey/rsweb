require 'minitest/autorun'
require 'rsweb'

class ProjectTest < MiniTest::Unit::TestCase
   def setup
    @project = Project.new
  end

  def test_get_project_name
    assert_equal "Project Name", @project.name
  end

  def test_get_repo_files
    project_files = @project.checked_in_files
    for inc_file in ["/lib/rsweb.rb", "/lib/rsweb/project.rb", "/README.markdown"]
      assert_includes project_files, inc_file
    end
    refute_includes project_files, "test/test_rsweb.rbb"
  end


end
