package com.pedidos.pedidos_api.controller;

import com.pedidos.pedidos_api.model.Producto;
import com.pedidos.pedidos_api.repository.ProductoRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/productos")
public class ProductoController {

    private final ProductoRepository productoRepository;

    public ProductoController(ProductoRepository productoRepository) {
        this.productoRepository = productoRepository;
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
        return productoRepository.save(producto);
    }

    @PutMapping("/{id}")
    public Producto modificarProducto(
            @PathVariable Long id,
            @RequestBody Producto producto) {

        Producto existente = productoRepository
                .findById(id)
                .orElse(null);

        if (existente == null) {
            return null;
        }

        existente.setNombre(producto.getNombre());
        existente.setPrecio(producto.getPrecio());

        return productoRepository.save(existente);
    }

    @DeleteMapping("/{id}")
    public void eliminarProducto(@PathVariable Long id) {
        productoRepository.deleteById(id);
    }
}