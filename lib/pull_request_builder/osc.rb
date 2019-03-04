# frozen_string_literal: true

module PullRequestBuilder
  class OSC
    include ActiveModel::Model

    attr_accessor :apiurl, :logger

    def checkout(project, dir)
      execute(['co', project, '--output-dir', dir])
    end

    def delete_project(project)
      execute(['api', '-X', 'DELETE', project])
    end

    def get_history(project)
      execute(['api', "/source/#{project}/_history"])
    end

    def add_remove(file_path)
      execute(['ar', file_path])
    end

    def meta_pkg(project, package, meta_file)
      meta(operation: :pkg, project: project, package: package, meta_file: meta_file)
    end

    def meta_prj(project, meta_file)
      meta(operation: :prj, project: project, meta_file: meta_file)
    end

    def commit(file_path, message = 'ok')
      execute(['commit', file_path, '-m', message])
    end

    private

    def meta(params = {})
      case params[:operation]
      when :prj
        execute(['meta', 'prj', params[:project], '--file', params[:meta_file]])
      when :pkg
        execute(['meta', 'pkg', params[:project], params[:package], '--file', params[:meta_file]])
      else
        raise ArgumentError, "#{operation} not vaild"
      end
    end

    def execute(args)
      ::Cheetah.run('osc', '-A', apiurl, *args, logger: logger, stdout: :capture)
    end
  end
end
