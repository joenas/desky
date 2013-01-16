#!/usr/bin/env ruby
require 'thor'
require 'json/pure'
require_relative 'project'

class Desky < Thor
  desc 'open', 'Opens your project!'
  def open(name)
    puts "Running project #{name}"
    project = Project.new(name)
    project.run_tasks
  end

  desc 'list', 'Lists all your projects'
  def list
    puts "ive got a lot of projects"
  end
end

Desky.start