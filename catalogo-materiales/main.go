package main

import (
	"log"
	"net/http"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// TipoMaterial representa los tipos de materiales disponibles
type TipoMaterial string

const (
	TipoFilamento TipoMaterial = "filamento"
	TipoResina    TipoMaterial = "resina"
)

// CaracteristicasMaterial representa las características técnicas de un material
type CaracteristicasMaterial struct {
	// Características comunes
	Color            string  `json:"color"`
	TemperaturaImpresion int    `json:"temperatura_impresion"` // °C
	TemperaturaPlataforma int    `json:"temperatura_plataforma"` // °C
	ResistenciaTensil float64 `json:"resistencia_tensil"`    // MPa
	Dureza          float64 `json:"dureza"`    // Para resinas
	
	// Características específicas de filamento
	DiametroFilamento float64 `json:"diametro_filamento"` // mm
	Densidad         float64 `json:"densidad"`    // g/cm³
	
	// Características específicas de resina
	Viscosidad       float64 `json:"viscosidad"`    // cP
	TiempoCura       int     `json:"tiempo_cura"`    // segundos
	Tolerancia       float64 `json:"tolerancia"`    // mm
}

// Material representa un material para impresión 3D
type Material struct {
	ID              string              `json:"id"`
	Nombre          string              `json:"nombre"`
	Tipo            TipoMaterial        `json:"tipo"`
	Fabricante      string              `json:"fabricante"`
	Disponible      bool                `json:"disponible"`
	Stock           float64             `json:"stock"` // En metros para filamentos, en ml para resinas
	PrecioPorUnidad float64             `json:"precio_por_unidad"`
	Caracteristicas CaracteristicasMaterial `json:"caracteristicas"`
}

var materiales = []Material{}

func main() {
	if err := setup(); err != nil {
		log.Fatalf("Error al configurar: %v", err)
	}

	r := gin.Default()

	// Rutas API
	api := r.Group("/api/v1")
	{
		api.GET("/materiales", getMaterials)
		api.GET("/materiales/:id", getMaterial)
		api.GET("/materiales/tipo/:tipo", getMaterialsByType)
		api.POST("/materiales", createMaterial)
		api.PUT("/materiales/:id", updateMaterial)
		api.DELETE("/materiales/:id", deleteMaterial)
		api.PUT("/materiales/:id/stock", updateStock)
	}

	log.Printf("Iniciando servicio de materiales en :8082")
	r.Run(":8082")
}

func setup() error {
	// Inicializar materiales de ejemplo
	materiales = []Material{
		{
			ID:              "m001",
			Nombre:          "PLA Premium",
			Tipo:            TipoFilamento,
			Fabricante:      "XYZ Filaments",
			Disponible:      true,
			Stock:           1000.0, // metros
			PrecioPorUnidad: 25.99,  // por kilogramo
			Caracteristicas: CaracteristicasMaterial{
				Color:            "Natural",
				TemperaturaImpresion: 200,
				TemperaturaPlataforma: 60,
				ResistenciaTensil: 70.0,
				DiametroFilamento: 1.75,
				Densidad:         1.25,
			},
		},
		{
			ID:              "m002",
			Nombre:          "Resina Standard",
			Tipo:            TipoResina,
			Fabricante:      "UV Resins",
			Disponible:      true,
			Stock:           5000.0, // ml
			PrecioPorUnidad: 45.99,  // por litro
			Caracteristicas: CaracteristicasMaterial{
				Color:            "Transparente",
				TemperaturaImpresion: 25,
				TemperaturaPlataforma: 25,
				ResistenciaTensil: 75.0,
				Dureza:          70,
				Viscosidad:       1000,
				TiempoCura:       6,
				Tolerancia:       0.05,
			},
		},
	}
	return nil
}

func getMaterials(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"data": materiales,
	})
}

func getMaterial(c *gin.Context) {
	id := c.Param("id")
	for _, m := range materiales {
		if m.ID == id {
			c.JSON(http.StatusOK, gin.H{
				"data": m,
			})
			return
		}
	}
	c.JSON(http.StatusNotFound, gin.H{"error": "Material no encontrado"})
}

func getMaterialsByType(c *gin.Context) {
	tipo := c.Param("tipo")
	var filtered []Material
	for _, m := range materiales {
		if string(m.Tipo) == tipo {
			filtered = append(filtered, m)
		}
	}
	c.JSON(http.StatusOK, gin.H{
		"data": filtered,
	})
}

func createMaterial(c *gin.Context) {
	var material Material
	if err := c.ShouldBindJSON(&material); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	material.ID = uuid.New().String()
	materiales = append(materiales, material)

	c.JSON(http.StatusCreated, gin.H{
		"data": material,
	})
}

func updateMaterial(c *gin.Context) {
	id := c.Param("id")
	var material Material
	if err := c.ShouldBindJSON(&material); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	for i, m := range materiales {
		if m.ID == id {
			materiales[i] = material
			c.JSON(http.StatusOK, gin.H{
				"data": material,
			})
			return
		}
	}
	c.JSON(http.StatusNotFound, gin.H{"error": "Material no encontrado"})
}

func deleteMaterial(c *gin.Context) {
	id := c.Param("id")
	for i, m := range materiales {
		if m.ID == id {
			materiales = append(materiales[:i], materiales[i+1:]...)
			c.JSON(http.StatusOK, gin.H{"message": "Material eliminado"})
			return
		}
	}
	c.JSON(http.StatusNotFound, gin.H{"error": "Material no encontrado"})
}

func updateStock(c *gin.Context) {
	id := c.Param("id")
	var stockUpdate struct {
		Stock float64 `json:"stock"`
	}
	if err := c.ShouldBindJSON(&stockUpdate); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	for i, m := range materiales {
		if m.ID == id {
			materiales[i].Stock = stockUpdate.Stock
			c.JSON(http.StatusOK, gin.H{
				"data": materiales[i],
			})
			return
		}
	}
	c.JSON(http.StatusNotFound, gin.H{"error": "Material no encontrado"})
}
