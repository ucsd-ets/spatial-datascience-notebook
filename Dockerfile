ARG BASE_CONTAINER=ghcr.io/ucsd-ets/datascience-notebook:2024.4-stable
FROM $BASE_CONTAINER

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

USER root

######################### ##
# Requested for DSC170 WI23
COPY requirements.txt /home/jovyan

RUN apt update -y && \
    apt-get install software-properties-common -y && \
    add-apt-repository universe && \
    apt update -y && \
    apt install graphviz -y
RUN mamba install -c esri arcgis=2.2.0 -y

RUN mamba install numpy -y

RUN pip install --upgrade pip setuptools wheel
RUN pip install --upgrade nbconvert

RUN mamba install -c conda-forge geopandas cartopy pygeos pysal contextily osmnx jupyterlab_widgets -y

RUN pip uninstall pillow fiona -y && \
    pip install -r ~/requirements.txt && \
    pip install --upgrade fiona

USER $NB_UID

COPY arcgis_test.ipynb /opt
RUN rm -rf /home/jovyan/requirements.txt

ENV USE_PYGEOS=0

