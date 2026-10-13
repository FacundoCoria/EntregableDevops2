package com.pedidos.pedidos_api.repository;

import com.pedidos.pedidos_api.model.Pedido;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PedidoRepository extends JpaRepository<Pedido, Long> {

    // Usado por el gauge "pedidos.en.estado" (cuántos pedidos hay hoy en cada estado)
    long countByEstadoIgnoreCase(String estado);
}
