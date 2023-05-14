*-----------------------------------------------------------
* Title      : PRAFIN23
* Written by : <nombres completos de los autores>
* Date       : 19/05/2023
* Description: Emulador de la HAL9000
*-----------------------------------------------------------
    ORG $1000
EMEM:   DC.W $E082,$E09B,$E0B4,$E01D,$2020,$C006,$2031,$C017,$F160
        DC.W $F170,$CE70,$3040,$EFFD,$501E,$4008,$8000,$0001
        DC.W $0001,$0001,$0001,$0001,$0001,$0000,$0000,$0000
EIR:    DC.W 0 ;eregistro de instruccion
EPC:    DC.W 0 ;econtador de programa
ET0:    DC.W 0 ;eregistro T0
ET1:    DC.W 0 ;eregistro T1
EX2:    DC.W 0 ;eregistro X2
EX3:    DC.W 0 ;eregistro X3
EX4:    DC.W 0 ;eregistro X4
EX5:    DC.W 0 ;eregistro X5
EX6:    DC.W 0 ;eregistro X6
EX7:    DC.W 0 ;eregistro X7
ESR:    DC.W 0 ;eregistro de estado (00000000 00000CNZ)

START:
    CLR.W EPC

FETCH:
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC,
	    ;*** y dejar listo el EPC para que apunte a la siguiente instruccion
	
	        ; ESCRIBID VUESTRO CODIGO AQUI	    
        
    MOVE.W EPC,D0           ; movemos el contador a D0
    MULU.W #2,D0            ; multiplicamos x2 D0
    
    LEA.L EMEM,A0           ; cogemos la dirección de la memoria
    ADD.W D0,A0             ; sumamos D0 (PC) a A0 para tener la dirección de
                                ; la instrucción a ejecutar
    
    ADD.W #1,EPC            ; sumamos 1 al EPC para ya apuntar a la siguiente
    MOVE.W (A0),EIR         ; movemos la instrucción al eregistro
                                ; de instrucción
    
        
    ;--- FFETCH: FIN FETCH
    
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1

    	    ; ESCRIBID VUESTRO CODIGO AQUI    	    
IBREDECOD:
    MOVE.W #0,-(A7)         ; preparamos la pila
    MOVE.W (EIR),-(A7)      ; metemos la instrucción en la pila
    
    JSR DECOD               ; saltamos a la subrutina de librería
                                ; de decodificación
                                
    ADDQ.W #2,A7            ; sumamos 2 a A7
    MOVE.W (A7)+,D1         ; en D1 tenemos la instrucción a ejecutar

        
    ;--- FBRDECOD: FIN SALTO A DECOD
    
    
    
    ;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
        ;*** Esta seccion se usa para saltar a la fase de ejecucion
        ;*** NO HACE FALTA MODIFICARLA
    MULU #6,D1
    MOVEA.L D1,A1
    JMP JMPLIST(A1)
JMPLIST:
    JMP ELOA
    JMP ESTO
    JMP ELOIP
    JMP ESTIP
    JMP EGOI
    JMP EGOZ
    JMP EGON
    JMP EEXIT
    JMP ECOPY
    JMP EADD
    JMP ESUB
    JMP EAND
    JMP ESET
    JMP EADQ
    JMP ELSH
    ;--- FBREXEC: FIN SALTO A FASE DE EJECUCION
    
    
    
    ;--- IEXEC: INICIO EJECUCION
        ;*** En esta seccion debeis implementar la ejecucion de cada einstr.
	
	; ESCRIBID EN CADA ETIQUETA LA FASE DE EJECUCION DE CADA INSTRUCCION
