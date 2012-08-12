require 'pipar/registry/spain'

Configuration.for('pipar') {
  registry   Pipar::Spain
  entries {
    per_page 25
  }
  data_dir   "#{Dir.pwd}/data"
  data_file  "#{self.data_dir}/parties.json"
  url        'https://servicio.mir.es/nfrontal/webpartido_politico.html'
  page_url   'https://servicio.mir.es/nfrontal/webpartido_politico/partido_politicoBuscar.html?pagActual=%{page}'
  # Partial download support.
  start_page 0
  skip_to    0
}
