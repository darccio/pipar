require 'pipar/registry/spain'

Configuration.for('pipar') {
  registry   Pipar::Spain
  entries {
    per_page 25
  }
  data_dir   "#{Dir.pwd}/data/spain"
  data_file  "#{self.data_dir}/parties.json"
  url        'https://servicio.mir.es/nfrontal/webpartido_politico.html'
  page_url   'https://servicio.mir.es/nfrontal/webpartido_politico/partido_politicoBuscar.html?pagActual=%{page}'

  # Data metadata
  __metadata__ = {
    'organization' => {
      'name' => 'Ministerio del Interior de España',
      'href' => 'http://www.interior.gob.es/',
      'source' => {
        'name' => 'Registro de Partidos Políticos',
        'href' => self.url
      }
    },
    'license' => {
      'name' => 'CC0 1.0 Universal (CC0 1.0)',
      'href' => 'http://creativecommons.org/publicdomain/zero/1.0/'
    }
  }
  metadata __metadata__

  # Partial download support.
  start_page 0
  skip_to    0
}
