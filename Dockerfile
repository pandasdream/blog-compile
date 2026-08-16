# 阶段1：构建
FROM crpi-k220k92a7i8r9d24.cn-beijing.personal.cr.aliyuncs.com/oomm/node:26.7.0 AS build
USER root
WORKDIR /app

# 先复制依赖清单，利用 Docker 层缓存
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/releases ./.yarn/releases
RUN node .yarn/releases/yarn-3.6.1.cjs install

# 复制源码并构建
COPY . .
RUN node .yarn/releases/yarn-3.6.1.cjs build

# 阶段2：运行（standalone）
FROM crpi-k220k92a7i8r9d24.cn-beijing.personal.cr.aliyuncs.com/oomm/node:26.7.0
USER root
WORKDIR /app
ENV NODE_ENV=production \
    PORT=3000 \
    HOSTNAME=0.0.0.0

COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static
COPY --from=build /app/public ./public

EXPOSE 3000
CMD ["node", "server.js"]
