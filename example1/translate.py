import logging

from apache_beam import Create
from apache_beam import DoFn
from apache_beam import Map
from apache_beam import ParDo
from apache_beam import Pipeline
from apache_beam.options.pipeline_options import GoogleCloudOptions
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions
from google.cloud import translate


class Translate(DoFn):
  def __init__(self, project, source_language_code, target_language_code):
    self._client = None
    self._project = project
    self._source_code = source_language_code
    self._target_code = target_language_code

  def setup(self):
    self._client = translate.TranslationServiceClient()

  def process(self, text):
    # See https://cloud.google.com/translate/docs/advanced/quickstart
    request = {
        'parent': f'projects/{self._project}/locations/global',
        'contents': [text],
        'mime_type': 'text/plain',
        'source_language_code': self._source_code,
        'target_language_code': self._target_code,
    }

    response = self._client.translate_text(request)

    translated_text = None
    for translation in response.translations:
      translated_text = translation.translated_text
      break

    yield text, translated_text


def main():
  options = PipelineOptions()
  options.view_as(SetupOptions).save_main_session = True

  project = options.view_as(GoogleCloudOptions).project
  assert project is not None, '"project" is not specified.'

  source_code = 'en-US'
  target_code = 'ja'
  texts = ['Hello', 'Thank you', 'Goodbye']

  p = Pipeline(options=options)
  (p
   | 'Texts' >> Create(texts)
   | 'Translate' >> ParDo(Translate(project, source_code, target_code))
   | 'Print' >> Map(lambda pair: logging.info('%s -> %s', pair[0], pair[1])))

  p.run()


if __name__ == '__main__':
  logging.getLogger().setLevel(logging.INFO)
  main()
