import logging

from apache_beam import CombineGlobally
from apache_beam import Create
from apache_beam import ParDo
from apache_beam import Pipeline
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions


def main():
  options = PipelineOptions()
  options.view_as(SetupOptions).save_main_session = True

  p = Pipeline(options=options)

  start = 1
  end = 100
  (p
   | 'From {} to {}'.format(start, end) >> Create(list(range(start, end + 1)))
   | 'Sum' >> CombineGlobally(sum)
   | 'Print' >> ParDo(
          lambda total: logging.info('Sum from 1 to 100 is %s', total)))

  p.run()


if __name__ == '__main__':
  logging.getLogger().setLevel(logging.INFO)
  main()
