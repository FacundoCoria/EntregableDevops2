package com.pedidos.pedidos_api.service;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.stereotype.Service;

@Service
public class PedidoMetricsService {

    private final MeterRegistry meterRegistry;

    public PedidoMetricsService(MeterRegistry meterRegistry) {
        this.meterRegistry = meterRegistry;
    }

    public void registrarPedido(String producto) {

        Counter counter = Counter.builder("pedidos_creados_total")
                .description("Cantidad de pedidos creados")
                .tag("producto", producto)
                .register(meterRegistry);

        counter.increment();
    }
}