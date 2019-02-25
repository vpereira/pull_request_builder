# frozen_string_literal: true

require 'spec_helper'

include PullRequestBuilder

RSpec.describe GitHubStatusReporter, :vcr do

  let(:client) do
    Octokit::Client.new({access_token: '6fccee211b93aae7aa24b0263d05d59cdx4a9ec1', 
                         logging: false})
  end

  let(:github_status_reporter) do
      described_class.new(repository: 'vpereira/hello_world', package: 'hello_world', client: client)
  end


  describe '.initialize' do
    it { expect(described_class.new(repository: 'foo', package: 'bar')).not_to be_nil }
    it { expect { described_class.new(bar: 'foo') }.to raise_error(ActiveModel::UnknownAttributeError) }
  end

  describe '.state' do
    let(:summary_success) do
      { failure: 0, success: 1, pending: 0 }
    end

    before do
      allow_any_instance_of(described_class).to receive(:summary).and_return(summary_success)
    end

    it { expect(github_status_reporter.send(:state)).to eq(:success) }
  end
end
