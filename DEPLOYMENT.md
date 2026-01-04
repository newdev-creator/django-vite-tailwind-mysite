# Django + Vite + Tailwind Deployment on Coolify

## Overview

This guide will help you deploy your Django application with Vite and Tailwind CSS on Coolify.

## Prerequisites

1. A Coolify account and access to a Coolify instance
2. A domain name pointing to your Coolify instance
3. Basic knowledge of Docker and Django

## Deployment Steps

### 1. Prepare Your Project

Before deploying, make sure you have:

1. **Updated all configuration files:**
   - `.env.production` - Contains production environment variables
   - `Dockerfile` - Container configuration
   - `docker-compose.yml` - Multi-container setup
   - `coolify.yml` - Coolify-specific configuration

2. **Generated a secure Django secret key:**
   ```bash
   python -c "import secrets; print(secrets.token_urlsafe(50))")
   ```

3. **Updated allowed hosts and trusted origins:**
   - Replace `your-domain.com` with your actual domain in `.env.production` and `coolify.yml`

### 2. Coolify Setup

#### Step 1: Create a New Project in Coolify

1. Log in to your Coolify dashboard
2. Click "New Project" and give it a name
3. Select "Docker Compose" as the deployment method

#### Step 2: Configure the Deployment

1. **Repository Setup:**
   - Connect your Git repository (GitHub, GitLab, etc.)
   - Select the branch you want to deploy (usually `main` or `production`)

2. **Environment Variables:**
   - Go to the "Secrets" section
   - Add the following secrets based on the `coolify.yml` file:
     - `DJANGO_SECRET_KEY` - Your secure Django secret key
     - `POSTGRES_DB` - Database name (default: `django_db`)
     - `POSTGRES_USER` - Database username (default: `django_user`)
     - `POSTGRES_PASSWORD` - Secure database password
     - `ALLOWED_HOSTS` - Your domain name (e.g., `your-domain.com,localhost`)
     - `CSRF_TRUSTED_ORIGINS` - Trusted origins (e.g., `https://your-domain.com`)

3. **Build Configuration:**
   - Set the build context to `/`
   - Use the provided `Dockerfile`
   - Set the build command to: `docker-compose -f docker-compose.yml up -d --build`

### 3. Database Migration and Static Files

Coolify will automatically run the following commands during deployment:

1. **Database Migration:**
   ```bash
   docker-compose -f docker-compose.yml exec web python manage.py migrate
   ```

2. **Collect Static Files:**
   ```bash
   docker-compose -f docker-compose.yml exec web python manage.py collectstatic --noinput
   ```

### 4. Domain and SSL Configuration

1. **Domain Setup:**
   - In Coolify, go to your project settings
   - Add your domain name
   - Configure DNS records to point to your Coolify instance

2. **SSL Certificate:**
   - Coolify will automatically provision SSL certificates using Let's Encrypt
   - Make sure your domain is properly configured before deployment

### 5. Deployment Process

1. **Trigger Deployment:**
   - Click "Deploy" in the Coolify dashboard
   - Monitor the build logs for any errors

2. **Post-Deployment Checks:**
   - Verify the application is running: `https://your-domain.com`
   - Check database connectivity
   - Verify static files are served correctly
   - Test Vite assets are loading properly

### 6. Monitoring and Maintenance

1. **Logs:**
   - Monitor application logs in the Coolify dashboard
   - Check for any errors or warnings

2. **Updates:**
   - When you push changes to your repository, Coolify can automatically redeploy
   - Configure auto-deployment in project settings if desired

3. **Backups:**
   - Regularly backup your PostgreSQL database
   - Consider setting up automated backups in Coolify

## Troubleshooting

### Common Issues

1. **Database Connection Errors:**
   - Verify PostgreSQL credentials in secrets
   - Check that the database service is running
   - Ensure the database name, user, and password match

2. **Static Files Not Loading:**
   - Verify `DEBUG=False` in production
   - Check that `collectstatic` ran successfully
   - Ensure WhiteNoise is properly configured

3. **Vite Assets Not Loading:**
   - Verify `DJANGO_VITE_DEV_MODE=False`
   - Check that Vite build completed successfully
   - Ensure the manifest file is generated

4. **SSL/HTTPS Issues:**
   - Verify domain DNS is properly configured
   - Check that Coolify SSL provisioning completed
   - Ensure all URLs use `https://` in production

## Security Best Practices

1. **Keep Secrets Secure:**
   - Never commit `.env` files to version control
   - Use Coolify secrets management for sensitive data
   - Rotate secrets regularly

2. **Database Security:**
   - Use strong PostgreSQL passwords
   - Consider using Coolify's managed database services
   - Regularly backup your database

3. **Application Security:**
   - Keep Django and all dependencies updated
   - Regularly apply security patches
   - Monitor for vulnerabilities

## Coolify-Specific Notes

- Coolify handles automatic SSL certificate provisioning and renewal
- The platform provides built-in monitoring and logging
- You can configure auto-scaling and resource limits in the Coolify dashboard
- Coolify supports zero-downtime deployments with proper configuration

## Additional Resources

- [Coolify Documentation](https://coolify.io/docs)
- [Django Deployment Checklist](https://docs.djangoproject.com/en/stable/howto/deployment/checklist/)
- [WhiteNoise Documentation](http://whitenoise.evans.io/en/stable/)
- [Django Vite Documentation](https://github.com/MrBin99/django-vite)