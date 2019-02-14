#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../lib/pull_request_builder'

# The "runner used" by obs-tools
if $PROGRAM_NAME == __FILE__
  octokit_config = YAML.load_file('config/config.yml')
  fetcher = PullRequestBuilder::GithubPullRequestFetcher.new(octokit_config)
  fetcher.pull('openSUSE/open-build-service', 'master')
  fetcher.delete
end
