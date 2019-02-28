# frozen_string_literal: true

require 'spec_helper'

include PullRequestBuilder

RSpec.describe PackageTemplate do
  describe '.initialize' do
    it { expect(PackageTemplate.new('foo', 'bar')).not_to be_nil }
  end

  describe '.to_xml' do
    let(:package_template) do
      described_class.new('foo', 'bar')
    end
    it { expect(package_template.to_xml).to be_a(String) }
    it { expect(package_template.to_xml).to have_tag('package') }
    it { expect(package_template.to_xml).to have_tag('package', with: { name: 'foo' }) }
  end
end
