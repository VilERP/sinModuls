# VilERP Deploy - Configuración para Producción

Este repositorio contiene la configuración necesaria para desplegar **VilERP** (Frappe/ERPNext personalizado) en plataformas cloud como Railway, Render, o DigitalOcean.

## 🏢 VilERP - Enterprise Resource Planning

**VilERP** es una versión personalizada de ERPNext que incluye:
- ✅ **Laboratory Quality Control** - Sistema completo de control de calidad
- ✅ **Personalizaciones específicas** para tu negocio
- ✅ **Módulos adaptados** según tus necesidades

## 📁 Estructura del Proyecto

```
vilerp-deploy/
├── apps/                    # Submódulos de VilERP
│   ├── frappe/             # Framework base (VilERP fork)
│   ├── erpnext/            # ERP con personalizaciones (VilERP fork)
│   └── payments/           # App de pagos (VilERP fork)
├── setup_production.py     # Script de configuración automática
├── railway.json           # Configuración para Railway
├── Procfile               # Configuración de procesos
├── requirements.txt       # Dependencias Python
├── .gitmodules           # Configuración de submódulos
├── .gitignore            # Archivos a ignorar
└── README.md             # Esta documentación
```

## 🚀 Deploy en Railway

### 1. Preparar el Repositorio

```bash
# Crear nuevo repositorio
mkdir vilerp-deploy
cd vilerp-deploy
git init

# Copiar archivos de configuración
cp /ruta/a/setup_production.py .
cp /ruta/a/railway.json .
cp /ruta/a/requirements.txt .
cp /ruta/a/Procfile .
cp /ruta/a/.gitignore .

# Agregar submódulos VilERP
git submodule add https://github.com/VilERP/frappe.git apps/frappe
git submodule add https://github.com/VilERP/erpnext.git apps/erpnext
git submodule add https://github.com/VilERP/payments.git apps/payments

# Configurar ramas
cd apps/frappe && git checkout develop && cd ../..
cd apps/erpnext && git checkout develop && cd ../..
cd apps/payments && git checkout develop && cd ../..

# Commit inicial
git add .
git commit -m "Initial VilERP deploy configuration"
git push origin main
```

### 2. Configurar Railway

1. **Crear cuenta en Railway**: https://railway.app
2. **New Project** → **Deploy from GitHub repo**
3. **Seleccionar** tu repositorio `vilerp-deploy`
4. **Add Database** → **MySQL**
5. **Add Database** → **Redis**

### 3. Variables de Entorno (Automáticas)

Railway configura automáticamente:
- `MYSQL_HOST`, `MYSQL_PORT`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`
- `REDIS_URL`

Variables adicionales configuradas:
- `FRAPPE_SITE_NAME=vilerp`
- `DEVELOPER_MODE=0`
- `AUTO_MIGRATE=1`
- `APP_NAME=VilERP`

## 🎯 Personalizaciones VilERP Incluidas

### Laboratory Quality Control System
- **DocType Principal**: `Laboratory Quality Control`
- **Child Table**: `Laboratory Process Detail`
- **Módulo**: Quality Management
- **Funcionalidades**:
  - ✅ Control de calidad de laboratorio completo
  - ✅ Procesos granulares de testing
  - ✅ Integración con Sales Order, Work Order
  - ✅ Workflow de aprobación multi-nivel
  - ✅ Reportes de calidad personalizados

### Otros Módulos Personalizados
- 🔄 **Adaptaciones contables** específicas
- 🔄 **Reportes personalizados** 
- 🔄 **Workflows específicos** del negocio
- 🔄 **Integraciones personalizadas**

## 🔄 Actualización desde Repos Oficiales

### Configurar Upstream en tus Forks

```bash
# En cada fork VilERP, agregar upstream oficial:

# En VilERP/frappe
cd apps/frappe
git remote add upstream https://github.com/frappe/frappe.git

# En VilERP/erpnext
cd apps/erpnext  
git remote add upstream https://github.com/frappe/erpnext.git

# En VilERP/payments
cd apps/payments
git remote add upstream https://github.com/frappe/payments.git
```

### Actualizar desde Oficiales

```bash
# Actualizar Frappe oficial → tu fork
cd apps/frappe
git fetch upstream
git merge upstream/version-15
git push origin develop

# Actualizar ERPNext oficial → tu fork (cuidado con conflictos)
cd apps/erpnext
git fetch upstream
git merge upstream/version-15  # Resolver conflictos con tus personalizaciones
git push origin develop

# Actualizar Payments oficial → tu fork
cd apps/payments
git fetch upstream
git merge upstream/version-15
git push origin develop
```

### Actualizar Deploy

```bash
# En tu repo de deploy
git submodule update --remote
git add apps/
git commit -m "Update VilERP modules from upstream"
git push origin main
# Railway redespliega automáticamente
```

## 🛠️ Desarrollo Local

### Agregar Nueva Personalización

1. **Desarrollar en tu fork local**:
```bash
cd apps/erpnext
# ... hacer cambios en Laboratory Quality Control ...
git add .
git commit -m "feat: Mejoras en Laboratory Quality Control"
git push origin develop
```

2. **Actualizar en deploy**:
```bash
cd vilerp-deploy
git submodule update --remote apps/erpnext
git add apps/erpnext
git commit -m "Update erpnext with new Laboratory features"
git push origin main
```

## 🔍 Troubleshooting

### Error de Submódulos
```bash
# Inicializar submódulos
git submodule update --init --recursive

# Actualizar todos los submódulos
git submodule update --remote
```

### Error de Base de Datos
```bash
# Verificar variables Railway
echo $MYSQL_HOST
echo $MYSQL_DATABASE

# Re-ejecutar setup
python setup_production.py
```

### Error de Migración
```bash
# Migración manual
bench migrate --site vilerp

# Verificar apps instaladas
bench list-apps
```

## 🎯 Flujo de Trabajo Recomendado

### Desarrollo Diario
1. **Desarrollar** en forks VilERP localmente
2. **Push** cambios a GitHub VilERP forks
3. **Actualizar** submódulos en repo deploy
4. **Railway** redespliega automáticamente

### Actualizaciones Mensuales
1. **Fetch** cambios oficiales de Frappe
2. **Merge** en tus forks VilERP (resolver conflictos)
3. **Test** localmente
4. **Deploy** a producción

## 📞 Soporte VilERP

- **Issues**: Crear issue en repositorio deploy
- **Documentación**: Frappe Framework + ERPNext + personalizaciones VilERP
- **Updates**: Seguir repos oficiales + desarrollos VilERP

## 📄 Licencia

- **Frappe Framework**: MIT License
- **ERPNext**: GNU General Public License v3.0
- **Payments**: MIT License
- **VilERP Personalizaciones**: [Tu licencia]

---

**VilERP - Enterprise Resource Planning**  
*Powered by Frappe Framework & ERPNext*
