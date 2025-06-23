# Trabajo Final Módulo 3 | SimpleSwap: Implementación de Exchange Descentralizado

## Descripción

SimpleSwap es un contrato inteligente que permite crear un exchange descentralizado básico entre dos tokens ERC-20. El usuario puede:

- Agregar y remover liquidez a un pool.
- Intercambiar tokens de forma directa.
- Consultar precios y calcular cantidades de salida antes de hacer swaps.

---

## Funciones principales

| Función                        | Descripción                                                                                |
|--------------------------------|--------------------------------------------------------------------------------------------|
| `addLiquidity`                 | Agrega liquidez al pool, transfiriendo tokens del usuario y emitiendo tokens de liquidez.  |
| `removeLiquidity`              | Retira liquidez, quema tokens de liquidez y devuelve los tokens proporcionales al usuario. |
| `swapExactTokensForTokens`     | Intercambia una cantidad exacta de tokens A por tokens B, calculando la cantidad a recibir.|
| `getPrice`                     | Retorna el precio actual de un token en términos del otro según las reservas.              |
| `getAmountOut`                 | Calcula cuántos tokens se recibirán al intercambiar una cantidad exacta de tokens.         |

---

## Variables principales

| Variable    | Descripción                         |
|-------------|-----------------------------------|
| `tokenA`    | Dirección del primer token del par.|
| `tokenB`    | Dirección del segundo token del par.|
| `reserveA`  | Reserva actual del token A en el pool.|
| `reserveB`  | Reserva actual del token B en el pool.|

---

## Uso Básico

1. Desplegar el contrato `SimpleSwap` con las direcciones de dos tokens ERC-20 distintos.
2. Llamar a `addLiquidity` para proveer tokens y recibir tokens de liquidez.
3. Usar `swapExactTokensForTokens` para intercambiar tokens dentro del pool.
4. Consultar precios con `getPrice` y cantidades a recibir con `getAmountOut`.
5. Remover liquidez con `removeLiquidity` cuando se quiera recuperar los tokens.

---

## Autor

Pedro Quirós — pedrobquiros@gmail.com
