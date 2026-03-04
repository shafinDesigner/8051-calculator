RS      EQU P2.1
EN      EQU P2.2
MODE_KEY  EQU P2.3
MMIN_KEY  EQU P2.4
MR_KEY    EQU P2.5
MC_KEY    EQU P2.6

CUR0    EQU 30H
CUR1    EQU 31H
CUR2    EQU 32H
CURCNT  EQU 35H
LASTTOK EQU 36H
VALSP   EQU 37H
OPSP    EQU 38H
DIVFLAG EQU 39H
LDIV0   EQU 3AH
LDIV1   EQU 3BH
LDIV2   EQU 3CH
LREM0   EQU 3DH
LREM1   EQU 3EH
LREM2   EQU 3FH

TMP0    EQU 20H
TMP1    EQU 21H
TMP2    EQU 22H
TMP3    EQU 23H
TMP4    EQU 24H
TMP5    EQU 25H
TMP6    EQU 26H
TMP7    EQU 27H

VALBASE EQU 40H
OPBASE  EQU 5EH
MAXV    EQU 10
MAXO    EQU 10

MULM0   EQU 68H
MULM1   EQU 69H
MULM2   EQU 6AH
MULM3   EQU 6BH
MULM4   EQU 6CH
MULM5   EQU 6DH
ACC0    EQU 6EH
ACC1    EQU 6FH
ACC2    EQU 70H
ACC3    EQU 71H
ACC4    EQU 72H
ACC5    EQU 73H

MEM0    EQU 28H
MEM1    EQU 29H
MEM2    EQU 2AH
MEMSRC  EQU 2BH
MODEFLG EQU 2CH

DIVA0   EQU 74H
DIVA1   EQU 75H
DIVA2   EQU 76H
DIVB0   EQU 77H
DIVB1   EQU 78H
DIVB2   EQU 79H

            ORG 0000H
            LJMP START

            ORG 0100H
MSG_START:  DB 'BASIC CALCULATOR',0
MSG_ERR0:   DB 'ERROR: DIV BY 0',0
MSG_ERR1:   DB 'OVERFLOW!',0
MSG_ERR3:   DB 'ERR:3DIG',0
MSG_ERRB:   DB 'BRACKET ERR',0
SQRT_TAB:   DB 0,1,1,1,2,2,2,2,2,3
DIVTAB:
            DB 080H,096H,098H
            DB 040H,042H,00FH
            DB 0A0H,086H,001H
            DB 010H,027H,000H
            DB 0E8H,003H,000H
            DB 064H,000H,000H
            DB 00AH,000H,000H
            DB 001H,000H,000H

            ORG 0200H

START:      LCALL INITIALYZE

L1:
            JNB  MODE_KEY, MODE_STUB
            JNB  MMIN_KEY, MMIN_STUB
            JNB  MR_KEY,   MR_STUB
            JNB  MC_KEY,   MC_STUB
            JNB  P3.0, C1
            JNB  P3.1, C2
            JNB  P3.2, C3
            JNB  P3.3, C4
            SJMP L1

MODE_STUB:  LJMP TOGGLE_MODE
MMIN_STUB:  LJMP DO_MMINUS
MR_STUB:    LJMP DO_MR
MC_STUB:    LJMP DO_MC

TOGGLE_MODE:
            JNB  MODE_KEY, TOGGLE_MODE
            LCALL SMALL_DELAY
            MOV  A, MODEFLG
            XRL  A, #01H
            MOV  MODEFLG, A
            LJMP L1

C1:
            JNB  P3.4, JUMP_TO_7
            JNB  P3.5, JUMP_TO_4
            JNB  P3.6, JUMP_TO_1
            JNB  P3.7, JUMP_CLR
            SETB P3.0
            CLR  P3.1
            SJMP L1

C2:
            JNB  P3.4, JUMP_TO_8
            JNB  P3.5, JUMP_TO_5
            JNB  P3.6, JUMP_TO_2
            JNB  P3.7, JUMP_TO_0
            SETB P3.1
            CLR  P3.2
            SJMP L1

C3:
            JNB  P3.4, JUMP_TO_9
            JNB  P3.5, JUMP_TO_6
            JNB  P3.6, JUMP_TO_3
            JNB  P3.7, JUMP_EQUAL
            SETB P3.2
            CLR  P3.3
            SJMP L1

C4:
            JNB  P3.4, JUMP_DIV
            JNB  P3.5, JUMP_MUL
            JNB  P3.6, JUMP_SUB
            JNB  P3.7, JUMP_ADD
            SETB P3.3
            CLR  P3.0
            LJMP L1

JUMP_CLR:   LJMP CLEAR_ALL
JUMP_TO_0:  LJMP NUM_0
JUMP_TO_1:  LJMP NUM_1
JUMP_TO_2:  LJMP NUM_2
JUMP_TO_3:  LJMP NUM_3
JUMP_TO_4:  LJMP NUM_4
JUMP_TO_5:  LJMP NUM_5
JUMP_TO_6:  LJMP NUM_6
JUMP_TO_7:  LJMP NUM_7
JUMP_TO_8:  LJMP NUM_8
JUMP_TO_9:  LJMP NUM_9
JUMP_ADD:   LJMP ADD_FUNC
JUMP_SUB:   LJMP SUB_FUNC
JUMP_MUL:   LJMP MUL_FUNC
JUMP_DIV:   LJMP DIV_FUNC
JUMP_EQUAL: LJMP EQU_FUNC

