#!/usr/bin/env ruby
require 'thor'
require 'json/pure'
require_relative 'project'

class Desky < Thor
  include Thor::Actions

  EDITOR = 'nano'

  map "-o" => :open
  map "-d" => :delete
  #map "-l" => :list
  map "-e" => :edit
  map "-n" => :new
  map "-c" => :new
  map "-v" => :view

  desc '-o | open PROJECT', 'Opens your project!'
  def open(name)
    check_if_exists_or_exit name
    say "Running '#{name}':"
    say_status :open, project_file(name)
    project = Project.new(name)
    tasks = project.tasks
    threads = []
    tasks.each do |task|
      threads << Thread.new(task) { |atask|
        say_status :starting, task.cmd
        run("#{task.command}", :verbose => false, :capture => false)
        #say_status :finished, ret.inspect
        #end
      }
      #ret = task.run
      #ret.join
      #puts ret
    end
    threads.each {|athread| athread.join }

  end

  desc 'list', "Lists all your projects."
  method_option :horizontal, :type => :boolean, :aliases => "-h", :desc => "List horizontaly", :default => true
  method_option :vertical, :type => :boolean, :aliases => "-v", :desc => "List verticaly"
  def list
    projects = Dir.glob("projects/*.json").map { |file| file[/\/(.*)\./, 1] }
    if options.vertical?
      say "Projects:"
      projects.each { |file| say "  #{file}" }
      say "\n"
    else
      print_in_columns projects
    end
  end

  desc '-v | view PROJECT', 'View a project and its tasks.'
  def view(name)
    check_if_exists_or_exit name
    project = Project.new(name)
    say "Project:\n  #{name} - #{project_file(name)}\n\nCommands:"
    print_table project.tasks.map { |name, options| ["  #{options['command']}", options['args']]}
    say "\n"
  end

  desc '-n | new PROJECT', 'Make a new project.'
  def new(name)
    file = project_file name
    str = { task: { command: 'desky', args: "view #{name}"} }.to_json
    test = create_file file, str
  end

  desc '-e | edit PROJECT', 'Edit your project. '
  def edit(name)
    check_if_exists_or_exit name
    system "nano #{project_file name}"
  end

  desc '-d | delete PROJECT', 'Delete a project. '
  def delete(name)
    check_if_exists_or_exit name
    remove_file project_file(name)
  end

private
  def check_if_exists_or_exit(name)
    project_missing name and exit unless project_exists? name
  end

  def project_missing(name)
    say_status :error, "Project '#{name}' does not exist.", :red
  end

  def project_file(name)
    "#{project_root}/#{name}.json"
  end

  def project_root
    "#{destination_root}/projects"
  end

  def project_exists?(name)
    File.exists? project_file(name)
  end
end

Desky.start