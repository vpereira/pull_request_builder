# frozen_string_literal: true

module PullRequestBuilder
  class BuilderConfig
    attr_accessor :octokit_client, :logger, :build_server,
                  :build_server_project_integration_prefix,
                  :build_server_project, :build_server_package_name,
                  :git_server, :git_repository, :git_branch, :osc

    def initialize(config = {})
      @octokit_client = Octokit::Client.new(config[:credentials])
      @logger = config[:logging] ? Logger.new(STDOUT) : Logger.new(nil)
      @build_server_project = config.fetch(:build_server_project, 'OBS:Server:Unstable')
      @git_branch = config.fetch(:github_branch, 'master')
      @git_server = config.fetch(:github_repository, 'https://github.com')
      @git_repository = config.fetch(:github_repository, 'openSUSE/open-build-service.git')
      @build_server = config.fetch(:build_server, 'https://build.opensuse.org')
      @build_server_package_name = config.fetch(:build_server_package_name, 'obs-server')
      @build_server_project_integration_prefix = config.fetch(:build_server_project_integration_prefix,
                                                              'OBS:Server:Unstable:TestGithub:PR')
      @osc = OSC.new(apiurl: @build_server, logger: @logger)
    end

    def git_repository_full_address
      File.join(@git_server, @git_repository)
    end
  end
end