CLEAR_ALL:
            MOV  R0, #01H
            LCALL COMMAND
            MOV  CUR0,  #00H
            MOV  CUR1,  #00H
            MOV  CUR2,  #00H
            MOV  CURCNT,#00H
            MOV  LASTTOK,#00H
            MOV  VALSP, #00H
            MOV  OPSP,  #00H
            MOV  DIVFLAG,#00H
            LJMP L1

; ---- Number keys ----
NUM_0:  JNB P3.7,NUM_0
        MOV A,MODEFLG
        JZ  N0N
        LJMP DO_RPAREN_CORE
N0N:    MOV R0,#'0'
        LCALL ASCII_2_DEC
        LCALL DISPLAY
        LJMP L1

NUM_1:  JNB P3.6,NUM_1
        MOV A,MODEFLG
        JZ  N1N
        LJMP DO_MR_CORE
N1N:    MOV R0,#'1'
        LCALL ASCII_2_DEC
        LCALL DISPLAY
        LJMP L1

NUM_2:  JNB P3.6,NUM_2
        MOV A,MODEFLG
        JZ  N2N
        LJMP DO_MC_CORE
N2N:    MOV R0,#'2'
        LCALL ASCII_2_DEC
        LCALL DISPLAY
        LJMP L1

NUM_3:  JNB P3.6,NUM_3
        MOV A,MODEFLG
        JZ  N3N
        LJMP DO_MPLUS_CORE
N3N:    MOV R0,#'3'
        LCALL ASCII_2_DEC
        LCALL DISPLAY
        LJMP L1

NUM_4:  JNB P3.5,NUM_4
        MOV A,MODEFLG
        JZ  N4N
        LJMP DO_MMINUS_CORE
N4N:    MOV R0,#'4'
        LCALL ASCII_2_DEC
        LCALL DISPLAY
        LJMP L1

NUM_5:  JNB P3.5,NUM_5
        MOV A,MODEFLG
        JZ  N5N
        LJMP DO_PERCENT_CORE
N5N:    MOV R0,#'5'
        LCALL ASCII_2_DEC
        LCALL DISPLAY
        LJMP L1

NUM_6:  JNB P3.5,NUM_6
        MOV A,MODEFLG
        JZ  N6N
        LJMP DO_ROOT_CORE
N6N:    MOV R0,#'6'
        LCALL ASCII_2_DEC
        LCALL DISPLAY
        LJMP L1

NUM_7:  JNB P3.4,NUM_7
        MOV A,MODEFLG
        JZ  N7N
        LJMP DO_SQUARE_CORE
N7N:    MOV R0,#'7'
        LCALL ASCII_2_DEC
        LCALL DISPLAY
        LJMP L1

NUM_8:  JNB P3.4,NUM_8
        MOV A,MODEFLG
        JZ  N8N
        LJMP DO_CUBE_CORE
N8N:    MOV R0,#'8'
        LCALL ASCII_2_DEC
        LCALL DISPLAY
        LJMP L1

NUM_9:  JNB P3.4,NUM_9
        MOV A,MODEFLG
        JZ  N9N
        LJMP DO_LPAREN_CORE
N9N:    MOV R0,#'9'
        LCALL ASCII_2_DEC
        LCALL DISPLAY
        LJMP L1

; ---- Operators ----
EQU_FUNC:
        JNB P3.7,EQU_FUNC
        MOV R0,#'='
        LCALL DISPLAY
        LCALL EVAL_EQUAL
        LJMP L1

ADD_FUNC:
        JNB P3.7,ADD_FUNC
        MOV R0,#'+'
        LCALL DISPLAY
        MOV A,#'+'
        LCALL HANDLE_OPERATOR
        LJMP L1

SUB_FUNC:
        JNB P3.6,SUB_FUNC
        MOV R0,#'-'
        LCALL DISPLAY
        MOV A,#'-'
        LCALL HANDLE_OPERATOR
        LJMP L1

MUL_FUNC:
        JNB P3.5,MUL_FUNC
        MOV R0,#'*'
        LCALL DISPLAY
        MOV A,#'*'
        LCALL HANDLE_OPERATOR
        LJMP L1

DIV_FUNC:
        JNB P3.4,DIV_FUNC
        MOV R0,#'/'
        LCALL DISPLAY
        MOV A,#'/'
        LCALL HANDLE_OPERATOR
        LJMP L1

; ---- ASCII to decimal (build CUR) ----
ASCII_2_DEC:
        MOV A,MEMSRC
        JZ  AD_CONT
        MOV MEMSRC,#00H
        MOV CUR0,#00H
        MOV CUR1,#00H
        MOV CUR2,#00H
        MOV CURCNT,#00H
AD_CONT:
        MOV A,CURCNT
        CJNE A,#03H,AD_OK
        LCALL ERR_3DIG
        RET
