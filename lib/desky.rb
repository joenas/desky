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
    map "-l" => :list
    map "-s" => :show
    map "-v" => :version

    desc '(open) PROJECT (-o)', 'Opens your project!'
    def open(name)
      @project_manager.run_project name
    end

    desc 'list', "Lists all your projects."
    def list
      say_status "Projects: ", @project_manager.all*"  ", :blue
    end

    desc 'show PROJECT (-s)', 'Show a project and its tasks.'
    def show(name)
      @project_manager.read name
    end

    desc 'new PROJECT (-n|-c)', 'Make a new project.'
    def new(name)
      @project_manager.create name
    end

    desc 'edit PROJECT (-e)', 'Edit your project. '
    def edit(name)
      @project_manager.update name
    end

    desc 'delete PROJECT (-d)', 'Delete a project. '
    def delete(name)
      @project_manager.delete name if yes? "Are you sure?"
    end

    desc 'version (-v)', 'Shows Desky version'
    def version
      say VERSION
    end

    def method_missing(name, *args)
      return send :open, name if @project_manager.all.include? name.to_s
      say "Could not find task or project \"#{name}\"!", :red
      send :help
    end
  end
end

#Desky::Desky.start
