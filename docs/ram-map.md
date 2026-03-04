
| Address   | Name              | Size    | Description                          |
|-----------|-------------------|---------|--------------------------------------|
| 20H–27H   | TMP0..TMP7        | 8 bytes | General-purpose scratch registers    |
| 28H–2AH   | MEM0..MEM2        | 3 bytes | 24-bit signed memory register        |
| 2BH       | MEMSRC            | 1 byte  | Flag: MR was used (next digit clears)|
| 2CH       | MODEFLG           | 1 byte  | 0 = normal, 1 = function key layer   |
| 30H–32H   | CUR0..CUR2        | 3 bytes | Current input number (24-bit, LE)    |
| 35H       | CURCNT            | 1 byte  | Digit count (max 3)                  |
| 36H       | LASTTOK           | 1 byte  | Parser state token                   |
| 37H       | VALSP             | 1 byte  | Value stack pointer                  |
| 38H       | OPSP              | 1 byte  | Operator stack pointer               |
| 39H       | DIVFLAG           | 1 byte  | Set if last op was division          |
| 3AH–3CH   | LDIV0..LDIV2      | 3 bytes | Saved absolute divisor               |
| 3DH–3FH   | LREM0..LREM2      | 3 bytes | Saved absolute remainder             |
| 40H–5DH   | VALUE STACK       | 30 bytes| 10 × 3-byte 24-bit signed values     |
| 5EH–67H   | OP STACK          | 10 bytes| 10 × 1-byte ASCII operator chars     |
| 68H–6DH   | MULM0..MULM5      | 6 bytes | 48-bit multiplicand (shift register) |
| 6EH–73H   | ACC0..ACC5        | 6 bytes | 48-bit product accumulator           |
| 74H–79H   | DIVA0..DIVB2      | 6 bytes | Division operand scratch             |
| 7AH–7FH   | Print temps       | 6 bytes | Working area for PRINT_RES_24        |