AD_OK:  INC CURCNT
        CLR C
        MOV A,R0
        SUBB A,#30H
        MOV TMP0,A
        ; CUR*2 -> TMP1..3
        MOV A,CUR0
        ADD A,CUR0
        MOV TMP1,A
        MOV A,CUR1
        ADDC A,CUR1
        MOV TMP2,A
        MOV A,CUR2
        ADDC A,CUR2
        MOV TMP3,A
        ; CUR*8 -> TMP4..6 (shift left 3)
        MOV TMP4,CUR0
        MOV TMP5,CUR1
        MOV TMP6,CUR2
        CLR C
        MOV A,TMP4
        RLC A
        MOV TMP4,A
        MOV A,TMP5
        RLC A
        MOV TMP5,A
        MOV A,TMP6
        RLC A
        MOV TMP6,A
        CLR C
        MOV A,TMP4
        RLC A
        MOV TMP4,A
        MOV A,TMP5
        RLC A
        MOV TMP5,A
        MOV A,TMP6
        RLC A
        MOV TMP6,A
        CLR C
        MOV A,TMP4
        RLC A
        MOV TMP4,A
        MOV A,TMP5
        RLC A
        MOV TMP5,A
        MOV A,TMP6
        RLC A
        MOV TMP6,A
        ; CUR = CUR*8 + CUR*2 + digit
        CLR C
        MOV A,TMP4
        ADD A,TMP1
        MOV CUR0,A
        MOV A,TMP5
        ADDC A,TMP2
        MOV CUR1,A
        MOV A,TMP6
        ADDC A,TMP3
        MOV CUR2,A
        CLR C
        MOV A,CUR0
        ADD A,TMP0
        MOV CUR0,A
        MOV A,CUR1
        ADDC A,#00H
        MOV CUR1,A
        MOV A,CUR2
        ADDC A,#00H
        MOV CUR2,A
        MOV LASTTOK,#01H
        RET

; ---- Push CUR to value stack if entry pending ----
PUSH_CUR_IF_ANY:
        MOV A,CURCNT
        JNZ PCC_PUSH
        MOV A,MEMSRC
        JZ  PCC_DONE
PCC_PUSH:
        LCALL VAL_PUSH_CUR
        MOV CUR0,#00H
        MOV CUR1,#00H
        MOV CUR2,#00H
        MOV CURCNT,#00H
        MOV MEMSRC,#00H
PCC_DONE:
        RET

; ---- '(' handler ----
DO_LPAREN_CORE:
        MOV A,LASTTOK
        CJNE A,#01H,LP_CHK2
        MOV A,#'*'
        LCALL HANDLE_OPERATOR
        SJMP LP_GO
LP_CHK2:
        CJNE A,#02H,LP_GO
        MOV A,#'*'
        LCALL HANDLE_OPERATOR
LP_GO:
        MOV A,#'('
        LCALL OP_PUSH
        MOV LASTTOK,#00H
        MOV R0,#'('
        LCALL DISPLAY
        LJMP L1

; ---- '%' handler ----
DO_PERCENT_CORE:
        MOV R0,#'%'
        LCALL DISPLAY
        MOV A,#'%'
        LCALL HANDLE_OPERATOR
        LJMP L1

; ---- GET active value into TMP ----
GET_ACTIVE_VALUE_TO_TMP:
        MOV TMP0,CUR0
        MOV TMP1,CUR1
        MOV TMP2,CUR2
        RET

; ---- 24-bit signed MEM = MEM + TMP ----
ADD24_SIGNED_MEM_TMP:
        MOV A,MEM2
        ANL A,#80H
        MOV TMP4,A
        MOV A,TMP2
        ANL A,#80H
        MOV TMP5,A
        CLR C
        MOV A,MEM0
        ADD A,TMP0
        MOV TMP6,A
        MOV A,MEM1
        ADDC A,TMP1
        MOV B,A
        MOV A,MEM2
        ADDC A,TMP2
        MOV R7,A
        MOV A,TMP4
        XRL A,TMP5
        JNZ ADDS_NO_OVCHK
        MOV A,R7
        ANL A,#80H
        XRL A,TMP4
        JZ  ADDS_NO_OVCHK
        LCALL ERR_OVER
        RET
ADDS_NO_OVCHK:
        MOV MEM0,TMP6
        MOV MEM1,B
        MOV MEM2,R7
        RET

; ---- M+ ----
DO_MPLUS_CORE:
        LCALL GET_ACTIVE_VALUE_TO_TMP
        LCALL ADD24_SIGNED_MEM_TMP
        LJMP L1

; ---- M- ----
DO_MMINUS:
        JNB  MMIN_KEY, DO_MMINUS
DO_MMINUS_CORE:
        LCALL GET_ACTIVE_VALUE_TO_TMP
        MOV DIVB0,MEM0
        MOV DIVB1,MEM1
        MOV DIVB2,MEM2
        MOV DIVA0,TMP0
        MOV DIVA1,TMP1
        MOV DIVA2,TMP2
        LCALL SUB24_SIGNED
        MOV MEM0,TMP0
        MOV MEM1,TMP1
        MOV MEM2,TMP2
        LJMP L1

; ---- MR ----
DO_MR:
        JNB  MR_KEY, DO_MR
DO_MR_CORE:
        MOV CUR0,MEM0
        MOV CUR1,MEM1
        MOV CUR2,MEM2
        MOV CURCNT,#00H
        MOV MEMSRC,#01H
        MOV LASTTOK,#01H
        MOV R0,#080H
        LCALL COMMAND
        MOV 40H,CUR0
        MOV 41H,CUR1
        MOV 42H,CUR2
        LCALL PRINT_RES_24_SIGNED
        LJMP L1

