# =============================================================================
# Playerbot 分支私服镜像 Dockerfile
# -----------------------------------------------------------------------------
# 派生自 AzerothCore 官方 apps/docker/Dockerfile (GNU AGPL v3 / GPL 许可证,
# 源码见 https://github.com/azerothcore/azerothcore-wotlk/tree/master/apps/docker),
# 本文件在此基础上做了如下适配套件化改动:
#   1. 编译阶段与官方一致 (ubuntu:24.04 + clang + ccache + MySQL 8 客户端库)
#   2. 模块集固定为 6 个 vendor 模块 (modules/ 下整目录 COPY, CMake 自动发现):
#        mod-playerbots / mod-ale / mod-ah-bot / mod-transmog /
#        mod-random-enchants / mod-boss-announcer
#      -DSCRIPTS=static -DMODULES=static, 全部静态链入 worldserver
#   3. runtime 注入套件私有配置种子 (custom/conf-seed -> ref/etc, no-clobber)
#   4. 注入套件私有 lua 脚本 (custom/lua_scripts -> /azerothcore/lua_scripts,
#      供 mod-ale 的 ALE.ScriptPath 使用)
#   5. 保留 db-import 目标 (全新安装路径; 迁移路径不需要)
#
# 说明: worldserver/authserver 不强制 AC_UPDATES_ENABLE_DATABASES=0,
#       迁移路径依赖世界服务器启动时自动追平上游数据库补丁
#       (Updates.EnableDatabases=7 / AutoSetup=1)
# =============================================================================
ARG UBUNTU_VERSION=24.04 # lts

FROM ubuntu:$UBUNTU_VERSION AS skeleton

ARG TZ=Etc/UTC
ARG DOCKER=1
ARG DEBIAN_FRONTEND=noninteractive

ENV AC_FORCE_CREATE_DB=1

RUN mkdir -pv \
        /azerothcore/bin                   \
        /azerothcore/data                  \
        /azerothcore/deps                  \
        /azerothcore/env/dist/bin          \
        /azerothcore/env/dist/data/Cameras \
        /azerothcore/env/dist/data/dbc     \
        /azerothcore/env/dist/data/maps    \
        /azerothcore/env/dist/data/mmaps   \
        /azerothcore/env/dist/data/vmaps   \
        /azerothcore/env/dist/logs         \
        /azerothcore/env/dist/temp         \
        /azerothcore/env/dist/etc          \
        /azerothcore/modules               \
        /azerothcore/src                   \
        /azerothcore/build

RUN apt-get update                                                       \
    && apt-get install -y --no-install-recommends tzdata ca-certificates \
    && ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime                  \
    && echo "$TZ" > /etc/timezone                                          \
    && dpkg-reconfigure --frontend noninteractive tzdata                 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /azerothcore

FROM skeleton AS build

ARG CTOOLS_BUILD="all"
ARG CTYPE="RelWithDebInfo"
ARG CCACHE_CPP2="true"
ARG CSCRIPTPCH="OFF"
ARG CSCRIPTS="static"
ARG CMODULES="static"
ARG CSCRIPTS_DEFAULT_LINKAGE="static"
ARG CWITH_WARNINGS="ON"
ARG CMAKE_EXTRA_OPTIONS=""
ARG GIT_DISCOVERY_ACROSS_FILESYSTEM=1

ARG CCACHE_DIR="/ccache"
ARG CCACHE_MAXSIZE="1000MB"
ARG CCACHE_SLOPPINESS="pch_defines,time_macros,include_file_mtime"
ARG CCACHE_COMPRESS=""
ARG CCACHE_COMPRESSLEVEL="9"
ARG CCACHE_COMPILERCHECK="content"
ARG CCACHE_LOGFILE=""

