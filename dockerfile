FROM --platform=linux/x86_64 thr3a/cuda12.1-torch:latest

ENV WHISPER_IMPLEMENTATION=faster-whisper

RUN apt-get update \
 && apt-get install -y --no-install-recommends ffmpeg \
 && rm -rf /var/lib/apt/lists/*

COPY ./requirements.txt ./
RUN pip install -r requirements.txt
RUN python -c "from huggingface_hub import snapshot_download; snapshot_download('Systran/faster-whisper-large-v3')"
# ENV HF_HUB_OFFLINE=1

COPY . ./

CMD ["python", "app.py", "--input_audio_max_duration", "-1", "--server_name", "0.0.0.0", "--auto_parallel", "True", "--default_model_name", "large-v3", "--language", "ja"]
