require 'thor'

module Desky
  require 'desky/project_manager'
  require 'desky/errors'
  require 'desky/version'
  require 'psych'

  # whoop whoop
  class Desky < Thor
    include Thor::Actions

    PROJECT_MANAGER = ProjectManager.new

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
      PROJECT_MANAGER.run_project name
    end

    desc 'list', "Lists all your projects."
    def list
      say_status "Projects: ", PROJECT_MANAGER.all*"  ", :blue
    end

    desc 'show PROJECT (-s)', 'Show a project and its tasks.'
    def show(name)
      PROJECT_MANAGER.read name
    end

    desc 'new PROJECT (-n|-c)', 'Make a new project.'
    def new(name)
      PROJECT_MANAGER.create name
    end

    desc 'edit PROJECT (-e)', 'Edit your project. '
    def edit(name)
      PROJECT_MANAGER.update name
    end

    desc 'delete PROJECT (-d)', 'Delete a project. '
    def delete(name)
      PROJECT_MANAGER.delete name if yes? "Are you sure?"
    end

    desc 'version (-v)', 'Shows Desky version'
    def version
      say VERSION
    end

    def method_missing(name)
      return send :open, name if PROJECT_MANAGER.all.include? name.to_s
      say "Could not find task or project \"#{name}\"!", :red
      send :help
    end
  end
end