; ---- MC ----
DO_MC:
        JNB  MC_KEY, DO_MC
DO_MC_CORE:
        MOV MEM0,#00H
        MOV MEM1,#00H
        MOV MEM2,#00H
        MOV MEMSRC,#00H
        LJMP L1

; ---- ')' handler ----
DO_RPAREN_CORE:
        LCALL PUSH_CUR_IF_ANY
        LCALL CLOSE_PAREN
        MOV LASTTOK,#02H
        MOV R0,#')'
        LCALL DISPLAY
        LJMP L1

; ---- Operator handler (shunting-yard) ----
HANDLE_OPERATOR:
        MOV TMP7,A
        LCALL PUSH_CUR_IF_ANY
        MOV A,LASTTOK
        CJNE A,#00H,HO_NORM
        MOV A,TMP7
        CJNE A,#'-',HO_NORM
        MOV CUR0,#00H
        MOV CUR1,#00H
        MOV CUR2,#00H
        MOV CURCNT,#01H
        LCALL VAL_PUSH_CUR
        MOV CURCNT,#00H
HO_NORM:
HO_WHILE:
        LCALL OP_TOP
        JZ   HO_PUSHNEW
        MOV TMP6,A
        CJNE A,#'(',HO_PREC
        SJMP HO_PUSHNEW
HO_PREC:
        MOV A,TMP6
        LCALL PREC
        MOV TMP5,A
        MOV A,TMP7
        LCALL PREC
        MOV TMP4,A
        MOV A,TMP5
        CLR C
        SUBB A,TMP4
        JC  HO_PUSHNEW
        LCALL APPLY_TOP_OP
        SJMP HO_WHILE
HO_PUSHNEW:
        MOV A,TMP7
        LCALL OP_PUSH
        MOV LASTTOK,#00H
        RET

; ---- '=' evaluation ----
EVAL_EQUAL:
        LCALL PUSH_CUR_IF_ANY
        MOV DIVFLAG,#00H
EQ_LOOP:
        LCALL OP_TOP
        JZ   EQ_DONE
        CJNE A,#'(',EQ_AP
        LCALL ERR_BRACKET
        RET
EQ_AP:  LCALL APPLY_TOP_OP
        SJMP EQ_LOOP
EQ_DONE:
        MOV A,VALSP
        CJNE A,#01H,EQ_BAD
        LCALL VAL_POP_TO_T
        MOV CUR0,TMP0
        MOV CUR1,TMP1
        MOV CUR2,TMP2
        MOV R0,#0C0H
        LCALL COMMAND
        MOV 40H,CUR0
        MOV 41H,CUR1
        MOV 42H,CUR2
        LCALL PRINT_RES_24_SIGNED
        MOV A,DIVFLAG
        ANL A,#01H
        JZ  EQ_RET
        MOV A,LREM0
        ORL A,LREM1
        ORL A,LREM2
        JZ  EQ_RET
        MOV R0,#'.'
        LCALL DISPLAY
        LCALL DIV_DECIMAL_1DIG_24
        ADD A,#30H
        MOV R0,A
        LCALL DISPLAY
EQ_RET: RET
EQ_BAD: LCALL ERR_OVER
        RET

; ---- Close parenthesis ----
CLOSE_PAREN:
CP_LOOP:
        LCALL OP_TOP
        JZ   CP_ERR
        CJNE A,#'(',CP_AP
        LCALL OP_POP
        RET
CP_AP:  LCALL APPLY_TOP_OP
        SJMP CP_LOOP
CP_ERR: LCALL ERR_BRACKET
        RET

; ---- Precedence ----
PREC:
        CJNE A,#'+',PRC2
        MOV A,#01H
        RET
PRC2:   CJNE A,#'-',PRC3
        MOV A,#01H
        RET
PRC3:   CJNE A,#'*',PRC4
        MOV A,#02H
        RET
PRC4:   CJNE A,#'/',PRC4B
        MOV A,#02H
        RET
PRC4B:  CJNE A,#'%',PRC5
        MOV A,#02H
        RET
PRC5:   MOV A,#00H
        RET

; ---- Apply top operator ----
APPLY_TOP_OP:
        LCALL OP_POP
        MOV TMP7,A
        LCALL VAL_POP_TO_T
        MOV DIVA0,TMP0
        MOV DIVA1,TMP1
        MOV DIVA2,TMP2
        LCALL VAL_POP_TO_T
        MOV DIVB0,TMP0
        MOV DIVB1,TMP1
        MOV DIVB2,TMP2
        MOV A,TMP7
        CJNE A,#'+',ATO_SUB
        MOV TMP0,DIVB0
        MOV TMP1,DIVB1
        MOV TMP2,DIVB2
        LCALL ADD24_ABS
        JNC ATO_PUSH
        LCALL ERR_OVER
        RET
ATO_SUB:
        CJNE A,#'-',ATO_MUL
        LCALL SUB24_SIGNED
        SJMP ATO_PUSH
ATO_MUL:
        CJNE A,#'*',ATO_PCT
        LCALL MUL24x24_TO24
        JNC ATO_PUSH
        LCALL ERR_OVER
        RET
