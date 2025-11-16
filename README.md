# Proyecto Final — Data Visualization

Este proyecto comprende la visualización de un conjunto de datos reales para crear un dashboard interactivo en Shiny.  
El objetivo central es transformar información de criminalidad de la ciudad de Chicago en una herramienta visual que facilite la exploración y el análisis de patrones delictivos desde el año 2020 en adelante.

---

## Autores

- **Juan M. González-Campo:** 21077  
- **Mario E. Puente:** 21290

---

## Fuente de los Datos

Los datos se extrajeron del sitio oficial de datos abiertos de la Ciudad de Chicago, específicamente del siguiente dataset:

**Crimes – 2001 to Present**  
https://data.cityofchicago.org/Public-Safety/Crimes-2001-to-Present/ijzp-q8t2/about_data

Este dataset contiene información histórica de incidentes reportados al Departamento de Policía de Chicago.  
Para este proyecto se extrajeron únicamente los registros correspondientes a los **años 2020 en adelante**, con datos actualizados al **15 de noviembre de 2025**.

Este archivo se guardo localmente como *chicago_crime_2020-2025.csv*

---

## Descripción General del Dataset

El dataset original contiene **22 variables**, cada una describiendo un aspecto del incidente reportado.  
La siguiente sección detalla cada columna según la documentación oficial del portal de datos de Chicago.

---

## Variables del Dataset

### 1. **ID**
- Identificador único del registro.  
- **Campo API:** `id`  
- **Tipo:** Number  

### 2. **Case Number**  
- Número RD asignado por el CPD. Es único por incidente.  
- **Campo API:** `case_number`  
- **Tipo:** Text  

### 3. **Date**  
- Fecha y hora del incidente (a veces estimada).  
- **Campo API:** `date`  
- **Tipo:** Floating Timestamp  

### 4. **Block**  
- Dirección parcialmente redactada donde ocurrió el incidente.  
- **Campo API:** `block`  
- **Tipo:** Text  

### 5. **IUCR**  
- Código Illinois Uniform Crime Reporting. Clasifica el tipo primario y secundario del delito.  
- **Campo API:** `iucr`  
- **Tipo:** Text  

### 6. **Primary Type**  
- Clasificación primaria del delito.  
- **Campo API:** `primary_type`  
- **Tipo:** Text  

### 7. **Description**  
- Subcategoría del delito.  
- **Campo API:** `description`  
- **Tipo:** Text  

### 8. **Location Description**  
- Descripción del lugar donde ocurrió el incidente.  
- **Campo API:** `location_description`  
- **Tipo:** Text  

### 9. **Arrest**  
- Indica si hubo arresto (`TRUE`/`FALSE`).  
- **Campo API:** `arrest`  
- **Tipo:** Checkbox  

### 10. **Domestic**  
- Indica si el incidente estuvo relacionado con violencia doméstica.  
- **Campo API:** `domestic`  
- **Tipo:** Checkbox  

### 11. **Beat**  
- Beat policial donde ocurrió el incidente (unidad geográfica más pequeña del CPD).  
- **Campo API:** `beat`  
- **Tipo:** Text  

### 12. **District**  
- Distrito policial correspondiente al incidente.  
- **Campo API:** `district`  
- **Tipo:** Text  

### 13. **Ward**  
- Distrito del City Council donde ocurrió el incidente.  
- **Campo API:** `ward`  
- **Tipo:** Number  

### 14. **Community Area**  
- Área comunitaria correspondiente (Chicago tiene 77).  
- **Campo API:** `community_area`  
- **Tipo:** Text  

### 15. **FBI Code**  
- Código NIBRS del FBI para clasificar delitos.  
- **Campo API:** `fbi_code`  
- **Tipo:** Text  

### 16. **X Coordinate**  
- Coordenada X (proyección Illinois State Plane NAD 1983).  
- Datos desplazados para privacidad.  
- **Campo API:** `x_coordinate`  
- **Tipo:** Number  

### 17. **Y Coordinate**  
- Coordenada Y en la misma proyección.  
- **Campo API:** `y_coordinate`  
- **Tipo:** Number  

### 18. **Year**  
- Año en que ocurrió el incidente.  
- **Campo API:** `year`  
- **Tipo:** Number  

### 19. **Updated On**  
- Fecha y hora de la última actualización del registro.  
- **Campo API:** `updated_on`  
- **Tipo:** Floating Timestamp  

### 20. **Latitude**  
- Latitud desplazada ligeramente para protección de privacidad.  
- **Campo API:** `latitude`  
- **Tipo:** Number  

### 21. **Longitude**  
- Longitud desplazada ligeramente.  
- **Campo API:** `longitude`  
- **Tipo:** Number  

### 22. **Location**  
- Punto geográfico para visualización en mapas.  
- **Campo API:** `location`  
- **Tipo:** Location  




