# Procedencia de recursos C07

14/11/2026. Bruno requiere fuentes oficiales para las descargas. Se revisaron
los puntos de descarga de los archivos y las siguientes fuentes primarias.
Esto identifica procedencia e integridad disponible; no garantiza ausencia de
vulnerabilidades ni equivale a verificar todas las dependencias transitivas.

| Recurso | Fuente y comprobación aplicada |
|---|---|
| Jenkins | [Jenkins oficial](https://www.jenkins.io/doc/book/installing/docker/), imagen `jenkins/jenkins`, digest en `ci/jenkins/images.env` |
| Docker CLI/DinD | [Docker Official Image](https://hub.docker.com/_/docker), namespace oficial `docker`, digests en images.env |
| Java build/runtime | [Eclipse Temurin Official Image](https://hub.docker.com/_/eclipse-temurin), digests en Dockerfile |
| Plugins Jenkins | [Update site oficial](https://updates.jenkins.io/), 67 versiones/URLs en plugins.lock.json y SHA256 comprobados al construir |
| Maven | [Distribución Apache](https://maven.apache.org/download.cgi), repo.maven.apache.org, bootstrap verifica SHA512; wrapper usa ZIP del mismo repositorio |
| Snyk | [Instalación oficial](https://docs.snyk.io/developer-tools/snyk-cli/install-the-snyk-cli), downloads.snyk.io, versión y SHA256 fijados |
| Helm | [Instalación oficial](https://helm.sh/docs/intro/install/), get.helm.sh, versión y SHA256 del proveedor |
| kubectl | [Instalación oficial](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/), dl.k8s.io, versión y SHA256 del proveedor |
| Semgrep | [Repositorio oficial](https://github.com/semgrep/semgrep), instalación PyPI recomendada; bootstrap fuerza https://pypi.org/simple y modo pip aislado, versión comprobada |
| Kyverno | [Instalación oficial](https://kyverno.io/docs/installation/installation/), chart https://kyverno.github.io/kyverno/, versión 3.10.0-rc.4 |
| Falco | [Instalación oficial](https://falco.org/docs/setup/kubernetes/), chart https://falcosecurity.github.io/charts, versión 9.2.2 |
| Prometheus / Grafana | [Prometheus](https://prometheus.io/docs/prometheus/latest/installation/) / [Grafana](https://grafana.com/docs/grafana/latest/setup-grafana/installation/docker/), prom/prometheus y grafana/grafana, digests en values.yaml |
| Minikube | [Proyecto Kubernetes](https://minikube.sigs.k8s.io/docs/start/), binario existente; registra versión y descarga imágenes de los registros del proyecto |
| Paquetes de SO / Java | APT firmado de las bases oficiales y Maven Central; inventarios efectivos conservados, sin afirmar fijación bit a bit de transitivas |

El bootstrap restringe curl a HTTPS, incluso después de redirecciones.
Los checksums obtenidos junto al recurso detectan alteración accidental; no
constituyen por sí solos una firma independiente del proveedor. El candidato
conserva excepciones y vulnerabilidades C04/C05/C06 documentadas.
