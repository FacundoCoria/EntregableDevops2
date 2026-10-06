package com.pedidos.pedidos_api.repository;

import com.pedidos.pedidos_api.model.Producto;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductoRepository extends JpaRepository<Producto, Long> {
}