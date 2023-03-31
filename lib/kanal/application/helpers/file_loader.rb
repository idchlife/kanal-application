module Kanal
  module Application
    module Helpers
      module FileLoader
        class << self
          #
          # Loads all ruby files in directory and subdirectories
          #
          # @param dir [String] directory path
          # @param recursive [Boolean] if true, it will load all subdirectories
          #
          # @return [void] <description>
          # 
          # NOTE: be wary of require and that it can skip loading of ruby file
          #
          def load_ruby_files_from_dir(dirpath, recursive = false)
            recursive_part = recursive ? "/**" : ""
            Dir["#{dirpath}#{recursive_part}/*.rb"].each { |f| require(f) }
          end
        end
      end
    end
  end
end
