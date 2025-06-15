package main

import (
	"log"
	"net/http"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/swaggo/gin-swagger"
	"github.com/swaggo/gin-swagger/swaggerFiles"
)

// @title API de Catálogo de Productos
// @version 1.0
// @description API REST para gestión de productos 3D
// @termsOfService http://swagger.io/terms/

// @contact.name API Support
// @contact.url http://www.swagger.io/support
// @contact.email support@swagger.io

// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html

// @host localhost:8081
// @BasePath /api/v1

// @securityDefinitions.apikey ApiKeyAuth
// @in header
// @name Authorization

func main() {
	if err := setup(); err != nil {
		log.Fatalf("Error al configurar: %v", err)
	}

	r := gin.Default()

	// Documentación Swagger
	r.GET("/swagger/*any", ginSwagger.WrapHandler(swaggerFiles.Handler))

	// Rutas API
	api := r.Group("/api/v1")
	{
		api.GET("/productos", getProducts)
		api.GET("/productos/:id", getProduct)
		api.POST("/productos", createProduct)
		api.PUT("/productos/:id", updateProduct)
		api.DELETE("/productos/:id", deleteProduct)
	}

	log.Printf("Iniciando servicio de productos en :8081")
	r.Run(":8081")
}

type Dimensiones struct {
	Ancho   float64 `json:"ancho"`
	Alto    float64 `json:"alto"`
	Profundo float64 `json:"profundo"`
}

type Producto struct {
	ID          string      `json:"id"`
	Nombre      string      `json:"nombre"`
	Descripcion string      `json:"descripcion"`
	PrecioBase  float64     `json:"precio_base"`
	Dimensiones Dimensiones `json:"dimensiones"`
	Categoria   string      `json:"categoria"`
	Estado      string      `json:"estado"`
}

var productos = []Producto{}

func main() {
	if err := setup(); err != nil {
		log.Fatalf("Error al configurar: %v", err)
	}

	r := gin.Default()

	// Rutas API
	api := r.Group("/api/v1")
	{
		api.GET("/productos", getProducts)
		api.GET("/productos/:id", getProduct)
		api.POST("/productos", createProduct)
		api.PUT("/productos/:id", updateProduct)
		api.DELETE("/productos/:id", deleteProduct)
	}

	log.Printf("Iniciando servicio de productos en :8081")
	r.Run(":8081")
}

func setup() error {
	// Inicializar productos de ejemplo
	productos = []Producto{
		{
			ID:          "p001",
			Nombre:      "Pieza de Soporte",
			Descripcion: "Soporte para impresión 3D",
			PrecioBase:  15.99,
			Dimensiones: Dimensiones{
				Ancho:   10.0,
				Alto:    5.0,
				Profundo: 3.0,
			},
			Categoria: "Soportes",
			Estado:    "disponible",
		},
	}
	return nil
}

// Obtener todos los productos
// @Summary Obtener todos los productos
// @Description Obtiene la lista completa de productos
// @Tags productos
// @Accept json
// @Produce json
// @Success 200 {object} docs.productosResponse
// @Router /productos [get]
func getProducts(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"data": productos,
	})
}

// Obtener un producto por ID
// @Summary Obtener un producto por ID
// @Description Obtiene un producto específico por su ID
// @Tags productos
// @Accept json
// @Produce json
// @Param id path string true "ID del producto"
// @Success 200 {object} docs.productoResponse
// @Failure 404 {object} docs.errorResponse
// @Router /productos/{id} [get]
func getProduct(c *gin.Context) {
	id := c.Param("id")
	for _, p := range productos {
		if p.ID == id {
			c.JSON(http.StatusOK, gin.H{
				"data": p,
			})
			return
		}
	}
	c.JSON(http.StatusNotFound, gin.H{"error": "Producto no encontrado"})
}

// Crear un nuevo producto
// @Summary Crear un nuevo producto
// @Description Crea un nuevo producto en el catálogo
// @Tags productos
// @Accept json
// @Produce json
// @Param producto body docs.Producto true "Producto a crear"
// @Success 201 {object} docs.productoResponse
// @Failure 400 {object} docs.errorResponse
// @Router /productos [post]
func createProduct(c *gin.Context) {
	var producto docs.Producto
	if err := c.ShouldBindJSON(&producto); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	producto.ID = uuid.New().String()
	productos = append(productos, producto)

	c.JSON(http.StatusCreated, gin.H{
		"data": producto,
	})
}

// Actualizar un producto
// @Summary Actualizar un producto
// @Description Actualiza un producto existente
// @Tags productos
// @Accept json
// @Produce json
// @Param id path string true "ID del producto"
// @Param producto body docs.Producto true "Producto actualizado"
// @Success 200 {object} docs.productoResponse
// @Failure 404 {object} docs.errorResponse
// @Failure 400 {object} docs.errorResponse
// @Router /productos/{id} [put]
func updateProduct(c *gin.Context) {
	id := c.Param("id")
	var producto docs.Producto
	if err := c.ShouldBindJSON(&producto); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	for i, p := range productos {
		if p.ID == id {
			productos[i] = producto
			c.JSON(http.StatusOK, gin.H{
				"data": producto,
			})
			return
		}
	}
	c.JSON(http.StatusNotFound, gin.H{"error": "Producto no encontrado"})
}

// Eliminar un producto
// @Summary Eliminar un producto
// @Description Elimina un producto del catálogo
// @Tags productos
// @Accept json
// @Produce json
// @Param id path string true "ID del producto"
// @Success 200 {object} docs.successResponse
// @Failure 404 {object} docs.errorResponse
// @Router /productos/{id} [delete]
func deleteProduct(c *gin.Context) {
	id := c.Param("id")
	for i, p := range productos {
		if p.ID == id {
			productos = append(productos[:i], productos[i+1:]...)
			c.JSON(http.StatusOK, gin.H{"message": "Producto eliminado"})
			return
		}
	}
	c.JSON(http.StatusNotFound, gin.H{"error": "Producto no encontrado"})
}
