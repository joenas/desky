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

  desc 'open PROJECT', '-o | Opens your project!'
  #method_option :test,  :aliases => "-t", :desc => "This is a test.."
  def open(name)
    if project_exists? name
      say_status :open, "Running project #{name}"
      project = Project.new(name)
      project.run_tasks
    else
      project_missing name
    end
  end

  desc 'list', "Lists all your projects."
  method_option :horizon, :type => :boolean, :aliases => "-h", :desc => "List horizontaly", :default => true
  method_option :vertical, :type => :boolean, :aliases => "-v", :desc => "List verticaly"
  def list
    projects = Dir.glob("projects/*.json").map { |file| file[/\/(.*)\./, 1] }
    if options.vertical?
      projects.each { |file| say file }
    else
      print_in_columns projects
    end
  end

  desc 'new PROJECT', '-n | Make a new project.'
  def new(name)
    file = project_file name
    str = { task: { command: '', args: ''} }.to_json
    test = create_file file, str
  end

  desc 'edit PROJECT', '-e | Edit your project. '
  def edit(name)
    if project_exists? name
      system "nano #{project_file name}"
    else
      project_missing name
    end
  end

  desc 'delete PROJECT', '-d | Delete a project. '
  def delete(name)
    if project_exists? name
      remove_file project_file(name)
    else
      project_missing name
    end
  end

private
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