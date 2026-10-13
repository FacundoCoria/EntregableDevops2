package com.pedidos.pedidos_api.service;

import com.pedidos.pedidos_api.repository.PedidoRepository;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.DistributionSummary;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Locale;

/**
 * Métricas de negocio de pedidos, expuestas en /actuator/prometheus.
 *
 * Micrometer traduce los nombres a formato Prometheus:
 *   "pedidos.creados"        -> pedidos_creados_total
 *   "pedidos.monto"          -> pedidos_monto_total
 *   "pedidos.minutos.espera" -> pedidos_minutos_espera_bucket / _sum / _count
 *
 * Los estados se normalizan a una lista cerrada para no generar
 * una serie nueva por cada texto distinto que llegue en el JSON.
 */
@Service
public class PedidoMetricsService {

    public static final String PENDIENTE = "pendiente";
    public static final String EN_PREPARACION = "en_preparacion";
    public static final String ENTREGADO = "entregado";
    public static final String CANCELADO = "cancelado";
    public static final String OTRO = "otro";

    private static final List<String> ESTADOS =
            List.of(PENDIENTE, EN_PREPARACION, ENTREGADO, CANCELADO);

    private final MeterRegistry registry;

    public PedidoMetricsService(MeterRegistry registry, PedidoRepository pedidoRepository) {
        this.registry = registry;

        // GAUGE: cantidad actual de pedidos en cada estado.
        // Se calcula en cada scrape de Prometheus consultando la base.
        for (String estado : ESTADOS) {
            Gauge.builder("pedidos.en.estado",
                            pedidoRepository,
                            repo -> repo.countByEstadoIgnoreCase(textoEstado(estado)))
                    .description("Cantidad actual de pedidos en cada estado")
                    .tag("estado", estado)
                    .register(registry);
        }
    }

    // ------------------------------------------------------------------
    // 1) Pedido creado (métrica de la consigna: X órdenes de un producto en Y min)
    // ------------------------------------------------------------------

    /** Firma original: la mantiene compatible con el controller existente. */
    public void registrarPedido(String nombreProducto) {
        Counter.builder("pedidos.creados")
                .description("Pedidos creados, por producto")
                .tag("producto", nombreProducto)
                .register(registry)
                .increment();
    }

    /** Versión completa: además del conteo registra monto, estado inicial y espera. */
    public void registrarPedido(String nombreProducto, Double precioUnitario,
                                String estado, Integer minutosEspera) {
        registrarPedido(nombreProducto);
        registrarMonto(nombreProducto, precioUnitario);
        registrarEspera(nombreProducto, minutosEspera);

        Counter.builder("pedidos.estado.transiciones")
                .description("Cambios de estado de pedidos (origen 'nuevo' = recién creado)")
                .tag("desde", "nuevo")
                .tag("hacia", normalizarEstado(estado))
                .register(registry)
                .increment();
    }

    // ------------------------------------------------------------------
    // 2) Facturación
    // ------------------------------------------------------------------

    public void registrarMonto(String nombreProducto, Double monto) {
        if (monto == null || monto < 0) {
            return;
        }
        Counter.builder("pedidos.monto")
                .description("Monto acumulado facturado, por producto")
                .baseUnit("pesos")
                .tag("producto", nombreProducto)
                .register(registry)
                .increment(monto);
    }

    // ------------------------------------------------------------------
    // 3) Tiempo de espera (permite alertar por p95)
    // ------------------------------------------------------------------

    public void registrarEspera(String nombreProducto, Integer minutosEspera) {
        if (minutosEspera == null || minutosEspera < 0) {
            return;
        }
        DistributionSummary.builder("pedidos.minutos.espera")
                .description("Minutos de espera informados por pedido")
                .baseUnit("minutos")
                .tag("producto", nombreProducto)
                .publishPercentileHistogram()   // genera buckets para histogram_quantile()
                .serviceLevelObjectives(5, 10, 15, 30, 60)
                .register(registry)
                .record(minutosEspera);
    }

    // ------------------------------------------------------------------
    // 4) Cambios de estado (cancelaciones, entregas, etc.)
    // ------------------------------------------------------------------

    public void registrarCambioEstado(String nombreProducto, String estadoAnterior, String estadoNuevo) {
        String desde = normalizarEstado(estadoAnterior);
        String hacia = normalizarEstado(estadoNuevo);
        if (desde.equals(hacia)) {
            return; // no hubo transición real
        }

        Counter.builder("pedidos.estado.transiciones")
                .description("Cambios de estado de pedidos (origen 'nuevo' = recién creado)")
                .tag("desde", desde)
                .tag("hacia", hacia)
                .register(registry)
                .increment();

        if (CANCELADO.equals(hacia)) {
            Counter.builder("pedidos.cancelados")
                    .description("Pedidos cancelados, por producto")
                    .tag("producto", nombreProducto)
                    .register(registry)
                    .increment();
        }
    }

    // ------------------------------------------------------------------
    // 5) Bajas y errores
    // ------------------------------------------------------------------

    public void registrarEliminacion() {
        Counter.builder("pedidos.eliminados")
                .description("Pedidos eliminados")
                .register(registry)
                .increment();
    }

    /** motivo: producto_inexistente | pedido_inexistente */
    public void registrarError(String operacion, String motivo) {
        Counter.builder("pedidos.errores")
                .description("Operaciones de pedidos que fallaron")
                .tag("operacion", operacion)
                .tag("motivo", motivo)
                .register(registry)
                .increment();
    }

    // ------------------------------------------------------------------
    // Utilidades
    // ------------------------------------------------------------------

    /** "En Preparación", "en preparacion", "EN_PREPARACION" -> "en_preparacion" */
    public static String normalizarEstado(String estado) {
        if (estado == null || estado.isBlank()) {
            return PENDIENTE;
        }
        String e = estado.trim().toLowerCase(Locale.ROOT)
                .replace('á', 'a').replace('é', 'e').replace('í', 'i')
                .replace('ó', 'o').replace('ú', 'u')
                .replace(' ', '_');
        return ESTADOS.contains(e) ? e : OTRO;
    }

    /** Texto con el que se guarda el estado en la base (el controller usa "Pendiente"). */
    private static String textoEstado(String estadoNormalizado) {
        return switch (estadoNormalizado) {
            case PENDIENTE -> "Pendiente";
            case EN_PREPARACION -> "En preparacion";
            case ENTREGADO -> "Entregado";
            case CANCELADO -> "Cancelado";
            default -> estadoNormalizado;
        };
    }
}
