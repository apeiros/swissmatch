# encoding: utf-8



require 'date'
require 'swissmatch/ruby'
require 'swissmatch/canton'
require 'swissmatch/cantons'
require 'swissmatch/community'
require 'swissmatch/communities'
require 'swissmatch/datafiles'
require 'swissmatch/version'
require 'swissmatch/zipcode'
require 'swissmatch/zipcodes'



# SwissMatch
# Deal with swiss zip codes, cities, communities and cantons.
#
# Notice that all strings passed to SwissMatch are expected to be utf-8. All strings
# returned by SwissMatch are also in utf-8.
#
# @example Load the data
#     require 'swissmatch'
#     SwissMatch.load
#     # alternatively, just require 'swissmatch/autoload'
#
# @example Get the ONRP for a given zip-code + city
#     require 'swissmatch/autoload'
#     SwissMatch.zip_code(8000, 'Zürich').ordering_number # => 
module SwissMatch
  @data               = nil
  @directory_service  = nil

  class <<self
    # @return [SwissMatch::DataFiles, nil] The data source used
    attr_reader :data

    # @return [SwissMatch::DirectoryService, nil]
    # The directory service used to search for addresses
    attr_accessor :directory_service
  end

  def self.canton(name_or_plate)
    @data.cantons[name_or_plate]
  end

  def self.cantons
    @data.cantons
  end

  def self.community(key)
    @data.communities.by_community_number(key)
  end

  def self.communities(name=nil)
    name ? @data.communities.by_name(name) : @data.communities
  end

  # @param [String, Integer] code_or_name
  #   Either the 4 digit zip code as Integer or String, or the city name as a String in
  #   utf-8.
  #
  # @return [Array<SwissMatch::ZipCode>]
  #   A list of zip codes with the given code or name.
  def self.zip_codes(code_or_name=nil)
    case code_or_name
      when Integer, /\A\d{4}\z/
        @data.zip_codes.by_code(code_or_name.to_i)
      when String
        @data.zip_codes.by_name(code_or_name)
      when nil
        @data.zip_codes
      else
        raise ArgumentError, "Invalid argument, must be a ZipCode#code (Integer or String) or ZipCode#name (String)"
    end
  end

  # Returns a single zip code. A zip code can be uniquely identified by any of:
  # * Its ordering_number (ONRP, a 4 digit Integer)
  # * Its zip code (4 digit Integer) and add-on (2 digit Integer)
  # * Its zip code (4 digit Integer) and any official name (String)
  # The data can be passed in different ways, e.g. all numbers can be passed either
  # as a String or as an Integer. The identification by zip code and add-on can be done
  # by either using a combined 6 digit number (e.g. 800000 for "8000 Zürich"), or by
  # passing 2 arguments, passing the zip code and the add-on separately.
  #
  # === IMPORTANT
  # You must be aware, that passing a single 4-digit code to SwissMatch::zip_code uses
  # the ONRP, and NOT the zip-code. The 4 digit zip code alone does NOT uniquely identify
  # a zip code.
  #
  #
  # @example Get a zip code by ONRP
  #   SwissMatch.zip_code(4384)           # => #<SwissMatch::ZipCode:003ff996cf8d3c 8000 Zürich>
  #
  # @example Get a zip code by 4-digit code and add-on
  #   SwissMatch.zip_code(8000, 0)        # => #<SwissMatch::ZipCode:003ff996cf8d3c 8000 Zürich>
  #   SwissMatch.zip_code("8000", "00")   # => #<SwissMatch::ZipCode:003ff996cf8d3c 8000 Zürich>
  #   SwissMatch.zip_code(800000)         # => #<SwissMatch::ZipCode:003ff996cf8d3c 8000 Zürich>
  #   SwissMatch.zip_code("800000")       # => #<SwissMatch::ZipCode:003ff996cf8d3c 8000 Zürich>
  #
  # @example Get a zip code by 4-digit code and name
  #   SwissMatch.zip_code(8000, "Zürich") # => #<SwissMatch::ZipCode:003ff996cf8d3c 8000 Zürich>
  #   SwissMatch.zip_code(8000, "Zurigo") # => #<SwissMatch::ZipCode:003ff996cf8d3c 8000 Zürich>
  #
  #
  # @param [String, Integer] code
  #   The 4 digit zip code as Integer or String
  # @param [String, Integer] city_or_add_on
  #   Either the 2 digit zip-code add-on as string or integer, or the city name as a
  #   String in utf-8.
  #
  # @return [SwissMatch::ZipCode]
  #   The zip codes with the given code and the given add-on or name.
  def self.zip_code(code, city_or_add_on=nil)
    case city_or_add_on
      when nil
        @data.zip_codes.by_ordering_number(code.to_i)
      when Integer, /\A\d\d\z/
        @data.zip_codes.by_code_and_add_on(code.to_i, city_or_add_on.to_i)
      when String
        @data.zip_codes.by_code_and_name(code.to_i, city_or_add_on)
      else
        raise ArgumentError, "Invalid second argument, must be nil, ZipCode#add_on or ZipCode#name"
    end
  end

  # @param [String] name
  #   The name for which to return matching zip codes
  #
  # @return [Array<SwissMatch::ZipCode>]
  #   Zip codes whose name equals the given name
  def self.city(name)
    @data.zip_codes.by_name(name)
  end

  # @param [String, Integer] code
  #   The 4 digit zip code
  # @param [nil, Array<Integer>] only_types
  #   An array of zip code types (see ZipCode#type) which the returned zip codes must match.
  # @param [nil, Symbol] locale
  #   Return the names in the given locale, defaults to nil/:native (nil and :native are
  #   treated the same and will return the native names)
  #
  # @return [Array<String>]
  #   A list of unique names matching the parameters (4 digit code, type, locale).
  def self.cities_for_zip_code(code, only_types=nil, locale=nil)
    codes = @data.zip_codes.by_code(code.to_i)
    return [] unless codes
    codes = codes.select { |code| only_types.include?(code.type) } if only_types
    names = case locale
      when :native,nil then codes.map(&:name)
      when :de then codes.map(&:name_de)
      when :fr then codes.map(&:name_fr)
      when :it then codes.map(&:name_it)
      when :rt then codes.map(&:name_rt)
      else raise ArgumentError, "Invalid locale #{locale}"
    end

    names.uniq
  end

  def self.load(data_source=nil)
    @data = data_source || DataFiles.new
    @data.load!
  end

  # @private
  # Used to transliterate city names
  Transliteration1 = {
    "à" => "a",
    "â" => "a",
    "ä" => "a",
    "è" => "e",
    "é" => "e",
    "ê" => "e",
    "ë" => "e",
    "ì" => "i",
    "î" => "i",
    "ï" => "i",
    "ô" => "o",
    "ö" => "o",
    "ù" => "u",
    "ü" => "u",
  }

  # @private
  # Used to transliterate city names
  Transliteration2 = Transliteration1.merge({
    "ä" => "ae",
    "ö" => "oe",
    "ü" => "ue",
  })

  # @private
  # Used to transliterate city names
  TransMatch1 = /#{Transliteration1.keys.map { |k| Regexp.escape(k) }.join("|")}/

  # @private
  # Used to transliterate city names
  TransMatch2 = /#{Transliteration2.keys.map { |k| Regexp.escape(k) }.join("|")}/

  # @private
  # Used to transliterate city names
  def self.transliterate1(word)
    word.gsub(TransMatch1, Transliteration1).delete("^ A-Za-z").downcase
  end

  # @private
  # Used to transliterate city names
  def self.transliterate2(word)
    word.gsub(TransMatch2, Transliteration2).delete("^ A-Za-z").downcase
  end
end
