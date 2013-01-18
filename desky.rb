#!/usr/bin/env ruby
require 'thor'
require 'json/pure'
require_relative 'project'
require 'pathname'

class Desky < Thor
  include Thor::Actions
  APP_ROOT = File.dirname(Pathname.new(__FILE__).realpath)
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
    threads = {}
    tasks.each do |task|
      say_status :running, task.cmd
      threads[task] = Thread.new {
        #run("#{task.command}", :verbose => false, :capture => false)
        ret = `#{task.command}` rescue say_status(:error, "#{task.cmd}", :red)
        print_result ret, task.cmd if task.capture
        say_status :stopping, "#{task.cmd}, status #{$?.exitstatus}", :blue
      }
    end
    threads.each {|task, athread|
      athread.join if task.wait
    }
    rescue Interrupt
      say_status :interrupt, "User exit", :red
  end

  desc 'list', "Lists all your projects."
  method_option :horizontal, :type => :boolean, :aliases => "-h", :desc => "List horizontaly", :default => true
  method_option :vertical, :type => :boolean, :aliases => "-v", :desc => "List verticaly"
  def list
    projects = Dir.glob("#{APP_ROOT}/projects/*.json").map { |file| file[/\/*(\w*)\./, 1] }
    if options.vertical?
      say "Projects:"
      projects.each { |file| say "  #{file}" }
      say "\n"
    else
      print_in_columns projects
    end
  end

  desc 'view PROJECT (-v)', 'View a project and its tasks.'
  def view(name)
    check_if_exists_or_exit name
    project = Project.new(name)
    say "Project:\n  #{name} - #{project_file(name)}\n\nCommands:"
    print_table project.tasks.map { |task| ["  #{task.cmd}", task.args] }
    say "\n"
  end

  desc 'new PROJECT (-n)', 'Make a new project.'
  def new(name)
    create_file project_file(name), { task: { command: 'desky', args: "view #{name}"} }.to_json
  end

  desc 'edit PROJECT (-e)', 'Edit your project. '
  def edit(name)
    check_if_exists_or_exit name
    system "nano #{project_file name}"
  end

  desc 'delete PROJECT (-d)', 'Delete a project. '
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
    "#{APP_ROOT}/projects"
  end

  def project_exists?(name)
    File.exists? project_file(name)
  end

  def print_result(result, cmd)
    case result
    when String
      result.split("\n").each { |line|
        say_status cmd, line, :blue
      }
    else
      #puts result.inspect
    end
  end

  def self.source_root
    File.dirname(__FILE__)
  end
end
#begin
Desky.start
