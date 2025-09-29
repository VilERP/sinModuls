#!/bin/bash
set -e

echo "🚀 Iniciando VilERP..."

# 1. Instalar bench CLI
echo "📦 Instalando Bench CLI..."
pip install frappe-bench

# 2. Crear estructura bench si no existe
if [ ! -d "frappe-bench" ]; then
    echo "🏗️ Inicializando Bench..."
    bench init frappe-bench --frappe-path https://github.com/VilERP/frappe.git --frappe-branch develop
    cd frappe-bench
    
    # 3. Instalar apps adicionales
    echo "📥 Instalando ERPNext y Payments..."
    bench get-app erpnext https://github.com/VilERP/erpnext.git --branch develop
    bench get-app payments https://github.com/VilERP/payments.git --branch develop
else
    echo "✅ Bench ya existe, entrando al directorio..."
    cd frappe-bench
fi

# 4. Configurar sitio (aquí SÍ están las variables de entorno)
echo "⚙️ Configurando sitio..."
python ../setup_production.py

# 5. Crear sitio si no existe
SITE_NAME=${FRAPPE_SITE_NAME:-vilerp}
if [ ! -d "sites/$SITE_NAME" ]; then
    echo "🏗️ Creando sitio $SITE_NAME..."
    bench new-site $SITE_NAME --admin-password admin --mariadb-root-password ${MYSQL_PASSWORD}
    
    # Instalar apps en el sitio
    bench --site $SITE_NAME install-app erpnext
    bench --site $SITE_NAME install-app payments
else
    echo "✅ Sitio $SITE_NAME ya existe"
fi

# 6. Migrar base de datos
echo "🗄️ Migrando base de datos..."
bench --site $SITE_NAME migrate

# 7. Iniciar servidor
echo "🌐 Iniciando servidor Frappe..."
exec bench serve --port $PORT
