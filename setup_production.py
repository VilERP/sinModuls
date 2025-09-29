#!/usr/bin/env python3
"""
Script de configuración para producción - Frappe/ERPNext VilERP
Genera site_config.json desde variables de entorno para deploy en cloud
"""

import os
import json
import secrets
import sys

def generate_encryption_key():
    """Generar clave de encriptación segura"""
    return secrets.token_urlsafe(32)

def create_site_config():
    """Crear site_config.json desde variables de entorno"""
    
    print("🚀 Configurando sitio VilERP para producción...")
    
    # Obtener variables de entorno (Railway/Render las proporciona automáticamente)
    db_host = os.environ.get("FRAPPE_DB_HOST") or os.environ.get("MYSQL_HOST") or os.environ.get("DATABASE_HOST")
    db_port = os.environ.get("FRAPPE_DB_PORT") or os.environ.get("MYSQL_PORT") or os.environ.get("DATABASE_PORT", "3306")
    db_name = os.environ.get("FRAPPE_DB_NAME") or os.environ.get("MYSQL_DATABASE") or os.environ.get("DATABASE_NAME")
    db_user = os.environ.get("FRAPPE_DB_USER") or os.environ.get("MYSQL_USER") or os.environ.get("DATABASE_USER")
    db_password = os.environ.get("FRAPPE_DB_PASSWORD") or os.environ.get("MYSQL_PASSWORD") or os.environ.get("DATABASE_PASSWORD")
    
    # Redis URLs (Railway/Render proporcionan automáticamente)
    redis_cache = os.environ.get("FRAPPE_REDIS_CACHE") or os.environ.get("REDIS_URL") or "redis://localhost:6379"
    redis_queue = os.environ.get("FRAPPE_REDIS_QUEUE") or os.environ.get("REDIS_URL") or "redis://localhost:6379"
    redis_socketio = os.environ.get("FRAPPE_REDIS_SOCKETIO") or os.environ.get("REDIS_URL") or "redis://localhost:6379"
    
    # Validar variables críticas
    if not all([db_host, db_name, db_user, db_password]):
        print("❌ Error: Variables de base de datos no configuradas")
        print("Requeridas: DB_HOST, DB_NAME, DB_USER, DB_PASSWORD")
        print("Railway/Render deberían proporcionar estas automáticamente")
        sys.exit(1)
    
    # Configuración del sitio
    config = {
        "db_type": "mysql",
        "db_host": db_host,
        "db_port": int(db_port),
        "db_name": db_name,
        "db_user": db_user,
        "db_password": db_password,
        "redis_cache": redis_cache,
        "redis_queue": redis_queue,
        "redis_socketio": redis_socketio,
        "developer_mode": int(os.environ.get("DEVELOPER_MODE", "0")),
        "server_script_enabled": True,
        "encryption_key": os.environ.get("ENCRYPTION_KEY") or generate_encryption_key(),
        
        # Configuración de email (opcional)
        "mail_server": os.environ.get("MAIL_SERVER"),
        "mail_port": int(os.environ.get("MAIL_PORT", "587")) if os.environ.get("MAIL_PORT") else None,
        "use_ssl": int(os.environ.get("MAIL_USE_SSL", "0")) if os.environ.get("MAIL_USE_SSL") else 0,
        "mail_login": os.environ.get("MAIL_LOGIN"),
        "mail_password": os.environ.get("MAIL_PASSWORD"),
        "auto_email_id": os.environ.get("AUTO_EMAIL_ID"),
        
        # Configuración de producción
        "always_use_account_email_id_as_sender": int(os.environ.get("ALWAYS_USE_ACCOUNT_EMAIL", "0")),
        "hide_footer": int(os.environ.get("HIDE_FOOTER", "1")),
        "disable_website_cache": int(os.environ.get("DISABLE_WEBSITE_CACHE", "1")),
        
        # Configuración VilERP específica
        "app_name": "VilERP",
        "app_title": "VilERP - Enterprise Resource Planning"
    }
    
    # Limpiar valores None
    config = {k: v for k, v in config.items() if v is not None}
    
    # Crear directorio sites si no existe (estructura bench)
    site_name = os.environ.get("FRAPPE_SITE_NAME", "vilerp")
    sites_dir = f"frappe-bench/sites/{site_name}"
    os.makedirs(sites_dir, exist_ok=True)
    
    # Escribir configuración
    config_path = f"{sites_dir}/site_config.json"
    with open(config_path, "w") as f:
        json.dump(config, f, indent=2)
    
    print(f"✅ site_config.json creado en {config_path}")
    print(f"📊 Base de datos: {db_user}@{db_host}:{db_port}/{db_name}")
    print(f"📊 Redis: {redis_cache}")
    print(f"📊 Modo desarrollador: {'Activado' if config['developer_mode'] else 'Desactivado'}")
    print(f"🏢 Sitio: {site_name}")
    
    return config_path

def create_common_site_config():
    """Crear common_site_config.json para producción"""
    
    config = {
        "background_workers": int(os.environ.get("BACKGROUND_WORKERS", "1")),
        "default_site": os.environ.get("FRAPPE_SITE_NAME", "vilerp"),
        "serve_default_site": True,
        "server_script_enabled": True,
        "developer_mode": int(os.environ.get("DEVELOPER_MODE", "0")),
        "maintenance_mode": int(os.environ.get("MAINTENANCE_MODE", "0")),
        "pause_scheduler": int(os.environ.get("PAUSE_SCHEDULER", "0")),
        "webserver_port": int(os.environ.get("PORT", "8000")),
        "socketio_port": int(os.environ.get("SOCKETIO_PORT", "9000")),
        "gunicorn_workers": int(os.environ.get("GUNICORN_WORKERS", "4")),
        "auto_migrate": int(os.environ.get("AUTO_MIGRATE", "1")),
        "restart_supervisor_on_update": False,
        "restart_systemd_on_update": False,
        
        # VilERP branding
        "app_name": "VilERP",
        "app_title": "VilERP - Enterprise Resource Planning"
    }
    
    os.makedirs("frappe-bench/sites", exist_ok=True)
    
    with open("frappe-bench/sites/common_site_config.json", "w") as f:
        json.dump(config, f, indent=2)
    
    print("✅ common_site_config.json creado")

def setup_apps_txt():
    """Crear apps.txt con las aplicaciones VilERP a instalar"""
    
    # Apps en orden de instalación
    apps = [
        "frappe",    # Framework base (tu fork)
        "payments",  # App de pagos (tu fork)  
        "erpnext"    # ERP con tus personalizaciones
    ]
    
    os.makedirs("frappe-bench/sites", exist_ok=True)
    
    with open("frappe-bench/sites/apps.txt", "w") as f:
        for app in apps:
            f.write(f"{app}\n")
    
    print("✅ apps.txt creado con apps VilERP")

def main():
    """Función principal"""
    print("=" * 60)
    print("🚀 SETUP PRODUCCIÓN VilERP - FRAPPE/ERPNEXT")
    print("=" * 60)
    print("📦 Usando repositorios VilERP:")
    print("   - https://github.com/VilERP/frappe")
    print("   - https://github.com/VilERP/erpnext") 
    print("   - https://github.com/VilERP/payments")
    print("=" * 60)
    
    try:
        # Crear configuraciones
        create_common_site_config()
        setup_apps_txt()
        config_path = create_site_config()
        
        print("\n" + "=" * 60)
        print("✅ CONFIGURACIÓN VilERP COMPLETADA")
        print("=" * 60)
        print(f"📁 Archivos creados:")
        print(f"   - sites/common_site_config.json")
        print(f"   - sites/apps.txt")
        print(f"   - {config_path}")
        print("\n🎯 Próximos pasos:")
        print("   1. bench migrate")
        print("   2. bench serve --port $PORT")
        print("\n🏢 VilERP - Enterprise Resource Planning")
        
    except Exception as e:
        print(f"❌ Error durante la configuración VilERP: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main()
