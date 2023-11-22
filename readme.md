### Instalación
Para instalar se debe descargar en este mismo directorio el repositorio de Pantheon del sitio. En este caso, el repositorio remoto del sitio corresponderá a: `src/`.

Nota: el directorio `src/` se encuentra excluida de los archivos *trackeados* por git (*.gitignore*) [repositorio global].

**Ejemplo: Comandos de instalación**
```bash
# Dirigirse a la ruta del proyecto dockerizado
cd /path/site-docker

# Clonar el repositorio de Pantheon
git clone [Pantheon-Repo-URL] src/

# Docker build ...
```
