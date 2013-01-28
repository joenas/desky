require 'thor'
require 'pathname'

module Desky
  APP_ROOT = File.dirname(Pathname.new(__FILE__).realpath+"../")

  require 'desky/project_manager'
  require 'desky/errors'

  # whoop whoop
  class Desky < Thor
    include Thor::Actions
    #APP_ROOT = File.dirname(Pathname.new(__FILE__).realpath)

    map "-o" => :open
    map "-d" => :delete
    map "-e" => :edit
    map "-n" => :new
    map "-c" => :new
    map "-s" => :show

    desc 'open PROJECT (-o)', 'Opens your project!'
    def open(name)
      pm = ProjectManager.new
      pm.run_project name
    end

    desc 'list', "Lists all your projects."
    def list
      print_in_columns ProjectManager.new.all
    end

    desc 'show PROJECT (-s)', 'show a project and its tasks.'
    def show(name)
      pm = ProjectManager.new
      project = pm.show(name)
    end

    desc 'new PROJECT (-n|-c)', 'Make a new project.'
    def new(name)
      ProjectManager.new.create name
    end

    desc 'edit PROJECT (-e)', 'Edit your project. '
    def edit(name)
      pm = ProjectManager.new
      pm.edit name
    end

    desc 'delete PROJECT (-d)', 'Delete a project. '
    def delete(name)
      pm = ProjectManager.new.delete name
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
