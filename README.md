# Proyecto Cronómetro Velocista
Proyecto final Electrónica digital 1.

Integrantes:
- Ana Maria Amaya Gómez
- Cristian Esteban Agualimpia 
- Cristian Yesid Vargas Losada

# **Contenido**
1. [Objetivos del proyecto](#objetivos-del-proyecto)
2. [Arquitectura del sistema](#2-arquitectura-del-sistema)
3. [Plan de trabajo](#3-plan-de-trabajo-fases-y-entregables)
4. [Cumplimiento de los criterios de diseño](#4-cumplimiento-de-criterios-de-diseño)

## 1. Objetivo general del proyecto

Diseñar un sistema digital de cronómetro para medir tiempo que toma un velocista en recorrer toda la pista.

## 1.1. Objetivos específicos del proyecto

- Precisión: Implementar un cronómetro a nivel de hardware (FPGA) capaz de capturar el tiempo de vuelta con precisión de microsegundos, basado en los sensores de meta.
Visualización
- (Look & Feel): Crear una experiencia profesional para el público y los competidores mediante un gran cartel LED (estilo 7 segmentos) y un sistema de salida ("Ready, Set, Go") con semáforo, sonido y movimiento de un banderín con un servomotor.
- Potencia: Diseñar y gestionar la etapa de potencia necesaria para controlar el cartel LED y demás elementos de alto consumo desde las señales de bajo voltaje de la FPGA.
- Integración: Enviar el tiempo final registrado de forma inalámbrica al backend de la aplicación UNRobot Live-Hub, asociándolo a la ronda individual correcta, según la lógica de la API.

## 2. Arquitectura del sistema

### Núcleo (FPGA Colorlight V8.2): 
Es el "Procesador de Tiempo Real". Sus responsabilidades son:
- Leer el/los sensor(es) de meta con latencia cero.
- Ejecutar la Máquina de Estados Finita (FSM) que controla el flujo "Ready -> Set -> Go -> Timing -> Finish".
- Controlar los actuadores de señalización (Semáforo de 3 LEDs, Buzzer, servomotor).
- Ejecutar el contador del cronómetro.
- Manejar la multiplexación de alta frecuencia y la lógica de decodificación BCD-a-7-Segmentos para el cartel LED.
- Transmitir (vía UART) el tiempo final capturado al gateway para transmisión.
- Manejar entradas digitales set y reset para activación del sistema.

### Gateway (ESP-32): 
Es el "Procesador de Aplicación y Red". Sus responsabilidades son:
- Generar señales digitales de control set y reset para la FPGA en base a interfaz de usuario para el juez (botones de set y reset físicos o desde la app).
- Conectarse al WiFi de la competencia.
Recibir (vía UART) el string del tiempo final enviado por la FPGA.
- Identificar la ronda actual que se está corriendo (ya sea por una simple interfaz en el ESP32 o recibiendo el dato desde el backend).
- Formatear y enviar la llamada HTTP PUT a la API del backend para registrar el tiempo.

## 3. Plan de Trabajo (Fases y Entregables)
### Fase 0: Configuración de entorno de desarrollo y revisión de conceptos

**Tareas:**
- [X] Instalar Linux y las herramientas de desarrollo requeridas para el proyecto en equipo de trabajo
- [X] Revisar conceptos y teoría importante para el proyecto

**Entregable:** Entorno de desarrollo completamente configurado y claridad global en aspectos de diseño a emplear.


### Fase 1: Diseño Lógico y Simulación (FPGA)

**Tareas:**
- [X] Desarrollar el módulo VHDL/Verilog de la FSM Principal (Estados: IDLE, READY, SET, GO, TIMING, FINISH).
- [X] Desarrollar el módulo Contador de alta frecuencia (cronómetro).
- Desarrollar el módulo Controlador de Display (Decodificador Binario-a-BCD, Decodificador BCD-a-7-Segmentos, y Módulo de Multiplexación/Refresco).
- [ ]Desarrollar el módulo Transmisor UART para serializar el tiempo final.

**Entregable:** Código VHDL/Verilog simulado y verificado con testbenches que prueben todos los flujos y transiciones. Debe haberse simulado el sistema en iverilog / gtkwave.


### Fase 2: Diseño e Implementación de Interfaz de Potencia

**Tareas:**
- [X]Seleccionar los componentes: LEDs de alta luminosidad, Transistores MOSFET (N-Channel) adecuados para la corriente y voltaje de los LEDs, y resistencias de gate, entre otros.
- [X] Diseñar el circuito esquemático de la placa "Driver". Esta placa recibirá las señales de control de 3.3V de la FPGA y las usará para conmutar la alimentación externa (ej. 12V/24V) de los segmentos del cartel.
Diseño de PCB y ensamblaje de la placa Driver.

**Entregable:** Placa de circuito impreso (PCB) funcional que aísla la lógica de la potencia.

### Fase 3: Desarrollo de Gateway (ESP32)

**Tareas:**
- [ ] Desarrollar el código C++ (Arduino) para la lógica del ESP32.
Implementar la lectura de los botones físicos (set, reset) y la lógica de debounce por software.
- [ ] Implementar la rutina de escucha del puerto serial (UART) para recibir el tiempo desde la FPGA.
Implementar la lógica de conexión WiFi y el cliente HTTP para realizar la llamada a la API.

**Entregable:** Código fuente del ESP32 capaz de conectarse a la API y enviar un tiempo de prueba.

### Fase 4: Integración y Pruebas

**Tareas:**
- [X]Conectar físicamente todos los componentes: Sensores -> FPGA, FPGA -> Drivers MOSFET -> Cartel LED, FPGA (Tx) -> ESP32 (Rx), ESP32 -> Botones.
Cargar el bitstream (lógica compilada) a la FPGA.
- [ ] Cargar el firmware al ESP32.
- [ ] Realizar prueba End-to-End: Simular el paso del robot, verificar el semáforo, verificar el conteo en el cartel y confirmar que el dato llega al backend.
 
**Entregable:** Sistema de cronometraje funcional y validado.

## 4. Cumplimiento de Criterios de Diseño
La arquitectura cumple con los requerimientos específicos del proyecto de la siguiente forma:

**Look and Feel del Proyecto:**
- *Público/Competidor:* La experiencia es de alta profesionalidad. El inicio de la carrera no es solo un "ya", sino una secuencia de Semáforo (Rojo, Amarillo, Verde) y Buzzer sincronizada por hardware.La visualización del tiempo en un cartel LED gigante es inmediata, clara y visible para todos, eliminando la dependencia de un pequeño LCD.
- *Juez:* La interacción del juez es robusta y simple. Se reduce a dos acciones físicas: SET (preparar el sistema para la secuencia de salida) y RESET (anular una carrera o prepararse para la siguiente), liberándolo de manejar la API.

**Protocolos (I2C/UART/SPI):**
- El protocolo de comunicación clave es UART (Serial Asíncrono). Se utiliza para la comunicación en una vía (simplex) desde la FPGA (Tx) hacia el ESP32 (Rx). Es la solución más eficiente en pines (solo 1 pin de datos) para enviar el tiempo final (ej. T_15450\n).
- No se requiere I2C ni SPI en este diseño, simplificando la lógica.

**Visualización en LCD:**
- Este criterio se mejora y reemplaza por la Visualización en Cartel LED Gigante. El módulo VHDL de la FPGA manejará la decodificación BCD-a-7-Segmentos y la multiplexación de alta velocidad (refresco) para controlar los segmentos del cartel.
 
**Gestión de Sensores y Actuadores:**
- **Sensores (Input):** Los sensores de barrera IR se conectan directamente a la FPGA. La lógica de debounce y detección de flanco se implementa en VHDL, garantizando que no se pierda ningún trigger.
- **Actuadores (Output):** La FPGA controla directamente el Semáforo, el Buzzer y el servomotor. Para el Cartel LED y el servomotor, la FPGA controla los drivers de potencia.

**Análisis de Consumo de Energía y Fuente Adecuada:**
- Este es un punto central del diseño. El alto consumo del cartel LED (que puede ser de varios Amperios) se maneja creando una separación entre la lógica de control y la etapa de potencia.
- La FPGA (3.3V) no alimenta los LEDs. En su lugar, sus pines de 3.3V alimentan las compuertas (Gates) de Transistores MOSFET, los cuales requieren muy poca corriente.
- Los MOSFETs actúan como interruptores electrónicos que conmutan una fuente de alimentación externa de alta potencia (ej. 12V o 24V @ 5A) que es la que alimenta los segmentos del cartel. Esto protege la FPGA y maneja la potencia de forma segura.
 
**Comunicación Inalámbrica (API):**
- El ESP32 actúa como el gateway de red.
- Se conectará al WiFi y, al recibir el dato de tiempo por UART desde la FPGA, ejecutará la llamada a la API.
- Basado en la documentación de la API, la categoría "Seguidor de Linea Velocista Amateur" es de tipo RONDA_INDIVIDUAL. El ESP32 deberá estar al tanto del id_ronda actual para hacer la llamada correcta (asumiendo un endpoint como PUT /api/v1/rondas-individuales/registrar-tiempo/{id_ronda}).

