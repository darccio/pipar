require 'pipar'
require 'watir-webdriver'
require 'headless'
require 'json'

module Pipar
  class Spain
    def start
      Headless.ly do
        profile = Selenium::WebDriver::Firefox::Profile.new
        browser = Watir::Browser.new :firefox, :profile => profile
        browser.goto 'https://servicio.mir.es/nfrontal/webpartido_politico.html'
        search = browser.inputs(:value, 'Buscar').first
        search.click
        next_link = nil
        parties = []
        begin
          next_link.first.click if next_link
          results_data = browser.tables(:id, 'resultado')
          break if results_data.size == 0
          results = results_data.first
          results.tbody.trs.each do |row|
            party_link = row.tds.first.links.first
            party_link.click
            browser.driver.switch_to.window browser.driver.window_handles[1]
            parties << extract_party(browser)
            browser.driver.switch_to.window browser.driver.window_handles[0]
            browser.windows[1].close
          end
          break # debug
          next_link = browser.links(:text, 'Siguiente')
        end while next_link.size > 0
        json = JSON.new
        json.dump parties, File.new('data/parties.json')
      end
    end

    def extract_party(browser)
      party = {}
      %w(tipoFormacion siglas nombre fecInscripcion domicilioSocial poblacion autonomia telefono1 telefono2 fax email paginaweb desSimbolo observaciones).each do |field|
        fields = browser.spans(:id, field)
        party[field] = fields.first.text if fields.size > 0
      end
      party
    end
  end
end