ATO_PCT:
        CJNE A,#'%',ATO_DIV
        LCALL MUL24x24_TO24
        JNC PCT_DIV100
        LCALL ERR_OVER
        RET
PCT_DIV100:
        MOV DIVA0,TMP0
        MOV DIVA1,TMP1
        MOV DIVA2,TMP2
        MOV DIVB0,#064H
        MOV DIVB1,#00H
        MOV DIVB2,#00H
        LCALL DIV24U_BY24U
        SJMP ATO_PUSH
ATO_DIV:
        MOV A,DIVA0
        ORL A,DIVA1
        ORL A,DIVA2
        JNZ DIV_OK
        LCALL ERR_DIV0
        RET
DIV_OK:
        LCALL DIV24_BY24_SIGNED
        JNC DIV_OK2
        LCALL ERR_DIV0
        RET
DIV_OK2:
        ORL DIVFLAG,#01H
ATO_PUSH:
        LCALL VAL_PUSH_T
        RET

; ---- 24-bit add (unsigned) ----
ADD24_ABS:
        CLR C
        MOV A,TMP0
        ADD A,DIVA0
        MOV TMP0,A
        MOV A,TMP1
        ADDC A,DIVA1
        MOV TMP1,A
        MOV A,TMP2
        ADDC A,DIVA2
        MOV TMP2,A
        RET

; ---- 24-bit subtract signed (a-b) a=DIVB b=DIVA -> TMP ----
SUB24_SIGNED:
        CLR C
        MOV A,DIVB0
        SUBB A,DIVA0
        MOV TMP0,A
        MOV A,DIVB1
        SUBB A,DIVA1
        MOV TMP1,A
        MOV A,DIVB2
        SUBB A,DIVA2
        MOV TMP2,A
        RET

; ---- 24x24 multiply -> TMP (CY=1 overflow) ----
MUL24x24_TO24:
        MOV MULM0,DIVB0
        MOV MULM1,DIVB1
        MOV MULM2,DIVB2
        MOV MULM3,#00H
        MOV MULM4,#00H
        MOV MULM5,#00H
        MOV ACC0,#00H
        MOV ACC1,#00H
        MOV ACC2,#00H
        MOV ACC3,#00H
        MOV ACC4,#00H
        MOV ACC5,#00H
        MOV R5,#24
M24_LOOP:
        MOV A,DIVA0
        ANL A,#01H
        JZ  M24_SKIPADD
        CLR C
        MOV A,ACC0
        ADD A,MULM0
        MOV ACC0,A
        MOV A,ACC1
        ADDC A,MULM1
        MOV ACC1,A
        MOV A,ACC2
        ADDC A,MULM2
        MOV ACC2,A
        MOV A,ACC3
        ADDC A,MULM3
        MOV ACC3,A
        MOV A,ACC4
        ADDC A,MULM4
        MOV ACC4,A
        MOV A,ACC5
        ADDC A,MULM5
        MOV ACC5,A
M24_SKIPADD:
        CLR C
        MOV A,MULM0
        RLC A
        MOV MULM0,A
        MOV A,MULM1
        RLC A
        MOV MULM1,A
        MOV A,MULM2
        RLC A
        MOV MULM2,A
        MOV A,MULM3
        RLC A
        MOV MULM3,A
        MOV A,MULM4
        RLC A
        MOV MULM4,A
        MOV A,MULM5
        RLC A
        MOV MULM5,A
        CLR C
        MOV A,DIVA2
        RRC A
        MOV DIVA2,A
        MOV A,DIVA1
        RRC A
        MOV DIVA1,A
        MOV A,DIVA0
        RRC A
        MOV DIVA0,A
        DJNZ R5,M24_LOOP
        MOV A,ACC3
        ORL A,ACC4
        ORL A,ACC5
        JZ  M24_OK
        SETB C
        RET
M24_OK:
        MOV TMP0,ACC0
        MOV TMP1,ACC1
        MOV TMP2,ACC2
        CLR C
        RET

; ---- Signed 24/24 division ----
DIV24_BY24_SIGNED:
        MOV A,DIVA0
        ORL A,DIVA1
        ORL A,DIVA2
        JNZ DOK
        SETB C
        RET
DOK:
        MOV LDIV0,DIVA0
        MOV LDIV1,DIVA1
        MOV LDIV2,DIVA2
        MOV A,DIVB2
        ANL A,#80H
        MOV TMP4,A
        MOV A,DIVA2
        ANL A,#80H
        MOV TMP5,A
        MOV DIVA0,DIVB0
        MOV DIVA1,DIVB1
        MOV DIVA2,DIVB2
        MOV A,TMP4
        JZ  ABS_A_DONE
        LCALL TWOSCOMP_24_DIVA
ABS_A_DONE:
        MOV DIVB0,LDIV0
        MOV DIVB1,LDIV1
        MOV DIVB2,LDIV2
        MOV A,TMP5
        JZ  ABS_B_DONE
        LCALL TWOSCOMP_24_DIVB
ABS_B_DONE:
        LCALL DIV24U_BY24U
        MOV A,TMP4
        XRL A,TMP5
        ANL A,#80H
        JZ  DIV_SIGN_DONE
        LCALL TWOSCOMP_24_TMP
DIV_SIGN_DONE:
        CLR C
        RET

