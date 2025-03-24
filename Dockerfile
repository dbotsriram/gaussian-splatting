FROM nvidia/cuda:11.6.1-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive

# Update and install system dependencies, including gcc-9/g++-9
RUN apt update -y && \
    apt upgrade -y && \
    apt install sudo -y

ENV PATH="/usr/local/cuda-11.6/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda-11.6/lib64:${LD_LIBRARY_PATH}"

# RUN echo 'export PATH="/usr/local/cuda-11.6/bin:$PATH"' >> ~/.bashrc
# RUN echo 'export LD_LIBRARY_PATH="/usr/local/cuda-11.6/lib64:$LD_LIBRARY_PATH"' >> ~/.bashrc
# ENV echo 'export PATH="/usr/local/cuda-11.6/bin:$PATH"' >> ~/.bashrc
# ENV echo 'export LD_LIBRARY_PATH="/usr/local/cuda-11.6/bin:$LD_LIBRARY_PATH"' >> ~/.bashrc
# RUN source ~/.bashrc

RUN apt-get update && apt-get install -y --no-install-recommends \
    git wget curl unzip build-essential cmake libgl1-mesa-dev libglib2.0-0 \
    python3-pip python3-dev \
    gcc-9 g++-9 \
    && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90 \
           --slave /usr/bin/g++ g++ /usr/bin/g++-9 \
    && rm -rf /var/lib/apt/lists/*


ENV TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6+PTX"
#ENV TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9+PTX"
#ENV TORCH_CUDA_ARCH_LIST="3.5;5.0;6.0;6.1;7.0;7.5;8.0;8.6;8.9;9.0+PTX"


RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    /opt/conda/bin/conda clean --all

# Ensure conda commands are on PATH
ENV PATH=/opt/conda/bin:$PATH

RUN conda update -n base -c defaults conda

WORKDIR /workspace
RUN git clone https://github.com/dbotsriram/gaussian-splatting --recursive

# Set working directory to gaussian-splatting
WORKDIR /workspace/gaussian-splatting

# Create and configure the conda environment
RUN conda create -n gaussian_splatting python=3.7.13 -y
RUN conda run -n gaussian_splatting pip install ninja torch==1.12.1+cu116 torchvision==0.13.1+cu116 torchaudio==0.12.1 --extra-index-url https://download.pytorch.org/whl/cu116
RUN conda run -n gaussian_splatting pip install -r requirements.txt
RUN echo "source /opt/conda/bin/activate gaussian_splatting" >> ~/.bashrc
#COPY /parking /workspace/parking
ENTRYPOINT ["/bin/bash"]
