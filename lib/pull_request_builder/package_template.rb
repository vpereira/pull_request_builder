# frozen_string_literal: true

module PullRequestBuilder
  class PackageTemplate
    attr_reader :package_name, :project_name

    def initialize(package_name, project_name)
      @package_name = package_name
      @project_name = project_name
    end

    def template
      File.read(File.join(File.dirname(__FILE__), '..', 'views', 'new_package.xml.erb'))
    end

    def to_xml
      ERB.new(template).result(binding)
    end
  end
end
