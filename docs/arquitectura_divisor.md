# Proyecto Corto 02 — Arquitectura propuesta del divisor

**Estado:** propuesta para revisión manual antes de implementar RTL.

## 1. Objetivo y alcance

Implementar en SystemVerilog un divisor **sin signo** de 32 bits, modular y secuencial, basado en el diagrama de la página 2 del enunciado (algoritmo de división con restauración y divisor desplazable). Dado un dividendo `A` y un divisor `B` no nulo, debe producir:

- Cociente de 32 bits `Q = floor(A / B)`.
- Residuo de 32 bits `R = A mod B`.
- Garantizar `A = B * Q + R` y `0 <= R < B`.

No se implementan operandos con signo en esta versión.

## 2. Interfaz propuesta

| Señal | Dirección | Ancho | Significado |
|---|---|---:|---|
| `clk` | Entrada | 1 | Reloj |
| `reset` | Entrada | 1 | Reset síncrono activo en alto |
| `start` | Entrada | 1 | Solicita una operación cuando el divisor está libre |
| `dividendo` | Entrada | 32 | Numerador sin signo |
| `divisor` | Entrada | 32 | Denominador sin signo |
| `cociente` | Salida | 32 | Resultado de división |
| `residuo` | Salida | 32 | Resto de división |
| `busy` | Salida | 1 | Operación en curso |
| `done` | Salida | 1 | Resultado disponible: pulso de un ciclo |
| `div_zero` | Salida | 1 | Se detectó división entre cero |

## 3. Módulos propuestos

1. **Registro divisor desplazable (64 bits):** carga `{divisor, 32'b0}` y se desplaza una posición a la derecha por iteración.
2. **ALU de resta y restauración (64 bits + bit de préstamo):** calcula la diferencia entre residuo actual (64 bits) y divisor desplazado; retiene el residuo anterior si la resta es negativa. Para decidir correctamente si hubo resta negativa, la operación se evalúa con un bit temporal adicional (65 bits en total), sin cambiar el ancho de los registros del esquema.
3. **Registro de residuo (64 bits):** carga el dividendo extendido a 64 bits y conserva el residuo restaurado o actualizado.
4. **Registro de cociente (32 bits):** inicia en cero y en cada iteración se desplaza a la izquierda e inserta `1` si la resta fue no negativa o `0` si fue negativa.
5. **Unidad de control:** máquina de estados IDLE → LOAD → RUN → DONE, con contador de 33 iteraciones.
6. **Módulo superior:** conecta los cinco elementos y expone los puertos.

## 4. Algoritmo y temporización

La implementación propuesta sigue el diagrama del proyecto de división con restauración:

- **IDLE:** espera `start`.
- **LOAD:** carga `R = {32'b0, dividendo}`, `D = {divisor, 32'b0}`, `Q = 0` y pone el contador en cero.
- **RUN, 33 iteraciones** (índices 0…32):
  1. Calcular una diferencia temporal `R - D`, con ancho suficiente para interpretar su signo.
  2. Si la diferencia no es negativa, actualizar `R` con la diferencia y desplazar `Q` a la izquierda insertando `1`.
  3. Si la diferencia es negativa, restaurar/conservar `R` y desplazar `Q` insertando `0`.
  4. Desplazar `D` a la derecha una posición.
- **DONE:** emitir `done` durante un ciclo, con `cociente` y `residuo` estables; regresar a IDLE.

Se realizan **33 iteraciones** porque el divisor empieza alineado en los bits superiores (`B << 32`); la primera comparación es un intento inicial que no añade un bit útil de cociente, y las otras 32 generan los bits de resultado.

**Observación del enunciado:** en el diagrama de la página 2, la decisión dice `33rd repetition`, mientras que dos flechas indican `65 repetitions`. Para esta arquitectura se interpreta que corresponden **33** iteraciones, consistente con el algoritmo de la figura y operandos de 32 bits. Se documentará esta interpretación en el informe.

## 5. Situaciones especiales y decisiones propuestas

- `divisor = 0`: no intentar la división; se propone `div_zero=1`, `cociente=0`, `residuo=dividendo` y un pulso de `done` sin completar la secuencia normal de 33 iteraciones. Esta política es una decisión de diseño y no aparece especificada en el enunciado.
- `dividendo = 0`, `divisor != 0`: cociente y residuo cero.
- `dividendo < divisor`: cociente cero y residuo igual al dividendo.
- `start` mientras `busy=1`: se ignora la solicitud; los operandos deben mantenerse estables hasta LOAD.
- Después de `done`, salidas estables hasta iniciar una operación nueva.
- `reset`: limpia registros y control.

## 6. Plan de verificación independiente

El testbench se derivará de estas reglas y no de las señales internas del RTL. Utilizará divisiones matemáticas **solo como referencia en el testbench** (`/` y `%`, nunca en el hardware sintetizable). Casos mínimos:

| Dividendo | Divisor | Cociente | Residuo |
|---:|---:|---:|---:|
| 13 | 3 | 4 | 1 |
| 100 | 7 | 14 | 2 |
| 0 | 5 | 0 | 0 |
| 7 | 19 | 0 | 7 |
| 4294967295 | 1 | 4294967295 | 0 |
| 4294967295 | 4294967295 | 1 | 0 |
| 123456789 | 321 | 384600 | 189 |
| 13 | 0 | 0 + error | 13 |

También se verificarán: contador y finalización, un único pulso de `done`, estabilidad de salidas, reset e intentos de `start` durante `busy`.

## 7. Revisión humana pendiente

Antes de codificar, revisar y aprobar:

1. Operación solo **sin signo** de 32 bits.
2. **33 iteraciones** conforme al rombo de la figura.
3. Política propuesta para **división entre cero**.
4. Interfaz `start`, `busy`, `done`, `div_zero` y reset síncrono.

---

**Referencia:** Proyecto Corto 02, página 2 (esquema y diagrama de flujo del divisor) y páginas 3–4 (marco de diseño RTL con revisión humana).
