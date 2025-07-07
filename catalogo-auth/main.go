package main

import (
	"log"
	"net/http"
	"os"

	"github.com/gin-gonic/gin"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var db *gorm.DB

// PerfilImpresion representa la configuración de impresión para un material específico
type PerfilImpresion struct {
	gorm.Model
	MaterialID         uint    `gorm:"not null" json:"material_id"`
	Nombre             string  `gorm:"not null" json:"nombre"`
	Descripcion        string  `json:"descripcion"`
	TemperaturaNozzle  int     `json:"temperatura_nozzle"` // °C
	TemperaturaCama    int     `json:"temperatura_cama"`   // °C
	VelocidadImpresion int     `json:"velocidad_impresion"` // mm/s
	AlturaCapa         float64 `json:"altura_capa"`         // mm
	Relleno            int     `json:"relleno"`             // %
	VelocidadRetraccion int    `json:"velocidad_retraccion"` // mm/s
	DistanciaRetraccion float64 `json:"distancia_retraccion"` // mm
	VelocidadVentilador int    `json:"velocidad_ventilador"` // %
	EsRecomendado      bool    `gorm:"default:false" json:"es_recomendado"`
}

func main() {
	if err := setupDB(); err != nil {
		log.Fatalf("Error al configurar la base de datos: %v", err)
	}

	r := gin.Default()

	// Rutas API
	api := r.Group("/api/v1")
	{
		// Perfiles de impresión
		api.GET("/perfiles-impresion", getPerfilesImpresion)
		api.GET("/perfiles-impresion/:id", getPerfilImpresion)
		api.GET("/perfiles-impresion/material/:materialId", getPerfilesPorMaterial)
		api.GET("/perfiles-impresion/recomendados", getPerfilesRecomendados)
		api.POST("/perfiles-impresion", createPerfilImpresion)
		api.PUT("/perfiles-impresion/:id", updatePerfilImpresion)
		api.DELETE("/perfiles-impresion/:id", deletePerfilImpresion)
	}

	log.Printf("Iniciando servicio de configuraciones de impresión en :8083")
	r.Run(":8083")
}

func setupDB() error {
	postgresEndpoint := os.Getenv("POSTGRES_ENDPOINT")
	if postgresEndpoint == "" {
		postgresEndpoint = "localhost"
	}

	dsn := "host=" + postgresEndpoint + " user=postgres password=postgres123 dbname=configuraciones port=5432 sslmode=disable"
	var err error
	db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		return err
	}

	// Migrar el esquema
	return db.AutoMigrate(&PerfilImpresion{})
}

// getPerfilesImpresion obtiene todos los perfiles de impresión
func getPerfilesImpresion(c *gin.Context) {
	var perfiles []PerfilImpresion
	if err := db.Find(&perfiles).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al obtener perfiles"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": perfiles})
}

// getPerfilImpresion obtiene un perfil de impresión por ID
func getPerfilImpresion(c *gin.Context) {
	id := c.Param("id")
	var perfil PerfilImpresion

	if err := db.First(&perfil, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Perfil no encontrado"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": perfil})
}

// getPerfilesPorMaterial obtiene perfiles por ID de material
func getPerfilesPorMaterial(c *gin.Context) {
	materialID := c.Param("materialId")
	var perfiles []PerfilImpresion

	if err := db.Where("material_id = ?", materialID).Find(&perfiles).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al obtener perfiles"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": perfiles})
}

// getPerfilesRecomendados obtiene los perfiles recomendados
func getPerfilesRecomendados(c *gin.Context) {
	var perfiles []PerfilImpresion

	if err := db.Where("es_recomendado = ?", true).Find(&perfiles).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al obtener perfiles recomendados"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": perfiles})
}

// createPerfilImpresion crea un nuevo perfil de impresión
func createPerfilImpresion(c *gin.Context) {
	var perfil PerfilImpresion
	if err := c.ShouldBindJSON(&perfil); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := db.Create(&perfil).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al crear el perfil"})
		return
	}

	c.JSON(http.StatusCreated, gin.H{"data": perfil})
}

// updatePerfilImpresion actualiza un perfil existente
func updatePerfilImpresion(c *gin.Context) {
	id := c.Param("id")
	var perfil PerfilImpresion

	if err := db.First(&perfil, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Perfil no encontrado"})
		return
	}

	if err := c.ShouldBindJSON(&perfil); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	if err := db.Save(&perfil).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al actualizar el perfil"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"data": perfil})
}

// deletePerfilImpresion elimina un perfil
func deletePerfilImpresion(c *gin.Context) {
	id := c.Param("id")
	var perfil PerfilImpresion

	if err := db.First(&perfil, id).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Perfil no encontrado"})
		return
	}

	if err := db.Delete(&perfil).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al eliminar el perfil"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Perfil eliminado correctamente"})
}
