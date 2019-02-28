# frozen_string_literal: true

module PullRequestBuilder
  class OSC
    include ActiveModel::Model

    attr_accessor :apiurl, :logger

    private

    def checkout(project, output_dir)
      execute(['co', project, '--output-dir', dir])
    end

    def delete_project(project)
      execute(['api', '-X', 'DELETE', project])
    end

    def execute(args)
      ::Cheetah.run('osc', '-A', apiurl, *args, stdout: :capture)
    end
  end
end
