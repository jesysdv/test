### Descripción
Este repositorio corresponde a la dockerización de la imagen base para los proyectos con Drupal.
Algunos de los repositorios que acutalmente utilizan esta imagen son:
- Brigard Urrutia
- Brigard Castro

### Ejecución
**Nota:** Para ejecutar el siguiente comando se debe contar con Docker (en ejecución) y con la herramienta de AWS CLI ya configurada y con las credenciales correspondientes.

Para realizar la ejecución —es decir, hacer *build* and *push* para la imagen de docker— se deben ejecutar el comando
`./pushImage.sh <AWS_ACCOUNT_ID> <AWS_DEFAULT_REGION> <IMAGE_NAME>`

Esto hará que se haga *build* de la imagen de Docker, luego que se le asigne el tag adecuado, y finalmente que se suba (*push*) al repositorio de AWS ECR correspondiente.

Los parámetros *AWS_ACCOUNT_ID*, *AWS_DEFAULT_REGION* e *IMAGE_NAME* si no son brindados, tienen valores por defecto, los cuales son:

**AWS_ACCOUNT_ID**: 137435002474 [*Cuenta de clientes*]
**AWS_DEFAULT_REGION**: us-east-1
**IMAGE_NAME**: drupal-dockerized