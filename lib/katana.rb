require "heroku"
require "yaml"

module Katana

  CONFIG_PATH = "config/katana.yml"

  class << self

    def run
      @env = ARGV.shift
      if @env == "init"
        init(ARGV.shift)
        exit
      end

      unless File.exists?(CONFIG_PATH)
        puts "Cannot find #{CONFIG_PATH}.  Run \"kat init your-app-name\" to create it."
        exit
      end

      @config = YAML.load_file(CONFIG_PATH)[@env]
      if !@config
        puts "Cannot find \"#{@env}\" environment in #{CONFIG_PATH}."
        exit
      end

      command = ARGV.shift || ""
      path = ARGV.join(" ")

      case command
      when "create"
        lc("heroku create #{@config["app"]}")

      when "deploy"
        lc("git push #{@env} master")
        hc("rake", "db:migrate")
        hc("restart")

      when "deploy:setup"
        lc("git init") unless File.exists?(".git")

        remotes = `git remote`.split("\n").select{|v| v == @env or v == "heroku"}
        git_commands = remotes.map{|v| "git remote rm #{v}"}
        git_commands << "git remote add #{@env} git@heroku.com:#{@config["app"]}.git"
        lc(git_commands.join(" && "))

        update_config
        update_stack

      when "config:update"
        update_config

      when "stack:update"
        update_stack

      when ""
        puts "Please specify a command."

      else
        # pass the command to heroku
        hc(command, path)
      end
    end

    private

    def init(app)
      if File.exists?(CONFIG_PATH)
        puts "File #{CONFIG_PATH} already exists."
      else
        app = "your-app-name" if !app or app.empty?

        config = <<CONFIG
# Heroku app configuration
# https://github.com/ankane/katana
#
# Commands: (for staging)
#   kat staging config:update  - adds the config vars below
#   kat staging stack:update   - migrates to the stack below


# shared settings

shared: &shared
  stack: bamboo-mri-1.9.2
  config: &config
    BUNDLE_WITHOUT: "development:test"
    # RACK_ENV is automatically added


# environments

production:
  app: #{app}
  <<: *shared

staging:
  app: #{app}-staging
  <<: *shared
CONFIG

        Dir.mkdir("config") unless File.exists?("config")
        File.open(CONFIG_PATH, "w") {|f| f.write(config) }

        puts "Created config file at #{CONFIG_PATH}."
      end
    end

    # heroku command
    def hc(command, path="")
      lc("heroku #{command} --app #{@config["app"]} #{path}")
    end

    # local command
    def lc(command)
      puts command
      system(command)
      puts
    end

    def update_config
      vars = (@config["config"] || {}).merge({"RACK_ENV" => @env})
      vars_str = vars.map{|k,v| "#{k}=#{v}"}.join(" ")
      hc("config:add", vars_str)
    end

    def update_stack
      hc("stack:migrate", @config["stack"]) if @config["stack"]
    end

  end

end
