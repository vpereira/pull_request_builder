# frozen_string_literal: true

module PullRequestBuilder
  class GithubStatusReporter
    include ActiveModel::Model
    attr_accessor :client, :logger, :package, :repository

    def report
      if update?
        logger.info("Update status to state #{state}.")
        client.create_status(repository, package.commit_sha, state, options)
      else
        logger.info('State did not change, continue...')
      end
    rescue Octokit::Error => e
      logger.error("Status not updated: #{e}.")
    end

    private

    def update?
      statuses = client.statuses(repository, package.commit_sha)
      build_status = statuses.select { |state| state.context == context }.first
      build_status.nil? || state.to_s != build_status.state || description != build_status.description
    end

    def context
      'OBS Package Build'
    end

    def description
      count_all = summary[:success] + summary[:failure] + summary[:pending]
      count_finished = count_all - summary[:pending]

      result = String.new("#{count_finished}/#{count_all} processed")
      result << " | #{summary[:failure]} failures" if summary[:failure].positive?
      result
    end

    def state
      if summary[:failure].positive?
        :failure
      elsif summary[:pending].positive? || summary[:success].zero?
        :pending
      else
        :success
      end
    end

    def options
      {
        context: context,
        target_url: package.url,
        description: description
      }
    end

    def judge_code(code)
      case code
      when 'succeeded'
        :success
      when 'excluded', 'disabled'
        :exclusion
      when 'broken', 'failed', 'unresolvable'
        :failure
      when 'building', 'dispatching', 'scheduled', 'finished', 'blocked'
        :pending
      else
        logger.error("Unmapped status result #{code} in #{package.obs_package_name}")
        :pending
      end
    end

    def summary
      return @summary if @summary

      @summary = { failure: 0, success: 0, pending: 0, exclusion: 0 }
      result = `osc api /build/#{package.obs_project_pr_name}/_result`
      node = Nokogiri::XML(result).root
      node.xpath('.//status').each do |status|
        @summary[judge_code(status['code'])] += 1
      end
      @summary
    end
  end
end
