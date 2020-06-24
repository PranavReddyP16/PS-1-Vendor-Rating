# Build an image that can do training and inference in Coleman AI
# This is a Python 3 image that uses the nginx, gunicorn, flask stack
# for serving inferences in a stable way.

FROM ubuntu:18.04

MAINTAINER Coleman AI <jslovak@infor.com>

# RUN echo "Adding Python3 PPA"
# RUN apt-get -y update && apt install -y software-properties-common && add-apt-repository ppa:deadsnakes/ppa -y
# RUN apt-get install --reinstall ca-certificates
RUN echo "Installing packages"

RUN apt-get -y update && apt-get install -y --no-install-recommends \
         wget \
         python3.7 \
         python3-distutils \
         nginx \
         ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN echo "Everything installed"

RUN echo "Installing throught pip"

# Here we get all python packages.
# There's substantial overlap between scipy and numpy that we eliminate by
# linking them together. Likewise, pip leaves the install caches populated which uses
# a significant amount of space. These optimizations save a fair amount of space in the
# image, which reduces start up time.
RUN wget https://bootstrap.pypa.io/get-pip.py && python3.7 get-pip.py && \
    pip3 install numpy==1.18.1 scipy==1.4.1 scikit-learn==0.22.1 pandas flask gevent gunicorn && \
        (cd /usr/local/lib/python3.7/dist-packages/scipy/.libs; rm *; ln ../../numpy/.libs/* .) && \
        rm -rf /root/.cache

# Set some environment variables. PYTHONUNBUFFERED keeps Python from buffering our standard
# output stream, which means that logs can be delivered to the user quickly. PYTHONDONTWRITEBYTECODE
# keeps Python from writing the .pyc files which are unnecessary in this case. We also update
# PATH so that the train and serve programs are found when the container is invoked.

RUN echo "Installation through pip is done"

ENV PYTHONUNBUFFERED=TRUE
ENV PYTHONDONTWRITEBYTECODE=TRUE
ENV PATH="/opt/program:${PATH}"

# Set up the program in the image
COPY algorithm_files /opt/program
WORKDIR /opt/program
EXPOSE 5000

CMD python3 temp_ps.py
#RUN chmod +x /opt/program/train
#RUN chmod +x /opt/program/serve
