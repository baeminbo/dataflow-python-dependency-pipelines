# dataflow-python-dependency-pipelines
Pipeline examples to learn options for python dependency


* [Example #0](example0): A simple pipeline without any dependency option.
* [Example #1](example1): Using `--requirement_file`. The job is successful.
* [Example #2](example2): Using `--extra_packages`. The jb is successful.
* [Example #3](example3): Using `lxml` in `--requirement_file`. The job fails with build error in SDK containers.
* [Example #4](example4): Using `lxml` binary package in `--extra_packages`. The job is successful.
* [Example #5](example5): Using `lxml` in `install_requires` of setup.py. The job is successful.
* [Example #6](example6): Custom container with `lxml` pre-installed. The job is successful. 
