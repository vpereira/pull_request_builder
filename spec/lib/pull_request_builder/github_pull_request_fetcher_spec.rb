# frozen_string_literal: true

require 'spec_helper'

include PullRequestBuilder

RSpec.describe GithubPullRequestFetcher, :vcr do
  describe '.initialize' do
    it { expect(GithubPullRequestFetcher.new(credentials: { access_token: 'X123' })).not_to be_nil }
  end

  describe '.pull' do
    before do
      allow_any_instance_of(ObsPullRequestPackage).to receive(:create).and_return(nil)
      allow_any_instance_of(GitHubStatusReporter).to receive(:report).and_return(nil)
    end

    let(:fetcher) { GithubPullRequestFetcher.new(credentials: { access_token: 'b723c67f1309dcded3674757c2e151daa39e358a' }) }

    let(:result) { fetcher.pull('openSUSE/open-build-service', 'master') }

    it { expect(result).to be_an(Array) }
    it { expect(result.first).to be_an(ObsPullRequestPackage) }
  end
end
