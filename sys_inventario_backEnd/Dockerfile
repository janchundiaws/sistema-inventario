# Dockerfile para Sistema de Inventario (MySQL Local)
FROM node:18-alpine

# Instalar dependencias del sistema necesarias
RUN apk add --no-cache \
    python3 \
    make \
    g++ \
    dumb-init \
    && rm -rf /var/cache/apk/*

# Crear usuario no-root para seguridad
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm ci --only=production && npm cache clean --force

# Copiar código fuente
COPY src ./src
COPY bd_mysql.sql ./

# Cambiar propietario de los archivos
RUN chown -R nodejs:nodejs /app

# Cambiar al usuario no-root
USER nodejs

# Exponer puerto
EXPOSE 3000

# Variables de entorno por defecto para MySQL local
# host.docker.internal
ENV NODE_ENV=production
ENV PORT=3000
ENV DB_HOST=10.10.61.216 
ENV DB_PORT=3306
ENV DB_NAME=sys_inventario
ENV DB_USER=root
ENV DB_PASSWORD=Isaias08032023
ENV JWT_SECRET=janchundia

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })" || exit 1

# Usar dumb-init para manejar señales correctamente
ENTRYPOINT ["dumb-init", "--"]

# Comando por defecto
CMD ["node", "src/app.js"] 