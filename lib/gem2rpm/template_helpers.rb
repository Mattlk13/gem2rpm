require 'gem2rpm/rpm_file_list'
require 'gem2rpm/rpm_dependency'

module Gem2Rpm
  module TemplateHelpers
    # File list block for the main package
    def main_file_entries(spec)
      entries = RpmFileList.new(spec.files).top_level_entries.main_entries
      entries.to_rpm
    end

    # File list block for the doc sub-package
    def doc_file_entries(spec)
      entries = RpmFileList.new(spec.files).top_level_entries.doc_entries
      entries.to_rpm
    end

    # Provides well formatted requirement with version.
    def requirement(name, version = nil)
      version = nil if version && version.to_s.empty?
      RpmDependency.new(Gem::Dependency.new(name, version)).to_rpm
    end
  end
end
