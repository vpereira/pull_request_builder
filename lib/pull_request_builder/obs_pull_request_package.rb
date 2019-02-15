# frozen_string_literal: true

module PullRequestBuilder
  class ObsPullRequestPackage
    include ActiveModel::Model
    attr_accessor :pull_request, :logger, :template_directory
    PullRequest = Struct.new(:number)

    def self.all(logger)
      result = `osc api "search/project?match=starts-with(@name,'OBS:Server:Unstable:TestGithub:PR')"`
      xml = Nokogiri::XML(result)
      xml.xpath('//project').map do |project|
        pull_request_number = project.attribute('name').to_s.split('-').last.to_i
        ObsPullRequestPackage.new(pull_request: PullRequest.new(pull_request_number), logger: logger)
      end
    end

    def delete
      capture2e_with_logs("osc api -X DELETE source/#{obs_project_name}")
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

    def obs_project_name
      "OBS:Server:Unstable:TestGithub:PR-#{pull_request_number}"
    end

    def url
      "https://build.opensuse.org/package/show/#{obs_project_name}/obs-server"
    end

    def last_commited_sha
      result = capture2e_with_logs("osc api /source/#{obs_project_name}/obs-server/_history")
      node = Nokogiri::XML(result).root
      return '' unless node

      node.xpath('.//revision/comment').last.content
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

    def capture2e_with_logs(cmd)
      logger.info("Execute command '#{cmd}'.")
      stdout_and_stderr_str, status = Open3.capture2e(cmd)
      stdout_and_stderr_str.chomp!
      if status.success?
        logger.info(stdout_and_stderr_str)
      else
        logger.error(stdout_and_stderr_str)
      end
      stdout_and_stderr_str
    end

    def create_project
      Tempfile.open("#{pull_request_number}-meta") do |f|
        f.write(project_meta)
        f.close
        capture2e_with_logs("osc meta prj #{obs_project_name} --file #{f.path}")
      end
    end

    def project_meta
      ProjectMeta.new(obs_project_name, project_title, repositories_to_build).to_xml
    end

    def project_title
      "https://github.com/openSUSE/open-build-service/pull/#{pull_request_number}"
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
      Tempfile.open("#{obs_project_name}-obs-server-meta") do |f|
        f.write(new_package_template)
        f.close
        capture2e_with_logs("osc meta pkg #{obs_project_name} obs-server --file #{f.path}")
      end
    end

    def new_package_template
      PackageTemplate.new(package_name = 'obs-server').to_xml
    end

    def copy_files
      Dir.mktmpdir do |dir|
        capture2e_with_logs("osc co OBS:Server:Unstable/obs-server --output-dir #{dir}/template")
        capture2e_with_logs("osc co #{obs_project_name}/obs-server --output-dir #{dir}/#{obs_project_name}")
        copy_package_files(dir)
        capture2e_with_logs("osc ar #{dir}/#{obs_project_name}")
        capture2e_with_logs("osc commit #{dir}/#{obs_project_name} -m '#{commit_sha}'")
      end
    end

    def copy_package_files(dir)
      Dir.entries("#{dir}/template").reject { |name| name.start_with?('.') }.each do |file|
        path = File.join(dir, 'template', file)
        target_path = File.join(dir, obs_project_name, file)
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
