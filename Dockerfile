ARG VERSION

FROM --platform=linux/amd64 hengyunabc/arthas:latest AS arthas

# 如果这里不重复定义参数，后面会取不到参数的值
ARG VERSION

# 基础镜像
FROM --platform=${TARGETPLATFORM} openjdk:${VERSION}

# 如果这里不重复定义参数，后面会取不到参数的值
ARG VERSION
ARG HTTP_PROXY
ARG HTTPS_PROXY

# 作者及邮箱
# 镜像的作者和邮箱
LABEL maintainer="nnzbz@163.com"
# 镜像的版本
LABEL version=${VERSION}
# 镜像的描述
LABEL description="集成了Open JDK的操作系统"

# copy arthas(从另一个镜像中复制，小技巧)
COPY --from=arthas /opt/arthas /usr/local/arthas

ENV http_proxy=${HTTP_PROXY}
ENV https_proxy=${HTTPS_PROXY}

COPY ./run.sh /bin/
RUN chmod +x /bin/run.sh && /bin/run.sh && unset http_proxy && unset https_proxy