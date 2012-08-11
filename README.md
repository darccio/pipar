# Pipar

Open Data scrapper of political parties registries. Currently only for [Ministry of Interior of Spain registry](https://servicio.mir.es/nfrontal/webpartido_politico.html). Open to other countries!

It was meant to be OpenRPP (Registro de Partidos Políticos) but... Why not being open to international collaboration? So, it was meant to be OpenPPR (Political Parties Registry) but...
PPR, in Spanish, sounds like PePpeR so... Why not translating "pepper" to Íslenska?

That is how it got its name: Pipar. Now with more data. Available under MIT license.

**Legal note**: extracted data belongs to the corresponding institutions ([Ministry of Interior of Spain](http://www.interior.gob.es/) et al) and it is released under [CC0](http://creativecommons.org/publicdomain/zero/1.0/legalcode) or another fitting license, depending on country's legislation of each registry.

---

Extractor Open Data de registros de partidos políticos. Actualmente sólo para el [registro del Ministerio del Interior](https://servicio.mir.es/nfrontal/webpartido_politico.html). ¡Abierto a más países!

Debió llamarse OpenRPP (Registro de Partidos Políticos) pero... ¿Por qué no hacerlo internacional? Así, debió llamarse OpenPPR (Political Parties Registry) pero...
PPR suena a PePper así que... ¿Por qué no traducirlo al Íslenksa?

Así es cómo acabó con este nombre: Pipar. Ahora con más datos. Disponible bajo licencia MIT.

**Nota legal**: la información extraída pertenece a las correspondientes instituciones ([Ministerio del Interior](http://www.interior.gob.es/) y otros) y es liberada bajo [CC0](http://creativecommons.org/publicdomain/zero/1.0/legalcode) o otra licencia adecuada a la legislación del país de cada registro.

## Installation

Add this line to your application's Gemfile:

    gem 'pipar'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pipar

## Usage

    $ pipar path/to/recipe

### Recipes

You must write a recipe in order to use Pipar. Check the examples directory. The following attributes are mandatory:

+ registry: class to use as scraper.
+ data_dir: where data must be stored.
+ data_file: where to dump the extracted data as JSON.
+ url: initial URL.

Other attributes can be added and made mandatory for one or more registries.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
