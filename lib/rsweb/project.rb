require 'yaml'
require 'grit'

# Manages the local files of the website project
#
class Project
  include Logging

  # Setup a website project.
  #
  # * *Args*    :
  #   - +project_path+ -> String path to the project, defaults to pwd
  #
  def initialize(project_path)
    project_path ||= Dir.pwd
    self.get_head(project_path)
    self.load_project_settings(project_path)
  end

  # Configure the name of the website project.
  # The name should be taken from a .rsweb YAML file in the project root.
  #
  # * *Returns* :
  #   - A String name
  #
  def name
    @config["project_name"]
  end

  # Get a list of files checked into git.
  # We only manage files which are checked in.
  # 
  # * *Returns* :
  #   - An Array of filenames, relative to the project root
  #
  def checked_in_files
    @recursed_tree ||= self.recurse_tree(@head, "")
  end

  protected

  # Get the project config from the .rsweb YAML file on the project root
  # 
  # * *Returns* :
  #   - A Boolean of whether the .rsweb file is commited to git
  #
  def load_project_settings(project_path)
    config_file = [project_path, ".rsweb"].join("/")

    if File.exist?(config_file)
      @config = YAML.load_file(config_file)
      self.config_is_checked_in
    else
      logger.error "There is no config file for this project. Create one!"
    end
  end

  # Check if the .rsweb file is commited to the the repo
  # 
  # * *Returns* :
  #   - A Boolean of whether the .rsweb file is commited to git
  #
  def config_is_checked_in
    config_in_head = @head / ".rsweb"
    if not config_in_head
      logger.warn "Your config file is not checked into the repo. Add it!"
    end
    return config_in_head
  end

  # Get the git master tree
  # 
  # * *Args*    :
  #   - +project_path+ -> String path to the project
  # * *Returns* :
  #   - A Grit::Tree object - the current master tree of the repo
  #
  def get_head(project_path)
    if not @head
      repo = Grit::Repo.new(project_path)
      @head = repo.commits.first.tree
    end
  end

  # Traverse the tree and build a list of files
  # 
  # * *Args*    :
  #   - +tree+ -> A Grit::Tree object to be traversed
  #   - +pathname+ -> The String of the path to that Tree's root
  # * *Returns* :
  #   - An Array of filenames, relative to the project root
  #
  def recurse_tree(tree, pathname)
    @recursed_tree ||= []
    for blob in tree.blobs
      @recursed_tree << "#{pathname}/#{blob.name}"
    end
    for subtree in tree.trees
      self.recurse_tree(subtree, "#{pathname}/#{subtree.name}")
    end
    return @recursed_tree
  end

end
