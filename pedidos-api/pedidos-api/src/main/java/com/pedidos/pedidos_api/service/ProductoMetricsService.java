package com.pedidos.pedidos_api.service;

import com.pedidos.pedidos_api.repository.ProductoRepository;
import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.Gauge;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.stereotype.Service;

/**
 * Métricas del catálogo de productos.
 *   "productos.operaciones"    -> productos_operaciones_total{operacion}
 *   "productos.cambios.precio" -> productos_cambios_precio_total{producto,direccion}
 *   "productos.registrados"    -> productos_registrados (gauge)
 */
@Service
public class ProductoMetricsService {

    private final MeterRegistry registry;

    public ProductoMetricsService(MeterRegistry registry, ProductoRepository productoRepository) {
        this.registry = registry;

        Gauge.builder("productos.registrados", productoRepository, ProductoRepository::count)
                .description("Cantidad de productos en el catálogo")
                .register(registry);
    }

    /** operacion: crear | modificar | eliminar */
    public void registrarOperacion(String operacion) {
        Counter.builder("productos.operaciones")
                .description("Altas, modificaciones y bajas de productos")
                .tag("operacion", operacion)
                .register(registry)
                .increment();
    }

    /** Detecta cambios de precio frecuentes o bruscos sobre un producto. */
    public void registrarCambioPrecio(String nombreProducto, Double precioAnterior, Double precioNuevo) {
        if (precioAnterior == null || precioNuevo == null || precioAnterior.equals(precioNuevo)) {
            return;
        }
        Counter.builder("productos.cambios.precio")
                .description("Cambios de precio de productos")
                .tag("producto", nombreProducto)
                .tag("direccion", precioNuevo > precioAnterior ? "suba" : "baja")
                .register(registry)
                .increment();
    }

    public void registrarError(String operacion) {
        Counter.builder("productos.errores")
                .description("Operaciones de productos sobre IDs inexistentes")
                .tag("operacion", operacion)
                .register(registry)
                .increment();
    }
}
