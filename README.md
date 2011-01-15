# Katana

Manage multiple environments on Heroku with ease!

This project was greatly inspired by [Capistrano](https://github.com/capistrano/capistrano) and [Heroku San](https://github.com/fastestforward/heroku_san).

## Install

### Rails 3

Add the following to your Gemfile.

    group :development do
      gem "katana"
    end

and run

    bundle install

You do not need to include the Heroku gem (it gets included as a dependency).

### Rails 2 and other Ruby apps

    gem install katana

## Setup

To use Katana with an existing or future Heroku app, run:

    kat init your-app-name

This will create a file in config/katana.yml.

## Commands

You can run any Heroku command through Katana.  Simply prefix the command with the environment. For instance:

    heroku rake db:migrate

becomes

    kat staging rake db:migrate

to run it on staging, and

    kat production rake db:migrate

to run it on production.

## Extras

Katana provides extra, Capistrano-like commands to make deployments easier.

### deploy:setup

    kat staging deploy:setup

Initializes a git repo (if necessary), removes the "heroku" remote, creates a remote for
the environment specified, and runs `config:update` and `stack:update` (see below for details).

### deploy

    kat staging deploy

Pushes the master branch to Heroku, runs your migrations, and restarts the app.

### config:update

    kat staging config:update

Runs `config:add` with all the vars listed in your configuration file.

### stack:update

    kat staging stack:update

Runs `stack:migrate` with the stack listed in your configuration file.

## Help make Katana better!

If you have suggestions or find a bug, create an issue at the top of the page.  We also accept pull requests for those feeling adventurous...
