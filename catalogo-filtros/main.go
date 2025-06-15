package main

import (
	"log"
	"net/http"
	"github.com/gin-gonic/gin"
)

type Busqueda struct {
	ID          string `json:"id"`
	Query       string `json:"query"`
	Categoria   string `json:"categoria"`
	Dimensiones struct {
		MinAncho  float64 `json:"min_ancho"`
		MaxAncho  float64 `json:"max_ancho"`
		MinAlto   float64 `json:"min_alto"`
		MaxAlto   float64 `json:"max_alto"`
		MinProfundo float64 `json:"min_profundo"`
		MaxProfundo float64 `json:"max_profundo"`
	} `json:"dimensiones"`
	PrecioMin   float64 `json:"precio_min"`
	PrecioMax   float64 `json:"precio_max"`
	TipoMaterial string  `json:"tipo_material"`
}

func main() {
	r := gin.Default()

	// Rutas API
	api := r.Group("/api/v1")
	{
		api.GET("/buscar", buscar)
		api.GET("/buscar/:id", getBusqueda)
		api.POST("/buscar", aplicarFiltros)
	}

	// Agregando logs para todas las rutas
	api.Use(func(c *gin.Context) {
		log.Printf("[API] %s %s", c.Request.Method, c.Request.URL.Path)
		c.Next()
	})

	log.Printf("Iniciando servicio de filtros y búsqueda en :8084")
	r.Run(":8084")
}

func buscar(c *gin.Context) {
	log.Printf("[GET /buscar] Endpoint de búsqueda GET")
	c.JSON(http.StatusOK, gin.H{
		"message": "Endpoint de búsqueda GET",
		"info": "Usar POST para realizar búsquedas con filtros",
		"status": "ok",
	})
}

func getBusqueda(c *gin.Context) {
	// Este endpoint serviría para obtener el estado de una búsqueda
	c.JSON(http.StatusOK, gin.H{
		"message": "Implementar la obtención del estado de búsqueda",
	})
}

func aplicarFiltros(c *gin.Context) {
	var filtros struct {
		Categoria   string `json:"categoria"`
		PrecioMax   float64 `json:"precio_max"`
	}

	if err := c.ShouldBindJSON(&filtros); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// Aquí iría la lógica de filtrado que interactuaría con los otros microservicios
	c.JSON(http.StatusOK, gin.H{
		"message": "Filtros aplicados correctamente",
		"filtros": filtros,
	})
}
