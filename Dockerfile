FROM gcr.io/google_appengine/python
RUN virtualenv /env
ENV PATH /env/bin:$PATH

RUN export DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository 'deb http://mozilla.debian.net/ jessie-backports firefox-release'
RUN apt-get install -y curl

RUN export BASE_URL=https://github.com/mozilla/geckodriver/releases/download   && export VERSION=$(curl -sL \
    https://api.github.com/repos/mozilla/geckodriver/releases/latest | \
    grep tag_name | cut -d '"' -f 4)   && curl -sL   $BASE_URL/$VERSION/geckodriver-$VERSION-linux64.tar.gz | tar -xz

CMD cp geckodriver /env/bin/
CMD cp geckodriver /usr/local/bin/
CMD cp geckodriver /env/usr/local/bin/

RUN apt-get update
RUN apt-get install -y --force-yes firefox 

RUN apt-get install python-pip

ADD requirements.txt /app/
RUN /env/bin/pip install -r /app/requirements.txt 
RUN apt-get install -y --force-yes xvfb


ADD . /app

ENV PATH /env/bin:/usr/local/bin:/env/usr/local/bin:/app:$PATH

CMD gunicorn -b :$PORT main:app

