# Secrets Management

This directory contains Docker secrets for the Student Management System.

## Required Secrets

### Development (auto-created by scripts)
- `api_username.txt` - API authentication username
- `api_password.txt` - API authentication password  
- `postgres_password.txt` - Database password

### Production (must be created manually)
Create these files with your production secrets:

```bash
echo "your_production_username" > api_username.txt
echo "your_production_password" > api_password.txt
echo "your_production_db_password" > postgres_password.txt
```

## Security Notes

- Never commit these files to version control
- Use strong, unique passwords for production
- Rotate secrets regularly
- Consider using external secret management systems for production

## File Permissions

Ensure proper file permissions:
```bash
chmod 600 *.txt
```
