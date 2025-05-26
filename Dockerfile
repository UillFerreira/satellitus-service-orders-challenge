# Usa a imagem oficial do PHP com FPM
FROM php:8.1-fpm

# Instala extensões e dependências do sistema
RUN apt-get update && apt-get install -y \
    libpq-dev \
    unzip \
    zip \
    curl \
    && docker-php-ext-install pdo pdo_pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instala o Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Define o diretório de trabalho
WORKDIR /var/www/html

# Copia os arquivos do projeto para dentro do container
COPY . .

# Dá permissões ao diretório para o usuário www-data
RUN chown -R www-data:www-data /var/www/html

# Expõe a porta do PHP-FPM
EXPOSE 9000

# Comando padrão para iniciar o PHP-FPM
CMD ["php-fpm"]

