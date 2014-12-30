require 'fog/core/collection'
require 'fog/aws/models/storage/version'

module Fog
  module Storage
    class Aws
      class Versions < Fog::Collection
        attribute :file
        attribute :directory

        model Fog::Storage::AWS::Version

        def all(options = {})
          data = if file
            service.get_bucket_object_versions(file.directory.key, options.merge('prefix' => file.key)).body['Versions']
          else
            service.get_bucket_object_versions(directory.key, options).body['Versions']
          end

          load(data)
        end

        def new(attributes = {})
          version_type = attributes.keys.first

          model = super(attributes[version_type])
          model.delete_marker = version_type == 'DeleteMarker'

          model
        end
      end
    end
  end
end
