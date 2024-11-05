ARG BASE_CONTAINER=ucsdets/datahub-base-notebook:stable
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
RUN mamba install -c esri arcgis=2.2.0 numpy=1.26.2 -y

RUN pip install --upgrade pip setuptools wheel
RUN pip install --upgrade nbconvert

RUN mamba install -c conda-forge geopandas cartopy pygeos pysal contextily osmnx jupyterlab_widgets -y

RUN pip uninstall pillow fiona -y && \
    pip install -r ~/requirements.txt && \
	pip install --upgrade fiona

RUN pip uninstall pillow fiona -y || echo "Failed to uninstall pillow or fiona" && \
    pip install -r ~/requirements.txt || echo "Failed to install requirements" && \
    pip install --upgrade fiona || echo "Failed to upgrade fiona"

RUN jupyter nbextension enable  --py --sys-prefix arcgis && \
	jupyter nbextension enable --py --sys-prefix arcgis

USER $NB_UID

COPY arcgis_test.ipynb /opt
RUN rm -rf /home/jovyan/requirements.txt

ENV USE_PYGEOS=0

