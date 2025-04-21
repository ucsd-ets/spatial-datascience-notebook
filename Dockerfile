FROM ghcr.io/ucsd-ets/datascience-notebook:2024.4-stable

LABEL maintainer="UC San Diego"

USER root

########################
# Requested for DSC170 WI25
COPY requirements.txt /home/jovyan

RUN apt update -y && \
    apt-get install software-properties-common -y && \
    add-apt-repository universe && \
    apt update -y && \
    apt install graphviz -y

RUN jupyter labextension install @dafeliton/jupyterlab-notebookparams

ENV SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL=True
# Install geospatial packages first
RUN pip uninstall pillow fiona -y && \
    pip install -r ~/requirements.txt && \
    pip install --upgrade fiona

# pygeos is deprecated and has been merged with shapely. (pygeos works around python GIL)
# https://github.com/shapely/shapely

# geopandas/cartopy/etc. error when importing sqlite3 from python:
# ImportError: /opt/conda/lib/python3.11/lib-dynload/_sqlite3.cpython-311-x86_64-linux-gnu.so: undefined symbol: sqlite3_deserialize
# Moved to requirements.txt

RUN mamba install -c esri arcgis arcgis-mapping -y && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER && \
    mamba clean --all

RUN pip install --upgrade pip setuptools wheel
RUN pip install --upgrade nbconvert
# RUN pip install numpy==1.26.4 pygris shap

ARG KERNEL=censusdis
# ARG CONDA_PREFIX=/opt/conda/envs/${KERNEL}
COPY ${KERNEL}.yaml /home/jovyan
RUN conda env create --file /home/jovyan/${KERNEL}.yaml && \
    # eval "$(conda shell.bash hook)" && \
    # conda activate ${KERNEL} && \
    # mkdir -p $CONDA_PREFIX/etc/conda/activate.d && \
    python -m ipykernel install --name=${KERNEL}

# RUN pip install "numpy<2"

USER $NB_UID

COPY arcgis_test.ipynb /opt
RUN rm -rf /home/jovyan/requirements.txt

ENV USE_PYGEOS=0
