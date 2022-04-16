# DNS service as docker container

Run docker-compose up -d to start a local dns server. The image will be build directly before running the container.
This allows full control over the image itself.

The main part of the source code comes currently from ([1](https://github.com/sameersbn/docker-bind)), so thank you for
sharing this. Small adaptation is that the
docker compose file is not taking the pre-build image it is building the image fresh if not present on your system.

## Linked references:

([1](https://github.com/sameersbn/docker-bind)) https://github.com/sameersbn/docker-bind