module Desky
  class Configuration
    attr_writer :editor, :projects_dir, :project_template
    def initialize
      @editor = 'nano'
      @format = 'yml'
      @projects_dir = File.join(Dir.home, '.desky')
      @project_template = { 'tasks' => [ { 'command' => 'ping', 'args' => "-c 2 google.com", 'options' => 'verbose wait' } ] }
    end

    def [](config_item)
      instance_variable_get("@#{config_item.to_s}")
    end
  end
end