ELOA:
ESTO:
ELOIP:
ESTIP:
EGOI:
EGOZ:
EGON:
EEXIT:
ECOPY:
EADD:                       ; Rc <-- [Rb] + [Ra]
    MOVE.W EIR, D5          ; movemos la instr. a D5
    JSR CogerA              ; llamamos a la sub. de usuario para coger el valor
    MOVE.W A5, A1           ; de A y lo movemos a A1
    
    MOVE.W EIR, D5
    JSR CogerB              ; llamamos a la sub. de usuario para coger el valor
    MOVE.W A5, A2           ; de B y lo movemos a A2
    
    MOVE.W EIR, D5
    JSR CogerC              ; llamamos a la sub. de usuario para coger el valor
    MOVE.W A5, A3           ; de C y lo movemos a A3
    
    CLR.L D6                ; preparamos D6 para poder poner el resultado
    ADD.W (A1),D6           ; sumamos el contenido de A1 (A) a D6
    ADD.W (A2),D6           ; sumamos el contenido de A2 (B) a D6
    
    MOVE.W SR,D2            ; guardamos los flags del 68k en D2
    CLR.W D4                
    JSR Flags_CNZ           ; actualizamos los eflags
    
    MOVE.W D6, (A3)         ; movemos D6 =  Xc <-- [Xa] + [Xb]
    
    BRA FETCH
    
ESUB:                       ; Rc <-- [Rb] - [Ra]

    MOVE.W EIR, D5          ; movemos la instr. a D5
    JSR CogerA              ; llamamos a la sub. de usuario para coger el valor
    MOVE.W A5, A1           ; de A y lo movemos a A1
    
    MOVE.W EIR, D5
    JSR CogerB              ; llamamos a la sub. de usuario para coger el valor
    MOVE.W A5, A2           ; de B y lo movemos a A2
    
    MOVE.W EIR, D5
    JSR CogerC              ; llamamos a la sub. de usuario para coger el valor
    MOVE.W A5, A3           ; de C y lo movemos a A3
    
    CLR.L D6                ; preparamos D6 para poder poner el resultado
    ADD.W (A1),D6           ; sumamos el contenido de A1 (A) a D6
    NOT.W D6                ; negamos y sumamos 1 a A para hacer una resta
    ADDQ.W #1, D6
    ADD.W (A2),D6           ; B + (-A)

    MOVE.W SR,D2            ; guardamos los flags del 68k en D2
    CLR.W D4                
    JSR Flags_CNZ           ; actualizamos los eflags
    
    MOVE.W D6, (A3)         ; movemos D6 =  Xc <-- [Xa] + [Xb]
    
    BRA FETCH
    
EAND:                       ; Rc <-- [Rb] and [Ra]

    MOVE.W EIR, D5          ; movemos la instr. a D5
    JSR CogerA              ; llamamos a la sub. de usuario para coger el valor
    MOVE.W A5, A1           ; de A y lo movemos a A1
    
    MOVE.W EIR, D5
    JSR CogerB              ; llamamos a la sub. de usuario para coger el valor
    MOVE.W A5, A2           ; de B y lo movemos a A2
    
    MOVE.W EIR, D5
    JSR CogerC              ; llamamos a la sub. de usuario para coger el valor
    MOVE.W A5, A3           ; de C y lo movemos a A3

    MOVE.W (A1),D6
    MOVE.W (A2),D7
    AND.W   D7 ,D6
    
    MOVE.W SR,D2            ; guardamos los flags del 68k en D2
    CLR.W D4                
    JSR Flags_NZ           ; actualizamos los eflags
    
    MOVE.W D6, (A3)         ; movemos D6 =  Xc <-- [Xa] + [Xb]
    
    BRA FETCH


ESET:
EADQ:
ELSH:
    ;--- FEXEC: FIN EJECUCION
    
    

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

	        ; ESCRIBID VUESTRO CODIGO AQUI
	        
CogerA:
    LSR.L #8,D5             ; movemos D5 8 posiciones a la derecha
    AND.W #$0007,D5         ; con una máscara, cogemos el valor de A (aaa)
    
    JSR REGISTROS           ; miramos a qué registro se corresponde
    
    RTS
    
    
CogerB:
    LSR.L #4,D5             ; movemos D5 4 posiciones a la derecha
    AND.W #$0007,D5         ; con una máscara, cogemos el valor de B (bbb)
    
    JSR REGISTROS           ; miramos a qué registro se corresponde
    
    RTS


CogerC:
    AND.W #$0007,D5         ; con una máscara, cogemos el valor de C (ccc)

    JSR REGISTROS           ; miramos a qué registro se corresponde
    
    RTS
   
CogerI:
    AND.W #0001,D5          ; con una máscara, cogemos el valor de I
    
    RTS
    
CogerJ:
    LSR.L #2,D5             ; movemos D5 4 posiciones a la derecha
    AND.W #0001,D5          ; con una máscara, cogemos el valor de J
    
    RTS
    
