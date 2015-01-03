require 'rsweb/settings'
require 'rsweb/logging'
require 'rsweb/project'
require 'rsweb/connection'

require 'table_print'

module RsWeb
  # == Manages the command line tool
  #
  class Application

    # === Setup the application
    # 
    # * *Args*    :
    #   - +command+ -> Command to be run
    #
    def initialize(command)
      @pwd = Dir.pwd
      @project = RsWeb::Project.new(@pwd)
      @connection = RsWeb::Connection.new
      valid_commands = self.public_methods(false)
      if valid_commands.include?(command.to_sym)
        self.send(command)
      else
        puts "Invalid command. Select from\n\t#{valid_commands.join(", ")}"
      end
    end

    # === Release a new version
    # 
    # Upload the files in HEAD of master and rollforward the index pointing
    #
    def release
      version_id = @project.head_id
      @connection.get_create_container(@project.container_name, nil)
      puts "Releasing #{version_id} to #{@connection.container.key}"
      for project_file in @project.checked_in_files
        uploaded_file = @connection.upload_file(project_file, @pwd, version_id)
        puts "\tUploaded #{uploaded_file.key}"
      end
      self.rollforward
    end

    # === Get the git master tree
    # 
    # Change the index pointing to move back a release
    #
    # * *Args*    :
    #   - +version_id+ -> version of the site to rollback to
    #
    def rollback
      version_id = @project.previous_commit
      puts "rollingback to #{version_id}"
      @connection.get_create_container(@project.container_name, self.build_metadata(version_id))
      self.show_live
    end

    # === Print a list of the released commits
    # 
    # * *Returns* :
    #   - Prints a table of the commit details
    #
    def list_releases
      tp @project.list_released_commits, "id", "author", "committed_date", "message"
      puts "\n"
      self.show_live
    end

    # === Print the commit ID of the liver release
    # 
    # * *Returns* :
    #   - A String commit ID
    #
    def show_live
      puts "Live: #{@connection.show_live(@project.container_name)}\n"
    end

    protected

    # === Update the container to point to the new release
    #
    # Print a link to the released site
    #
    def rollforward
      @connection.get_create_container(@project.container_name, self.build_metadata(nil))
      puts "Uploaded to #{@connection.container.public_url}"
    end

    # === Contruct the metadata hash for latest release
    # 
    # * *Returns* :
    #   - A Hash of options to be sent to the container creation method
    #
    def build_metadata(commit_id)
      commit_id ||= @project.head_id
      metadata = {:web_index           => "#{commit_id}/index.html",
                  :web_error           => "#{commit_id}/error.html",
                  :access_log_delivery => "true"}
    end

  end
end
