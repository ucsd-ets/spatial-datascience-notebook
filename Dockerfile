ARG BASE_CONTAINER=ucsdets/datahub-base-notebook:2022.3-stable
FROM $BASE_CONTAINER

LABEL maintainer="UC San Diego ITS/ETS <ets-consult@ucsd.edu>"

USER root

###########################
# Requested for DSC170 WI23
COPY requirements.txt /home/jovyan

RUN apt update -y && \
    apt-get install software-properties-common -y && \
    add-apt-repository universe && \
    apt update -y && \
    apt install graphviz -y
RUN mamba install -c esri arcgis=2.1.0.2 numpy=1.22.0 -y

RUN pip install --upgrade pip setuptools wheel
RUN pip install --upgrade nbconvert

RUN mamba install -c conda-forge geopandas cartopy pygeos pysal contextily osmnx jupyterlab_widgets -y

RUN pip uninstall pillow fiona -y && \
  pip install -r ~/requirements.txt && \
	pip install --upgrade fiona

RUN jupyter nbextension enable --py widgetsnbextension --sys-prefix && \
	jupyter labextension install @jupyter-widgets/jupyterlab-manager && \
	jupyter labextension install arcgis-map-ipywidget@2.0.1

RUN jupyter nbextension enable  --py --sys-prefix arcgis && \
	jupyter nbextension enable --py --sys-prefix arcgis

USER $NB_UID

COPY arcgis_test.ipynb /opt
RUN rm -rf /home/jovyan/requirements.txt

ENV USE_PYGEOS=0

