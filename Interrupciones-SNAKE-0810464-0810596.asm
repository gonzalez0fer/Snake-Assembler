#############################################################################
#>>>>>>>>>>>>>>>>>>>>>>> ORGANIZACION DEL COMPUTADOR <<<<<<<<<<<<<<<<<<<<<<<#																			
#      ---_ ...... _/_ -    		 				    #
#     /  .      ./ .'*\ \    						    #
#     : '         /__-'   \.   INTERRUPCIONES				    #
#    /                      ) _______  _        _______  _        _______   #
#  _/                  >   .'(  ____ \( (    /|(  ___  )| \    /\(  ____ \  #
#/   '   .       _.-" /  .'  | (    \/|  \  ( || (   ) ||  \  / /| (    \/  #
#\           __/"     /.'    | (_____ |   \ | || (___) ||  (_/ / | (__      #
# \ '--  .-" /     //'\ \\   (_____  )| (\ \) ||  ___  ||   _ (  |  __)	    #
#   \|  \ | /     //_ _\\\         ) || | \   || (   ) ||  ( \ \ | (        #
#        \:     //\ _ _ \|\  /\____) || )  \  || )   ( ||  /  \ \| (____/\  #
#     `\/     //   \	 \|\ \_______)|/    )_)|/     \||_/    \/(_______/  #
#      \__`\/ /     \- -  \  Giuli Latella USBid: 08-10596		    #
#           \_|	     \	     Fernando Gonzalez USBid: 08-10464 		    #
#############################################################################
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#   Este programa necesuta de las herramientas Keyboard and Display MMIO    #
# y Bitmat Display en conexion con MIPS				            #
#				        				    #
#			    IMPORTANTE:				            #
#									    #
#	configuracion para la herramienta Bitmap:			    #
#    Unit Width = 8							    #
#    Unit Height = 8							    #
#    Display Width = 512						    #
#    Display Height = 512						    #
#    Base Address for Display: 0x10008000 ($gp)				    #
#									    #
#xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx#
#############################################################################

.data
#Informacion pertinente al juego
#pantalla

AnchuraPantalla:.word 
AlturaPantalla: .word 



ColorSerpiente: .word	0x00	 
ColorFondo:     .word	0x00ff00	
ColorMarco:     .word	0x00	 	
ColorFruta: 	.word	0xff0000

#Puntuacion del juego variable
Puntuacion: 	.word 0
PuntuacionGain:	.word 1


VelocidadJuego:	.word 900

Arreglopuntuaciones: .word 1, 3, 5, 7, 9, 10, 20000 #25, 75, 150, 300, 600, 1000
ArreglopuntuacionesPosicion: .word 0

#Mensajes del juego
MensajeInicio1:		.asciiz " >>>>>>>>>>>>>>>>> BIENVENIDO A SNAKE MIPS <<<<<<<<<<<<<<<< \n\n RECUERDE ABRIR Y CONECTAR EL BITMAP DISPLAY Y EL KEYBOARD&DISPLAY MMIO"
MensajeFinJuego:	.asciiz "Has Muerto... tu puntuacion es : "
MensajeVolverAJugar:	.asciiz "Volver a Jugar?"
MensajeTamPantalla:	.asciiz "Introduce longitud del lado de la pantalla:\n (recomendados 256 / 512) "
MensajeTamPixel:        .asciiz "Introduce longitud del lado del pixel: \n (recomendados: (para pantalla 256 : 4 / 8) -- (para pantalla 512: 8 / 16)) "
MensajeBitmap:		.asciiz "recuerde colocar en los campos del Bitmap la info de resolucion y pixel y use ($gp) como direccion base "

CabezaSerpienteX: .word 31
CabezaSerpienteY:.word 31
ColaSerpienteX:	.word 31
ColaSerpienteY:	.word 31
Direccion:	.word 119 
DireccionCola:	.word 119

ArregloCambioDireccion:	.word 0:100

nuevoArregloCambioDireccion:	.word 0:100

arregloPosition:		.word 0
posicionArreglo2:		.word 0


PosicionFrutaX: .word
PosicionFrutaY: .word

.text
main:
#beq $zero, $zero, PosicionFrutaY-768976876
	lw $t0, 0xffff0000
	ori $t0, $t0, 0x10
	sw $t0, 0xffff0000
######################################################
# TOMAR DATOS DE RESOLUCION DEL BITMAP
######################################################
	li $v0, 55
	la $a0, MensajeInicio1
	li $a1, 3
	syscall	

SolicitaResolucion:
	li $v0, 51
	la $a0, MensajeTamPantalla
	syscall
	beq $a1, -2, JuegoFinalizado
	move $a2, $a0
	li $v0, 51
	la $a0, MensajeTamPixel
	syscall
	beq $a1, -2, SolicitaResolucion
	div $a0, $a2, $a0
	sw $a0, AnchuraPantalla
	sw $a0, AlturaPantalla
	li $v0, 55
	la $a0, MensajeBitmap
	li $a1, 2
	syscall
	li $a0, 0
	li $a1, 0
	li $a2, 0

ComienzoPartida:
######################################################
# CREAR PANTALLA 
######################################################
	lw $a0, AnchuraPantalla	#cargo la informacion del ancho de pantalla
	lw $a1, ColorFondo	#cargo la informacion del color de fondo (verde)
	mul $a2, $a0, $a0 	#numero total de pixeles en la pantalla
	mul $a2, $a2, 4 	#alineando direcciones
	add $a2, $a2, $gp 	#agrega apuntador al area global
	add $a0, $gp, $zero 	#asigno contador para el ciclo
CicloLlenado:
	beq $a0, $a2, InicializaVariables	#si el contador es igual al gp salta la instruccion
	sw $a1, 0($a0)				#almaceno el color 
	addiu $a0, $a0, 4			#incremento el contador
	j CicloLlenado

