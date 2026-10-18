# Métricas de monitoreo — API de Pedidos

La API utiliza **Micrometer y Prometheus** para registrar métricas relacionadas con la creación de pedidos y sus tiempos de espera. Estas métricas permiten visualizar el comportamiento de la aplicación mediante dashboards en Grafana.

## Métricas disponibles

| Métrica | Descripción |
|---|---|
| `pedidos_creados_total` | Cuenta los pedidos creados, agrupados por producto. |
| `pedidos_por_estado_total` | Cuenta los pedidos según su estado inicial, por ejemplo, Pendiente o Entregado. |
| `pedidos_espera_minutos_minutes_sum` | Acumula los minutos de espera registrados para los pedidos, agrupados por producto. |
| `pedidos_espera_minutos_minutes_count` | Cuenta los pedidos que tienen un tiempo de espera registrado. |
| `pedidos_espera_alta_total` | Cuenta los pedidos creados con un tiempo de espera igual o superior a 10 minutos. |

## Consultas PromQL

- **Pedidos por producto**
  ```promql
  sum by (producto) (pedidos_creados_total)
  ```

- **Pedidos por estado inicial**
  ```promql
  sum by (estado) (pedidos_por_estado_total)
  ```

- **Tiempo promedio de espera**
  ```promql
  sum(pedidos_espera_minutos_minutes_sum) / sum(pedidos_espera_minutos_minutes_count)
  ```

- **Pedidos con espera alta**
  ```promql
  sum(pedidos_espera_alta_total)
  ```

- **Tiempo promedio de espera por producto**
  ```promql
  sum by (producto) (pedidos_espera_minutos_minutes_sum) / sum by (producto) (pedidos_espera_minutos_minutes_count)
  ```

## Visualización

Las métricas pueden consultarse en Prometheus y utilizarse en Grafana para crear paneles de barras y estadísticas que faciliten el seguimiento de pedidos, demoras y tiempos promedio.

**Nota:** los contadores y las distribuciones de Micrometer se mantienen en memoria y se reinician al reiniciar la aplicación. Las métricas registran los pedidos creados mientras la aplicación está ejecutándose; no reconstruyen automáticamente las estadísticas a partir de los datos históricos de la base de datos.