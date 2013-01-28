module Desky
  require 'desky/project'
  require 'desky/task'
  require 'desky/project_file_persistor'

  class ProjectManager
    EDITOR = 'nano'
    PROJECT_ROOT = "#{APP_ROOT}/projects"

    def initialize(error_handler = default_error_handler)
      @error_handler = error_handler
      @project_persistor = ProjectFilePersistor
    end

    def find(name)
      project_exist_or_exit name
      project = Project.new(@project_persistor.new(name))
      puts project.tasks
    end

    def all
      projects = Dir.glob("#{PROJECT_ROOT}/*.json").map { |file| file[/\/*(\w*)\./, 1] }
    end

    def new_project(name)
      project_file name
      #contents = { task: { command: 'desky', args: "view #{name}"} }.to_json
    end

    def edit(name)
      project_exist_or_exit name
      system "#{EDITOR} #{project_file name}"
    end

    def error(msg)
      @error_handler.(msg)
    end

    def project_file(name)
      "#{PROJECT_ROOT}/#{name}.json"
    end

  private
    def project_exist_or_exit(name)
      unless project_exists? name
        project_missing name
        exit 1
      end
    end

    def project_missing(name)
      error("Project '#{name}' does not exist.")
    end

    def project_exists?(name)
      File.exists? project_file(name)
    end

    def default_error_handler
      ->(msg) {puts msg}
    end
  end
end