######################################################
#INICIALIZANDO VARIABLES DEL JUEGO
######################################################
InicializaVariables:

	lw $t0, AnchuraPantalla
	div $t0, $t0, 2
	sw $t0, CabezaSerpienteX
	sw $t0, CabezaSerpienteY
	sw $t0, ColaSerpienteX
	addi $t0, $t0, 6
	sw $t0, ColaSerpienteY
	li $t0, 119
	sw $t0, Direccion
	sw $t0, DireccionCola
	li $t0, 1
	sw $t0, PuntuacionGain
	li $t0, 200
	sw $t0, VelocidadJuego
	sw $zero, arregloPosition
	sw $zero, posicionArreglo2
	sw $zero, ArreglopuntuacionesPosicion
	sw $zero, Puntuacion
	
LimpiezaRegistros:

	li $v0, 0
	li $a0, 0
	li $a1, 0
	li $a2, 0
	li $a3, 0
	li $t0, 0
	li $t1, 0	#Los registros son limpiados para garanrizar el
	li $t2, 0	#buen funcionamiento del programa en cada iteracion
	li $t3, 0
	li $t4, 0
	li $t5, 0
	li $t6, 0
	li $t7, 0
	li $t8, 0
	li $t9, 0
	li $s0, 0
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s4, 0		

######################################################
# CREANDO LAS PAREDES DEL PLANO
######################################################
CrearMarco:

	li $t1, 0		#cargo coordenada Y para el borde izquierdo
	LoopIzq:
	move $a1, $t1		#mando la coordenada Y a $a1
	li $a0, 0		#cargo la coordena X a cero pues no cambia
	jal CoordenadasPantalla	#obtener las coordenadas de la pantalla
	move $a0, $v0		#copia las coordenadas a $a0
	lw $a1, ColorMarco	#almaceno el color de la serpiente en $a1
	jal CrearPixel		#creo el pixel del color deseado
	add $t1, $t1, 1		#incremento coordenada Y
	lw $a2, AnchuraPantalla
	bne $t1, $a2, LoopIzq	#si no he dibujado el marco izquierdo entero itera
	li $t1, 0
				#cargo coordenada Y para el borde izquierdo
	LoopDer:
	move $a1, $t1		#mando la coordenada Y a $a1
	lw $a2, AnchuraPantalla
	subi $a0, $a2, 1
	#li $a0, 63		#cargo la coordena X = Ancho -1 (marco derecho)
	jal CoordenadasPantalla	#obtener las coordenadas de la pantalla
	move $a0, $v0		#copia las coordenadas a $a0
	lw $a1, ColorMarco	#almaceno el color de la serpiente en $a1
	jal CrearPixel		#creo el pixel del color deseado
	add $t1, $t1, 1		#incremento coordenada Y
	bne $t1, $a2, LoopDer	#si no he dibujado el marco derecho entero itera
	li $t1, 0
				#cargo coordenada X para el borde izquierdo
	TechoLoop:
	move $a0, $t1		#mando la coordenada X a $a1
	li $a1, 0		#cargo la coordena Y a cero pues no cambia
	jal CoordenadasPantalla	#obtener las coordenadas de la pantalla
	move $a0, $v0		#copia las coordenadas a $a0
	lw $a1, ColorMarco	#almaceno el color de la serpiente en $a1
	jal CrearPixel		#creo el pixel del color deseado
	add $t1, $t1, 1 	#incremento coordenada X
	lw $a2, AnchuraPantalla
	bne $t1, $a2, TechoLoop 	#si no he dibujado el marco superior entero itera
	li $t1, 0		#cargo coordenada X para el borde izquierdo
	
	PisoLoop:
	move $a0, $t1		#mando la coordenada X a $a1
	lw $a2, AnchuraPantalla
	sub $a1, $a2, 1
	#li $a1, 63		#cargo la coordena Y a 63 (marco inferior)
	jal CoordenadasPantalla	#obtener las coordenadas de la pantalla
	move $a0, $v0		#copia las coordenadas a $a0
	lw $a1, ColorMarco	#almaceno el color de la serpiente en $a1
	jal CrearPixel		#creo el pixel del color deseado
	add $t1, $t1, 1		#incremento coordenada X	
	bne $t1, 64, PisoLoop	#si no he dibujado el marco superior entero itera
	
	
######################################################
#CREAR A LA SERPIENTE EN UNA POSICION INICIAL
######################################################
	
	#dibujando la cabeza de la serpiente	
	lw $a0, CabezaSerpienteX #cargo las coordenadas de la Cabeza de la Serpiente
	lw $a1, CabezaSerpienteY 
	jal CoordenadasPantalla	 #optener coordenadas en la pantalla
	move $a0, $v0 		 #copiar coordenadas a $a0
	li $a1, 0
	lw $a1, ColorSerpiente 	 #cargo la informacion de color de la serpiente
	jal CrearPixel		 #Creo el Pixel de la Cabeza
	
	#dibujando el resto de la serpiente
	lw $a0, CabezaSerpienteX #cargo las coordenadas de la Cabeza de la Serpiente
	lw $a1, CabezaSerpienteY 
	add $a1, $a1, 1
	jal CoordenadasPantalla  #optener coordenadas en la pantalla
	move $a1, $zero
	move $a0, $v0 		 #copiar coordenadas a $a0
	lw $a1, ColorSerpiente 	 #cargo la informacion de color de la serpiente
	jal CrearPixel		 #creo el siguiente pixel
	
	
	lw $a0, CabezaSerpienteX #cargo las coordenadas de la Cabeza de la Serpiente
	lw $a1, CabezaSerpienteY 
	add $a1, $a1, 2
	jal CoordenadasPantalla  #optener coordenadas en la pantalla
	move $a0, $v0 		 #copiar coordenadas a $a0
	lw $a1, ColorSerpiente 	 #cargo la informacion de color de la serpiente
	jal CrearPixel		 #creo el siguiente pixel
	
	lw $a0, CabezaSerpienteX #cargo las coordenadas de la Cabeza de la Serpiente
	lw $a1, CabezaSerpienteY 
	add $a1, $a1, 3
	jal CoordenadasPantalla  #optener coordenadas en la pantalla
	move $a0, $v0 		 #copiar coordenadas a $a0
	lw $a1, ColorSerpiente 	 #cargo la informacion de color de la serpiente
	jal CrearPixel		 #creo el siguiente pixel	
	
	lw $a0, CabezaSerpienteX #cargo las coordenadas de la Cabeza de la Serpiente
	lw $a1, CabezaSerpienteY 
	add $a1, $a1, 4
	jal CoordenadasPantalla  #optener coordenadas en la pantalla
	move $a0, $v0 		 #copiar coordenadas a $a0
	lw $a1, ColorSerpiente 	 #cargo la informacion de color de la serpiente
	jal CrearPixel		 #creo el siguiente pixel	
	
	lw $a0, CabezaSerpienteX #cargo las coordenadas de la Cabeza de la Serpiente
	lw $a1, CabezaSerpienteY 
	add $a1, $a1, 5
	jal CoordenadasPantalla  #optener coordenadas en la pantalla
	move $a0, $v0 		 #copiar coordenadas a $a0
	lw $a1, ColorSerpiente 	 #cargo la informacion de color de la serpiente
	jal CrearPixel		 #creo el siguiente pixel	
	
	lw $a0, CabezaSerpienteX #cargo las coordenadas de la Cabeza de la Serpiente
	lw $a1, CabezaSerpienteY 
	add $a1, $a1, 6
	jal CoordenadasPantalla  #optener coordenadas en la pantalla
	move $a0, $v0 		 #copiar coordenadas a $a0
	lw $a1, ColorSerpiente 	 #cargo la informacion de color de la serpiente
	jal CrearPixel		 #creo el siguiente pixel	
	
	#creando la cola de la serpiente
	lw $a0, ColaSerpienteX  #almaceno coordenada X de la cola
	lw $a1, ColaSerpienteY  #almaceno coordenada Y de la cola
	jal CoordenadasPantalla #obtener coordenadas de pantalla
	move $a0, $v0 		#copio coordenadas a $a0
	lw $a1, ColorSerpiente  #cargo la informacion del color
	jal CrearPixel		#creo el pixel de la cola