; ---- Two's complement helpers ----
TWOSCOMP_24_DIVA:
        CPL DIVA0
        CPL DIVA1
        CPL DIVA2
        CLR C
        MOV A,DIVA0
        ADD A,#01H
        MOV DIVA0,A
        MOV A,DIVA1
        ADDC A,#00H
        MOV DIVA1,A
        MOV A,DIVA2
        ADDC A,#00H
        MOV DIVA2,A
        RET

TWOSCOMP_24_DIVB:
        CPL DIVB0
        CPL DIVB1
        CPL DIVB2
        CLR C
        MOV A,DIVB0
        ADD A,#01H
        MOV DIVB0,A
        MOV A,DIVB1
        ADDC A,#00H
        MOV DIVB1,A
        MOV A,DIVB2
        ADDC A,#00H
        MOV DIVB2,A
        RET

TWOSCOMP_24_TMP:
        CPL TMP0
        CPL TMP1
        CPL TMP2
        CLR C
        MOV A,TMP0
        ADD A,#01H
        MOV TMP0,A
        MOV A,TMP1
        ADDC A,#00H
        MOV TMP1,A
        MOV A,TMP2
        ADDC A,#00H
        MOV TMP2,A
        RET

; ---- Unsigned 24/24 division ----
DIV24U_BY24U:
        MOV TMP0,#00H
        MOV TMP1,#00H
        MOV TMP2,#00H
        MOV LREM0,#00H
        MOV LREM1,#00H
        MOV LREM2,#00H
        MOV R5,#24
D24U_LOOP:
        CLR C
        MOV A,TMP0
        RLC A
        MOV TMP0,A
        MOV A,TMP1
        RLC A
        MOV TMP1,A
        MOV A,TMP2
        RLC A
        MOV TMP2,A
        CLR C
        MOV A,DIVA0
        RLC A
        MOV DIVA0,A
        MOV A,DIVA1
        RLC A
        MOV DIVA1,A
        MOV A,DIVA2
        RLC A
        MOV DIVA2,A
        MOV A,LREM0
        RLC A
        MOV LREM0,A
        MOV A,LREM1
        RLC A
        MOV LREM1,A
        MOV A,LREM2
        RLC A
        MOV LREM2,A
        LCALL CMP_R_GE_DIV
        JC  D24U_NOSUB
        CLR C
        MOV A,LREM0
        SUBB A,DIVB0
        MOV LREM0,A
        MOV A,LREM1
        SUBB A,DIVB1
        MOV LREM1,A
        MOV A,LREM2
        SUBB A,DIVB2
        MOV LREM2,A
        ORL TMP0,#01H
D24U_NOSUB:
        DJNZ R5,D24U_LOOP
        RET

CMP_R_GE_DIV:
        MOV A,LREM2
        CLR C
        SUBB A,DIVB2
        JC  CR_LT
        JNZ CR_GE
        MOV A,LREM1
        CLR C
        SUBB A,DIVB1
        JC  CR_LT
        JNZ CR_GE
        MOV A,LREM0
        CLR C
        SUBB A,DIVB0
        JC  CR_LT
CR_GE:  CLR C
        RET
CR_LT:  SETB C
        RET

; ---- One decimal digit after division ----
DIV_DECIMAL_1DIG_24:
        MOV A,LDIV0
        ORL A,LDIV1
        ORL A,LDIV2
        JNZ DDOK
        MOV A,#00H
        RET
DDOK:
        MOV DIVB0,LREM0
        MOV DIVB1,LREM1
        MOV DIVB2,LREM2
        CLR C
        MOV A,DIVB0
        RLC A
        MOV DIVB0,A
        MOV A,DIVB1
        RLC A
        MOV DIVB1,A
        MOV A,DIVB2
        RLC A
        MOV DIVB2,A
        MOV DIVA0,LREM0
        MOV DIVA1,LREM1
        MOV DIVA2,LREM2
        MOV R5,#03
DD_SH3:
        CLR C
        MOV A,DIVA0
        RLC A
        MOV DIVA0,A
        MOV A,DIVA1
        RLC A
        MOV DIVA1,A
        MOV A,DIVA2
        RLC A
        MOV DIVA2,A
        DJNZ R5,DD_SH3
        CLR C
        MOV A,DIVA0
        ADD A,DIVB0
        MOV DIVA0,A
        MOV A,DIVA1
        ADDC A,DIVB1
        MOV DIVA1,A
        MOV A,DIVA2
        ADDC A,DIVB2
        MOV DIVA2,A
        MOV DIVB0,LDIV0
        MOV DIVB1,LDIV1
        MOV DIVB2,LDIV2
        MOV A,#00H
        MOV TMP6,A
DD_SUBLOOP:
        LCALL CMP_DIVA_LT_DIVB
        JC  DD_DONE
        CLR C
        MOV A,DIVA0
        SUBB A,DIVB0
        MOV DIVA0,A
        MOV A,DIVA1
        SUBB A,DIVB1
        MOV DIVA1,A
        MOV A,DIVA2
        SUBB A,DIVB2
        MOV DIVA2,A
        INC TMP6
        MOV A,TMP6
        CJNE A,#0AH,DD_SUBLOOP
DD_DONE:
        MOV A,TMP6
        RET

