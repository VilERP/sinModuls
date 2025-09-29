#!/bin/bash
set -e

echo "🚀 Iniciando VilERP..."

# 1. Clonar repositorios si no existen
if [ ! -d "apps/frappe" ]; then
    echo "📥 Clonando repositorios VilERP..."
    git clone https://github.com/VilERP/frappe.git apps/frappe
    git clone https://github.com/VilERP/erpnext.git apps/erpnext  
    git clone https://github.com/VilERP/payments.git apps/payments
else
    echo "✅ Repositorios ya existen"
fi

# 2. Instalar apps
echo "📦 Instalando apps..."
pip install -e apps/frappe
pip install -e apps/erpnext
pip install -e apps/payments

# 3. Configurar sitio (aquí SÍ están las variables de entorno)
echo "⚙️ Configurando sitio..."
python setup_production.py

# 4. Migrar base de datos
echo "🗄️ Migrando base de datos..."
bench migrate

# 5. Iniciar servidor
echo "🌐 Iniciando servidor Frappe..."
exec bench serve --port $PORT --noreload --nothreading
