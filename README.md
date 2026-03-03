# 🛡️ Saraiba Phishing Training Landing Page

Página de concienciación en phishing para usuarios que hacen clic en simulaciones de phishing.

## 🌐 Dominios

- **Español**: `es.saraiba.eu`
- **Inglés**: `en.saraiba.eu`

## 🚀 Despliegue

### Vercel (Recomendado)

1. Ve a [vercel.com](https://vercel.com)
2. Importa el repositorio `polidisio/saraiba-phishing-training`
3. Añade los dominios personalizados:
   - `es.saraiba.eu` → Configura como dominio principal
   - `en.saraiba.eu` → Dominio adicional
4. Configura los registros DNS en tu proveedor de dominio:

```
Tipo: CNAME
Nombre: es
Valor: cname.vercel-dns.com

Tipo: CNAME
Nombre: en
Valor: cname.vercel-dns.com
```

## 📁 Estructura

```
├── index.html          # Página principal
├── css/
│   └── styles.css      # Estilos
├── js/
│   ├── i18n.js         # Manejo de idiomas
│   └── main.js         # Lógica principal
├── vercel.json         # Configuración de Vercel
└── README.md
```

## 🔧 Configuración

### Detección de idioma

El idioma se detecta automáticamente:
1. **Subdominio**: `es.` → Español, `en.` → Inglés
2. **Navegador**: Si no hay subdominio, usa el idioma del navegador

### Analytics

Vercel Analytics está integrado para rastrear:
- Visitas a la página
- Completación de formación

## 📝 Personalización

### Cambiar logo

Reemplaza el emoji 🛡️ en `index.html` línea 14 con tu logo.

### Añadir logo de empresa

```html
<img src="assets/logo.png" alt="Saraiba" class="logo-img">
```

### Añadir más contenido

Edita `index.html` para agregar secciones adicionales.

## 🔐 Seguridad

- Headers de seguridad configurados en `vercel.json`
- No se collectan datos personales
- Solo se registra: idioma, fecha de completación

## 📄 Licencia

Privado - Uso interno Saraiba
