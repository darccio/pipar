# -*- encoding: utf-8 -*-
require 'pipar'
require 'watir-webdriver'
require 'headless'
require 'json'
require 'active_support/core_ext/string'

module Pipar
  class Spain
    def initialize
      @config = Configuration.for 'pipar'
      @images_dir = "#{@config.data_dir}/images"
    end

    def start(parties = {})
      next_link = nil
      Headless.ly do
        @browser = Watir::Browser.new :firefox, :profile => get_profile
        page = get_to_results_page parties
        skip_to = get_entries_to_skip parties, page
        begin
          next_link.first.click if next_link
          break unless has_results?
          0.upto count_results - 1 do |i|
            next if i < skip_to
            open_party_at i
            switch_to_popup do
              party = extract_party
              parties[party['id']] = party
            end
            sleep 2 # We play fair. A full scrape will last about three hours.
          end
          skip_to = 0
          next_link = @browser.links(:text, 'Siguiente')
        end while next_link.size > 0
      end
      return parties
    rescue => e
      STDERR.puts e
      e.backtrace.each do |line|
        STDERR.puts line
      end
      return parties
    ensure
      @browser.quit unless @browser.nil?
    end

    def get_to_results_page(parties)
      @browser.goto @config.url
      search = @browser.inputs(:value, 'Buscar').first
      search.click
      if parties.size > 0
        page = (parties.size / @config.entries.per_page).to_i
        page += 1 if parties.size == (@config.entries.per_page * page)
        @browser.goto(@config.page_url % {:page => page})
        page
      else
        0
      end
    end

    def get_entries_to_skip(parties, page)
      if parties.size > 0
        parties.size - (@config.entries.per_page * page)
      else
        0
      end
    end

    def has_results?
      get_result_data.size > 0
    end

    def count_results
      get_result_table.tbody.trs.size
    end

    def open_party_at(index)
      party_link = get_result_table.links[index]
      STDERR.puts party_link.text
      party_link.click
    end

    def extract_party
      party = {}
      %w(tipoFormacion siglas nombre fecInscripcion domicilioSocial poblacion autonomia
         telefono1 telefono2 fax email paginaweb desSimbolo observaciones).each do |field|
        fields = @browser.spans(:id, field)
        party[field] = fields.first.text if fields.size > 0 and fields.first.text.strip != ''
      end
      fields = @browser.labels(:for, 'ambito')
      party['ambito'] = if fields.size > 0
                          fields.first.text
                        else
                          data = @browser.text.scan(/Ámbito Territorial\n[A-Za-z\/\- ',\.]+\n/).first.split "\n"
                          data.last
                        end
      party['id'] = if party.has_key? 'siglas'
                      "#{party['siglas']}_#{party['nombre']}".parameterize
                    else
                      party['siglas'] = party['nombre']
                      party['nombre'].parameterize
                    end
      fields = @browser.spans(:id, 'simbolo')
      party['simbolo'] = get_party_logo(fields, party['siglas']) if fields.size > 0
      party
    end

    def get_party_logo(fields, name)
      return nil if fields.size == 0
      target = "#{@images_dir}/#{name.parameterize}.jpeg"
      return get_relative_path(target) if File.exist? target
      image_url = fields.first.imgs.first.src
      @browser.goto image_url
      30.times do
        file = Dir.entries(@images_dir).reject do |entry|
          !entry.ends_with? '.jpeg'
        end.sort_by do |entry|
          -1 * File.stat("#{@images_dir}/#{entry}").ctime.to_i
        end.first
        if file =~ /imagen.*\.jpeg/
          sleep 1 # Just to be sure that file is written to disk.
          File.rename "#{@images_dir}/#{file}", target
          return get_relative_path(target)
        end
        sleep 1 # We try to find the image during 30 seconds.
      end
      STDERR.puts "Unable to get image #{image_url}"
    end

    def get_profile
      profile = Selenium::WebDriver::Firefox::Profile.new
      # We configure Firefox to download parties' logos automatically.
      profile['browser.download.folderList'] = 2 # custom location
      profile['browser.download.dir'] = @images_dir
      profile['browser.helperApps.neverAsk.saveToDisk'] = 'image/jpeg'
      # We don't want popups.
      profile['app.update.enabled'] = false
      profile
    end

    def get_result_data
      @browser.tables(:id, 'resultado')
    end

    def get_result_table
      get_result_data.first
    end

    def switch_to_popup
      while @browser.driver.window_handles.size == 1
        sleep 0.25
      end
      @browser.driver.switch_to.window @browser.driver.window_handles[1]
      yield
      @browser.driver.switch_to.window @browser.driver.window_handles[0]
      @browser.windows[1].close
    end

    def get_relative_path(path)
      Pathname.new(path).relative_path_from(Pathname.new(Dir.pwd))
    end
  end
end