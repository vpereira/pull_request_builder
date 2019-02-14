# frozen_string_literal: true

module PullRequestBuilder
  class ProjectMeta
    attr_accessor :name, :title, :repositories_to_build

    def initialize(name, title, repositories_to_build)
      @name = name
      @title = title
      @repositories_to_build = repositories_to_build
    end

    def template
      File.read(File.join(File.dirname(__FILE__), '..', 'views', 'new_project.xml.erb'))
    end

    def to_xml
      ERB.new(template).result(binding)
    end
  end
end
