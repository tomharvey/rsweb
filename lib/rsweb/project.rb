require 'yaml'
require 'grit'

module RsWeb
  # == Manages the local files of the website project
  #
  class Project
    include Logging

    # === Setup a website project.
    #
    # * *Args*    :
    #   - +project_path+ -> String path to the project, defaults to pwd
    #
    def initialize(project_path)
      project_path ||= Dir.pwd
      self.get_head(project_path)
      self.load_project_settings(project_path)
    end

    # === Configure the name of the website project.
    # The name should be taken from a .rsweb YAML file in the project root.
    #
    # * *Returns* :
    #   - A String name
    #
    def name
      @config["project_name"]
    end

    # === Get the commit ID of the currrent head
    #
    # * *Returns* :
    #   - A String SHA ID
    #
    def head_id
      @repo.commits.first.id
    end

    # === Get a list of files checked into git.
    #
    # We only manage files which are checked in.
    #
    # * *Returns* :
    #   - An Array of filenames, relative to the project root
    #
    def checked_in_files
      @recursed_tree ||= self.recurse_tree(@head, "")
    end

    # === Get a list of the commits in the repo
    #
    # * *Returns* :
    #   - An Array of Grit Commit objects
    #
    def list_commits
      @repo.commits("master", 10000)
    end

    # === Get the ID of the previously released commit
    #
    # * *Returns* :
    #   - A String commit ID
    #
    def previous_commit
      self.list_released_commits[1]
    end

    # === List the commits of the repo which are online
    # 
    # * *Returns* :
    #   - A List of Grit::Commit objects
    #
    def list_released_commits
      @connection ||= RsWeb::Connection.new
      released_commits = []
      released_ids = @connection.list_releases(self.container_name)
      for commit in self.list_commits
        if released_ids.include?(commit.id)
          released_commits << commit
        end
      end
      released_commits
    end

    # === Construct a name for the container to be used
    # 
    # * *Returns* :
    #   - A String name
    #
    def container_name
      "rswebsite-#{self.name}"
    end

    protected

    # === Get the project config
    #
    # Taken from the .rsweb YAML file on the project root
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

    # === Check if the .rsweb file is commited to the the repo
    #
    # I recommend that it is so all devs deploy to the same location
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

    # === Get the git master tree
    # 
    # * *Args*    :
    #   - +project_path+ -> String path to the project
    # * *Returns* :
    #   - A Grit::Tree object - the current master tree of the repo
    #
    def get_head(project_path)
      if not @head
        @repo = Grit::Repo.new(project_path)
        @head = @repo.commits.first.tree
      end
    end

    # === Traverse the tree and build a list of files
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
end
