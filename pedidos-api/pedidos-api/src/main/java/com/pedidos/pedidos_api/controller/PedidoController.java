package com.pedidos.pedidos_api.controller;

import com.pedidos.pedidos_api.model.Pedido;
import com.pedidos.pedidos_api.model.Producto;
import com.pedidos.pedidos_api.repository.PedidoRepository;
import com.pedidos.pedidos_api.repository.ProductoRepository;
import com.pedidos.pedidos_api.service.PedidoMetricsService;

import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/pedidos")
public class PedidoController {

    private final PedidoRepository pedidoRepository;
    private final ProductoRepository productoRepository;
    private final PedidoMetricsService pedidoMetricsService;

    public PedidoController(
            PedidoRepository pedidoRepository,
            ProductoRepository productoRepository,
            PedidoMetricsService pedidoMetricsService) {

        this.pedidoRepository = pedidoRepository;
        this.productoRepository = productoRepository;
        this.pedidoMetricsService = pedidoMetricsService;
    }

    @GetMapping
    public List<Pedido> obtenerPedidos() {
        return pedidoRepository.findAll();
    }

    @GetMapping("/{id}")
    public Pedido obtenerPedido(@PathVariable Long id) {
        return pedidoRepository.findById(id).orElse(null);
    }

   @PostMapping
    public Pedido crearPedido(@RequestBody Pedido pedido) {

        Producto producto = productoRepository
                .findById(pedido.getProducto().getId())
                .orElse(null);

        if (producto == null) {
            return null;
        }

        pedido.setProducto(producto);
        pedido.setPrecioUnitario(producto.getPrecio());

        if (pedido.getEstado() == null) {
            pedido.setEstado("Pendiente");
        }

        if (pedido.getMinutosEspera() == null) {
            pedido.setMinutosEspera(0);
        }

        pedido.setFechaCreacion(LocalDateTime.now());

        Pedido pedidoGuardado = pedidoRepository.save(pedido);

        pedidoMetricsService.registrarPedido(
                producto.getNombre()
        );

        return pedidoGuardado;
    }

    @PutMapping("/{id}")
    public Pedido modificarPedido(
            @PathVariable Long id,
            @RequestBody Pedido pedido) {

        Pedido existente = pedidoRepository
                .findById(id)
                .orElse(null);

        if (existente == null) {
            return null;
        }

        existente.setCliente(pedido.getCliente());
        existente.setEstado(pedido.getEstado());
        existente.setMinutosEspera(pedido.getMinutosEspera());

        return pedidoRepository.save(existente);
    }

    @DeleteMapping("/{id}")
    public void eliminarPedido(@PathVariable Long id) {
        pedidoRepository.deleteById(id);
    }
}