######################################################
#GENERAR FRUTA ALEATORIAMENTE
######################################################	
GenerarFruta:

	li $v0, 42		#aplico el syscall de Random int
	lw $a1, AnchuraPantalla		#rango (0<= $a0< $a1)
	subi $a1, $a1, 2
	syscall
	
	addiu $a0, $a0, 1	#aumento en uno la posicion X para que no quede en un borde
	sw $a0, PosicionFrutaX	#almaceno la coordenada X de la fruta
	syscall
	
	addiu $a0, $a0, 1	#aumento en uno la posicion Y para que no quede en un borde
	sw $a0, PosicionFrutaY	#almaceno la coordenada Y de la fruta
	jal SubirDificultad	#salto a la funcion de dificultad
	
######################################################
#VERIFICACION DE INPUT
######################################################

RevisaInput:
	lw $a0, VelocidadJuego	#cargo la velocidad del juego
	jal Pause		#salto a la funcion de pausa

#tomar las coordenadas para el cambio de direccion si es necesario
	lw $a0, CabezaSerpienteX
	lw $a1, CabezaSerpienteY
	jal CoordenadasPantalla
	add $a2, $v0, $zero


	#tomando el imput del teclado
	move $t1, $s7
	#andi $t1, $t1, 0x0001
	beqz $t1, SelectDirPixel #si no hay imput continua en la misma direccion
	move $a1, $s5	         #guarda la direccion del input
	
RevisaDireccion:	
	lw $a0, Direccion 	#carga la direccion actual a $a0
	jal RevisaDireccionInput#reviso si la direccion es valida
	beqz $v0, RevisaInput	
	sw $a1, Direccion	#si el input no es valido, toma uno nuevo
	lw $t7, Direccion	#cargo la direccion en $s7

######################################################
#DESPLAZANDO LA CABEZA DE LA SERPIENTE
######################################################	
			
SelectDirPixel:

	#Reviso en que direccion crear Pixeles dado codigo ascci input keyboard
	beq $t7, 32, AbortarJuego
	beq $t7, 119, PixelArribaLoop
	beq  $t7, 115, PixelAbajoLoop
	beq  $t7, 97, PixelizqLoop
	beq  $t7, 100, PixelDerLoop
	#regresa si se introdujo un caracter invalido
	j RevisaInput
	
PixelArribaLoop:

	#reviso si hay fin de partida antes de crear otro pixel
	lw $a0, CabezaSerpienteX	#cargo coordenada X de la cabeza
	lw $a1, CabezaSerpienteY	#cargo coordenada Y de la cabeza
	lw $a2, Direccion		#cargo la direccion de la serpiente
	jal RevisaChoqueSerpiente
	#dibuja la cabeza en la nueva posicion moviendo Y arriba
	lw $t0, CabezaSerpienteX	#cargo coordenadas X e Y
	lw $t1, CabezaSerpienteY
	addiu $t1, $t1, -1		#cambio la coordenada Y a su nuevo valor
	add $a0, $t0, $zero		#mando a $a0 la coordenada X y a $a1 la Y
	add $a1, $t1, $zero
	jal CoordenadasPantalla		#obtengo las coordenadas de pantalla
	add $a0, $v0, $zero		#copio coordenadas a $a0
	lw $a1, ColorSerpiente		#cargo la informacion del color
	jal CrearPixel			#trazo el pixel en el bitmap
	sw  $t1, CabezaSerpienteY	#almaceno posicion
	j DesplazarCola 	#ya desplazada la cabeza, desplazo la cola
	
PixelAbajoLoop:
	#reviso si hay fin de partida antes de crear otro pixel
	lw $a0, CabezaSerpienteX	#cargo coordenada X de la cabeza
	lw $a1, CabezaSerpienteY	#cargo coordenada Y de la cabeza
	lw $a2, Direccion		#cargo la direccion de la serpiente
	jal RevisaChoqueSerpiente	#revisa si la serpiente choca
	#dibuja la cabeza en la nueva posicion moviendo Y abajo
	lw $t0, CabezaSerpienteX	#cargo coordenadas X e Y
	lw $t1, CabezaSerpienteY
	addiu $t1, $t1, 1		#cambio la coordenada Y a su nuevo valor
	add $a0, $t0, $zero		#mando a $a0 la coordenada X y a $a1 la Y
	add $a1, $t1, $zero
	jal CoordenadasPantalla		#obtengo las coordenadas de pantalla
	add $a0, $v0, $zero		#copio coordenadas a $a0
	lw $a1, ColorSerpiente		#cargo la informacion del color
	jal CrearPixel			#dibujo el pixel	
	sw  $t1, CabezaSerpienteY	#almaceno posicion
	j DesplazarCola 		#ya desplazada la cabeza, desplazo la cola

