# FROM nvcr.io/nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04
FROM nvcr.io/nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

ARG PYTHON_VERSION=3.11
ARG PACKAGES="git curl ca-certificates ffmpeg"

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Tokyo
ENV PYTHONUNBUFFERED=1
ENV WHISPER_IMPLEMENTATION=faster-whisper
ENV PIP_NO_CACHE_DIR=on

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv f23c5a6cf475977595c89f51ba6932366a755776 \
 && echo "deb http://ppa.launchpadcontent.net/deadsnakes/ppa/ubuntu jammy main" > /etc/apt/sources.list.d/python.list \
 && echo "deb-src http://ppa.launchpad.net/deadsnakes/ppa/ubuntu jammy main" >> /etc/apt/sources.list.d/python.list

RUN apt-get update \
 && apt-get install -y --no-install-recommends ${PACKAGES} python${PYTHON_VERSION} \
 && ln -nfs /usr/bin/python${PYTHON_VERSION} /usr/bin/python \
 && ln -nfs /usr/bin/python${PYTHON_VERSION} /usr/bin/python3 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY ./requirements.txt ./

RUN curl -sSL https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py \
  && python /tmp/get-pip.py \
  && pip install torch==2.1.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu121 \
  && pip install -r requirements.txt
RUN python -c "from huggingface_hub import snapshot_download; snapshot_download('Systran/faster-whisper-large-v3')"
# ENV HF_HUB_OFFLINE=1

COPY . ./

CMD ["python", "app.py", "--input_audio_max_duration", "-1", "--server_name", "0.0.0.0", "--auto_parallel", "True", "--default_model_name", "large-v3"]
