FROM nvidia/cuda:12.1.0-cudnn8-devel-ubuntu22.04

# Dockerfileの先頭でARG命令でプロキシ変数を宣言
ARG HTTP_PROXY
ARG HTTPS_PROXY

# その後、必要に応じて環境変数に設定
ENV HTTP_PROXY=${HTTP_PROXY}
ENV HTTPS_PROXY=${HTTPS_PROXY}

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
RUN git clone https://huggingface.co/deepseek-ai/DeepSeek-R1-Distill-Llama-8B && \
    cd DeepSeek-R1-Distill-Llama-8B && \
    git lfs pull && \
    cd .. && \
    python3 llama.cpp/convert_hf_to_gguf.py --outfile DeepSeek-R1-Distill-Llama-8B.gguf DeepSeek-R1-Distill-Llama-8B && \
    rm -r DeepSeek-R1-Distill-Llama-8B && \
    llama.cpp/build/bin/llama-quantize DeepSeek-R1-Distill-Llama-8B.gguf DeepSeek-R1-Distill-Llama-8B-Q4_K_M.gguf Q4_K_M && \
    rm DeepSeek-R1-Distill-Llama-8B.gguf

RUN git clone https://huggingface.co/deepseek-ai/DeepSeek-Coder-V2-Lite-Instruct && \
    cd DeepSeek-Coder-V2-Lite-Instruct && \
    git lfs pull && \
    cd .. && \
    python3 llama.cpp/convert_hf_to_gguf.py --outfile DeepSeek-Coder-V2-Lite-Instruct.gguf DeepSeek-Coder-V2-Lite-Instruct && \
    rm -r DeepSeek-Coder-V2-Lite-Instruct && \
    llama.cpp/build/bin/llama-quantize DeepSeek-Coder-V2-Lite-Instruct.gguf DeepSeek-Coder-V2-Lite-Instruct-Q4_K_M.gguf Q4_K_M && \
    rm DeepSeek-Coder-V2-Lite-Instruct.gguf

RUN curl -fsSL https://ollama.com/install.sh -O && \
    bash ./install.sh

COPY Modelfile_DeepSeek-R1-Distill-Llama-8B /
RUN echo 'FROM ./DeepSeek-Coder-V2-Lite-Instruct-Q4_K_M.gguf' > Modelfile_DeepSeek-Coder-V2-Lite-Instruct

RUN echo '#!/bin/bash\nollama serve &\nsleep 5\nollama create DeepSeek-R1-Distill-Llama-8B -f Modelfile_DeepSeek-R1-Distill-Llama-8B\nollama create DeepSeek-Coder-V2-Lite-Instruct -f Modelfile_DeepSeek-Coder-V2-Lite-Instruct\n' > /launch_ollama_server.sh
RUN chmod +x /launch_ollama_server.sh
RUN /launch_ollama_server.sh
ENTRYPOINT ["ollama", "serve"]