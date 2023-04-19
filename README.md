# README

## The app
Sync Google Calendar events

## Up and run the project:

### Basic Rails commands

- Ruby version: `ruby 3.0.2`
- Install gems: `bundle install`
- Setup database: `bundle exec rake db:create && bundle exec rake db:migrate`
- Start server: `bundle exec rails s`

### Setup ENVs

- Copy credentials.example file and fill in right values: `cat ./config/credentials/development.yml.example | pbcopy`
- Setup development credentials: `EDITOR=nvim rails credentials:edit -e development`

### Overview

#### Basic functions
- Support to login with google, email/password(using devise)
- Full sync calendar single events into the database
- Show all events like google calendar UI
- Request is retriable by Faraday configuration

#### Need to improve
- Current codebase supports for one google calendar provider, so it saves all Oauth2 into the User model. Need to introduce `Identity` model when supporting multiple providers
- Support only happy path, need to handle errors when fetching google API failed, or "refresh token is invalid", or unexpected exception. Should put them into Sidekiq job, allow to retry on some errors,...
- Should implement endpoint to receive hook: https://developers.google.com/calendar/api/guides/push.
- For production-ready:
  + Google API has rate-limited, should handle this case.
  + Add more LOGs on network request, critical paths like auth, token, requests, upsert to the database...., save all hook event to database... so if something went wrong, we have LOGs to investigate and recover fast
  + Have cron jobs to fetch events, refresh tokens....
  + Build monitoring page to monitor invalid credentials, failed requests, abnormal numbers like 0 events,.... 

### Built with
- Rails and its ecosystem
- ActiveJob: Use default in-memory, can use Sidekiq by ActiveJob config.
- React for UI, react-big-calendar for Calendar.
- Coffee and ...hands :<3



