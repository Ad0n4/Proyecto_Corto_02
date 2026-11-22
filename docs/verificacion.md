# Verificación y simulación — Proyecto Corto 2

## 1. Objetivo

Verificar mediante simulaciones funcionales y análisis de formas de onda el funcionamiento de un multiplicador y un divisor de 32 bits implementados de forma modular en SystemVerilog.

Ambos circuitos fueron simulados utilizando Icarus Verilog 12.0 y GTKWave 3.3.100.

## 2. Verificación del multiplicador

### Arquitectura

El multiplicador trabaja con operandos sin signo de 32 bits y genera un producto de 64 bits.

Su funcionamiento se basa en sumas parciales y desplazamientos, realizando 32 iteraciones por operación.

### Pruebas realizadas

| Multiplicando | Multiplicador | Resultado esperado |
|---|---|---|
| 13 | 3 | 39 |
| 7 | 9 | 63 |
| 0 | 123 | 0 |
| 1 | 4294967295 | 4294967295 |
| 123456 | 654321 | 80779853376 |
| 4294967295 | 4294967295 | 18446744065119617025 |

**Resultado:** Las 6 pruebas fueron superadas.

### Análisis de ondas

En la simulación se observó:

- La señal `start` inicia el proceso.
- La señal `busy` indica que el circuito está realizando las operaciones.
- El multiplicando se desplaza hacia la izquierda.
- El multiplicador se desplaza hacia la derecha.
- El registro producto almacena las sumas parciales.
- La señal `done` indica la finalización del cálculo.

Para la operación 13 × 3, el producto acumulado pasa por los valores 0, 13 y 39.

**Evidencia:** `evidencias/multiplicador_ondas.png`

## 3. Verificación del divisor

### Arquitectura

El divisor trabaja con operandos sin signo de 32 bits y genera un cociente y un residuo de 32 bits.

Se implementó mediante restas, desplazamientos y restauración del residuo cuando una resta requiere préstamo.

El algoritmo realiza 33 iteraciones por división normal.

### Pruebas realizadas

Se verificaron 37 operaciones:

- 9 casos iniciales.
- 8 casos límite.
- 20 casos con operandos aleatorios.

Entre los casos principales se encuentran:

| Dividendo | Divisor | Cociente esperado | Residuo esperado |
|---|---|---|---|
| 13 | 3 | 4 | 1 |
| 100 | 10 | 10 | 0 |
| 0 | 7 | 0 | 0 |
| 7 | 9 | 0 | 7 |
| 4294967295 | 1 | 4294967295 | 0 |
| 4294967295 | 2 | 2147483647 | 1 |
| 2147483648 | 3 | 715827882 | 2 |

**Resultado:** Las 37 pruebas fueron superadas.

### Análisis de ondas

Durante la simulación se comprobó que:

- El divisor se desplaza hacia la derecha.
- La ALU realiza las restas parciales.
- El residuo se actualiza solamente cuando la resta es válida.
- El registro del cociente introduce los bits calculados.
- La señal `done` indica la finalización de las 33 iteraciones.

Para 13 ÷ 3, el circuito obtiene un cociente de 4 y un residuo de 1.

**Evidencia:** `evidencias/divisor_ondas.png`

## 4. División entre cero

Se implementó un mecanismo de detección de división entre cero.

Cuando el divisor es cero, el circuito:

- Activa `div_zero`.
- Finaliza sin ejecutar las 33 iteraciones.
- Devuelve cociente 0 y conserva el dividendo como residuo, según la convención definida para este diseño.

Se comprobó el caso 25 ÷ 0 mediante simulación.

**Evidencia:** `evidencias/division_cero.png`

## 5. Verificación independiente y trazabilidad

Los resultados matemáticos esperados se calcularon en los bancos de pruebas independientemente del procesamiento interno de los circuitos.

| Requisito | Implementación | Verificación |
|---|---|---|
| Multiplicación de 32 × 32 bits | `multiplicador32.sv` | `tb_multiplicador32.sv` |
| Producto de 64 bits | Registro producto y sumador | Pruebas con valores máximos |
| División de 32 bits | `divisor32.sv` | `tb_divisor32.sv` |
| Cociente y residuo | Registros y ALU del divisor | Comparaciones con `/` y `%` |
| Detección de división entre cero | `control_divisor.sv` | Caso 25 ÷ 0 |
| Funcionamiento secuencial | Unidades de control | Ondas y conteo de iteraciones |

## 6. Conclusión

Las simulaciones realizadas muestran que ambos circuitos cumplen los casos funcionales evaluados.

El multiplicador superó 6 pruebas y el divisor superó 37 pruebas, incluyendo operaciones con valores grandes y casos especiales.

Las formas de onda permiten observar el procesamiento secuencial, los cambios de los registros y las señales de finalización.

Los resultados respaldan la validez funcional de los diseños para los casos simulados.