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

### BEGIN censusdis
ARG KERNEL=censusdis
# COPY ${KERNEL}.yaml /home/jovyan
RUN mamba create --yes -p "${CONDA_DIR}/envs/${KERNEL}" \
    python=3.11 \
    ipykernel \
    jupyterlab \
    censusdis && \
    mamba clean --all -f -y

RUN "${CONDA_DIR}/envs/${KERNEL}/bin/python" -m ipykernel install --user --name="${KERNEL}" && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

RUN /opt/setup-scripts/activate_notebook_custom_env.py "${KERNEL}"
### END censusdis

ARG SKLEARN_ALLOW_DEPRECATED_SKLEARN_PACKAGE_INSTALL=True
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

RUN mamba install --yes 'py-xgboost' && \
    mamba clean --all -f -y && \
    fix-permissions "${CONDA_DIR}" && \
    fix-permissions "/home/${NB_USER}"

USER $NB_UID
COPY arcgis_test.ipynb /opt
RUN rm -rf /home/jovyan/requirements.txt

ENV USE_PYGEOS=0
