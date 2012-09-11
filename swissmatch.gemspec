# encoding: utf-8

Gem::Specification.new do |s|
  s.name                      = "swissmatch"
  s.version                   = "0.0.2"
  s.authors                   = "Stefan Rusterholz"
  s.email                     = "stefan.rusterholz@gmail.com"
  s.homepage                  = "http://github.com/apeiros/swissmatch"

  s.description               = <<-DESCRIPTION.gsub(/^    /, '').chomp
    Deal with everything related to swiss addresses.
  DESCRIPTION

  s.summary                   = <<-SUMMARY.gsub(/^    /, '').chomp
    Deal with everything related to swiss addresses.
    This is a meta-gem which consists of swissmatch-location, -street,
    -directories and -rails.
  SUMMARY

  s.files                     =
    Dir['bin/**/*'] +
    Dir['data/**/*'] +
    Dir['lib/**/*'] +
    Dir['rake/**/*'] +
    Dir['test/**/*'] +
    Dir['*.gemspec'] +
    %w[
      LICENSE.txt
      Rakefile
      README.markdown
    ]

  if File.directory?('bin') then
    executables = Dir.chdir('bin') { Dir.glob('**/*').select { |f| File.executable?(f) } }
    s.executables = executables unless executables.empty?
  end

  s.add_dependency "swissmatch-location"
  s.add_dependency "swissmatch-street"
  s.add_dependency "swissmatch-directories"
  s.add_dependency "swissmatch-rails"

  s.required_rubygems_version = Gem::Requirement.new("> 1.3.1")
  s.rubygems_version          = "1.3.1"
  s.specification_version     = 3
end
