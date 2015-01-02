require 'yaml'
require 'grit'

class Project
  include Logging

  def initialize(project_path = Dir.pwd)
    self.get_head(project_path)
    self.load_project_settings(project_path)
  end

  def name
    @config["project_name"]
  end

  def checked_in_files
    @recursed_tree ||= self.recurse_tree(@head, "")
  end

  protected

  def load_project_settings(project_path)
    config_file = [project_path, ".rsweb"].join("/")

    if File.exist?(config_file)
      @config = YAML.load_file(config_file)
      self.config_is_checked_in
    else
      logger.error "There is no config file for this project. Create one!"
    end
  end

  def config_is_checked_in
    config_in_head = @head / ".rsweb"
    if not config_in_head
      logger.warn "Your config file is not checked into the repo. Add it!"
    end
    return config_in_head
  end

  def get_head(project_path)
    if not @head
      repo = Grit::Repo.new(project_path)
      @head = repo.commits.first.tree
    end
  end

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
