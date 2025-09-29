#!/bin/bash
set -e

echo "🚀 Iniciando VilERP..."

# 1. Configurar sitio (aquí SÍ están las variables de entorno)
echo "⚙️ Configurando sitio..."
python setup_production.py

# 2. Clonar repositorios VilERP si no existen
if [ ! -d "apps/frappe" ]; then
    echo "📥 Clonando repositorios VilERP..."
    mkdir -p apps
    git clone https://github.com/VilERP/frappe.git apps/frappe --branch develop --depth 1
    git clone https://github.com/VilERP/erpnext.git apps/erpnext --branch develop --depth 1
    git clone https://github.com/VilERP/payments.git apps/payments --branch develop --depth 1
fi

# 3. Instalar apps
echo "📦 Instalando apps VilERP..."
pip install -e apps/frappe
pip install -e apps/erpnext  
pip install -e apps/payments

# 4. Crear apps.txt
echo "frappe
erpnext
payments" > sites/apps.txt

# 5. Usar método más directo - servidor de desarrollo de Frappe
echo "🌐 Iniciando servidor Frappe (modo desarrollo para Railway)..."
cd apps/frappe
export PYTHONPATH="/app:/app/apps/frappe:/app/apps/erpnext:/app/apps/payments"
export FRAPPE_SITE_NAME=${FRAPPE_SITE_NAME:-vilerp}

# Iniciar con el servidor interno de Frappe
exec python -c "
import frappe
import os
from werkzeug.serving import run_simple

# Configurar Frappe
frappe.init('$FRAPPE_SITE_NAME', sites_path='/app/sites')
frappe.connect()

# Crear aplicación WSGI
from frappe.app import application

# Ejecutar servidor
run_simple('0.0.0.0', int(os.environ.get('PORT', 8000)), application, use_reloader=False, use_debugger=False, threaded=True)
"
