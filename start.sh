#!/bin/bash
set -e

echo "🚀 Iniciando VilERP..."

# 1. Configurar sitio (aquí SÍ están las variables de entorno)
echo "⚙️ Configurando sitio..."
python setup_production.py

# 2. Clonar repositorios si no existen
if [ ! -d "apps/frappe" ]; then
    echo "📥 Clonando repositorios VilERP..."
    mkdir -p apps
    git clone https://github.com/VilERP/frappe.git apps/frappe
    git clone https://github.com/VilERP/erpnext.git apps/erpnext  
    git clone https://github.com/VilERP/payments.git apps/payments
else
    echo "✅ Repositorios ya existen"
fi

# 3. Instalar apps
echo "📦 Instalando apps..."
pip install -e apps/frappe
pip install -e apps/erpnext
pip install -e apps/payments

# 4. Migrar base de datos
echo "🗄️ Migrando base de datos..."
cd apps/frappe
python -m frappe.utils.bench migrate --site ${FRAPPE_SITE_NAME:-vilerp}
cd ../..

# 5. Iniciar servidor
echo "🌐 Iniciando servidor Frappe..."
cd apps/frappe
exec python -m frappe.utils.bench serve --port $PORT --site ${FRAPPE_SITE_NAME:-vilerp}
