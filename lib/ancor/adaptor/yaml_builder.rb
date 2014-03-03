require 'yaml'

module Ancor
  module Adaptor
    class YamlBuilder
      #!@group In-YAML constants

      # Top-level keys
      KEY_ROLES = 'roles'
      KEY_GOALS = 'goals'

      # Common keys
      KEY_NAME = 'name'
      KEY_DESCRIPTION = 'description'

      # Role keys
      KEY_SCENARIOS = 'scenarios'
      KEY_MAX = 'max'
      KEY_MIN = 'min'
      KEY_IS_PUBLIC = 'is_public'
      KEY_EXPORTS = 'exports'
      KEY_IMPORTS = 'imports'

      # Implementation keys
      KEY_DEFAULT = 'default'
      KEY_PROFILE = 'profile'

      # Channel keys
      KEY_TYPE = 'type'

      # Channel types
      CHANNEL_TYPE_SINGLE_PORT = 'single_port'
      CHANNEL_TYPE_PORT_RANGE = 'port_range'

      #!@endgroup

      def initialize(environment)
        @environment = environment
        @roles = HashWithIndifferentAccess.new
        @goals = HashWithIndifferentAccess.new
      end

      def build_from(filename)
        build(File.read(filename))
      end

      def build(spec)
        tree = YAML.load(spec)

        process_roles tree[KEY_ROLES]
        process_goals tree[KEY_GOALS]
      end

      def commit
        @roles.each_value(&:save!)
        @goals.each_value(&:save!)
      end

      private

      def process_roles(roles)
        # First pass, creates roles and the exported channels for each
        roles.each do |slug, spec|
          role = Role.new

          role.environment = @environment

          role.name = spec[KEY_NAME] || slug
          role.description = spec[KEY_DESCRIPTION]
          role.slug = slug.to_sym

          role.is_public = spec[KEY_IS_PUBLIC] || false
          role.min = spec[KEY_MIN] || 1
          role.max = spec[KEY_MAX] || spec[KEY_MIN] || 1

          process_role_scenarios role, spec[KEY_SCENARIOS]
          process_role_exports role, spec[KEY_EXPORTS]

          @roles[slug] = role
        end

        # Second pass, adds references for imported channels
        roles.each do |slug, spec|
          process_role_imports @roles[slug], spec[KEY_IMPORTS]
        end
      end

      def process_role_exports(role, exports)
        return unless exports

        exports.each do |slug, spec|
          channel_type = map_channel_type spec[KEY_TYPE]
          channel = channel_type.new

          channel.name = spec[KEY_NAME] || slug
          channel.description = spec[KEY_DESCRIPTION]
          channel.slug = slug.to_sym

          # Configure channel using keys specific to the channel type
          # This would include things like protocol and port range size
          specific_keys = spec.keys - [KEY_NAME, KEY_DESCRIPTION, KEY_TYPE]
          specific_keys.each do |key|
            channel[key] = spec[key]
          end

          role.exports << channel
        end
      end

      def process_role_scenarios(role, scenarios)
        unless scenarios && scenarios.size > 0
          scenarios = {
            KEY_DEFAULT => {
            }
          }
        end

        scenarios.each do |slug, spec|
          scenario = role.scenarios.build

          scenario.name = spec[KEY_NAME] || slug
          scenario.description = spec[KEY_DESCRIPTION]
          scenario.slug = slug.to_sym

          # Examples of this convention would include
          #   role::webapp::default
          #   role::weblb::nginx
          #   role::database_master::mysql
          scenario.profile = spec[KEY_PROFILE] || "role::#{role.slug}::#{slug}"
        end
      end

      def process_role_imports(role, imports)
        return unless imports

        imports.each do |slug, spec|
          # Accepts any of the following specifications:
          #
          # webapp: http
          # datastore: [routing, querying]
          channel_slugs =
            case spec
            when String
              [spec.to_sym]
            when Array
              spec.map &:to_sym
            else
              raise ArgumentError, "Invalid import specification for #{slug}"
            end

          exporter_role = find_role(slug)

          channel_slugs.each do |channel_slug|
            role.imports << find_channel(exporter_role, channel_slug)
          end
        end
      end

      def process_goals(goals)
        goals.each do |slug, spec|
          goal = Goal.new

          goal.name = spec[KEY_NAME] || slug
          goal.description = spec[KEY_DESCRIPTION]
          goal.slug = slug.to_sym

          spec[KEY_ROLES].each do |role_slug|
            role = find_role role_slug
            goal.roles << role
          end

          @goals[slug] = goal
        end
      end

      def find_role(slug)
        @roles.fetch slug
      rescue KeyError
        raise ArgumentError, "Unknown role #{slug}"
      end

      # Grabs the exported channel from the given role with the given slug
      def find_channel(role, slug)
        role.exports.each do |export|
          return export if export.slug == slug.to_sym
        end

        raise ArgumentError, "Unknown channel #{slug} from role #{role.slug}"
      end

      def map_channel_type(type)
        case type
        when CHANNEL_TYPE_SINGLE_PORT then SinglePortChannel
        when CHANNEL_TYPE_PORT_RANGE then PortRangeChannel
        else
          raise ArgumentError, "Unknown channel type #{type}"
        end
      end
    end # YamlBuilder
  end # Adaptor
end
