require 'thor'

module Desky
  require 'desky/project_manager'
  require 'desky/errors'
  require 'desky/version'

  # whoop whoop
  class Desky < Thor
    include Thor::Actions

    def initialize(*args)
      @project_manager = ProjectManager.new
      super
    end

    map "-o" => :open
    map "-d" => :delete
    map "-e" => :edit
    map "-n" => :new
    map "-c" => :new
    map "-s" => :show
    map "-v" => :version

    desc 'open PROJECT (-o)', 'Opens your project!'
    def open(name)
      @project_manager.run_project name
    end

    desc 'list', "Lists all your projects."
    def list
      say "Projects: "
      print_in_columns @project_manager.all
    end

    desc 'show PROJECT (-s)', 'Show a project and its tasks.'
    def show(name)
      @project_manager.show(name)
    end

    desc 'new PROJECT (-n|-c)', 'Make a new project.'
    def new(name)
      @project_manager.create name
    end

    desc 'edit PROJECT (-e)', 'Edit your project. '
    def edit(name)
      @project_manager.edit name
    end

    desc 'delete PROJECT (-d)', 'Delete a project. '
    def delete(name)
      @project_manager.delete name
    end

    desc 'version (-v)', 'Shows Desky version'
    def version
      say VERSION
    end

    #default_task :open
  end
end

Desky::Desky.start