PixelizqLoop:
	#reviso si hay fin de partida antes de crear otro pixel
	lw $a0, CabezaSerpienteX	#cargo coordenada X e Y de la cabeza
	lw $a1, CabezaSerpienteY
	lw $a2, Direccion		#cargo la direccion de la serpiente
	jal RevisaChoqueSerpiente	#reviso si la serpiente muere
	#dibuja la cabeza en la nueva posicion moviendo X izquierda
	lw $t0, CabezaSerpienteX	#cargo coordenadas X e Y
	lw $t1, CabezaSerpienteY
	addiu $t0, $t0, -1		#cambio la coordenada X a su nuevo valor
	add $a0, $t0, $zero		#mando a $a0 la coordenada X y a $a1 la Y
	add $a1, $t1, $zero
	jal CoordenadasPantalla		#obtengo las coordenadas de pantalla
	add $a0, $v0, $zero		#copio coordenadas a $a0
	lw $a1, ColorSerpiente		#cargo la informacion del color
	jal CrearPixel			#creo el pixel de la serpiente
	sw  $t0, CabezaSerpienteX	
	j DesplazarCola 	#ya desplazada la cabeza, desplazo la cola

PixelDerLoop:
	#reviso si hay fin de partida antes de crear otro pixel
	lw $a0, CabezaSerpienteX	#cargo coordenada X e Y de la cabeza
	lw $a1, CabezaSerpienteY
	lw $a2, Direccion		#cargo la direccion de la serpiente
	jal RevisaChoqueSerpiente	#reviso si la serpiente muere
	#dibuja la cabeza en la nueva posicion moviendo X derecha
	lw $t0, CabezaSerpienteX	#cargo coordenadas X e Y
	lw $t1, CabezaSerpienteY
	addiu $t0, $t0, 1		#cambio la coordenada Y a su nuevo valor
	add $a0, $t0, $zero		#mando a $a0 la coordenada X y a $a1 la Y
	add $a1, $t1, $zero
	jal CoordenadasPantalla		#obtengo las coordenadas de pantalla
	add $a0, $v0, $zero		#copio coordenadas a $a0
	lw $a1, ColorSerpiente		#cargo la informacion del color
	jal CrearPixel			#dibujo el pixel	
	sw  $t0, CabezaSerpienteX	#guardo posicion de la cabeza
	j DesplazarCola 	#ya desplazada la cabeza, desplazo la cola

######################################################
#DESPLAZAMIENTO DE LA COLA DE LA SERPIENTE
######################################################	
			
DesplazarCola:	
	lw $t2, DireccionCola	#cargo la direccion de la cola
	#Dependiendo de la direccion en la que se desplaza hacer salto
	beq  $t2, 119, DesplazaColaArriba
	beq  $t2, 115, DesplazaColaAbajo
	beq  $t2, 97, DesplazaColaIzq
	beq  $t2, 100, DesplazaColaDer

DesplazaColaArriba:	
	lw $t8, posicionArreglo2	#obtengo las coordenadas de la direccion de cambio
	la $t0, ArregloCambioDireccion 
	add $t0, $t0, $t8
	lw $t9, 0($t0)
	lw $a0, ColaSerpienteX  	#cargo la posicion de la cola
	lw $a1, ColaSerpienteY
	beq $s1, 1, AgregaLongArriba 	#llamado al procedimiento de incremento si ocurre
	addiu $a1, $a1, -1 	     	#cambia la posicion de la cola si no crece
	sw $a1, ColaSerpienteY		#almacenar coordenada Y de la cola	
	
AgregaLongArriba:
	li $s1, 0 				#regresa el flag a falso
	jal CoordenadasPantalla			#obtener coordenadas en pantalla
	add $a0, $v0, $zero			#copio a $a0
	bne $t9, $a0, CrearPixelColaArriba 	#cambiar direccion si esa fue la instruccion
	la $t3, nuevoArregloCambioDireccion  	#actualizando la direccion
	add $t3, $t3, $t8
	lw $t9, 0($t3)
	sw $t9, DireccionCola
	addiu $t8,$t8,4
	bne $t8, 396, GuardaPosArriba		#si el index esta fuera de rango, envialo a cero
	li $t8, 0
GuardaPosArriba:
	sw $t8, posicionArreglo2 
	
CrearPixelColaArriba:
	lw $a1, ColorSerpiente
	jal CrearPixel
	lw $t0, ColaSerpienteX		#tomo componentes de la cola de la serpiente
	lw $t1, ColaSerpienteY
	addiu $t1, $t1, 1		#aumento la coordenada Y en uno
	add $a0, $t0, $zero		#las asigno a $a0 y $a1
	add $a1, $t1, $zero
	jal CoordenadasPantalla		#cargo coordenadas de pantalla
	add $a0, $v0, $zero
	lw $a1, ColorFondo		#cargo color de fondo
	jal CrearPixel			#elimino rastro de la serpiente.
	j CrearFruta 	#actualiza la posicion de a fruta



DesplazaColaAbajo:
	#obtiene las proximas coordenadas de pantalla
	lw $t8, posicionArreglo2
	la $t0, ArregloCambioDireccion #toma la direccion del cambio
	add $t0, $t0, $t8
	lw $t9, 0($t0)
	lw $a0, ColaSerpienteX  #carga la posicion de la cola
	lw $a1, ColaSerpienteY
	beq $s1, 1, AgregaLongAbajo #branch si la longitud se debe incrementar
	addiu $a1, $a1, 1 #cambia la posicion de la cola si no debe incrementar
	sw $a1, ColaSerpienteY
	
