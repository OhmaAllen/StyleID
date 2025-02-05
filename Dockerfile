# 1️⃣ 选择 NVIDIA PyTorch 镜像（CUDA 11.3 兼容）
FROM nvcr.io/nvidia/pytorch:21.06-py3

# 2️⃣ 解决 Conda 冲突问题（不重复安装 Miniconda）
ENV PATH="/opt/conda/bin:$PATH"

# 3️⃣ 设置非交互模式，防止时间设置弹出
ARG DEBIAN_FRONTEND=noninteractive

# 4️⃣ 安装系统依赖项
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gdal-bin \
    libgdal-dev \
    wget \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 5️⃣ 设置工作目录
WORKDIR /workspace

# 6️⃣ 克隆 StyleID 代码
RUN git clone https://github.com/OhmaAllen/StyleID.git

# 7️⃣ 进入 StyleID 目录
WORKDIR /workspace/StyleID

# 8️⃣ 创建 Conda 环境（不重复安装 Miniconda）
RUN conda env create -f environment.yaml && \
    echo "source activate StyleID" >> ~/.bashrc

# 9️⃣ 设定默认 shell 为 bash
SHELL ["/bin/bash", "-c"]

# 🔟 创建入口脚本
RUN echo '#!/bin/bash\n\
source activate StyleID\n\
ln -s /mnt/sd-v1-4.ckpt /workspace/StyleID/models/ldm/stable-diffusion-v1/model.ckpt\n\
cd /workspace/StyleID\n\
python run_styleid.py --cnt data/cnt --sty data/sty --gamma 0.75 --T 1.5' > /workspace/start.sh && chmod +x /workspace/start.sh

# 设定默认执行的命令
ENTRYPOINT ["/bin/bash", "/workspace/start.sh"]


