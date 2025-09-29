# Procfile para VilERP - Railway/Heroku deployment
# Frappe/ERPNext Multi-Process Configuration

# Web Server - Sirve la aplicacion VilERP principal
web: bash start.sh

# Background Worker - Procesa trabajos en segundo plano
worker: bench worker --queue default,short,long

# Scheduler - Ejecuta tareas programadas (cron jobs)
scheduler: bench schedule

# Socket.IO - Para funcionalidades en tiempo real
socketio: node apps/frappe/socketio.js