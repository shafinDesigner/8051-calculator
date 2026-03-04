# How the Calculator Works

## Expression Parsing — Shunting-Yard Algorithm

The calculator uses Dijkstra's Shunting-Yard algorithm to evaluate
expressions with correct operator precedence. Two stacks stored in
internal 8051 RAM handle this:

- **Value Stack** — holds numeric operands (24-bit, up to 10 deep)
- **Operator Stack** — holds operator characters (up to 10 deep)

### Precedence Rules
| Operator  | Precedence |
|-----------|-----------|
| `+` `-`   | 1 (low)   |
| `*` `/` `%` | 2 (high) |
| `(`       | 0 (wall)  |

### Example: 3 + 4 * 2
```
Press 3  → VALUE: [3]          OP: []
Press +  → VALUE: [3]          OP: [+]
Press 4  → VALUE: [3,4]        OP: [+]
Press *  → prec(*) > prec(+)
           VALUE: [3,4]        OP: [+,*]
Press 2  → VALUE: [3,4,2]      OP: [+,*]
Press =  → apply *: 4*2=8  → VALUE: [3,8]  OP: [+]
           apply +: 3+8=11 → VALUE: [11]   OP: []
Result = 11 ✓
```

## 24-Bit Signed Arithmetic

All numbers are stored as 3-byte little-endian signed integers
(CUR0, CUR1, CUR2). This gives a range of **−8,388,608 to +8,388,607**.

- **Multiply** — 24-cycle bit-shift loop with 48-bit accumulator
- **Divide** — sign extraction → unsigned long division → re-apply sign
- **Negative** — two's complement applied on the 3-byte value

## Keypad Scanning

The 4×4 keypad is scanned using column-drive, row-read:
1. Drive P3.0 LOW → read P3.4–P3.7 → detects row A keys (7, 8, 9, ÷)
2. Drive P3.1 LOW → read P3.4–P3.7 → detects row B keys (4, 5, 6, ×)
3. Drive P3.2 LOW → read P3.4–P3.7 → detects row C keys (1, 2, 3, −)
4. Drive P3.3 LOW → read P3.4–P3.7 → detects row D keys (ON/C, 0, =, +)

## Memory System

A dedicated 24-bit signed register at RAM 28H–2AH stores the memory value.
- **M+** — signed add: MEM = MEM + CUR
- **M−** — signed subtract: MEM = MEM − CUR
- **MR** — copy MEM → CUR, set MEMSRC flag
- **MC** — zero out MEM0, MEM1, MEM2