RUN apt-get update                                                     \
    && apt-get install -y --no-install-recommends                         \
        build-essential ccache libtool cmake-data ninja-build cmake clang    \
        git lsb-base curl unzip default-mysql-client openssl                  \
        default-libmysqlclient-dev libboost-all-dev libssl-dev libmysql++-dev \
        libreadline-dev zlib1g-dev libbz2-dev libncurses5-dev liblzma-dev  \
    && rm -rf /var/lib/apt/lists/*

# 复制核心与全部 6 个 vendor 模块 (CMake 通过 modules/ 下是否存在 src/ 自动发现)
COPY CMakeLists.txt /azerothcore/CMakeLists.txt
COPY conf /azerothcore/conf
COPY deps /azerothcore/deps
COPY src /azerothcore/src
COPY modules /azerothcore/modules

ARG CACHEBUST=1

WORKDIR /azerothcore/build

RUN --mount=type=cache,target=/ccache,sharing=locked \
    --mount=type=bind,target=/azerothcore/.git,source=.git \
    git config --global --add safe.directory /azerothcore \
    && cmake /azerothcore \
       -G Ninja \
       -DCMAKE_INSTALL_PREFIX="/azerothcore/env/dist"  \
       -DAPPS_BUILD="all"                              \
       -DTOOLS_BUILD="$CTOOLS_BUILD"                   \
       -DSCRIPTS="$CSCRIPTS"                           \
       -DMODULES="$CMODULES"                           \
       -DWITH_WARNINGS="$CWITH_WARNINGS"               \
       -DCMAKE_BUILD_TYPE="$CTYPE"                     \
       -DCMAKE_CXX_COMPILER="clang++"                  \
       -DCMAKE_C_COMPILER="clang"                      \
       -DCMAKE_CXX_COMPILER_LAUNCHER="ccache"          \
       -DCMAKE_C_COMPILER_LAUNCHER="ccache"            \
       -DBoost_USE_STATIC_LIBS="ON"                    \
    && cmake --build . --config "$CTYPE" -j $(($(nproc) + 1)) \
    && cmake --install . --config "$CTYPE"

#############################
# Base runtime for services #
#############################

FROM skeleton AS runtime

ARG USER_ID=1000
ARG GROUP_ID=1000
ARG DOCKER_USER=acore

ENV ACORE_COMPONENT=undefined

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
      libmysqlclient21 libreadline8 libicu74 libncurses5-dev \
      gettext-base default-mysql-client \
      adduser \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /azerothcore/env/dist/etc/ /azerothcore/env/ref/etc

# 套件私有配置种子: 覆盖/补充到 ref/etc (entrypoint 首次启动时以 no-clobber 拷入卷)
# 注意: 本仓库 custom/conf-seed/ 当前仅含 .gitkeep 占位, 后续追加 *.conf.dist
#       种子文件时无需改动本 Dockerfile (cp -rn 自动合并)
COPY custom/conf-seed/ /azerothcore/custom/conf-seed/
RUN cp -rn /azerothcore/custom/conf-seed/* /azerothcore/env/ref/etc/

# 套件私有 lua 脚本 (mod-ale ALE.ScriptPath=lua_scripts, 相对 CWD=/azerothcore)
COPY custom/lua_scripts/ /azerothcore/lua_scripts/

VOLUME /azerothcore/env/dist/etc

ENV PATH="/azerothcore/env/dist/bin:$PATH"

RUN userdel --remove ubuntu \
  && addgroup --gid "$GROUP_ID" "$DOCKER_USER" \
  && adduser --disabled-password --gecos '' --uid "$USER_ID" --gid "$GROUP_ID" "$DOCKER_USER" \
  && passwd -d "$DOCKER_USER" \
  && chown -R "$DOCKER_USER:$DOCKER_USER" /azerothcore

COPY --chown=$USER_ID:$GROUP_ID \
     --chmod=755 \
     apps/docker/entrypoint.sh /azerothcore/entrypoint.sh

USER $DOCKER_USER

ENTRYPOINT ["/usr/bin/env", "bash", "/azerothcore/entrypoint.sh"]

###############
# Auth Server #
###############

FROM runtime AS authserver
LABEL description="Playerbot 分支 AzerothCore Auth Server (mysql:8.4, 6 模块)"

ENV ACORE_COMPONENT=authserver
ENV AC_DISABLE_INTERACTIVE=1

COPY --chown=$DOCKER_USER:$DOCKER_USER \
     --from=build \
     /azerothcore/env/dist/bin/authserver /azerothcore/env/dist/bin/authserver

CMD ["authserver"]

################
# World Server #
################

FROM runtime AS worldserver

LABEL description="Playerbot 分支 AzerothCore World Server (mysql:8.4, 6 模块)"

ENV ACORE_COMPONENT=worldserver
ENV AC_DISABLE_INTERACTIVE=1

COPY --chown=$DOCKER_USER:$DOCKER_USER \
     --from=build \
     /azerothcore/env/dist/bin/worldserver /azerothcore/env/dist/bin/worldserver

CMD ["worldserver"]

#############
# DB Import #
#############

FROM runtime AS db-import

LABEL description="AzerothCore Database Import tool (全新安装路径, 6 模块)"

USER $DOCKER_USER

ENV ACORE_COMPONENT=dbimport

COPY --chown=$DOCKER_USER:$DOCKER_USER \
    data data

COPY --chown=$DOCKER_USER:$DOCKER_USER \
    modules modules

COPY --chown=$DOCKER_USER:$DOCKER_USER \
    --from=build \
    /azerothcore/env/dist/bin/dbimport /azerothcore/env/dist/bin/dbimport

CMD [ "/azerothcore/env/dist/bin/dbimport" ]
