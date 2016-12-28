# frozen_string_literal: true
require 'active_support/core_ext/string'

module Starter
  require 'starter/builder/names'
  require 'starter/builder/template_files'
  require 'starter/builder/template_endpoints'

  class Builder
    extend Starter::Names
    extend Template::Files
    extend Template::Endpoints

    class << self
      attr_reader :resource, :set, :force, :entity, :destination

      # would be called from new command
      #
      # name - A String as project name
      # source - A String which provides the template path
      # destination - A String which provides the new project path
      def new!(name, source, destination)
        @resource = name
        @destination = destination

        FileUtils.copy_entry source, destination

        replace_static(File.join('script', 'server'), "API-#{resource}")
        replace_static(File.join('api', 'base.rb'), ":#{resource}")

        self
      end

      # would be called from add command
      #
      # resource - A String as name
      # options - A Hash to provide some optional arguments (default: {})
      #           :set – whitespace separated list of http verbs
      #                 (default: nil, possible: post get put patch delete)
      #           :force - A Boolean, if given existent files should be overwriten (default: false)
      #           :entity - A Boolean, if given an entity file would be created (default: false)
      def add!(resource, options = {})
        @resource = resource
        @set = options[:set]
        @force = options[:force]
        @entity = options[:entity]

        self
      end

      #
      # … it saves the files
      def save
        created_files = file_list.each_with_object([]) do |new_file, memo|
          memo << send("#{new_file}_name")
          save_file(new_file)
        end

        add_mount_point

        created_files
      end

      # would be called on from command
      #
      # resource - A String, which indicates the resource to remove
      # options - A Hash to provide some optional arguments (default: {})
      #           :entity - A Boolean, if given an entity file would also be removed (default: nil -> false)
      def remove!(resource, options = {})
        @resource = resource
        @entity = options[:entity]

        file_list.map { |x| send("#{x}_name") }.each do |file_to_remove|
          begin
            FileUtils.rm file_to_remove
          rescue => error
            $stdout.puts error.to_s
          end
        end

        remove_mount_point
      end

      # provides the endpoints for the given resource
      def endpoints
        content(endpoint_set).join("\n\n")
      end

      # provides the specs for the endpoints of the resource
      def endpoint_specs
        content(endpoint_set.map { |x| "#{x}_spec" }).join("\n")
      end

      private

      # get content for and save new resource files
      def save_file(new_file)
        new_file_name = "#{new_file}_name"
        should_raise?(send(new_file_name))
        write_file(send(new_file_name), send(new_file.strip_heredoc))
      end

      # provides an array of endpoints for the new resource
      def endpoint_set
        crud_set = singular? ? singular_one : crud
        return crud_set if set.blank?

        crud_set.each_with_object([]) { |x, memo| set.map { |y| memo << x if x.to_s.start_with?(y) } }
      end

      # provides a file list for the new resource
      def file_list
        standards = %w(api_file lib_file api_spec lib_spec)

        entity ? standards + ['entity_file'] : standards
      end

      # raises if resource exist and force false
      def should_raise?(file)
        raise StandardError, '… resource exists' if File.exist?(file) && !force
      end

      # replace something in exitend files
      #
      # will be called on project creation
      #
      # … static files such as under script folder,
      def replace_static(file, replacement)
        server_file = File.join(destination, file)

        file_foo(server_file) { |content| content.gsub!('{{{grape-starter}}}', replacement) }
      end

      # will be called an resource creation
      #
      # … add it in api base
      def add_mount_point
        file_foo(api_base_file_name) { |content| add_to_base(content) }
      end

      # … adding
      def add_to_base(file)
        occurence = file.scan(/(\s+mount\s.*?\n)/).last.first
        replacement = occurence + mount_point
        file.sub!(occurence, replacement)
      end

      # … remove it in api base
      def remove_mount_point
        file_foo(api_base_file_name) { |content| remove_from_base(content) }
      end

      # … removing
      def remove_from_base(file)
        file.sub!(mount_point, '')
      end

      # content of the given set of files,
      def content(set)
        set.map { |x| send(x) }
      end

      # general file stuff
      #
      # … reading and writing content
      def file_foo(file)
        content = read_file(file)
        yield content
        write_file(file, content)
      end

      # … read
      def read_file(file)
        File.read(file)
      end

      # … write
      def write_file(file, content)
        File.open(file, 'w') { |f| f.write(content) }
      end
    end
  end
end
