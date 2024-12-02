# Innovation Network Manager

Sistema de gestión para redes de innovación en formación profesional.

## Requisitos

- Node.js 20.x o superior
- NPM 10.x o superior
- MariaDB 10.11 o superior

## Instalación

1. Clonar el repositorio:
```bash
git clone https://github.com/your-username/innovation-network.git
cd innovation-network
```

2. Instalar dependencias:
```bash
npm install
```

3. Configurar variables de entorno:
```bash
cp .env.example .env
# Editar .env con tus configuraciones
```

4. Inicializar la base de datos:
```bash
# Crear base de datos y usuario
mysql -u root -p < docker/mariadb/init/01-init.sql
```

5. Iniciar la aplicación:
```bash
npm run dev
```

## Despliegue

1. Construir la aplicación:
```bash
npm run build
```

2. Usando Docker:
```bash
chmod +x deploy.sh
sudo ./deploy.sh
```

## Seguridad

- Las contraseñas y tokens se almacenan de forma segura
- Los datos sensibles están excluidos del control de versiones
- Se utilizan variables de entorno para la configuración
- Se implementa validación y sanitización de datos

## Licencia

MIT