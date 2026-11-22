# Proyecto Corto 2 — Especificación funcional

**Curso:** EL-3310 Diseño de Sistemas Digitales  
**Estado:** Especificación aprobada, implementada y verificada funcionalmente  
**Referencia:** Proyecto Corto 2, páginas 1–4, y capítulo 3 de *Computer Organization and Design — RISC-V* (Patterson y Hennessy).

## 1. Propósito

Implementar un multiplicador y un divisor secuenciales y modulares en SystemVerilog.

Los diseños se basan en los algoritmos y diagramas de datapath y control presentados en el enunciado del Proyecto Corto 2 y en el libro de referencia.

La implementación se desarrolla utilizando módulos independientes para los registros, las unidades aritméticas y las unidades de control.

El funcionamiento se verifica mediante bancos de pruebas independientes y simulaciones de formas de onda.

## 2. Multiplicación: comportamiento requerido

El multiplicador implementado presenta las siguientes características:

- Acepta dos operandos sin signo de **32 bits**.
- Genera un producto de **64 bits**.
- Inicializa el producto acumulado en cero al comenzar una operación.
- Utiliza el algoritmo de suma y desplazamiento.

### Algoritmo de multiplicación

1. Examinar el bit menos significativo del multiplicador.
2. Si el bit es 1, sumar el multiplicando desplazado al producto parcial.
3. Si el bit es 0, conservar el producto parcial.
4. Desplazar el multiplicando un bit hacia la izquierda.
5. Desplazar el multiplicador un bit hacia la derecha.
6. Repetir el proceso durante **32 iteraciones**.
7. Entregar el producto final de 64 bits.

Se realiza una iteración por ciclo de reloj durante el estado de procesamiento.

El resultado permanece estable durante el estado inactivo, salvo cuando se reinicia el circuito o comienza una nueva operación.

### Casos de referencia

| Operación | Resultado esperado |
|---|---:|
| 7 × 3 | 21 |
| 0 × 15 | 0 |
| 1 × 27 | 27 |
| 65535 × 65535 | 4294836225 |

## 3. División: comportamiento requerido

El divisor implementado presenta las siguientes características:

- Acepta un dividendo sin signo de 32 bits.
- Acepta un divisor sin signo de 32 bits.
- Genera un cociente de 32 bits.
- Genera un residuo de 32 bits.
- Emplea división secuencial con restauración.
- Realiza **33 iteraciones** por división normal.

### Algoritmo de división

1. Inicializar el registro del residuo con el dividendo.
2. Inicializar el registro del cociente en cero.
3. Cargar el divisor en la mitad superior de un registro de 64 bits.
4. Restar el divisor desplazado del residuo parcial.
5. Si la resta es válida, conservar la diferencia e introducir un bit 1 en el cociente.
6. Si la resta requiere préstamo, conservar el residuo anterior e introducir un bit 0.
7. Desplazar el divisor hacia la derecha.
8. Repetir durante 33 iteraciones y entregar el cociente y el residuo.

Para un divisor distinto de cero, los resultados deben cumplir:

`dividendo = cociente × divisor + residuo`

Con la condición:

`0 <= residuo < divisor`

### Casos de referencia

| Operación | Cociente | Residuo |
|---|---:|---:|
| 17 ÷ 5 | 3 | 2 |
| 20 ÷ 4 | 5 | 0 |
| 3 ÷ 7 | 0 | 3 |
| 13 ÷ 3 | 4 | 1 |

## 4. Interfaz y secuencia de operación aprobadas

Ambos circuitos utilizan una interfaz secuencial con las señales de control `clk`, `reset`, `start`, `busy` y `done`.

La unidad de división incorpora adicionalmente la señal `div_zero`.

### Secuencia de funcionamiento

1. **IDLE:** El circuito espera la activación de `start`.
2. **LOAD:** Se cargan los operandos y se inicializan los registros correspondientes.
3. **RUN:** Se ejecutan las iteraciones del algoritmo.
4. **DONE:** Se activa `done` durante un ciclo de reloj.
5. El circuito regresa a IDLE y puede aceptar una nueva operación.

Las solicitudes de inicio durante el procesamiento no producen una nueva operación.

Los operandos deben mantenerse estables hasta que se carguen en el estado LOAD.

El resultado calculado permanece almacenado hasta que comience una nueva operación o se aplique un reinicio.

## 5. Decisiones de diseño adoptadas

Las siguientes decisiones fueron revisadas y aprobadas antes de implementar los circuitos.

### 5.1 Representación numérica

Se utilizan operandos **sin signo (unsigned)** de 32 bits.

No se implementa procesamiento de números negativos mediante complemento a dos.

### 5.2 División entre cero

Cuando el divisor es cero:

- No se ejecutan las 33 iteraciones.
- Se activa la señal `div_zero` durante la finalización.
- El cociente se establece en cero.
- El residuo conserva el valor del dividendo.

Este comportamiento corresponde a una convención de diseño adoptada para el proyecto y no a un resultado matemático válido.

### 5.3 Latencia de procesamiento

El multiplicador ejecuta 32 iteraciones.

El divisor ejecuta 33 iteraciones para operaciones con divisor distinto de cero.

Cada iteración corresponde a un ciclo del reloj durante el estado RUN.

Los estados de inicialización y finalización requieren ciclos adicionales.

### 5.4 Reinicio

Se utiliza un reinicio síncrono, activo en alto, denominado `reset`.

Al activarlo, el circuito vuelve al estado inicial y se reinician los registros correspondientes.

### 5.5 Herramientas seleccionadas

La implementación y verificación se realizaron utilizando:

- Visual Studio Code.
- SystemVerilog.
- Icarus Verilog 12.0.
- GTKWave 3.3.100.
- Windows y PowerShell.

## 6. Verificación funcional

Los circuitos se verificaron mediante testbenches independientes, utilizando resultados matemáticos de referencia.

### Multiplicador

Se realizaron 6 pruebas funcionales, incluyendo:

- Multiplicaciones con operandos pequeños.
- Multiplicación por cero.
- Multiplicación por uno.
- Operaciones con valores grandes.
- Multiplicación de dos operandos con el valor máximo de 32 bits.

**Resultado: 6 pruebas superadas.**

### Divisor

Se realizaron 37 pruebas funcionales:

- 9 pruebas iniciales.
- 8 pruebas adicionales de casos límite.
- 20 pruebas con operandos aleatorios.

Se comprobaron divisiones exactas, operaciones con residuo, valores máximos, dividendos menores que el divisor y división entre cero.

**Resultado: 37 pruebas superadas.**

Las pruebas verificaron los resultados matemáticos, el conteo de iteraciones y las señales principales de control.

Las simulaciones de ondas permiten observar el comportamiento de los registros y las operaciones intermedias.

Queda como posible ampliación de verificación una prueba específica que mantenga `start` activado mientras el circuito está ocupado, para comprobar explícitamente el rechazo de nuevas solicitudes.

Las evidencias se encuentran en `docs/evidencias/` y el análisis detallado en `docs
