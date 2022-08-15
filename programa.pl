% Aquí va el código.

%Comercios adheridos en cada destino que entran en el programa

comercioAdherido(iguazu, grandHotelIguazu).
comercioAdherido(iguazu, gargantaDelDiabloTour).
comercioAdherido(bariloche, aerolineas).
comercioAdherido(iguazu, aerolineas).

valorMaximoHotel(5000).

%de cada persona, las facturas que presento
%factura(Persona, DetalleFactura).
%   Detalles de facturas posibles:
%   hotel(ComercioAdherido, ImportePagado)
%   excursion(ComercioAdherido, ImportePagadoTotal, CantidadPersonas)
%   vuelo(NroVuelo,NombreCompleto)

factura(estanislao, hotel(grandHotelIguazu, 2000)).
factura(antonieta, excursion(gargantaDelDiabloTour, 5000, 4)).
factura(antonieta, vuelo(1515, antonietaPerez)).

%Y los vuelos que efectivamente se hicieron:
%registroVuelo(NroVuelo,Destino,ComercioAdherido,Pasajeros,Precio)
registroVuelo(1515, iguazu, aerolineas, [estanislaoGarcia, antonietaPerez, danielIto], 10000).

% Punto 1 monto a devolver a cada persona que presento facutras.
valorMaximoDevolucion(100000).

montoADevolver(Persona, MontoFinal):-
    factura(Persona, _),
    calculoReintegro(Persona, MontoFinal),
    valorMaximoDevolucion(MaximoDevolucion),
    MontoFinal < MaximoDevolucion.

montoADevolver(Persona, MaximoDevolucion):-
    factura(Persona, _),
    calculoReintegro(Persona, MontoFinal),
    valorMaximoDevolucion(MaximoDevolucion),
    MontoFinal > MaximoDevolucion.

calculoReintegro(Persona, Monto):-
    montoTotalDeFacturas(Persona, MontoFacturas),
    montoAdicional(Persona, Adicional),
    montoPenalidad(Persona, Penalidad),
    Monto is MontoFacturas + Adicional - Penalidad.


montoTotalDeFacturas(Persona, MontoFinal):-
    findall(Devolucion, montoPorFactura(Persona, Devolucion),MontosFacturas),
    sum_list(MontosFacturas, MontoFinal).


montoPorFactura(Persona, Monto):-
    factura(Persona, Detalle),
    esFacturaValida(Detalle),
    devolucionCorrespondiente(Detalle, Monto).

esFacturaValida(hotel(Comercio, Monto)):-
    comercioAdherido(_, Comercio),
    valorMaximoHotel(MontoMaximo),
    Monto < MontoMaximo.
esFacturaValida(vuelo(NroVuelo, NombreCompleto)):-
    registroVuelo(NroVuelo, _, Comercio, Pasajeros, _),
    comercioAdherido(_, Comercio),
    member(NombreCompleto, Pasajeros).
esFacturaValida(excursion(Comercio, _, _)):-
    comercioAdherido(_, Comercio).


devolucionCorrespondiente(hotel(_, Importe), Monto):-
    Monto is Importe * 0.5.
devolucionCorrespondiente(excursion(_, Importe, CantPersonas), Monto):-
    Monto is Importe * 0.8 /CantPersonas.
devolucionCorrespondiente(vuelo(NroVuelo, _), Monto):-
    registroVuelo(NroVuelo, Destino, _, _, Importe),
    Destino \= buenosAires,
    Monto is Importe * 0.3.
devolucionCorrespondiente(vuelo(NroVuelo, _), 0):-
    registroVuelo(NroVuelo, buenosAires, _, _,_).


montoPenalidad(Persona, 0):-
    forall(factura(Persona,Detalle), esFacturaValida(Detalle)).
montoPenalidad(Persona, 15000):-
    factura(Persona,Detalle),
    not(esFacturaValida(Detalle)).

montoAdicional(Persona, Adicional):-
    destinosAlosQueViajo(Persona, Destinos),
    list_to_set(Destinos, DestinosSinRepetir),
    length(DestinosSinRepetir, CantDestinos),
    Adicional is 1000*CantDestinos.

destinosAlosQueViajo(Persona,Destinos):-
    findall(Destino,(factura(Persona, Detalle), destino(Detalle, Destino)),Destinos).
    
destino(hotel(Comercio,_), Destino):-
    comercioAdherido(Destino,Comercio).
destino(excursion(Comercio,_,_), Destino):-
    comercioAdherido(Destino,Comercio).
destino(vuelo(NroVuelo,_),Destino):-
    registroVuelo(NroVuelo,Destino, _, _, _).

%Punto 2

destinoDeTrabajo(Destino):-
    registroVuelo(_, Destino, _, _, _),
    findall(Comercio,comercioAdherido(Destino, Comercio),Comercios),
    length(Comercios, 1).  % o que haya uno y se compruebe que no hay otro 
destinoDeTrabajo(Destino):-
    registroVuelo(_, Destino, _, _, _),
    not(hayTuristaAlojado(Destino)).

hayTuristaAlojado(Destino):-
    factura(_, hotel(Comercio,_)),
    comercioAdherido(Destino,Comercio).

%Punto 3

esEstafador(Persona):-
    forall(factura(Persona, Detalle), esInvalidaOMonto0(Detalle)).

esInvalidaOMonto0(DetalleFactura):-
    not(esFacturaValida(DetalleFactura)).
esInvalidaOMonto0(hotel(_,0)).
esInvalidaOMonto0(excursion(_,_,0)).
esInvalidaOMonto0(vuelo(NroVuelo,_)):-
    registroVuelo(NroVuelo, _, _, _, 0).


%noEsValidaOMontoCero(Detalle):- not(facturaValida(Detalle)).
%noEsValidaOMontoCero(Detalle):- montoFactura(Detalle, 0).

%montoFactura(hotel(_,Monto),Monto).
%montoFactura(excursion(_, Monto, _),Monto).
%montoFactura(vuelo(NumeroVuelo,_),Monto):- registroVuelo(NumeroVuelo, _, _, _, Monto).

%Punto 4

%el concepto que nos permite agregar comercios sin modificar el codigo
%es el concepto de acoplamiento y polimorfismo.
%Como el predicado es polimorfico, es decir que puede trabajar con cualquier comercio
%el grado de acomplamiento de los predicados es adecuado ya que nos permite agregar comercios sin la neceisdad de modificar nuestros predicados.
%(estarian desacoplados proque cuando cambio uno, no debo cambiar el otro)