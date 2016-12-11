# docker-apache-newrelic
Base image to decrease time to build for CI

# Configure NEW_RELIC

newrelic.ini is configured to read 2 env var

```
NEW_RELIC_LICENSE_KEY
NEW_RELIC_APP_NAME
```

# Web root

WORKDIR points to `/var/www` 
You need to create a folder `/html` which is apache DOCUMENT_ROOT