CogerM:
    LSR.L #4,D5             ; movemos D5 4 posiciones a la derecha
    AND.W #$00FF,D5         ; con una máscara, cogemos el valor de M (mmmmmmmm)
    
    RTS
   
CogerK:
    LSR.L #3,D5             ; movemos D5 3 posiciones a la derecha
    AND.B #$00FF,D5         ; con una máscara, cogemos el valor de K (kkkkkkkk)
    EXT.W D5                ; hacemos una extensión de signo (byte -> word)
    
    RTS

*--------------------------------------

REGISTROS:
    BTST.L #2,D5            ; miramos el tercer bit del registro
    BNE REGISTROS_1XX       ; si no es 0, saltamos para mirar el registro 1XX
    
   ;0XX
    BTST.L #1,D5            ; miramos el segundo bit del registro
    BNE REGISTROS_01X       ; si no es 0, saltamos para mirar el registro 01X
    
        ;00X
         BTST.L #0,D5       ; miramos el primer bit del registro
         BEQ REGISTRO_T0    ; si es 0, el registro es B0
         JMP REGISTRO_T1    ; si es 0, el registro es B1
    
        REGISTROS_01X:
         BTST.L #0,D5       ; miramos el primer bit del registro
         BEQ REGISTRO_X2    ; si es 0, el registro es R2
         JMP REGISTRO_X3    ; si es 0, el registro es R3
    
   REGISTROS_1XX:
    BTST.L #1,D5            ; miramos el segundo bit del registro
    BNE REGISTROS_11X       ; si no es 0, saltamos para mirar el registro 11X
    
        ;10X
         BTST.L #0,D5       ; miramos el primer bit del registro
         BEQ REGISTRO_X4    ; si es 0, el registro es R4
         JMP REGISTRO_X5    ; si es 0, el registro es R5
    
        REGISTROS_11X:
         BTST.L #0,D5       ; miramos el primer bit del registro
         BEQ REGISTRO_X6    ; si es 0, el registro es T6
         JMP REGISTRO_X7    ; si es 0, el registro es T7
    

  ; A partir de aquí guardamos las direcciones y salimos de la subrutina 
   REGISTRO_T0:
    LEA.L ET0,A5            ; guardamos el contenido de ET0 en A5
    JMP FIN_REGISTROS       ; saltamos al final de la subrutina de registros
    
   REGISTRO_T1:
    LEA.L ET1,A5            ; guardamos el contenido de ET1 en A5
    JMP FIN_REGISTROS       ; saltamos al final de la subrutina de registros
    
   REGISTRO_X2:
    LEA.L EX2,A5            ; guardamos el contenido de EX2 en A5
    JMP FIN_REGISTROS       ; saltamos al final de la subrutina de registros
    
   REGISTRO_X3:
    LEA.L EX3,A5            ; guardamos el contenido de EX3 en A5
    JMP FIN_REGISTROS       ; saltamos al final de la subrutina de registros
    
   REGISTRO_X4:
    LEA.L EX4,A5            ; guardamos el contenido de EX4 en A5
    JMP FIN_REGISTROS       ; saltamos al final de la subrutina de registros
    
   REGISTRO_X5:
    LEA.L EX5,A5            ; guardamos el contenido de EX5 en A5
    JMP FIN_REGISTROS       ; saltamos al final de la subrutina de registros
    
   REGISTRO_X6:
    LEA.L EX6,A5            ; guardamos el contenido de EX6 en A5
    JMP FIN_REGISTROS       ; saltamos al final de la subrutina de registros
    
   REGISTRO_X7:
    LEA.L EX7,A5            ; guardamos el contenido de EX7 en A5
    JMP FIN_REGISTROS       ; saltamos al final de la subrutina de registros
    
   FIN_REGISTROS: 
    RTS

        
    ;--- FSUBR: FIN SUBRUTINAS
    
    

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
	        ; ESCRIBID VUESTRO CODIGO AQUI
	        
    MOVE.W D0,-(A7)         ; guardamos D0 en la pila
    MOVE.W D1,-(A7)         ; guardamos D1 en la pila
    MOVE.W 8(A7),D0         ; la instrucción que hemos guardado la pasamos a D0

    MOVE.W #0, D1           ; D1 contiene el id de la instrucción
    BTST.L #15, D0          ; miramos el bit 16º de la instr.
    BNE DECOD_1XXX          ; si no es 0, saltamos a para la instr. 1XXX
    
    ;0XXX
    BTST.L #14, D0          ; miramos el bit 15º de la instr.
    BNE DECOD_01XX          ; si no es 0, saltamos a para la instr. 01XX

        ;00XX
        BTST.L #13, D0      ; miramos el bit 14º de la instr.
        BNE DECOD_001X      ; si no es 0, saltamos a para la instr. 001X
        
            ;000X
            BTST.L #12, D0  ; miramos el bit 13º de la instr.
            BNE FINAL_AUX   ; si no es 0, saltamos a final aux para sumar 1
            JMP FINAL       ; si es 0, saltamos al final
            
          DECOD_001X:
            ADDQ.W #2, D1   ; sumamos 2 al id de la instr.
            BTST.L #12, D0  ; miramos el bit 13º de la instr.  
            BNE FINAL_AUX   ; si no es 0, saltamos a final aux para sumar 1
            JMP FINAL       ; si es 0, saltamos al final
         
      DECOD_01XX:
        ADDQ.W #4, D1       ; sumamos 4 al id de la instr.
        BTST.L #13, D0      ; miramos el bit 14º de la instr.
        BNE DECOD_0110      ; si no es 0, saltamos a la única otra 
                            ; posibilidad que es 0110
           ;010X
           BTST.L #12, D0   ; miramos el bit 13º de la instr.
           BNE FINAL_AUX    ; si no es 0, saltamos a final aux para sumar 1
           JMP FINAL        ; si es 0, saltamos directamente al final
      
      DECOD_0110:
        ADDQ.W #6, D1       ; sumamos 6 directamente porque solo hay 1 instr.
        JMP FINAL           ; que empiece por 011
        
  DECOD_1XXX:
    ADDQ.W #7, D1           ; id = 7
    BTST.L #14, D0          ; miramos el bit 15º de la instr.
    BNE DECOD_11XXX         ; si no es 0, saltamos a la instr. 10XXX
    JMP FINAL               ; como la única instr. con 10 sumamos el id
                            ; y saltamos directamente al final
        
      
  DECOD_11XXX:
    BTST.L #13, D0          ; miramos el bit 14º 
    BNE DECOD_111XX         ; si no es 0, saltamos a 111XX
    
        ;110XX
        BTST.L #12, D0      ; miramos el bit 13º
        BNE DECOD_1101X
        
            ;1100X
            ADDQ.W #1, D1   ; id = 8
            BTST.L #11, D0  ; miramos el bit 12º 
            BNE FINAL_AUX   ; si es 1, saltamos al final aux para sumar 1
            JMP FINAL       ; si es 0, saltamos directamente al final


           DECOD_1101X:
            ADDQ.W #3, D1   ; id = 10
            BTST.L #11, D0  ; miramos el bit 12º
            BNE FINAL_AUX   ; si es 1, saltamos al final aux para sumar 1
            JMP FINAL       ; si es 0, saltamos directamente al final
      
      DECOD_111XX:
        ADDQ.W #5, D1       ; id = 12
        BTST.L #12, D0      ; miramos el bit 13º
        BNE DECOD_11110     ; si es 1, saltamos a 11110
        
            ;11100
            BTST.L #11, D0  ; miramos el bit 12º
            BNE FINAL_AUX   ; si es 1, sumamos 1 al id
            JMP FINAL       ; si es 0, saltamos al final
            
          DECOD_11110:
            ADDQ.W #2, D1   ; id = 14
            JMP FINAL

   FINAL_AUX:
    ADDQ.W #1,D1            ; sumamos 1 al id
    
   FINAL: 
    MOVE.W D1,10(A7)        ; guardamos el id en la pila
    MOVE.W (A7)+,D1         ; sacamos D1 de la pila
    MOVE.W (A7)+,D0         ; sacamos D0 de la pila
    
    RTS


    ;--- FDECOD: FIN DECOD
    END    START



*~Font name~Courier New~
*~Font size~18~
*~Tab type~1~
*~Tab size~4~
