#!/bin/bash
set -e

echo "🚀 Iniciando VilERP..."

# Función para manejar errores
handle_error() {
    echo "❌ Error en línea $1: $2"
    exit 1
}

# Configurar trap para errores
trap 'handle_error $LINENO "$BASH_COMMAND"' ERR

# 1. Debug: Verificar variables de entorno
echo "🔍 Verificando variables de entorno..."
echo "PORT: ${PORT:-'No definido'}"
echo "FRAPPE_SITE_NAME: ${FRAPPE_SITE_NAME:-'No definido'}"
echo "Variables MySQL disponibles:"
env | grep -i mysql || echo "  ❌ No hay variables MySQL"
env | grep -i redis || echo "  ❌ No hay variables Redis"

# 2. Configurar sitio (aquí SÍ están las variables de entorno)
echo "⚙️ Configurando sitio..."
python setup_production.py

# 3. Clonar repositorios VilERP si no existen
if [ ! -d "apps/frappe" ]; then
    echo "📥 Clonando repositorios VilERP..."
    mkdir -p apps
    git clone https://github.com/VilERP/frappe.git apps/frappe --branch develop --depth 1
    git clone https://github.com/VilERP/erpnext.git apps/erpnext --branch develop --depth 1
    git clone https://github.com/VilERP/payments.git apps/payments --branch develop --depth 1
fi

# 4. Instalar apps
echo "📦 Instalando apps VilERP..."
pip install -e apps/frappe
pip install -e apps/erpnext  
pip install -e apps/payments

# 5. Crear apps.txt
echo "frappe
erpnext
payments" > sites/apps.txt

# 6. Crear directorios necesarios para Frappe
echo "📁 Creando directorios necesarios..."
mkdir -p /logs /app/logs apps/logs sites/logs sites/assets public/files

# 7. Verificar que las apps se instalaron correctamente
echo "🔍 Verificando instalación de apps..."
if [ ! -f "apps/frappe/frappe/__init__.py" ]; then
    echo "❌ Error: Frappe no se instaló correctamente"
    exit 1
fi

# 8. Configurar variables de entorno
echo "🌐 Iniciando servidor Frappe..."
export PYTHONPATH="/app:/app/apps/frappe:/app/apps/erpnext:/app/apps/payments"
export FRAPPE_SITE_NAME=${FRAPPE_SITE_NAME:-vilerp}
cd /app

# 9. Iniciar servidor Frappe con manejo de errores
exec python -c "
import sys
import os
import traceback

try:
    # Agregar paths necesarios
    sys.path.insert(0, '/app/apps/frappe')
    sys.path.insert(0, '/app/apps/erpnext')
    sys.path.insert(0, '/app/apps/payments')
    
    import frappe
    from werkzeug.serving import run_simple
    
    print('🔧 Configurando Frappe...')
    site_name = os.environ.get('FRAPPE_SITE_NAME', 'vilerp')
    frappe.init(site_name, sites_path='/app/sites')
    frappe.connect()
    
    print('📦 Importando aplicación WSGI...')
    from frappe.app import application
    
    print('🌐 Iniciando servidor en puerto', os.environ.get('PORT', 8000))
    port = int(os.environ.get('PORT', 8000))
    run_simple('0.0.0.0', port, application, 
               use_reloader=False, use_debugger=False, threaded=True)
               
except Exception as e:
    print('❌ Error crítico:', str(e))
    traceback.print_exc()
    sys.exit(1)
"
