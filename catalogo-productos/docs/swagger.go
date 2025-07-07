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

package docs

import (
	_ "github.com/swaggo/files"
	_ "github.com/swaggo/gin-swagger"
)

// Dimensiones representa las dimensiones de un producto
// swagger:model
// @required
// @property ancho required
// @property alto required
// @property profundo required
type Dimensiones struct {
	Ancho    float64 `json:"ancho"`
	Alto     float64 `json:"alto"`
	Profundo float64 `json:"profundo"`
}

// Producto representa un producto en el catálogo
// swagger:model
// @required
// @property nombre required
// @property descripcion required
// @property precio_base required
// @property dimensiones required
// @property categoria required
// @property estado required
type Producto struct {
	ID          string      `json:"id"`
	Nombre      string      `json:"nombre"`
	Descripcion string      `json:"descripcion"`
	PrecioBase  float64     `json:"precio_base"`
	Dimensiones Dimensiones `json:"dimensiones"`
	Categoria   string      `json:"categoria"`
	Estado      string      `json:"estado"`
}

// Respuesta exitosa para obtener productos
// swagger:response productosResponse
type productosResponse struct {
	// Lista de productos
	// in:body
	Body struct {
		Data []Producto `json:"data"`
	}
}

// Respuesta exitosa para obtener un producto
// swagger:response productoResponse
type productoResponse struct {
	// Producto encontrado
	// in:body
	Body struct {
		Data Producto `json:"data"`
	}
}

// Respuesta de error
// swagger:response errorResponse
type errorResponse struct {
	// Mensaje de error
	// in:body
	Body struct {
		Error string `json:"error"`
	}
}

// Respuesta de éxito para operaciones
// swagger:response successResponse
type successResponse struct {
	// Mensaje de éxito
	// in:body
	Body struct {
		Message string `json:"message"`
	}
}
