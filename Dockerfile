# NOTE: to run:
# 	docker run -it -d -p=6006:6006 -p=8888:8888 -v=~/DockerShared/JupykerShared:/host  ea167/jupyker-cpu
#
# http://localhost:8888 for Jupyter Notebook
# http://localhost:6006 for TensorBoard
#
# Built for CPUs (without gpu support)
#
# To run tensorboard:
# 	tensorboard --logdir=path/to/logs
# 	where path/to/logs is typically related to
# 		file_writer = tf.summary.FileWriter('/path/to/logs', sess.graph)


### Other great Docker images similar to this one:
### 	https://hub.docker.com/r/gw000/keras-full/
### 	https://hub.docker.com/r/waleedka/modern-deep-learning/


# 18.04 is the latest - Out on April, 2018
FROM ubuntu:18.04
LABEL maintainer="Eric Amram <eric dot amram at gmail dot com>"

# Headless front-end, remove warnings
ARG DEBIAN_FRONTEND=noninteractive

# Get most recent updates
RUN apt-get update -qq

# Utils
RUN apt-get install -y --no-install-recommends apt-utils \
 && apt-get install -y --no-install-recommends \
    locales \
	ssh vim unzip less procps \
	git curl wget \
	build-essential g++ cmake \
 && echo 'Acquire::Retries "5";' > /etc/apt/apt.conf.d/99AcquireRetries \
 && sed -i 's/main$/main contrib non-free/' /etc/apt/sources.list
 ##&& apt-get install -y --no-install-recommends linux-headers-generic initramfs-tools


# Locales
RUN locale-gen "en_US.UTF-8" \
 && update-locale LC_ALL="en_US.UTF-8" LANG="en_US.UTF-8"

ENV LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8"


# Python (3.5)
# Aliases (but don't sym-link) python -> python3 and pip -> pip3
RUN apt-get install -y --no-install-recommends \
    python3 \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-virtualenv \
    pkg-config \
    # Required for keras
    python3-h5py \
    python3-yaml \
    python3-pydot
# Upgrade with latest pip and create aliases
RUN pip3 install --no-cache-dir --upgrade pip setuptools \
 && echo "alias python='python3'" >> /root/.bash_aliases \
 && echo "alias pip='pip3'" >> /root/.bash_aliases


# Pillow (with dependencies)
RUN apt-get install -y --no-install-recommends libjpeg-dev zlib1g-dev \
 && pip3 --no-cache-dir install Pillow

# OpenBLAS
RUN apt-get install -y --no-install-recommends libopenblas-base libopenblas-dev

# Python scientific libs
RUN pip3 --no-cache-dir install \
    numpy \
    scipy \
    scikit-learn \
    scikit-image \
    statsmodels \
    pandas \
    matplotlib \
    seaborn

# Note: seaborn is high-level statistical data visualization on top of matplotlib

### We should not need old Python2. Otherwise, we'll need to install:
#RUN apt-get install -y --no-install-recommends \
#    python \
#    python-dev \
#    python-pip \
#    python-setuptools \
#    python-virtualenv \
#    python-wheel \
#    python-matplotlib \
#    python-pillow


# Jupyter notebook
RUN pip3 --no-cache-dir install jupyter \
# Jupyter config: don't open browser. Password will be set when launching, see below.
 && mkdir /root/.jupyter \
 && echo "c.NotebookApp.ip = '*'" \
         "\nc.NotebookApp.open_browser = False" \
         > /root/.jupyter/jupyter_notebook_config.py
EXPOSE 8888


# Tensorflow
RUN pip3 install --no-cache-dir --upgrade tensorflow
# Port for TensorBoard
EXPOSE 6006


# Keras
RUN pip3 --no-cache-dir install keras


# Clean-up
RUN apt-get clean && apt-get autoremove \
 && rm -rf /var/lib/apt/lists/*


# Configure console -- FIXME !!!
RUN echo 'alias ll="ls --color=auto -lA"' >> /root/.bashrc \
 && echo '"\e[5~": history-search-backward' >> /root/.inputrc \
 && echo '"\e[6~": history-search-forward' >> /root/.inputrc
# default password: keras
ENV PASSWD='sha1:98b767162d34:8da1bc3c75a0f29145769edc977375a373407824'

# dump package lists
RUN dpkg-query -l > /dpkg-query-l.txt \
 && pip3 freeze > /pip3-freeze.txt

# Volumes and folders shared with host
VOLUME ["/host"]

# Start Jupyter Notebook
#WORKDIR /root/
WORKDIR /host/

CMD jupyter notebook --allow-root --no-browser --ip=* --NotebookApp.password="$PASSWD" \
    & /bin/bash
