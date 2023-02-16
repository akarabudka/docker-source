```bash
docker build -t <tag-name> -f php-apache/8.1.Dockerfile .

docker image build -t 1.0 -f php-apache/7.4.Dockerfile . && \
docker tag 1.0:latest akarabudka/php-apache:7.4 && \
docker push akarabudka/php-apache:7.4

docker image build -t 1.0 -f php-apache/8.1.Dockerfile . && \
docker tag 1.0:latest akarabudka/php-apache:8.1 && \
docker push akarabudka/php-apache:8.1

```

```bash
docker build -t <tag-name> -f php-fpm/8.1.Dockerfile .

docker image build -t 1.0 -f php-fpm/8.1.Dockerfile . && \
docker tag 1.0:latest akarabudka/php-fpm:8.1 && \
docker push akarabudka/php-fpm:8.1
```
