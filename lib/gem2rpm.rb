require 'erb'
require 'socket'
require 'gem2rpm/package'
require 'gem2rpm/distro'
require 'gem2rpm/format'
require 'gem2rpm/spec_fetcher'
require 'gem2rpm/specification'

module Gem2Rpm
  Gem2Rpm::VERSION = "0.9.0"

  def self.find_download_url(name, version)
    dep = Gem::Dependency.new(name, "=#{version}")
    fetcher = Gem2Rpm::SpecFetcher.new(Gem::SpecFetcher.fetcher)
    dummy, source = fetcher.spec_for_dependency(dep, false).first.first

    download_path = source.uri

    download_path += "gems/" if download_path.to_s != ""
    return download_path
  end

  def Gem2Rpm.convert(fname, template=TEMPLATE, out=$stdout,
                      nongem=true, local=false, doc_subpackage = true)
    package = Gem2Rpm::Package.new(fname)
    format = Gem2Rpm::Format.new(package)
    spec = Gem2Rpm::Specification.new(package.spec)
    spec.description ||= spec.summary
    download_path = ""
    unless local
      begin
        download_path = find_download_url(spec.name, spec.version)
      rescue Gem::Exception => e
        $stderr.puts "Warning: Could not retrieve full URL for #{spec.name}\nWarning: Edit the specfile and enter the full download URL as 'Source0' manually"
        $stderr.puts "#{e.inspect}"
      end
    end
    template = ERB.new(template, 0, '-')
    out.puts template.result(binding)
  rescue Gem::Exception => e
    puts e
  end

  # Returns the email address of the packager (i.e., the person running
  # gem2spec).  Taken from RPM macros if present, constructed from system
  # username and hostname otherwise.
  def Gem2Rpm.packager()
    packager = `rpmdev-packager`.chomp rescue ''

    if packager.empty?
      packager = `rpm --eval '%{packager}'`.chomp rescue ''
    end

    if packager.empty? or packager == '%{packager}'
      passwd_entry = Etc::getpwnam(Etc::getlogin)
      packager = "#{(passwd_entry && passwd_entry.gecos) || Etc::getlogin } <#{Etc::getlogin}@#{Socket::gethostname}>"
    end

    packager
  end

  def Gem2Rpm.template_dir
    File.join(File.dirname(__FILE__), '..', 'templates')
  end

  TEMPLATE = File.read File.join(template_dir, "#{Distro.nature.to_s}.spec.erb")
end

# Local Variables:
# ruby-indent-level: 2
# End:
