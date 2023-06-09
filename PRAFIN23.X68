*-----------------------------------------------------------
* Title      : PRAFIN23
* Written by : <nombres completos de los autores>
* Date       : 19/05/2023
* Description: Emulador de la HAL9000

* Dudas = 
* -(instrucciones ADD) cuando coges un reg y lo sumas
*   hay que hacer (A1) o A1
* - instrucciones LOIP y STIP  �Xb <-- [Xb] + 1? �es pila?
* - Diferencia entre SET y ADQ solo move en vez de add? 
*-----------------------------------------------------------
    ORG $1000
EMEM:   DC.W $0011,$1013,$C012,$400A,$D222,$8000,$CA22,$8000,$0001,$0000
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
    
    LEA.L EMEM,A0           ; cogemos la direcci�n de la memoria
    ADD.W D0,A0             ; sumamos D0 (PC) a A0 para tener la direcci�n de
                                ; la instrucci�n a ejecutar
    
    ADD.W #1,EPC            ; sumamos 1 al EPC para ya apuntar a la siguiente
    MOVE.W (A0),EIR         ; movemos la instrucci�n al eregistro
                                ; de instrucci�n
    
        
    ;--- FFETCH: FIN FETCH
    
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1

    	    ; ESCRIBID VUESTRO CODIGO AQUI    	    
IBREDECOD:
    MOVE.W #0,-(A7)         ; preparamos la pila
    MOVE.W (EIR),-(A7)      ; metemos la instrucci�n en la pila
    
    JSR DECOD               ; saltamos a la subrutina de librer�a
                                ; de decodificaci�n
                                
    ADDQ.W #2,A7            ; sumamos 2 a A7
    MOVE.W (A7)+,D1         ; en D1 tenemos la instrucci�n a ejecutar

        
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
ELOA:                       ; Ti <-- [M]
    MOVE.W EIR, D5          ; metemos la instr. en D5
    JSR CogerM              ; sacamaos el valor de M
    MULU.W #2, D5           ; mult. M por 2, ya que estamos trabajando en Words
    MOVEA.L D5, A3          ; guardamos el valor de M en A3
    
    MOVE.W EMEM(A3),D6      ; cogemos el contenido  EMemoria + M y la 
                            ; y la guardamos en D6
    MOVE.W EIR, D5          ; movemos la inst. a D5, ya que hemos modificado D5
    JSR CogerI              ; sacamos el valor de I
    CMP #0, D5              ; comparamos I con 0              
    BNE I1_Load             ; si no son iguales significa que I es 1, por tanto,
                            ; saltamos al caso donde I es 1
    MOVE.W D6,ET0           ; cuando I es 0, guardamos el contenido de Emem + M
                            ; en ET0
    MOVE.W SR, D2           ; movemos los flags a D2
    JMP FINAL_Load          ; saltamos al final del ELoad    
   
   I1_Load:
    MOVE.W D6,ET1           ;guardamos el contenido de Emem + M en ET1
    MOVE.W SR, D2           ; movemos los flags a D2
    
 FINAL_Load:
    CLR.W D4                ; limpiamos el registro D4, para modificar los flags
    JSR FLAGS_NZ
    BRA FETCH            
*--------------------------------------------------
ESTO:                       ; M <-- [Ti]
    MOVE.W EIR, D5          ; metemos la instr. en D5
    JSR CogerM              ; sacamaos el valor de M
    MULU.W #2, D5           ; mult. M por 2, ya que estamos trabajando en Words
    MOVEA.L D5, A3          ; guardamos el valor de M en A3  
 
    MOVE.W EIR, D5          ; metemos la instr. en D5
    JSR CogerI
    CMP #0, D5              ; si i = 1 saltamos al caso de ET1
    BNE I1_Store            
    
    MOVE.W ET0, EMEM(A3)          ; movemos el contenido de ET0 a EMEM + M
    JMP FINAL_Store
    
   I1_Store:
    MOVE.W ET1, EMEM(A3)          ; movemos el contenido de ET1 a EMEM + M
  
  FINAL_Store:
    BRA FETCH
    
*--------------------------------------------------
ELOIP:                      ; Ti <-- [[Xb]], Xb <-- [Xb] + 1
    MOVE.W EIR, D5          ; metemos la instr. en D5
    JSR CogerB              ; sacamaos el registro B
    MOVE.W A5, A2           ; guardamos el Xb en A2
    
    MOVE.W EIR, D5          ; metemos la inst. en D5
    JSR CogerI              ; cogemos I
    CMP #0, D5              ; comparamos D5(I) con 0
    BNE I1_LOIP             ; si no son iguales saltamos donde I = 1
    
    MOVE.W (A2),D6           ; movemos la direccion efectiva de Emem a D6
    MULU.W #2, D6            ; mult. por 2, ya que estamos trabajando en Words
    MOVEA.L D6, A3           ; guardamos la direccion efectiva de Emem a A3
    MOVE.W EMEM(A3),ET0      ; guardamos [[Xb]] en ET0
    MOVE.W SR, D2           ; guardamos los flags despues de la op.
    ADD.W #1, (A2)          ; Xb <-- [Xb] + 1   
    JMP FINAL_LOIP
    
   I1_LOIP:
    MOVE.W (A2),D6         ; movemos la direccion efectiva de Emem a D6
    MULU.W #2, D6          ; mult. por 2, ya que estamos trabajando en Words
    MOVEA.L D6, A3         ; guardamos la direccion efectiva de Emem a A3
    MOVE.W EMEM(A3),ET1    ; guardamos [[Xb]] en ET1   
    MOVE.W SR, D2           ; guardamos los flags despues de la op.
    ADD.W #1, (A2)          ; Xb <-- [Xb] + 1   
    
 FINAL_LOIP:
    CLR.W D4                ; limpiamos D4 por si hay algo, ya que lo 
    JSR FLAGS_NZ            ; necesitaremos D4 para actualizar los flags N y Z
    
    BRA FETCH

*--------------------------------------------------
ESTIP:                      ; [Xb] <-- [Ti], Xb <-- [Xb] + 1
    MOVE.W EIR, D5          ; metemos la instr. en D5
    JSR CogerB              ; sacamaos el registro B
    MOVE.W A5, A2           ; guardamos el Rb en A2
    
    MOVE.W EIR, D5          ; metemos la inst. en D5
    JSR CogerI              ; cogemos I
    CMP #0, D5              ; comparamos D5(I) con 0
    BNE I1_STIP             ; si no son iguales saltamos donde I = 1
    
    MOVE.W (A2),D6          ; Movemos la Xb a D6
    MULU.W #2, D6           ; mult. por 2, ya que estamos trabajando en Words
    MOVEA.L D6, A3          ; guardamos Xb en A3
    MOVE.W (ET0),EMEM(A3)   ; [Xb] <-- [T0]
    ADD.W #1, (A2)          ; Xb <-- [Xb] + 1  
    JMP FINAL_STIP
    
   I1_STIP:
    MOVE.W (A2),D6       ; Movemos la Xb a D6
    MULU.W #2, D6           ; mult. por 2, ya que estamos trabajando en Words
    MOVEA.L D6, A3          ; guardamos Xb en A3
    MOVE.W (ET1),EMEM(A3)   ; [Xb] <-- [T1]
    ADD.W #1, (A2)          ; Xb <-- [Xb] + 1  
    
 FINAL_STIP:
    JMP FETCH

*--------------------------------------------------
EGOI:                       ; PC <-- M

    MOVE.W EIR, D5          ; movemos la instr. a D5
    JSR CogerM              ; llamamos a la subr. para coger M
    MOVE.W D5, EPC          ; guardamos D5 en el PC del eprograma
    
    BRA FETCH
                   
*--------------------------------------------------
EGOZ:                       ; si Z=1,  PC <-- M

    MOVE.W ESR, D2          ; movemos los eflags a D2
    BTST.L #0, D2           ; comprobamos si el eflag Z es 1
    BEQ Z0                  ; si es 0 saltamos al final de la instr.
    
    MOVE.W EIR, D5          ; movemos la instr. a D5
    JSR CogerM              ; llamamos a la subr. para coger M
    MOVE.W D5, EPC          ; guardamos D5 en el PC del eprograma

  Z0:
    BRA FETCH    
    
*--------------------------------------------------
EGON:                       ; si N=1,  PC <-- M

    MOVE.W ESR, D2          ; movemos los eflags a D2
    BTST.L #1, D2           ; comprobamos si el eflag N es 1
    BEQ N0                  ; si es 0 saltamos al final de la instr.
    
    MOVE.W EIR, D5          ; movemos la instr. a D5
    JSR CogerM              ; llamamos a la subr. para coger M
    MOVE.W D5, EPC          ; guardamos D5 en el PC del eprograma

  N0:
    BRA FETCH    
    
*--------------------------------------------------
EEXIT:                      ; Detiene la maquina
    JMP SIMHALT
*--------------------------------------------------
ECOPY:                      ; Rc <-- Rb

    MOVE.W EIR, D5          ; movemos la inst. a D5
    JSR CogerB              ; cogemos B
    MOVE.W A5, A2           ; guardamos B en A2
    
    MOVE.W EIR, D5          ; movemos de nuevo la inst. a D5,ya que se modific�
    JSR CogerC              ; cogemos C
    MOVE.W A5, A1           ; guardamos C en A1
    
    MOVE.W (A2),(A1)        ; copiamos el contenido de A2 dentro de A1
    
    MOVE.W SR, D2           ; copiamos los flags a D2
    CLR.W D4                ; limpiamos D4 por si hay algo, ya que lo 
    JSR FLAGS_NZ            ; necesitaremos D4 para actualizar los flags N y Z
    
    BRA FETCH
    
*--------------------------------------------------
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
    
    MOVE.W D6, (A3)         ; movemos el resultado a Rc
    
    BRA FETCH
*--------------------------------------------------    
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
    CLR.W D4                ; limpiamos D4
    JSR Flags_CNZ           ; actualizamos los eflags
    
    MOVE.W D6, (A3)         ; movemos el resultado a Rc
    
    BRA FETCH
*--------------------------------------------------    
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

    MOVE.W (A1),D6          ; movemos A y B a los registros de dat.
    MOVE.W (A2),D7
    AND.W   D7 ,D6          ; A and B
    
    MOVE.W SR,D2            ; guardamos los flags del 68k en D2
    CLR.W D4                ; limpiamos D4 
    JSR Flags_NZ            ; actualizamos los eflags
    
    MOVE.W D6, (A3)         ; movemos el resultado a Rc
    
    BRA FETCH
*--------------------------------------------------
ESET:                       ; Rc <-- k (ext. signo)
    MOVE.W EIR, D5          ; movemos la instr. a D5
    JSR CogerC              ; llamamos a la sub. de usuario para coger el valor
    MOVE.W A5, A3           ; de C y lo movemos a A3
    
    MOVE.W EIR, D5          ; movemos la instr. a D5
    JSR CogerK              ; cogemos k (dentro se realiza la ext. de signo)
    MOVE.W D5, D6           ; guardamos k en D6
    
    MOVE.W D6,(A3)          ; guardamos D6 (k) dentro de A3 (C)
    
    MOVE.W SR,D2            ; guardamos los flags del 68k en D2
    CLR.W D4                ; limpiamos D4 por si hay algo, ya que lo 
    JSR FLAGS_NZ            ; necesitaremos D4 para actualizar los flags N y Z

    BRA FETCH

*--------------------------------------------------
EADQ:                       ; Rc <-- [Rc] + k (ext. signo)
    MOVE.W EIR, D5          ; movemos la instr. a D5
    JSR CogerC              ; llamamos a la sub. de usuario para coger el valor
    MOVE.W A5, A3           ; de C y lo movemos a A3
    
    MOVE.W EIR, D5          ; movemos la instr. a D5
    JSR CogerK              ; cogemos k (dentro se realiza la ext. de signo)
    MOVE.W D5, D6           ; guardamos k en D6
    
    ADD.W D6,(A3)           ; sumamos D6 (k) con A3(C) y lo guardamos en A3(C)
    
    MOVE.W SR,D2            ; guardamos los flags del 68k en D2
    CLR.W D4                ; limpiamos D4 por si hay algo, ya que lo 
    JSR FLAGS_CNZ           ; necesitaremos D4 para actualizar todos los eflags

    BRA FETCH
*--------------------------------------------------
ELSH:                       ; si n=0 => Rb <-- [Rb] left shift p
                            ; si n=1 => Rb <-- [Rb] right shift p
    MOVE.W EIR, D5          ; movemos la inst. a D5
    JSR CogerB              ; cogemos el registro B
    MOVE.W A5, A2           ; guardamos el Rb en A2
    MOVE.W (A2),D7          ; movemos el contenido de A2(B) a un registro
                            ; temporal
    
    MOVE.W EIR, D5          ; movemos la inst. a D5
    JSR CogerP              ; cogemos P
    MOVE.W D5, D6           ; guardamos D5(P) en D6

    MOVE.W EIR, D5          ; movemos la intsrucci�n a D5
    JSR CogerN              ; cogemos el valor de N
    CMP #0, D5              ; comparamos 0 con N
    BNE RShift              ; si N es 1 saltamos a right shift
    
    LSL.W D6 , D7           ; n=0, por tanto hacemos un LSL con desp. D6(P)
    MOVE.W SR, D2           ; guardamos los flags despu�s de la operaci�n
    MOVE.W D7, (A2)           ; guardamos el resultado en A2(B)
    JMP FINAL_LSH           ; saltamos al final
    
   RShift:
    LSR.W D6, D7            ; n=1, por tanto hacemos un LSR con desp. D6(P)
    MOVE.W SR, D2           ; guardamos los flags 
    MOVE.W D7, A2           ; guardamos el resultado en A2(B)
    
 FINAL_LSH:
    CLR.W D4                ; limpiamos D4 porque lo utilizamos para actualizar
    JSR FLAGS_CNZ           ; los flags CNZ
    
    BRA FETCH
    
*--------------------------------------------------
    ;--- FEXEC: FIN EJECUCION
    
    

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion

	        ; ESCRIBID VUESTRO CODIGO AQUI
	        
CogerA:
    LSR.L #8,D5             ; movemos D5 8 posiciones a la derecha
    AND.W #$0007,D5         ; con una m�scara, cogemos el valor de A (aaa)
    
    JSR REGISTROS           ; miramos a qu� registro se corresponde
    
    RTS
    
    
CogerB:
    LSR.L #4,D5             ; movemos D5 4 posiciones a la derecha
    AND.W #$0007,D5         ; con una m�scara, cogemos el valor de B (bbb)
    
    JSR REGISTROS           ; miramos a qu� registro se corresponde
    
    RTS


CogerC:
    AND.W #$0007,D5         ; con una m�scara, cogemos el valor de C (ccc)

    JSR REGISTROS           ; miramos a qu� registro se corresponde
    
    RTS
   
CogerI:
    AND.W #0001,D5          ; con una m�scara, cogemos el valor de I
    
    RTS
    
CogerN:
    AND.W #0001,D5          ; con una m�scara, cogemos el valor de N
    
    RTS
    
CogerP:
    LSR.L #8,D5             ; movemos D5 8 posiciones a la derecha
    AND.W #0007,D5          ; con una m�scara, cogemos el valor de P (ppp)
    
    RTS
    
CogerM:
    LSR.L #1,D5             ; movemos D5 4 posiciones a la derecha
    AND.W #$00FF,D5         ; con una m�scara, cogemos el valor de M (mmmmmmmm)
    
    RTS
   
CogerK:
    LSR.L #3,D5             ; movemos D5 3 posiciones a la derecha
    AND.B #$00FF,D5         ; con una m�scara, cogemos el valor de K (kkkkkkkk)
    EXT.W D5                ; hacemos una extensi�n de signo (byte -> word)
    
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
    

  ; A partir de aqu� guardamos las direcciones y salimos de la subrutina 
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
*--------------------------------------
; Flags 68k = NZVC, FLAGS HAL9000 = 0CNZ  

FLAGS_CNZ:
    MOVE D2,D3              ; copiamos los flags para poder manipularlos
    BTST.L #0,D3            ; miramos C
    BEQ FLAGS_NZ            ; si C es 0, saltamos a mirar el flag Z
    
    BSET.L #2,D4              ; si no es 0, pondremos a 1 el valor de C en D4
    
*--------------------------------------    
FLAGS_NZ:
    MOVE.W D2,D3            ; copiamos los flags para poder manipularlos
    BTST.L #3,D3            ; miramos N
    BEQ FLAG_Z              ; si N es 0, saltamos a mirar el siguiente flag
    
    BSET.L #1,D4            ; si no es 0, pondremos a 1 el valor de N en D4
    
   FLAG_Z:
    MOVE.W D2,D3            ; copiamos los flags para poder manipularlos
    BTST.L #2,D3            ; miramos Z
    BEQ FINAL_FLAGS         ; si Z es 0, saltamos al final de los flags
    
    BSET.L #0,D4            ; si no es 0, pondremos a 1 el valor de Z en D4
    
   FINAL_FLAGS:
    MOVE.W D4,ESR           ; movemos D4 (flags finales) a ESR, los eflags
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
    MOVE.W 8(A7),D0         ; la instrucci�n que hemos guardado la pasamos a D0

    MOVE.W #0, D1           ; D1 contiene el id de la instrucci�n
    BTST.L #15, D0          ; miramos el bit 16� de la instr.
    BNE DECOD_1XXX          ; si no es 0, saltamos a para la instr. 1XXX
    
    ;0XXX
    BTST.L #14, D0          ; miramos el bit 15� de la instr.
    BNE DECOD_01XX          ; si no es 0, saltamos a para la instr. 01XX

        ;00XX
        BTST.L #13, D0      ; miramos el bit 14� de la instr.
        BNE DECOD_001X      ; si no es 0, saltamos a para la instr. 001X
        
            ;000X
            BTST.L #12, D0  ; miramos el bit 13� de la instr.
            BNE FINAL_AUX   ; si no es 0, saltamos a final aux para sumar 1
            JMP FINAL       ; si es 0, saltamos al final
            
          DECOD_001X:
            ADDQ.W #2, D1   ; sumamos 2 al id de la instr.
            BTST.L #12, D0  ; miramos el bit 13� de la instr.  
            BNE FINAL_AUX   ; si no es 0, saltamos a final aux para sumar 1
            JMP FINAL       ; si es 0, saltamos al final
         
      DECOD_01XX:
        ADDQ.W #4, D1       ; sumamos 4 al id de la instr.
        BTST.L #13, D0      ; miramos el bit 14� de la instr.
        BNE DECOD_0110      ; si no es 0, saltamos a la �nica otra 
                            ; posibilidad que es 0110
           ;010X
           BTST.L #12, D0   ; miramos el bit 13� de la instr.
           BNE FINAL_AUX    ; si no es 0, saltamos a final aux para sumar 1
           JMP FINAL        ; si es 0, saltamos directamente al final
      
      DECOD_0110:
        ADDQ.W #6, D1       ; sumamos 6 directamente porque solo hay 1 instr.
        JMP FINAL           ; que empiece por 011
        
  DECOD_1XXX:
    ADDQ.W #7, D1           ; id = 7
    BTST.L #14, D0          ; miramos el bit 15� de la instr.
    BNE DECOD_11XXX         ; si no es 0, saltamos a la instr. 10XXX
    JMP FINAL               ; como la �nica instr. con 10 sumamos el id
                            ; y saltamos directamente al final
        
      
  DECOD_11XXX:
    BTST.L #13, D0          ; miramos el bit 14� 
    BNE DECOD_111XX         ; si no es 0, saltamos a 111XX
    
        ;110XX
        BTST.L #12, D0      ; miramos el bit 13�
        BNE DECOD_1101X
        
            ;1100X
            ADDQ.W #1, D1   ; id = 8
            BTST.L #11, D0  ; miramos el bit 12� 
            BNE FINAL_AUX   ; si es 1, saltamos al final aux para sumar 1
            JMP FINAL       ; si es 0, saltamos directamente al final


           DECOD_1101X:
            ADDQ.W #3, D1   ; id = 10
            BTST.L #11, D0  ; miramos el bit 12�
            BNE FINAL_AUX   ; si es 1, saltamos al final aux para sumar 1
            JMP FINAL       ; si es 0, saltamos directamente al final
      
      DECOD_111XX:
        ADDQ.W #5, D1       ; id = 12
        BTST.L #12, D0      ; miramos el bit 13�
        BNE DECOD_11110     ; si es 1, saltamos a 11110
        
            ;11100
            BTST.L #11, D0  ; miramos el bit 12�
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
    
SIMHALT:
    SIMHALT                 ; detiene la m�quina
    END    START










*~Font name~Courier New~
*~Font size~18~
*~Tab type~1~
*~Tab size~4~