CMP_DIVA_LT_DIVB:
        MOV A,DIVA2
        CLR C
        SUBB A,DIVB2
        JC  CDL_LT
        JNZ CDL_GE
        MOV A,DIVA1
        CLR C
        SUBB A,DIVB1
        JC  CDL_LT
        JNZ CDL_GE
        MOV A,DIVA0
        CLR C
        SUBB A,DIVB0
        JC  CDL_LT
CDL_GE: CLR C
        RET
CDL_LT: SETB C
        RET

; ---- Value stack ----
VAL_PUSH_CUR:
        MOV A,VALSP
        CJNE A,#MAXV,VPC_OK
        LCALL ERR_OVER
        RET
VPC_OK:
        MOV A,VALSP
        MOV TMP4,A
        ADD A,TMP4
        ADD A,TMP4
        ADD A,#VALBASE
        MOV R1,A
        MOV @R1,CUR0
        INC R1
        MOV @R1,CUR1
        INC R1
        MOV @R1,CUR2
        INC VALSP
        RET

VAL_PUSH_T:
        MOV A,VALSP
        CJNE A,#MAXV,VPT_OK
        LCALL ERR_OVER
        RET
VPT_OK:
        MOV A,VALSP
        MOV TMP4,A
        ADD A,TMP4
        ADD A,TMP4
        ADD A,#VALBASE
        MOV R1,A
        MOV @R1,TMP0
        INC R1
        MOV @R1,TMP1
        INC R1
        MOV @R1,TMP2
        INC VALSP
        RET

VAL_POP_TO_T:
        MOV A,VALSP
        JZ  VP_EMPTY
        DEC VALSP
        MOV A,VALSP
        MOV TMP4,A
        ADD A,TMP4
        ADD A,TMP4
        ADD A,#VALBASE
        MOV R1,A
        MOV TMP0,@R1
        INC R1
        MOV TMP1,@R1
        INC R1
        MOV TMP2,@R1
        RET
VP_EMPTY:
        LCALL ERR_OVER
        RET

; ---- Operator stack ----
OP_PUSH:
        MOV TMP4,A
        MOV A,OPSP
        CJNE A,#MAXO,OPP_OK
        LCALL ERR_OVER
        RET
OPP_OK:
        MOV A,OPSP
        ADD A,#OPBASE
        MOV R1,A
        MOV A,TMP4
        MOV @R1,A
        INC OPSP
        RET

OP_POP:
        MOV A,OPSP
        JZ  OP_EMPTY
        DEC OPSP
        MOV A,OPSP
        ADD A,#OPBASE
        MOV R1,A
        MOV A,@R1
        RET
OP_EMPTY:
        CLR A
        RET

OP_TOP:
        MOV A,OPSP
        JZ  OT_EMPTY
        DEC A
        ADD A,#OPBASE
        MOV R1,A
        MOV A,@R1
        RET
OT_EMPTY:
        CLR A
        RET

; ---- Single-digit extras ----
DO_SQUARE_CORE:
        MOV A,CURCNT
        CJNE A,#01H,DSQ_EXIT
        MOV A,CUR2
        JNZ DSQ_EXIT
        MOV A,CUR1
        JNZ DSQ_EXIT
        MOV A,CUR0
        CJNE A,#0AH,DSQ_OK
        SJMP DSQ_EXIT
DSQ_OK:
        MOV R0,#0C0H
        LCALL COMMAND
        MOV A,CUR0
        MOV B,CUR0
        MUL AB
        MOV 40H,A
        MOV 41H,B
        MOV 42H,#00H
        LCALL PRINT_RES_24_SIGNED
DSQ_EXIT:
        LJMP L1

DO_CUBE_CORE:
        MOV A,CURCNT
        CJNE A,#01H,DCB_EXIT
        MOV A,CUR2
        JNZ DCB_EXIT
        MOV A,CUR1
        JNZ DCB_EXIT
        MOV A,CUR0
        CJNE A,#0AH,DCB_OK
        SJMP DCB_EXIT
DCB_OK:
        MOV R0,#0C0H
        LCALL COMMAND
        MOV A,CUR0
        MOV B,CUR0
        MUL AB
        MOV DIVB0,A
        MOV DIVB1,B
        MOV DIVB2,#00H
        MOV DIVA0,CUR0
        MOV DIVA1,#00H
        MOV DIVA2,#00H
        LCALL MUL24x24_TO24
        MOV 40H,TMP0
        MOV 41H,TMP1
        MOV 42H,TMP2
        LCALL PRINT_RES_24_SIGNED
DCB_EXIT:
        LJMP L1

DO_ROOT_CORE:
        MOV A,CURCNT
        CJNE A,#01H,DRT_EXIT
        MOV A,CUR2
        JNZ DRT_EXIT
        MOV A,CUR1
        JNZ DRT_EXIT
        MOV A,CUR0
        CJNE A,#0AH,DRT_OK
        SJMP DRT_EXIT
DRT_OK:
        MOV R0,#0C0H
        LCALL COMMAND
        MOV DPTR,#SQRT_TAB
        MOV A,CUR0
        MOVC A,@A+DPTR
        MOV 40H,A
        MOV 41H,#00H
        MOV 42H,#00H
        LCALL PRINT_RES_24_SIGNED
DRT_EXIT:
        LJMP L1

