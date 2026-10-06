package com.pedidos.pedidos_api.model;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
public class Pedido {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String cliente;

    @ManyToOne
    @JoinColumn(name = "producto_id")
    private Producto producto;

    private Double precioUnitario;

    private String estado;

    private Integer minutosEspera;

    private LocalDateTime fechaCreacion;

    public Pedido() {
    }

    public Pedido(String cliente, Producto producto, Double precioUnitario,
                  String estado, Integer minutosEspera, LocalDateTime fechaCreacion) {
        this.cliente = cliente;
        this.producto = producto;
        this.precioUnitario = precioUnitario;
        this.estado = estado;
        this.minutosEspera = minutosEspera;
        this.fechaCreacion = fechaCreacion;
    }

    public Long getId() {
        return id;
    }

    public String getCliente() {
        return cliente;
    }

    public void setCliente(String cliente) {
        this.cliente = cliente;
    }

    public Producto getProducto() {
        return producto;
    }

    public void setProducto(Producto producto) {
        this.producto = producto;
    }

    public Double getPrecioUnitario() {
        return precioUnitario;
    }

    public void setPrecioUnitario(Double precioUnitario) {
        this.precioUnitario = precioUnitario;
    }

    public String getEstado() {
        return estado;
    }

    public void setEstado(String estado) {
        this.estado = estado;
    }

    public Integer getMinutosEspera() {
        return minutosEspera;
    }

    public void setMinutosEspera(Integer minutosEspera) {
        this.minutosEspera = minutosEspera;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }
}