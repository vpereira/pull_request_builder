# frozen_string_literal: true

module PullRequestBuilder
  class GithubPullRequestFetcher
    attr_reader :packages

    def initialize(config = {})
      @osc = OSC.new(apiurl: config[:build_server])
      @client = Octokit::Client.new(config[:credentials])
      @obs_project_name_prefix = config[:build_server_project_integration_prefix]
      @logger = config[:logging] ? Logger.new(STDOUT) : Logger.new(nil)
      @packages = []
    end

    def pull(prj, branch = 'master')
      @packages = @client.pull_requests(prj).collect do |pull_request|
        next if pull_request.base.ref != branch

        @logger.info('')
        @logger.info(line_seperator(pull_request))
        package = ObsPullRequestPackage.new(pull_request: pull_request, logger: @logger, obs_project_name_prefix: @obs_project_name_prefix,
                                            obs_package_name: 'hello_world', obs_project_name: 'home:vpereirabr')
        package.create
        GithubStatusReporter.new(repository: prj, package: package, client: @client, logger: @logger).report
        package
      end
    end

    def delete
      ObsPullRequestPackage.all(@logger).each do |obs_package|
        next if @packages.any? { |pr_package| pr_package.pull_request.number == obs_package.pull_request.number }

        obs_package.delete
      end
    end

    private

    def line_seperator(pull_request, separator_char = '=', separation_size = 15)
      separator_char * separation_size + " #{pull_request.title} (#{pull_request.number}) " + separator_char * separation_size
    end
  end
end
