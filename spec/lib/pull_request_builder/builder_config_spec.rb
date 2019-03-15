# frozen_string_literal: true

require 'spec_helper'

include PullRequestBuilder

RSpec.describe BuilderConfig do
  describe '.initialize' do
    it { expect(described_class.new(credentials: { access_token: 'XY321' }).octokit_client).to be_a(Octokit::Client) }
  end
  context 'default values' do
    let(:config) { described_class.new(credentials: { access_token: 'X123' }) }

    it { expect(config.build_server).to eq('https://build.opensuse.org') }
    it { expect(config.git_branch).to eq('master') }
    it { expect(config.git_repository_full_address).to eq('https://github.com/openSUSE/open-build-service') }
    it { expect(config.build_server_project).to eq('OBS:Server:Unstable') }
  end
end
