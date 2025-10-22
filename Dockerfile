# Dockerfile
FROM dunglas/frankenphp:latest-php8.3

WORKDIR /app

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 依存関係
COPY composer.json composer.lock symfony.lock ./
RUN composer install --no-dev --optimize-autoloader

# アプリケーション
COPY . .

# キャッシュウォームアップ
RUN APP_ENV=prod composer dump-autoload --optimize && \
    php bin/console cache:clear && \
    php bin/console cache:warmup

# Caddyfile を明示的に作成
RUN echo ':${PORT:-8000} {\n\
    root * /app/public\n\
    encode gzip\n\
    php_server\n\
}' > /etc/caddy/Caddyfile

EXPOSE 8000

CMD ["frankenphp", "run", "--config", "/etc/caddy/Caddyfile"]