AgregaLongAbajo:
	li $s1, 0 #set flag a falso
	jal CoordenadasPantalla
	add $a0, $v0, $zero
	bne $t9, $a0, CrearPixelColaAbajo #cambia la direccion si se requiere
	la $t3, nuevoArregloCambioDireccion  #actualiza la direccion
	add $t3, $t3, $t8
	lw $t9, 0($t3)
	sw $t9, DireccionCola
	addiu $t8,$t8,4
	#si el index esta fuera de rango reinicia a cero
	bne $t8, 396, GuardaPosAbajo
	li $t8, 0
GuardaPosAbajo:
	sw $t8, posicionArreglo2  
CrearPixelColaAbajo:	
	lw $a1, ColorSerpiente
	jal CrearPixel	
	#elimina detras de la serpiente
	lw $t0, ColaSerpienteX
	lw $t1, ColaSerpienteY
	addiu $t1, $t1, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordenadasPantalla
	add $a0, $v0, $zero
	lw $a1, ColorFondo
	jal CrearPixel	
	j CrearFruta #luego de actualizar la serpiente, crea una nueva fruta

DesplazaColaIzq:
	#actualiza la cola mientras se mueve a la izquierda
	lw $t8, posicionArreglo2
	la $t0, ArregloCambioDireccion #carga la direccion de cambio de coordenadas
	add $t0, $t0, $t8
	lw $t9, 0($t0)
	lw $a0, ColaSerpienteX #toma la posicion de la cola de la serpiente
	lw $a1, ColaSerpienteY
	beq $s1, 1, AgregaLongIzq #branch si la longitud debe aumentar
	addiu $a0, $a0, -1 #cambia la posicion de la cola si no debe aumentar
	sw $a0, ColaSerpienteX
	
AgregaLongIzq:
	li $s1, 0 #set flag a falso
	jal CoordenadasPantalla
	add $a0, $v0, $zero
	bne $t9, $a0, CrearPixelColaIzq #cambia la direccion se es necesario
	la $t3, nuevoArregloCambioDireccion #actualiza la direccion
	add $t3, $t3, $t8
	lw $t9, 0($t3)
	sw $t9, DireccionCola
	addiu $t8,$t8,4
	#si el index esta fuera de rango regresalo a cero
	bne $t8, 396, GuardaPosIzq
	li $t8, 0
GuardaPosIzq:
	sw $t8, posicionArreglo2  
CrearPixelColaIzq:	
	lw $a1, ColorSerpiente
	jal CrearPixel	
	#elimina detras de de la cola
	lw $t0, ColaSerpienteX
	lw $t1, ColaSerpienteY
	addiu $t0, $t0, 1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordenadasPantalla
	add $a0, $v0, $zero
	lw $a1, ColorFondo
	jal CrearPixel	
	j CrearFruta  #terminada la actualizacion de la serpiente, crea una fruta

DesplazaColaDer:
	#carga las coordenadas del proximo cambio de direccion
	lw $t8, posicionArreglo2
	#carga la direccion base del arreglo de cambio de direccion
	la $t0, ArregloCambioDireccion
	#ir al index deseado del arreglo
	add $t0, $t0, $t8
	#obten los datos del arreglo
	lw $t9, 0($t0)
	#obten la posicion actual de la cola
	lw $a0, ColaSerpienteX
	lw $a1, ColaSerpienteY
	#si el arreglo necesita ser incrementado,
	#no modifiques las coordenadas
	beq $s1, 1, AgregaLongDer
	#cambia la posicion de la cola
	addiu $a0, $a0, 1
	#almacena la nueva posicion
	sw $a0, ColaSerpienteX
	
AgregaLongDer:
	li $s1, 0 #retorna el flag a cero
	#carga las coordenadas de la pantalla
	jal CoordenadasPantalla
	#almacena las coordenadas en $a0
	add $a0, $v0, $zero
	#si las coordenadas marcan un cambio de posicion
	#continua dibujando en la misma posicion
	bne $t9, $a0, CrearPixelColaDer
	#obten la direccion base del arreglo
	la $t3, nuevoArregloCambioDireccion
	#mueve al index correcto del arregtlo
	add $t3, $t3, $t8
	#carga los datos de ese index
	lw $t9, 0($t3)
	#guarda la nueva direccion
	sw $t9, DireccionCola
	#incrementa la posicion en el arreglo
	addiu $t8,$t8,4
	#si el index esta fuera de de rango reinicialo
	bne $t8, 396, GuardaPosDer
	li $t8, 0
GuardaPosDer:
	sw $t8, posicionArreglo2  
CrearPixelColaDer:	

	lw $a1, ColorSerpiente
	jal CrearPixel	
	#borra tras la serpiente
	lw $t0, ColaSerpienteX
	lw $t1, ColaSerpienteY
	addiu $t0, $t0, -1
	add $a0, $t0, $zero
	add $a1, $t1, $zero
	jal CoordenadasPantalla
	add $a0, $v0, $zero
	lw $a1, ColorFondo
	jal CrearPixel
	j CrearFruta  #terminada la actualizacion de la serpiente, crea una fruta
	
######################################################
#CREANDO FRUTA	
######################################################	
CrearFruta:
	#revisa el choque con la fruta
	lw $a0, CabezaSerpienteX
	lw $a1, CabezaSerpienteY
	jal FrutaComida
	beq $v0, 1, IncrementaTam #si la fruta fue comida, aumenta tamano

	#crea la fruta en la pantalla
	lw $a0, PosicionFrutaX
	lw $a1, PosicionFrutaY
	jal CoordenadasPantalla
	add $a0, $v0, $zero
	lw $a1, ColorFruta
	jal CrearPixel
	j RevisaInput
	
IncrementaTam:
	li $s1, 1 #flag para incrementar el tamano
	j GenerarFruta

j RevisaInput 

##################################################################
#COORDENADAS PANTALLA
#_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_#
# en $a0 tengo la coordenada X					#
# en $a1 tengo la coordenada Y					#
# retorna en $v0 la direccion de las coordenadas del bitmap	#
#_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_#
##################################################################
CoordenadasPantalla:
	lw $v0, AnchuraPantalla 	#carga el ancho de la pantalla $v0
	mul $v0, $v0, $a1		#multiplica por la posicion Y
	add $v0, $v0, $a0		#suma la posicion de X
	mul $v0, $v0, 4			#multiplica por 4
	add $v0, $v0, $gp		#agrega el apuntador global del bitmap
	jr $ra				#retorna el v0

##################################################################
#CREACION DE PIXELES
#_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_#
# en $a0 direccion de la posicion a crear el pixel		#
# en $a1 color del pixel a crear				#
# no tiene valor de retorno					#
#_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_#
##################################################################
CrearPixel:
	sw $a1, ($a0) 	#rellena la coordenada con el color deseado
	jr $ra		#retorna
	
##################################################################
#REVISAR DIRECCION
#_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_#
# $a0 - direccion actual
# $a1 - input
# $a2 - coordenadas de direccion de cambio
# retorna $v0 = 0 - Direccion correcta
#	 $v0 = 1 - Direccion incorrecta
#_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_#
##################################################################
RevisaDireccionInput:
	beq $a0, $a1, MismaDir  		#si el imput es igual a la direccion almacenada no hacer nada
	beq $a0, 119, RevisaAbajoPresionado 	#si se mueve hacia arriba, revisa si esta presionado abajo
	beq $a0, 115, RevisaArribaPresionado	#si se muebe hacia abajo, revisa si arriba esta presionado
	beq $a0, 97, RevisaDerPresionado	#si va a la izquierda, revisa si derecha esta presionado
	beq $a0, 100, RevisaIzqPresionado 	#si va a la derecha, revisa si izquierda esta presionado
	j RevisaDireccionFinalizado 		# si el imput no es valido, toma uno nuevo
	
RevisaAbajoPresionado:
	beq $a1, 115, inaceptable 
	j aceptable

RevisaArribaPresionado:
	beq $a1, 119, inaceptable 
	j aceptable

RevisaDerPresionado:
	beq $a1, 100, inaceptable 
	j aceptable
	
RevisaIzqPresionado:
	beq $a1, 97, inaceptable 
	j aceptable
	
aceptable:
	li $v0, 1
	
	beq $a1, 119, AlmacenaDirArriba #guarda la locacion  del cambio de direccion hacia arriba
	beq $a1, 115, AlmacenaDirAbajo 	#guarda la locacion del cambio de direccion hacia abajo	
	beq $a1, 97, AlmacenaDirIzq  	#guarda la locacion del cambio de direccion hacia izquierda
	beq $a1, 100, AlmacenaDirDer 	#guarda la locacion del cambio de direccion hacia la derecha
	j RevisaDireccionFinalizado
	
AlmacenaDirArriba:
	lw $t4, arregloPosition 		#carga el index del arreglo
	la $t2, ArregloCambioDireccion 		#carga la direccion del cambio de direccion
	la $t3, nuevoArregloCambioDireccion 	#carga la direccion para la nueva direccion
	add $t2, $t2, $t4 			#suma el index a la base
	add $t3, $t3, $t4
		
	sw $a2, 0($t2) 		#almacena las coordenadas en ese index
	li $t5, 119
	sw $t5, 0($t3) 		#almacena la direccion en ese index
	
	addiu $t4, $t4, 4 	#incremente el indeel arreglox d
				#si el arreglo queda fuera de rango reinicialo
	bne $t4, 396, ArribaAlto
	li $t4, 0
ArribaAlto:
	sw $t4, arregloPosition	
	j RevisaDireccionFinalizado
	
AlmacenaDirAbajo:
	lw $t4, arregloPosition 		#toma el index del arreglo
	la $t2, ArregloCambioDireccion 		#obten la direccion base para las coordenadas de cambio de direccion
	la $t3, nuevoArregloCambioDireccion 	#carga la direccion del cambio de direccion
	add $t2, $t2, $t4 			#sumo el index a la posicion base
	add $t3, $t3, $t4
	
	sw $a2, 0($t2) 			#almacena las coordenadas en ese index
	li $t5, 115
	sw $t5, 0($t3) 			#almacena en ese index

	addiu $t4, $t4, 4 		#incrementa el index del arreglo
	#si el index del arreglo va fuera de rango reinicia
	bne $t4, 396, AbajoAlto
	li $t4, 0

AbajoAlto:	
	sw $t4, arregloPosition
	j RevisaDireccionFinalizado

AlmacenaDirIzq:
	lw $t4, arregloPosition 		#obtener el index del arreglo
	la $t2, ArregloCambioDireccion 		#carga la direccion de la coordenadas de cambiuo de direccion
	la $t3, nuevoArregloCambioDireccion 	#carga la base de la nueva direccion
	add $t2, $t2, $t4 			#agrega el index a la base
	add $t3, $t3, $t4

	sw $a2, 0($t2) 		#guarda las coordenadas en ese index
	li $t5, 97
	sw $t5, 0($t3) 		#guarda la direccion en ese index

	addiu $t4, $t4, 4 	#incrementa el index del arreglo
	#si el arreglo esta fuera de rango, reinicialo
	bne $t4, 396, IzqAlto
	li $t4, 0

IzqAlto:
	sw $t4, arregloPosition
	j RevisaDireccionFinalizado

AlmacenaDirDer:
	lw $t4, arregloPosition 		#carga el index del arreglo
	la $t2, ArregloCambioDireccion 		#carga la direccion base del arreglo de cambio de direccion
	la $t3, nuevoArregloCambioDireccion 	#carga la direccion base de la nueva direccion
	add $t2, $t2, $t4 			#suma el index a la direccion base
	add $t3, $t3, $t4
	
	sw $a2, 0($t2) #guarda las coordenadas en ese index
	li $t5, 100
	sw $t5, 0($t3) #guarda las coordenadas en ese index

	addiu $t4, $t4, 4 
	bne $t4, 396, DerAlto
	li $t4, 0

DerAlto:
	#guarda la posicion del arreglo
	sw $t4, arregloPosition		
	j RevisaDireccionFinalizado
	
inaceptable:
	li $v0, 0 #si la direccion es no aceptable
	j RevisaDireccionFinalizado
	
MismaDir:
	li $v0, 1
	
RevisaDireccionFinalizado:
	jr $ra
	
#################################################################
#FUNCION QUE PAUSA EL JUEGO					#
#_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_#
# Funcion que se encarga de pausar el juego			#
# en $a0 amount pausa						#
# NO retorna valor alguno					#
#_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_#
##################################################################
Pause:
	li $v0, 32 #syscall para dormir
	syscall
	jr $ra
	
##################################################################
# FUNCION QUE DETERMINA CUANDO HA SIDO COMIDA UNA FRUTA
#_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_#
# Funcion que se encarga de comprobar si se come la fruta	#
# y de asignar las puntuaciones respectivas			#
# 								#
#  $a0 coordenada X de la serpiente				#
#  $a1 coordenada Y de la serpiente				#
#  Retorna $v0:							#
#	1 - si comio la fruta					#
#	0 - si no comio la fruta				#
#_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_#
##################################################################
FrutaComida:
	
	#carga las coordenadas de la fruta
	lw $t0, PosicionFrutaX
	lw $t1, PosicionFrutaY
	#toma el $v0 a cero para marcar una no-colicion
	add $v0, $zero, $zero	
	#revisa si los X de la fruta y la serpiente coinciden
	beq $a0, $t0, XcoincideFruta
	#si no son iguales termina la funcion
	j SalirFrutaComida
	
XcoincideFruta:
	#revisa si Y coincide con la fruta
	beq $a1, $t1, YcoincideFruta
	#si no es igual termina la funcion
	j SalirFrutaComida
YcoincideFruta:
	#actualiza la puntuacion de la fruta
	lw $t5, Puntuacion
	lw $t6, PuntuacionGain
	add $t5, $t5, $t6
	sw $t5, Puntuacion
	# reproduce un sonido en caso que la serpiente haya comido
	li $v0, 31
	li $a0, 79
	li $a1, 150
	li $a2, 7
	li $a3, 127
	syscall	
	
	li $a0, 96
	li $a1, 250
	li $a2, 7
	li $a3, 127
	syscall
	
	li $v0, 1 #manda el valor de retorno a 1 si ya comio
	
SalirFrutaComida:
	jr $ra
	
##################################################################
#COMPROBAR CHOQUE DE LA SERPIENTE
#_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_#
# Funcion que se encarga de determinar cuando la serpiente	#
# se come a si misma...						#
#								#
#  $a0 - Coordenada X de la cabeza de la serpiente		#
#  $a1 - Coordenada Y de la cabeza de la serpiente		#
#  $a2 - Direccion de la cabeza de la serpiente			#
# Retorna:							#
#	0 - si no se come a si misma				#
#	1 - si se come a si misma				#
#_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_#
##################################################################	
RevisaChoqueSerpiente:
	#salva coordenadas de cabeza
	add $s3, $a0, $zero
	add $s4, $a1, $zero
	#salva direccion de retorno
	sw $ra, 0($sp)

	beq  $a2, 119, RevisaArriba
	beq  $a2, 115, RevisaAbajo
	beq  $a2, 97,  RevisaIzq
	beq  $a2, 100, RevisaDer
	j ChoqueConCuerpo 
	
RevisaArriba:
	#mira adelante de la posicion
	addiu $a1, $a1, -1
	jal CoordenadasPantalla
	#carga color a la direccion de pantalla
	lw $t1, 0($v0)
	#add $s6, $t1, $zero
	lw $t2, ColorSerpiente
	lw $t3, ColorMarco
	beq $t1, $t2, Exit 	#si los colores son iguales - YOU LOST!
	beq $t1, $t3, Exit 	#si golpeaste el borde- YOU LOST!
	j ChoqueConCuerpo 	# si no, sal de la funcion

RevisaAbajo:

	#revisa abajo de la posicion
	addiu $a1, $a1, 1
	jal CoordenadasPantalla
	#obtener el color a la direccion de la pantalla
	lw $t1, 0($v0)
	#add $s6, $t1, $zero
	lw $t2, ColorSerpiente
	lw $t3, ColorMarco
	beq $t1, $t2, Exit 	#si los colores son iguales - YOU LOST!
	beq $t1, $t3, Exit 	#si golpeaste el borde- YOU LOST!
	j ChoqueConCuerpo 	# sino abandona la funcion

RevisaIzq:

	#revisa la posicion a la izquierda
	addiu $a0, $a0, -1
	jal CoordenadasPantalla
	#toma el color a la direccion de pantalla
	lw $t1, 0($v0)
	#add $s6, $t1, $zero
	lw $t2, ColorSerpiente
	lw $t3, ColorMarco
	beq $t1, $t2, Exit 	#si los colores son iguales - YOU LOST!
	beq $t1, $t3, Exit 	#si golpeaste el borde - YOU LOST!
	j ChoqueConCuerpo 	# si no, abandona la funcion

RevisaDer:

	#revisa posicion a la derecha
	addiu $a0, $a0, 1
	jal CoordenadasPantalla
	#carga el color en la direccion de pantalla
	lw $t1, 0($v0)
	#add $s6, $t1, $zero
	lw $t2, ColorSerpiente
	lw $t3, ColorMarco
	beq $t1, $t2, Exit 	#si los colores son iguales - YOU LOST!
	beq $t1, $t3, Exit 	#si golpeaste el borde - YOU LOST!
	j ChoqueConCuerpo 	# si no, abandona la funcion

ChoqueConCuerpo:
	lw $ra, 0($sp) 		#restaura la direccion de retorno
	jr $ra		
	
##################################################################
#FUNCION SUBIR DIFICULTAD
# no parametros
##################################################################
# no retorna valores
##################################################################
SubirDificultad:
	lw $t0, Puntuacion 			#carga la puntuacion del jugador
	la $t1, Arreglopuntuaciones 		#carga la direccion al arreglo de puntuaciones
	lw $t2, ArreglopuntuacionesPosicion 	#obten el la posicion del arreglo
	add $t1, $t1, $t2 			#muevete a la posicion del arreglo
	lw $t3, 0($t1) 				#obten el valor en esa direccion
	
	#si la puntuacion del jugador no es igual a la del arreglo
	#abandona la funcion, si son iguales incrementa la dificultad
	bne $t3, $t0, FinishedDiff 
	#incrementa el index al arreglo de puntuaciones
	addiu $t2, $t2, 4
	#guarda la nueva posicion
	sw $t2, ArreglopuntuacionesPosicion
	#load the PuntuacionGain variable para incrementar valor 
	
	lw $t0, PuntuacionGain
	#multiplica el valor
	sll $t0, $t0, 1 
	#carga la velocidad del juego
	lw $t1, VelocidadJuego
	#aumenta la velocidad paulatinamente
	addiu $t1, $t1, -25
	#guarda la nueva velocidad
	sw $t1, VelocidadJuego

