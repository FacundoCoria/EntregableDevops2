
package com.pedidos.pedidos_api.service;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.DistributionSummary;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.stereotype.Service;

@Service
public class PedidoMetricsService {

    private final MeterRegistry meterRegistry;

    public PedidoMetricsService(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
    }

    public void registrarPedido(
            String producto,
            String estado,
            Integer minutosEspera) {

        // 1. Total de pedidos por producto
        Counter.builder("pedidos_creados_total")
                .description("Cantidad de pedidos creados")
                .tag("producto", producto)
                .register(meterRegistry)
                .increment();

        // 2. Pedidos creados según su estado inicial
        Counter.builder("pedidos_por_estado_total")
                .description("Cantidad de pedidos creados por estado inicial")
                .tag("estado", estado != null ? estado : "Sin estado")
                .register(meterRegistry)
                .increment();

        // 3. Distribución de los minutos de espera informados
        if (minutosEspera != null && minutosEspera >= 0) {
            DistributionSummary.builder("pedidos_espera_minutos")
                    .description("Distribucion de minutos de espera por pedido")
                    .baseUnit("minutes")
                    .tag("producto", producto)
                    .register(meterRegistry)
                    .record(minutosEspera);
        }

        // 4. Pedidos con espera de 10 minutos o más
        if (minutosEspera != null && minutosEspera >= 10) {
            Counter.builder("pedidos_espera_alta_total")
                    .description("Pedidos creados con espera de 10 minutos o mas")
                    .tag("producto", producto)
                    .register(meterRegistry)
                    .increment();
        }
    }
}
