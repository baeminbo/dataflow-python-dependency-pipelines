import logging
import time

from apache_beam import Create
from apache_beam import DoFn
from apache_beam import ParDo
from apache_beam import Pipeline
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions
from apache_beam.transforms.window import GlobalWindow
from apache_beam.utils.windowed_value import WindowedValue
from lxml import etree


class ToXmlDoFn(DoFn):
  def __init__(self):
    self._root = None

  def start_bundle(self):
    self._root = etree.Element('root')

  def process(self, element):
    etree.SubElement(self._root, 'element').text = str(element)

  def finish_bundle(self):
    xml = etree.tostring(self._root, pretty_print=True)
    self._root = None
    yield WindowedValue(xml, GlobalWindow().max_timestamp(), [GlobalWindow()])


class Sleep(DoFn):
  def __init__(self, secs):
    self._secs = secs

  def process(self, element):
    time.sleep(self._secs)
    yield element

def main():
  options = PipelineOptions()
  options.view_as(SetupOptions).save_main_session = True
  p = Pipeline(options=options)

  start = 1
  end = 10

  (p
   | 'From {} to {}'.format(start, end)
   >> Create(list(range(start, end + 1)))
   | 'ToXml' >> ParDo(ToXmlDoFn())
   # If a job finishes too quickly, worker VMs can be shutdown before they send
   # logs in local files to Cloud Logging. Adding 30s sleep to avoid this
   | 'Sleep30s' >> ParDo(Sleep(30))
   | 'Print' >> ParDo(lambda xml: logging.info(xml))
   )

  p.run()


if __name__ == '__main__':
  logging.getLogger().setLevel(logging.INFO)
  main()
