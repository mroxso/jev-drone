FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    MUJOCO_GL=egl

# git + ca-certificates: fetch the Skydio X2 model
# libegl/libgl/mesa: headless OpenGL (MUJOCO_GL=egl)
# libgomp: mujoco runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        libegl1 \
        libegl-mesa0 \
        libgl1 \
        libgles2 \
        libgomp1 \
        libosmesa6 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

# Same as setup.sh: fetch the Skydio X2 model and wire up the asset path.
RUN git clone --depth 1 --filter=blob:none --sparse \
        https://github.com/google-deepmind/mujoco_menagerie.git \
    && cd mujoco_menagerie \
    && git sparse-checkout set skydio_x2

RUN ln -sfn mujoco_menagerie/skydio_x2/assets assets

CMD ["python", "run.py", "--seconds", "65", "--seeds", "1"]
