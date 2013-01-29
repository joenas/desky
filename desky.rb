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
  map "-e" => :edit
  map "-n" => :new
  map "-c" => :new
  map "-s" => :show

  desc 'open PROJECT (-o)', 'Opens your project!'
  def open(name)
    project_exist_or_exit name
    say "\n" #"Running '#{name}':"
    say_status :open, project_file(name)
    run_in_threads name
    rescue Interrupt
      say_status :exit, "User interrupt!\n", :red
  end

  desc 'list', "Lists all your projects."
  def list
    projects = Dir.glob("#{APP_ROOT}/projects/*.json").map { |file| file[/\/*(\w*)\./, 1] }
    print_in_columns projects
  end

  desc 'show PROJECT (-s)', 'show a project and its tasks.'
  def show(name)
    project_exist_or_exit name
    project = Project.new(name)
    say "Project:\n  #{name} - #{project_file(name)}\n\nTasks:"
    project.show_tasks task_presenter
    say "\n"
  end

  desc 'new PROJECT (-n|-c)', 'Make a new project.'
  def new(name)
    create_file project_file(name), { task: { command: 'desky', args: "view #{name}"} }.to_json
  end

  desc 'edit PROJECT (-e)', 'Edit your project. '
  def edit(name)
    project_exist_or_exit name
    system "nano #{project_file name}"
  end

  desc 'delete PROJECT (-d)', 'Delete a project. '
  def delete(name)
    project_exist_or_exit name
    remove_file project_file(name)
  end

private
  def project_exist_or_exit(name)
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

  def task_presenter
    lambda { |array| print_table array }
  end

  def run_after_task
    lambda { |task|
      say_status :finished, "#{task.cmd}, status #{$?.exitstatus}", :blue
    }
  end

  def result_handler
    lambda { |command, result|
      print_result command, result
    }
  end

  def error_handler
    lambda { |cmd, msg|
      say_status :error, "#{cmd}: #{msg}", :red
    }
  end

  def print_result(status, result)
    case result
    when String
      result.split("\n").each { |line|
        say_status status, line, :blue
      }
    else
      puts result.inspect
      #puts "something"
    end
  end

  def self.source_root
    File.dirname(__FILE__)
  end

  def run_in_threads(name)
    project = Project.new(name)
    @tasks = project.tasks.map { |task|
      task.startup { |name| say_status :running, name }
      {
        thread: task.call(error_handler, result_handler, &run_after_task),
        wait: task.wait?
      }
    }.each { |task |
      task[:thread].join if task[:wait]
    }
  end
end
#begin
Desky.start
