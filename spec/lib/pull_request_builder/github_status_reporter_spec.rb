# frozen_string_literal: true

require 'spec_helper'

include PullRequestBuilder

RSpec.describe GitHubStatusReporter, :vcr do
  describe '.initialize' do
    it { expect(GitHubStatusReporter.new(repository: 'foo', package: 'bar')).not_to be_nil }
    it { expect { GitHubStatusReporter.new(bar: 'foo') }.to raise_error(ActiveModel::UnknownAttributeError) }
  end

  describe '.state' do
    let(:github_status_reporter) do 
      GitHubStatusReporter.new(repository: 'foo', package: 'bar')
    end

    let(:summary_success) do 
      {failure: 0, success: 1, pending: 0}
    end

    before do
      allow_any_instance_of(GitHubStatusReporter).to receive(:summary).and_return(summary_success)
    end
   
    it { expect(github_status_reporter.send(:state)).to eq(:success) }
  end

end
