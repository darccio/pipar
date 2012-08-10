# -*- encoding: utf-8 -*-
require 'pipar'
require 'watir-webdriver'
require 'headless'
require 'json'
require 'active_support/core_ext/string'

module Pipar
  class Spain
    def initialize
      @images_dir = "#{Dir.pwd}/data/images"
    end

    def start
      next_link, parties = nil, []
      Headless.ly do
        @browser = Watir::Browser.new :firefox, :profile => get_profile
        @browser.goto 'https://servicio.mir.es/nfrontal/webpartido_politico.html'
        search = @browser.inputs(:value, 'Buscar').first
        search.click
        begin
          next_link.first.click if next_link
          break unless has_results?
          0.upto count_results - 1 do |i|
            party_link = get_result_table.links[i]
            STDERR.puts party_link.text
            party_link.click
            switch_to_popup { parties << extract_party }
          end
          next_link = @browser.links(:text, 'Siguiente')
        end while next_link.size > 0
      end
    rescue => e
      raise e
    ensure
      @browser.quit if @browser
      JSON.dump parties, STDOUT
    end

    def has_results?
      get_result_data.size > 0
    end

    def count_results
      get_result_table.tbody.trs.size
    end

    def extract_party
      party = {}
      %w(tipoFormacion siglas nombre fecInscripcion domicilioSocial poblacion autonomia
         telefono1 telefono2 fax email paginaweb desSimbolo observaciones).each do |field|
        fields = @browser.spans(:id, field)
        party[field] = fields.first.text if fields.size > 0 and fields.first.text.strip != ''
      end
      party['siglas'] = party['nombre'] unless party.has_key? 'siglas'
      fields = @browser.spans(:id, 'simbolo')
      party['simbolo'] = get_party_logo(fields, party['siglas']) if fields.size > 0
      fields = @browser.labels(:for, 'ambito')
      party['ambito'] = if fields.size > 0
        fields.first.text
      else
        data = @browser.text.scan(/Ámbito Territorial\n[A-Za-z]+\n/).first.split "\n"
        data.last
      end
      party
    end

    def get_party_logo(fields, name)
      return nil if fields.size == 0
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
          target = "#{@images_dir}/#{name.parameterize}.jpeg"
          File.rename "#{@images_dir}/#{file}", target
          return Pathname.new(target).relative_path_from(Pathname.new(Dir.pwd))
        end
        sleep 1
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
      @browser.driver.switch_to.window @browser.driver.window_handles[1]
      yield
      @browser.driver.switch_to.window @browser.driver.window_handles[0]
      @browser.windows[1].close
    end
  end
end