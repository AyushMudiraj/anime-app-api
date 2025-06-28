# """
# Dockerfile for Django application
# This Dockerfile is used to create a Docker image for a Django application. 
# It uses the official Python 3.9 Alpine image as the base image and installs the required packages from a requirements.txt file. 
# """

FROM python:3.9-alpine3.13
LABEL maintainer="Ayush"

# """
# Set the environment variables:
#     1. PYTHONUNBUFFERED: Ensures that the output from Python is sent straight to the terminal without being buffered.
# """
ENV PYTHONUNBUFFERED=1

# """ 
# 1. Copy requirements file from local to docker image
# 2. Copy the rest of the application code to the image
# 3. Set the working directory to /app
# 4. Expose port 8000 for the application
# """
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# """
# Run the following commands:
#     1. Create a virtual environment in /py
#     2. Upgrade pip to the latest version
#     3. Install the required packages from requirements.txt
#     4. If DEV is true, install the required packages from requirements-dev.txt
#        (this is used for development purposes i.e. when building the image with --build-arg DEV=true)
#        This is useful for installing development dependencies such as linters, formatters, and testing tools (these should work only on development image).
#     5. Remove the temporary files
#     6. Create a new user named django-user with no password and no home directory
# """
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \ 
        then /py/bin/pip install -r /tmp/requirements.dev.txt; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# """
# Set the environment variable PYTHONPATH to /app and add /py/bin to the PATH variable
# """
ENV PATH="/py/bin:$PATH"

# """
# Set the user to django-user and run the application using gunicorn
# """
USER django-user