; ---- Print signed 24-bit (42:41:40) ----
PRINT_RES_24_SIGNED:
        MOV A,42H
        JNB ACC.7,PR_POS
        MOV R0,#'-'
        LCALL DISPLAY
        MOV A,40H
        CPL A
        ADD A,#01H
        MOV 40H,A
        MOV A,41H
        CPL A
        ADDC A,#00H
        MOV 41H,A
        MOV A,42H
        CPL A
        ADDC A,#00H
        MOV 42H,A
PR_POS: LCALL PRINT_RES_24
        RET

PRINT_RES_24:
        MOV A,40H
        MOV 7AH,A
        MOV A,41H
        MOV 7BH,A
        MOV A,42H
        MOV 7CH,A
        MOV DPTR,#DIVTAB
        MOV R7,#08
        MOV R6,#00
PR_LOOP:
        CLR A
        MOVC A,@A+DPTR
        MOV 7DH,A
        INC DPTR
        CLR A
        MOVC A,@A+DPTR
        MOV 7EH,A
        INC DPTR
        CLR A
        MOVC A,@A+DPTR
        MOV 7FH,A
        INC DPTR
        MOV R5,#00
PR_SUB:
        LCALL CMP_TMP_DIV
        JC  PR_DONE
        CLR C
        MOV A,7AH
        SUBB A,7DH
        MOV 7AH,A
        MOV A,7BH
        SUBB A,7EH
        MOV 7BH,A
        MOV A,7CH
        SUBB A,7FH
        MOV 7CH,A
        INC R5
        SJMP PR_SUB
PR_DONE:
        MOV A,R5
        JNZ PR_PRINT
        MOV A,R6
        JNZ PR_PRINT
        CJNE R7,#01,PR_NEXT
PR_PRINT:
        MOV R6,#01
        MOV A,R5
        ADD A,#30H
        MOV R0,A
        LCALL DISPLAY
PR_NEXT:
        DJNZ R7,PR_LOOP
        RET

CMP_TMP_DIV:
        MOV A,7CH
        CLR C
        SUBB A,7FH
        JC  CTL
        JNZ CTG
        MOV A,7BH
        CLR C
        SUBB A,7EH
        JC  CTL
        JNZ CTG
        MOV A,7AH
        CLR C
        SUBB A,7DH
        JC  CTL
CTG:    CLR C
        RET
CTL:    SETB C
        RET

; ---- Error routines ----
ERR_DIV0:
        MOV R0,#0C0H
        LCALL COMMAND
        MOV DPTR,#MSG_ERR0
        LCALL PRINT_STR
        RET

ERR_OVER:
        MOV R0,#0C0H
        LCALL COMMAND
        MOV DPTR,#MSG_ERR1
        LCALL PRINT_STR
        RET

ERR_3DIG:
        MOV R0,#0C0H
        LCALL COMMAND
        MOV DPTR,#MSG_ERR3
        LCALL PRINT_STR
        RET

ERR_BRACKET:
        MOV R0,#0C0H
        LCALL COMMAND
        MOV DPTR,#MSG_ERRB
        LCALL PRINT_STR
        RET

PRINT_STR:
PSL:    CLR A
        MOVC A,@A+DPTR
        JZ  PSE
        MOV R0,A
        LCALL DISPLAY
        INC DPTR
        SJMP PSL
PSE:    RET

; ---- LCD routines ----
DISPLAY:
        MOV P1,R0
        SETB RS
        SETB EN
        LCALL DELAY
        CLR EN
        RET

COMMAND:
        MOV P1,R0
        CLR RS
        SETB EN
        LCALL DELAY
        CLR EN
        RET

; ---- Initialise ----
INITIALYZE:
        CLR A
        MOV CUR0,A
        MOV CUR1,A
        MOV CUR2,A
        MOV CURCNT,A
        MOV LASTTOK,#00H
        MOV VALSP,#00H
        MOV OPSP,#00H
        MOV DIVFLAG,#00H
        MOV MEM0,#00H
        MOV MEM1,#00H
        MOV MEM2,#00H
        MOV MEMSRC,#00H
        MOV MODEFLG,#00H
        MOV P0,A
        MOV P1,#00H
        MOV P2,#0F9H
        MOV P3,#0FEH
        MOV R0,#38H
        LCALL COMMAND
        MOV R0,#0EH
        LCALL COMMAND
        MOV R0,#01H
        LCALL COMMAND
        MOV R0,#06H
        LCALL COMMAND
        MOV R0,#80H
        LCALL COMMAND
        MOV R0,#01H
        LCALL COMMAND
        MOV DPTR,#MSG_START
        LCALL PRINT_STR
        LCALL DELAY
        LCALL DELAY
        MOV R0,#01H
        LCALL COMMAND
        RET

; ---- Delay ----
DELAY:
        PUSH 07H
        PUSH 06H
        PUSH 05H
        MOV R7,#2
D1:     MOV R6,#100
D2:     MOV R5,#250
D3:     DJNZ R5,D3
        DJNZ R6,D2
        DJNZ R7,D1
        POP 05H
        POP 06H
        POP 07H
        RET

SMALL_DELAY:
        PUSH 07H
        PUSH 06H
        MOV R6,#10
SD_O:   MOV R7,#250
SD_I:   DJNZ R7,SD_I
        DJNZ R6,SD_O
        POP 06H
        POP 07H
        RET

        END
