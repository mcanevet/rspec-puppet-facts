require 'facter'
require 'json'

module RspecPuppetFacts

  def on_supported_os( opts = {} )
    opts[:hardwaremodels] ||= RspecPuppetFacts.meta_supported_os
    opts[:supported_os] ||= RspecPuppetFacts.meta_supported_os
    opts[:factslocation] ||= File.expand_path(File.join(File.dirname(__FILE__), "../facts/"))

    h = {}

    opts[:supported_os].map do |os_sup|
      operatingsystem = os_sup['operatingsystem'].downcase
      os_sup['operatingsystemrelease'].map do |operatingsystemmajrelease|
        opts[:hardwaremodels].map do |hardware_sup|
          hardware_sup['hardware'].each do |hardware|
            os = "#{operatingsystem}-#{operatingsystemmajrelease.split(" ")[0]}-#{hardware}"
            # TODO: use SemVer here
            facter_minor_version = Facter.version[0..2]
            file = "#{opts[:factslocation]}/#{facter_minor_version}/#{os}.facts"
            # Use File.exists? instead of File.file? here so that we can stub File.file?
            if ! File.exists?(file)
              warn "Can't find facts for '#{os}' for facter #{facter_minor_version}, skipping..."
            else
              h[os] = JSON.parse(IO.read(file), :symbolize_names => true)
            end
          end
        end
      end
    end

    h
  end

  # @api private
  def self.meta_supported_os
    @meta_supported_os ||= get_meta_supported_os
  end

  # @api private
  def self.get_meta_supported_os
    metadata = get_metadata
    if metadata['operatingsystem_support'].nil?
      fail StandardError, "Unknown operatingsystem support"
    end
    metadata['operatingsystem_support']
  end
  
  # @api private
  def self.get_metadata
    if ! File.file?('metadata.json')
      fail StandardError, "Can't find metadata.json... dunno why"
    end
    JSON.parse(File.read('metadata.json'))
  end
end

RSpec.configure do |c|
  begin
    #c.formatter = 'NyanCatFormatter' if Date.today.strftime('%m%d') == '0401'
    #Love for NyanCat
    c.formatter = 'NyanCatFormatter'
  rescue LoadError
  end
end
