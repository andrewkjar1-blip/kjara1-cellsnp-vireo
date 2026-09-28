FROM mambaorg/micromamba:1.5.10

USER root

# Utilities expected by the WDL shell scripts.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      bash \
      coreutils \
      findutils \
      gawk \
      grep \
      sed \
      && \
    rm -rf /var/lib/apt/lists/*

# Copy the reproducible Conda-environment specification.
COPY --chown=$MAMBA_USER:$MAMBA_USER environment.yml /tmp/environment.yml

# Create the environment.
RUN micromamba create \
      --yes \
      --name cellsnp-vireo \
      --file /tmp/environment.yml && \
    micromamba clean --all --yes

# Make Conda environment programs available without activation.
ENV PATH=/opt/conda/envs/cellsnp-vireo/bin:$PATH
ENV PYTHONUNBUFFERED=1
ENV PYTHONNOUSERSITE=1

# Validate requirements during the build.
RUN command -v python && \
    command -v samtools && \
    command -v cellsnp-lite && \
    command -v vireo && \
    python -c '\
import anndata, pysam, vireoSNP; \
print("anndata:", anndata.__version__); \
print("pysam:", pysam.__version__); \
print("vireoSNP:", vireoSNP.__version__)'

WORKDIR /workspace

CMD ["bash"]
