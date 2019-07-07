# frozen_string_literal: true

module PullRequestBuilder
  class GithubPullRequestFetcher
    attr_reader :packages

    def initialize(config = {})
      @config = BuilderConfig.new(config)
      @packages = []
    end

    def pull
      @packages = @config.octokit_client.pull_requests(@config.git_repository).collect do |pull_request|
        next if pull_request.base.ref != @config.git_branch

        @config.logger.info('')
        @config.logger.info(line_seperator(pull_request))
        package = ObsPullRequestPackage.new(pull_request: pull_request, logger: @config.logger,
                                            obs_project_name_prefix: @config.build_server_project_integration_prefix,
                                            obs_package_name: @config.build_server_package_name, obs_project_name: @config.build_server_project,
                                            osc: @config.osc)
        package.create
        GithubStatusReporter.new(repository: @config.git_repository, package: package, client: @config.octokit_client, logger: @config.logger, osc: OSC.new).report
        package
      end
    end

    def delete
      ObsPullRequestPackage.all(@config.logger, @config.build_server_project_integration_prefix).each do |obs_package|
        next if @packages.any? { |pr_package| pr_package.pull_request.number == obs_package.pull_request.number }

        @config.logger.info('Delete obs_package')
        @config.build_server_package_name
      end
    end

    private

    def line_seperator(pull_request, separator_char = '=', separation_size = 15)
      separator_char * separation_size + " #{pull_request.title} (#{pull_request.number}) " + separator_char * separation_size
    end
  end
end
