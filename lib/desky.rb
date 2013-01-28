require 'thor'
require 'pathname'

module Desky
  APP_ROOT = File.dirname(Pathname.new(__FILE__).realpath+"../")

  require 'desky/project_manager'
  require 'desky/errors'

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

    desc 'open PROJECT (-o)', 'Opens your project!'
    def open(name)
      @project_manager.run_project name
    end

    desc 'list', "Lists all your projects."
    def list
      say "Projects: "
      print_in_columns @project_manager.all
    end

    desc 'show PROJECT (-s)', 'show a project and its tasks.'
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

    desc 'debug', 'Show debug info'
    def debug
      puts "\n"
      print_table [['APP_ROOT', APP_ROOT]]
      puts "\n"
    end
  end
end

Desky::Desky.start
