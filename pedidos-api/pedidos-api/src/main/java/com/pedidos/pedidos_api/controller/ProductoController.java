package com.pedidos.pedidos_api.controller;

import com.pedidos.pedidos_api.model.Producto;
import com.pedidos.pedidos_api.repository.ProductoRepository;
import com.pedidos.pedidos_api.service.ProductoMetricsService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/productos")
public class ProductoController {

    private final ProductoRepository productoRepository;
    private final ProductoMetricsService productoMetricsService;

    public ProductoController(ProductoRepository productoRepository,
                              ProductoMetricsService productoMetricsService) {
        this.productoRepository = productoRepository;
        this.productoMetricsService = productoMetricsService;
    }

    @GetMapping
    public List<Producto> obtenerProductos() {
        return productoRepository.findAll();
    }

    @GetMapping("/{id}")
    public Producto obtenerProducto(@PathVariable Long id) {
        return productoRepository.findById(id).orElse(null);
    }

    @PostMapping
    public Producto crearProducto(@RequestBody Producto producto) {
        Producto guardado = productoRepository.save(producto);
        productoMetricsService.registrarOperacion("crear");
        return guardado;
    }

    @PutMapping("/{id}")
    public Producto modificarProducto(
            @PathVariable Long id,
            @RequestBody Producto producto) {

        Producto existente = productoRepository
                .findById(id)
                .orElse(null);

        if (existente == null) {
            productoMetricsService.registrarError("modificar");
            return null;
        }

        Double precioAnterior = existente.getPrecio();

        existente.setNombre(producto.getNombre());
        existente.setPrecio(producto.getPrecio());

        Producto guardado = productoRepository.save(existente);

        productoMetricsService.registrarOperacion("modificar");
        productoMetricsService.registrarCambioPrecio(
                guardado.getNombre(), precioAnterior, guardado.getPrecio());

        return guardado;
    }

    @DeleteMapping("/{id}")
    public void eliminarProducto(@PathVariable Long id) {
        if (!productoRepository.existsById(id)) {
            productoMetricsService.registrarError("eliminar");
            return;
        }
        productoRepository.deleteById(id);
        productoMetricsService.registrarOperacion("eliminar");
    }
}
