# Use our python alpine image to run webapp proper
FROM uisautomation/python:3.7-alpine

# Postgre Configuration
ENV POSTGRES_DB=%POSTGRES_DB%
ENV POSTGRES_USER=%POSTGRES_USER%
ENV POSTGRES_PASSWORD=%POSTGRES_PASSWORD%

# Database configuration. Note that the postgres container also uses these
# values with differing names.
ENV DJANGO_DB_ENGINE=django.db.backends.postgresql
ENV DJANGO_DB_HOST=%DJANGO_DB_HOST%
ENV DJANGO_DB_NAME=%DJANGO_DB_NAME%
ENV DJANGO_DB_USER=%DJANGO_DB_USER%
ENV DJANGO_DB_PASSWORD=%DJANGO_DB_PASSWORD%
ENV DJANGO_DB_CONN_MAX_AGE=60
ENV DJANGO_DB_PORT=5432
ENV DJANGO_SECRET_KEY=some-secret-key-used-only-in-development
ENV DJANGO_PORT=8000
# Email configuration for development SMTP server
ENV DJANGO_EMAIL_HOST=localhost
ENV DJANGO_EMAIL_PORT=1025

# Object store configuration
ENV DJANGO_USE_AWS=1
ENV DJANGO_AWS_ACCESS_KEY_ID=%DJANGO_AWS_ACCESS_KEY_ID%
ENV DJANGO_AWS_SECRET_ACCESS_KEY=%DJANGO_AWS_SECRET_ACCESS_KEY%
ENV DJANGO_AWS_STORAGE_BUCKET_NAME=%DJANGO_AWS_STORAGE_BUCKET_NAME%
ENV DJANGO_AWS_S3_ENDPOINT_URL=%DJANGO_AWS_S3_ENDPOINT_URL%
ENV DJANGO_DANGEROUS_DISABLE_AWS_USE_SSL=1
ENV DJANGO_AWS_S3_REGION_NAME=%DJANGO_AWS_S3_REGION_NAME%
ENV DJANGO_AWS_S3_HOST=%DJANGO_AWS_S3_HOST%

# Ensure packages are up to date and install some useful utilities
RUN apk update && apk add git vim postgresql-dev libffi-dev gcc musl-dev \
	libxml2-dev libxslt-dev libjpeg-turbo-dev curl

# From now on, work in the application directory
WORKDIR /usr/src/app

# Copy Docker configuration and install any requirements. We install
# requirements/docker.txt last to allow it to override any versions in
# requirements/requirements.txt.
ADD ./requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Default environment for image.  By default, we use the settings module bundled
# with this repo. Change DJANGO_SETTINGS_MODULE to install a custom settings.
#
# You probably want to modify the following environment variables:
#
# DJANGO_DB_ENGINE, DJANGO_DB_HOST, DJANGO_DB_PORT, DJANGO_DB_USER
EXPOSE 8080
ENV \
	DJANGO_SETTINGS_MODULE=botolphs.settings \
	PORT=8080

# Copy remaining application files
COPY ./manage.py ./
COPY ./botolphs/ ./botolphs/

# Collect static files using placeholder values for required settings.
RUN DJANGO_SECRET_KEY=placeholder ./manage.py collectstatic

# Create unprivileged user to run application
RUN adduser -S webapp

# Give webapp ability to *read* files but not write anything. Our container
# should not need to write to the local filesystem.
RUN chown -R webapp /usr/src/app && chmod -R oug-w /usr/src/app

# Run everything as the unprivileged user
USER webapp
#CMD ["tail", "-f" ,"/dev/null"]
# Use gunicorn as a web-server after running migration command
CMD gunicorn \
	--name botolphs \
	--bind :$DJANGO_PORT \
	--workers 3 \
	--log-level=info \
	--log-file=- \
	--access-logfile=- \
	--capture-output \
	botolphs.wsgi
