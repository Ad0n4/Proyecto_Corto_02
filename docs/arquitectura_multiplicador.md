# Proyecto Corto 02 — Arquitectura del multiplicador

**Estado:** borrador para revisión manual antes de implementar RTL.

## Objetivo y alcance

Implementar el multiplicador secuencial de la página 1 del enunciado mediante el algoritmo de suma y desplazamiento. Los dos operandos son enteros **sin signo de 32 bits** y el producto se representa en **64 bits**. El circuito realiza exactamente 32 iteraciones.

## Interfaz propuesta

| Señal | Dirección | Ancho | Descripción |
|---|---|---:|---|
| `clk` | Entrada | 1 | Reloj |
| `rst` | Entrada | 1 | Reinicio síncrono, activo en alto |
| `start` | Entrada | 1 | Solicita un cálculo cuando el circuito está libre |
| `multiplicando` | Entrada | 32 | Primer operando sin signo |
| `multiplicador` | Entrada | 32 | Segundo operando sin signo |
| `producto` | Salida | 64 | Resultado del cálculo, conservado hasta el próximo cálculo o reinicio |
| `busy` | Salida | 1 | Indica que las 32 iteraciones están en curso |
| `done` | Salida | 1 | Pulso de un ciclo al finalizar el cálculo |

## Bloques de datos

- **Registro del multiplicando:** 64 bits. Carga `{32'b0, multiplicando}` y se desplaza 1 bit a la izquierda por iteración.
- **Registro del multiplicador:** 32 bits. Carga `multiplicador` y se desplaza 1 bit a la derecha por iteración.
- **Registro del producto:** 64 bits. Inicia en cero y conserva la suma parcial.
- **Sumador:** 64 bits. Calcula `producto_reg + multiplicando_reg` únicamente cuando el bit menos significativo del multiplicador es 1.
- **Contador:** 6 bits, cuenta las 32 iteraciones (0 a 31).
- **Controlador:** administra inicialización, trabajo y señalización del final.

## Secuencia temporal

1. En reposo, `busy=0` y `done=0`; se mantiene el resultado anterior.
2. En un flanco ascendente con `start=1` estando libre, se cargan los operandos, se pone producto a cero y se inicia la operación.
3. En cada uno de los siguientes 32 flancos ascendentes:
   - Si `multiplicador_reg[0]` es 1, se suma el registro del multiplicando al producto.
   - Se desplaza `multiplicando_reg` a la izquierda 1 bit.
   - Se desplaza `multiplicador_reg` a la derecha 1 bit.
   - Se incrementa el contador.
4. Tras la iteración 32, `busy` pasa a 0 y `done` vale 1 durante un ciclo de reloj.
5. Se ignoran nuevos pulsos `start` durante `busy=1`.
6. El reinicio síncrono pone a cero registros, salida y señales de estado.

## Estados del control

- `IDLE`: espera `start` y carga registros.
- `RUN`: procesa exactamente 32 bits del multiplicador.
- `DONE`: anuncia el resultado mediante un pulso `done`, luego vuelve a `IDLE`.

La implementación puede fusionar la señalización `DONE` con el final del último ciclo `RUN`, siempre que respete el comportamiento externo aquí definido.

## Ejemplo manual

`13 × 3`:

| Iteración | Bit LSB | Multiplicando desplazado | Producto tras operación |
|---:|---:|---:|---:|
| 1 | 1 | 13 | 13 |
| 2 | 1 | 26 | 39 |
| 3–32 | 0 | 52, 104, ... | 39 |

Resultado final: `39`.

## Revisión humana requerida

Confirmar antes de generar RTL:

- [ ] Operandos sin signo (el enunciado no explicita tratamiento de negativos).
- [ ] Interfaz `clk`, `rst`, `start`, `multiplicando`, `multiplicador`, `producto`, `busy`, `done`.
- [ ] Reinicio síncrono y pulso `done` de un ciclo.
- [ ] 32 iteraciones, conforme a la figura del multiplicador.
- [ ] Se ignorará `start` si el circuito está ocupado.

## Verificación independiente prevista

Pruebas con cero, uno, `13×3=39`, casos con un bit encendido, valores máximos (`0xFFFFFFFF × 0xFFFFFFFF = 0xFFFFFFFE00000001`), pruebas aleatorias, y verificación de `busy`/`done` y de las 32 iteraciones. Captura de ondas de registros, contador y resultado.
