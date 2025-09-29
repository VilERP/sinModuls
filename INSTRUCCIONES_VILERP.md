# 🏢 INSTRUCCIONES DEPLOY VilERP

## 📋 Resumen de Configuración

**Has creado archivos para submódulos con TUS forks VilERP:**
- ✅ **VilERP/frappe** → Tu fork del framework
- ✅ **VilERP/erpnext** → Tu fork con Laboratory Quality Control
- ✅ **VilERP/payments** → Tu fork de pagos

## 🔄 Cómo Funcionan las Actualizaciones

### **Configuración de Upstream (EN TUS FORKS, no en deploy repo)**

**Esto lo haces UNA VEZ en cada fork VilERP:**

```bash
# 1. En tu fork VilERP/frappe
git clone https://github.com/VilERP/frappe.git
cd frappe
git remote add upstream https://github.com/frappe/frappe.git
git remote -v
# origin    https://github.com/VilERP/frappe.git (tu fork)
# upstream  https://github.com/frappe/frappe.git (oficial)

# 2. En tu fork VilERP/erpnext  
git clone https://github.com/VilERP/erpnext.git
cd erpnext
git remote add upstream https://github.com/frappe/erpnext.git

# 3. En tu fork VilERP/payments
git clone https://github.com/VilERP/payments.git  
cd payments
git remote add upstream https://github.com/frappe/payments.git
```

### **Flujo de Actualización Mensual**

```bash
# PASO 1: Actualizar tu fork Frappe
cd VilERP-frappe-local/
git fetch upstream
git checkout develop
git merge upstream/version-15
git push origin develop

# PASO 2: Actualizar tu fork ERPNext (CUIDADO: tienes personalizaciones)
cd VilERP-erpnext-local/
git fetch upstream  
git checkout develop
git merge upstream/version-15  # ⚠️ Puede haber conflictos
# Resolver conflictos manualmente si los hay
git push origin develop

# PASO 3: Actualizar tu fork Payments
cd VilERP-payments-local/
git fetch upstream
git checkout develop  
git merge upstream/version-15
git push origin develop

# PASO 4: Actualizar repo de deploy
cd vilerp-deploy/
git submodule update --remote
git add .
git commit -m "Update all VilERP modules"
git push origin main
# Railway redespliega automáticamente
```

## 🎯 Configuración del Deploy Repo

### **El repo de deploy (.gitmodules) apunta SOLO a tus forks:**

```ini
[submodule "apps/frappe"]
    url = https://github.com/VilERP/frappe.git    # ← TU fork

[submodule "apps/erpnext"]  
    url = https://github.com/VilERP/erpnext.git   # ← TU fork

[submodule "apps/payments"]
    url = https://github.com/VilERP/payments.git  # ← TU fork
```

### **Railway clona automáticamente:**

```bash
# Railway ejecuta:
git clone --recursive https://github.com/tu-usuario/vilerp-deploy.git

# Esto descarga:
# 1. Tu repo deploy (configuración)
# 2. VilERP/frappe (tu fork)
# 3. VilERP/erpnext (tu fork con Laboratory Quality Control)  
# 4. VilERP/payments (tu fork)
```

## 🏗️ Pasos para Crear el Deploy

### **1. Crear Repo Deploy**

```bash
mkdir vilerp-deploy
cd vilerp-deploy
git init

# Copiar archivos creados
copy "D:\pasos a seguir\SinModuls\*" .

# Agregar submódulos (apuntan a TUS forks VilERP)
git submodule add https://github.com/VilERP/frappe.git apps/frappe
git submodule add https://github.com/VilERP/erpnext.git apps/erpnext  
git submodule add https://github.com/VilERP/payments.git apps/payments

# Configurar ramas
cd apps/frappe && git checkout develop && cd ../..
cd apps/erpnext && git checkout develop && cd ../..  
cd apps/payments && git checkout develop && cd ../..

# Commit y push
git add .
git commit -m "VilERP deploy configuration with custom forks"
git remote add origin https://github.com/tu-usuario/vilerp-deploy.git
git push -u origin main
```

### **2. Deploy en Railway**

1. **Railway** → **New Project** → **Deploy from GitHub**
2. **Seleccionar** `vilerp-deploy`
3. **Add MySQL** database
4. **Add Redis** database  
5. **Deploy** automático

## 🎯 Ventajas de esta Configuración

### **✅ Para Desarrollo:**
- Desarrollas en tus forks VilERP localmente
- Mantienes tus personalizaciones separadas
- Recibes actualizaciones oficiales controladas

### **✅ Para Deploy:**
- Un solo repo de deploy simple
- Railway clona todo automáticamente
- Redeploy automático cuando actualizas

### **✅ Para Mantenimiento:**
- Actualizaciones desde oficiales a tus forks
- Control total de conflictos
- Historial limpio de cambios

## ⚠️ Puntos Importantes

### **Configuración Upstream es MANUAL:**
- **NO está** en los archivos que creé
- **Debes configurarla** en cada fork VilERP
- **Se hace UNA VEZ** por fork

### **Resolución de Conflictos:**
- **ERPNext upstream** puede conflictar con Laboratory Quality Control
- **Resolver manualmente** cada actualización
- **Probar localmente** antes de push

### **Orden de Actualización:**
1. **Frappe primero** (base)
2. **Payments** (menos conflictos)
3. **ERPNext último** (más conflictos)
4. **Deploy repo** al final

## 🎉 Resultado Final

**Tendrás:**
- 🏢 **VilERP funcionando** en Railway
- 🔧 **Tus personalizaciones** intactas
- 🔄 **Actualizaciones oficiales** controladas
- 📦 **Deploy automático** desde Git

**¡Tu Laboratory Quality Control estará funcionando en producción con la capacidad de recibir actualizaciones oficiales!**
