# Development Environment (dev-env)

## Docker based

This variant will build on the first start the ubuntu based docker image and later connects then into this. While
building the scripts located in ``/setup`` will be executed. For the later startup make sure that you have the
parameter in the ``.env`` are defined to your needs.

````
docker-compose run --rm dev_env
````

## WSL

This variant uses the Windows subsystem for Linux. To make the WSL ready please execute the installation scripts
located in ``/setup`` as root (sudo). 