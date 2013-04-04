# encoding: utf-8

begin
  require 'rubygems/version' # newer rubygems use this
rescue LoadError
  require 'gem/version' # older rubygems use this
end

module SwissMatch

  # The version of the swissmatch gem.
  Version = Gem::Version.new("0.1.1")
end