FinishedDiff:
	jr $ra

Exit:   
	#tono de game over
	li $v0, 31
	li $a0, 28
	li $a1, 250
	li $a2, 32
	li $a3, 127
	syscall
		
	li $a0, 33
	li $a1, 250
	li $a2, 32
	li $a3, 127
	syscall
	
	li $a0, 47
	li $a1, 1000
	li $a2, 32
	li $a3, 127
	syscall
	
	li $v0, 56 #syscall de dialogo
	la $a0, MensajeFinJuego #carga mensaje
	lw $a1, Puntuacion	#carga Puntuacion
	syscall

AbortarJuego:	
	li $v0, 50 #syscall for yes/no dialog
	la $a0, MensajeVolverAJugar #carga message
	syscall
	
	beqz $a0, ComienzoPartida#retry del juego
	
	#fin de programa

JuegoFinalizado:
	li $v0, 10
	syscall
	
	
	
#############################################################################
#>>>>>>>>>>>>>>>>>>>>>>> ORGANIZACION DEL COMPUTADOR <<<<<<<<<<<<<<<<<<<<<<<#																			
#      ---_ ...... _/_ -    		 				    #
#     /  .      ./ .'*\ \    						    #
#     : '         /__-'   \.   INTERRUPCIONES				    #
#    /                      ) _______  _        _______  _        _______   #
#  _/                  >   .'(  ____ \( (    /|(  ___  )| \    /\(  ____ \  #
#/   '   .       _.-" /  .'  | (    \/|  \  ( || (   ) ||  \  / /| (    \/  #
#\           __/"     /.'    | (_____ |   \ | || (___) ||  (_/ / | (__      #
# \ '--  .-" /     //'\ \\   (_____  )| (\ \) ||  ___  ||   _ (  |  __)	    #
#   \|  \ | /     //_ _\\\         ) || | \   || (   ) ||  ( \ \ | (        #
#        \:     //\ _ _ \|\  /\____) || )  \  || )   ( ||  /  \ \| (____/\  #
#     `\/     //   \	 \|\ \_______)|/    )_)|/     \||_/    \/(_______/  #
#      \__`\/ /     \- -  \  Giuli Latella USBid: 08-10596		    #
#           \_|	     \	     Fernando Gonzalez USBid: 08-10464 		    #
#===========================================================================#
#			   INFORME DE BUGS....                              #
#############################################################################
#
#		Durante el acoplamiento del manejador surgieron problemas
#	a la hora de almacenar la direccion de la cola de la
#	serpiente, esto causa que la misma se desprenda en algunas
#	partidas y no borre el rastro su rastro. A pesar de los
#	esfuerzos, el problema no pudo ser corregido a tiempo para
#	la entrega de la asignacion, el bug se sospecha que se encuentra
#	en la linea 350, de Interrupciones-SNAKE.asm en la cual hay un
#	condicional que lleva al correcto proceso de actualizacion de la
#	cola de nuestra serpiente. Dicho branch esta basado en el valor
#	0 o 1 que retorna la accion de presionar la tecla, anteriormente
#	era tomada directamente desde el teclado (version del programa
#	libre de Bugs pero SIN MANEJADOR) en la version con manejador 
#	dicho valor proviene de un registro, el cual no se modifica en 
#	el punto preciso para poder acceder a ese importante branch.
#
#		Al programa NO le fue eliminada la logica selectora de
#	correctitud de las teclas, a pesar que esta es innecesaria
#	puesto a que nuestro manejador se encarga de NO transmitir 
#	teclas invalidas, esto fue por falta de tiempo basicamente,
#	de eliminar dichas funciones, ya que en ellas llamo otras
#	que si son necesarias, se veria afectado en un nivel mayor
#	el funcionamiento del juego.
#
#	LOS BUGS PRESENTADOS NO SE MUESTRAN SIEMPRE EN EL MISMO LOOP
#	POR ENDE, CABE LA POSIBILIDAD QUE EXISTAN PARTIDAS CORTAS EN 
#	LAS CUALES LA SERPIENTE CONSERVE SU CUERPO Y CORRECTO
#	FUNCIONAMIENTO.
#
#	SNAKE cuenta con los siguientes aspectos extra:
#
#	- reinicio de partida: el jugador tiene la opcion de reiniciar
#	el juego cuando este lo aborta o muere.
#
#	- aumento de velocidad: fue implementado por medio de un arreglo
#	de puntuaciones como indicador, una variable que vaya aumentando 
#	la velocidad del juego cuando el valor asociado a la etiqueta
#	Puntuacion llegue a cada valor en la lista.
#
#	- auto-reset de la pantalla: este juego no necesita que se use
#	la opcion de reset del BitmapDisplay, reinicia la pantalla
#	automaticamente.
#
#	-sonido MIDI: el juego cuenta con un sonido cada vez que nuestra
#	serpiente se alimenta y uno diferente cuando la misma muere...
#
#                    /^\/^\
#                  _|__|  O|		UN GUSTO PROGRAMAR PARA
#         \/     /~     \_/ \		ESTA MATERIA
#          \____|__________/  \
#                 \_______      \
#                         `\     \                 \
#                           |     |                  \
#                          /      /                    \
#                         /     /                       \\
#                       /      /                         \ \
#                      /     /                            \  \
#                    /     /             _----_            \   \
#                   /     /           _-~      ~-_         |   |
#                  (      (        _-~    _--_    ~-_     _/   |
#                   \      ~-____-~    _-~    ~-_    ~-_-~    /
#                     ~-_           _-~          ~-_       _-~   
#                        ~--______-~                ~-___-~
#