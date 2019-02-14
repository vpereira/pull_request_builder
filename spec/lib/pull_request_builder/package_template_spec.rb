# frozen_string_literal: true

require 'spec_helper'

include PullRequestBuilder

RSpec.describe PackageTemplate do
  describe '.initialize' do
    it { expect(PackageTemplate.new('foo')).not_to be_nil }
  end

  describe '.to_xml' do
    it { expect(PackageTemplate.new('foo').to_xml).to be_a(String) }
    it { expect(PackageTemplate.new('foo').to_xml).to have_tag('package') }
    it { expect(PackageTemplate.new('foo').to_xml).to have_tag('package', with: { name: 'foo' }) }
  end
end
