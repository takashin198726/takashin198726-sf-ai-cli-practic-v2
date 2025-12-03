FROM node:18-alpine

LABEL maintainer="takashin"
LABEL description="Salesforce AI-driven CI/CD Development Container"

# 必須ツールインストール
RUN apk add --no-cache \
    git \
    openssh \
    openssl \
    bash \
    curl \
    jq \
    openjdk17-jre

# Salesforce CLI v2
RUN npm install --global @salesforce/cli

# Salesforce CLI自動更新無効化
ENV SF_AUTOUPDATE_DISABLE=true

# sfdx-hardis
RUN sf plugins install sfdx-hardis

# sfdx-git-delta
RUN echo "y" | sf plugins install sfdx-git-delta

# git-secrets
RUN apk add --no-cache git-secrets || \
    (git clone https://github.com/awslabs/git-secrets /tmp/git-secrets && \
     cd /tmp/git-secrets && make install && cd / && rm -rf /tmp/git-secrets)

WORKDIR /workspace

# package.jsonコピー（キャッシュ活用）
COPY package*.json ./
RUN npm ci --only=production || npm install --production

# プロジェクトファイルコピー
COPY . .

CMD ["/bin/bash"]
