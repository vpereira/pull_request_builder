# frozen_string_literal: true

module PullRequestBuilder
  class ObsPullRequestPackage
    include ActiveModel::Model
    attr_accessor :pull_request, :logger, :template_directory, :obs_project_name_prefix,
                  :obs_package_name, :obs_project_name, :obs_project_pr_name, :osc
    PullRequest = Struct.new(:number)

    def self.all(logger, obs_project_name_prefix, osc = OSC.new)
      result = osc.search_project(obs_project_name_prefix)
      xml = Nokogiri::XML(result)
      xml.xpath('//project').map do |project|
        pull_request_number = project.attribute('name').to_s.split('-').last.to_i
        ObsPullRequestPackage.new(pull_request: PullRequest.new(pull_request_number), logger: logger)
      end
    end

    def delete
      osc.delete_project("source/#{obs_project_name}")
    end

    def ==(other)
      pull_request.number == other.pull_request.number
    end

    def eql?(other)
      pull_request.number.eql(other.pull_request.number)
    end

    def hash
      pull_request.number.hash
    end

    def pull_request_number
      pull_request.number
    end

    def commit_sha
      pull_request.head.sha
    end

    def merge_sha
      # github test merge commit
      pull_request.merge_commit_sha
    end

    def obs_project_pr_name
      "#{obs_project_name_prefix}-#{pull_request_number}"
    end

    # TODO
    # address must be configurable
    def url
      "https://build.opensuse.org/package/show/#{obs_project_pr_name}/#{obs_package_name}"
    end

    def last_commited_sha
      # if its a new PR, get_history will fail with a 404 and we have to ignore it

      result = osc.get_history("#{obs_project_pr_name}/#{obs_package_name}")
      node = Nokogiri::XML(result).root
      node.xpath('.//revision/comment').last.content
    rescue StandardError, Cheetah::ExecutionFailed
      ''
    end

    def create
      if last_commited_sha == commit_sha
        logger.info('Pull request did not change, skipping ...')
        return
      end
      create_project
      create_package
      copy_files
    end

    private

    def send_meta_file(filename, operation: :prj)
      tmp_meta_file = Tempfile.open(filename)
      begin
        tmp_meta_file.puts(operation == :prj ? project_meta : package_meta)
        tmp_meta_file.close
        osc_meta(tmp_meta_file, operation)
      ensure
        tmp_meta_file.unlink
      end
    end

    def osc_meta(tmpfile, operation)
      case operation
      when :prj
        osc.meta_prj(obs_project_pr_name, tmpfile.path)
      when :pkg
        osc.meta_pkg(obs_project_pr_name, obs_package_name, tmpfile.path)
      else
        raise ArgumentError, "#{operation} not vaild"
      end
    end

    def create_project
      send_meta_file("#{pull_request_number}-meta", operation: :prj)
    end

    def package_meta
      PackageTemplate.new(obs_package_name, obs_project_pr_name).to_xml
    end

    def project_meta
      ProjectMeta.new(obs_project_pr_name, project_title, repositories_to_build).to_xml
    end

    def project_title
      pull_request.html_url
    end

    # TODO
    # make it configurable
    def repositories_to_build
      [
        OpenStruct.new(name: 'SLE_15', path: 'OBS:Server:Unstable', arches: ['x86_64']),
        OpenStruct.new(name: 'SLE_12_SP4', path: 'OBS:Server:Unstable', arches: ['x86_64'])
      ]
    end

    # TODO
    # package name should be configurable
    def create_package
      send_meta_file("#{obs_package_name}-meta", operation: :pkg)
    end

    def new_package_template
      PackageTemplate.new(package_name = obs_package_name).to_xml
    end

    def copy_files
      Dir.mktmpdir do |dir|
        osc.checkout(File.join(obs_project_name, obs_package_name), File.join(dir, 'template'))
        osc.checkout(File.join(obs_project_pr_name, obs_package_name), File.join(dir, obs_project_pr_name))
        copy_package_files(dir)
        osc.add_remove(File.join(dir, obs_project_pr_name))
        osc.commit(File.join(dir, obs_project_pr_name), commit_sha)
      end
    end

    def copy_package_files(dir)
      Dir.entries("#{dir}/template").reject { |name| name.start_with?('.') }.each do |file|
        path = File.join(dir, 'template', file)
        target_path = File.join(dir, obs_project_pr_name, file)
        if file == '_service'
          copy_service_file(path, target_path)
        else
          FileUtils.cp path, target_path
        end
      end
    end

    def copy_service_file(path, target_path)
      File.open(target_path, 'w') do |f|
        f.write(service_file(path))
      end
    end

    def service_file(path)
      content = File.read(path)
      xml = Nokogiri::XML(content)
      node = xml.root.at_xpath(".//param[@name='revision']")
      node.content = merge_sha
      xml.to_s
    end
  end
end
