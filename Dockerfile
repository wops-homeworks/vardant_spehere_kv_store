# Use an official PHP image as the base image
FROM php:8.3-fpm

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip

# Install PHP extensions
RUN docker-php-ext-install gd pdo pdo_mysql sockets

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Add user with specific UID, home directory, and group memberships
ARG user=dockeruser
ARG uid=1000
RUN useradd -G www-data,root -u $uid -d /home/$user -m -s /bin/bash $user

# Change current user to dockeruser
USER dockeruser

# Copy necessary files and set ownership
COPY --chown=dockeruser:dockeruser ./package.json /app
COPY --chown=dockeruser:dockeruser ./.env.ci /app/.env

# Copy the rest of the application directory contents
COPY --chown=dockeruser:dockeruser . /app

# Start php-fpm server
ENTRYPOINT ["php"]
CMD ["artisan","key:generate"]
