FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04

ENV DEBIAN_FRONTEND noninteractive

# install dependencies via apt
ENV DEBCONF_NOWARNINGS yes
RUN set -x && \
  apt-get update -y -qq && \
  apt-get upgrade -y -qq --no-install-recommends && \
  apt-get install -y -qq \
    curl software-properties-common \
    python3-pip git git-lfs cmake && \
  : "remove cache" && \
  apt-get autoremove -y -qq && \
  rm -rf /var/lib/apt/lists/*

RUN pip3 install -U pip
RUN git clone https://github.com/ggerganov/llama.cpp && \
    cd llama.cpp && \
    pip3 install -r requirements.txt && \
    cmake -B build && \
    cmake --build build --config Release
#RUN git clone https://huggingface.co/deepseek-ai/DeepSeek-R1-Distill-Llama-32B && \
RUN git clone https://huggingface.co/deepseek-ai/DeepSeek-R1-Distill-Qwen-32B && \
    cd DeepSeek-R1-Distill-Qwen-32B && \
    git lfs pull
RUN python3 llama.cpp/convert_hf_to_gguf.py --outfile DeepSeek-R1-Distill-Qwen-32B.gguf DeepSeek-R1-Distill-Qwen-32B

RUN curl -fsSL https://ollama.com/install.sh -O && \
    bash ./install.sh
#RUN echo 'FROM ./DeepSeek-R1-Distill-Qwen-32B.gguf' > Modelfile_DeepSeek-R1-Distill-Qwen-32B
COPY Modelfile_DeepSeek-R1-Distill-Qwen-32B /

RUN echo '#!/bin/bash\nollama serve &\nsleep 5\nollama create DeepSeek-R1-Distill-Qwen-32B -f Modelfile_DeepSeek-R1-Distill-Qwen-32B\n' > /launch_ollama_server.sh
RUN chmod +x /launch_ollama_server.sh
RUN /launch_ollama_server.sh
ENTRYPOINT ["ollama", "serve"]