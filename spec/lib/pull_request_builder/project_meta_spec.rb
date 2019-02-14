# frozen_string_literal: true

require 'spec_helper'

include PullRequestBuilder

RSpec.describe ProjectMeta do
  let(:repositories_to_build) do
    [
      OpenStruct.new(name: 'SLE_15', path: 'OBS:Server:Unstable', arches: ['x86_64']),
      OpenStruct.new(name: 'SLE_12_SP4', path: 'OBS:Server:Unstable', arches: ['x86_64'])
    ]
  end
  describe '.initialize' do
    it { expect(ProjectMeta.new('foo', 'bar', repositories_to_build)).not_to be_nil }
  end

  describe '.to_xml' do
    it { expect(ProjectMeta.new('foo', 'bar', repositories_to_build).to_xml).to be_a(String) }
    it { expect(ProjectMeta.new('foo', 'bar', repositories_to_build).to_xml).to have_tag('project') }
    it { expect(ProjectMeta.new('foo', 'bar', repositories_to_build).to_xml).to have_tag('repository', count: 2) }
  end
end
