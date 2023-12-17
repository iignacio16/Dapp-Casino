// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./Tipos.sol";

contract Dados{

    address public manager;
    uint256 public dado1;
    uint256 public dado2;
    uint256 public sumaDados;
    uint256 public punto;
   
    
    uint256[] private numDados;

    struct infoApuesta {
        PassOrNotPass[] tipoApuesta;
        mapping(PassOrNotPass => uint256) cantidades;
        mapping(PassOrNotPass => uint256) puntoCraps;
    }

    mapping (address => infoApuesta) private apuestas;

    address payable[] private betsPassNotPassAddress;
    address payable[] private betsComeNotComeAddress;
    address payable[] private betsFieldAddress;
    bool public primeraTirada; //Si no se ha realizado ninguna es false
 
    constructor() payable{
        require(msg.value >= 0.2 ether, "Debes introducir 0.2 ether para desplegar el contrato");
        manager = msg.sender;
        numDados.push(1);
        numDados.push(2);
        numDados.push(3);
        numDados.push(4);
        numDados.push(5);
        numDados.push(6);
    }

    event resultadoDados(uint256 dado1, uint256 dado2);
    event apuestaSucces(string info,address jugador, uint256 cantidad);
    event craps(string craps);
    event nuevoPunto(string s, uint256 punto);
    event puntoApuestasComeNotCome(string tipo, uint256 punto);
 
    modifier validarApuesta(){
        require(msg.value > 0, "Debes apostar una cantidad");
        require(msg.value <= 100, "Apuesta maxima 100 Wei");
        _;
    }


    function lanzarPrimerDado() private view returns (uint256 num){
        uint256 a = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, numDados)))
        % 6;
        return a;
    }

    function lanzarSegundoDado() private view returns (uint256 num){
        uint256 a = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp)))
        % 6;
        return a;
    }

    function haApostadoATipo(infoApuesta storage apuesta, PassOrNotPass tipo) internal view returns (bool) {
        for (uint8 i = 0; i < apuesta.tipoApuesta.length; i++) {
            if (apuesta.tipoApuesta[i] == tipo) {
                return true;
            }
        }
        return false;
    }

    function lanzarDados(address player) public {
        require(player != manager, "El manager no puede lanzar los dados");
        require(betsPassNotPassAddress.length > 0, "Debe haberse realizado alguna apuesta");

        dado1 = numDados[lanzarPrimerDado()];
        dado2 = numDados[lanzarSegundoDado()];

        sumaDados = dado1 + dado2;
        emit resultadoDados(dado1, dado2);

        if(!primeraTirada){ //Si es la primera tirada
            for (int256 i = int256(betsPassNotPassAddress.length) - 1; i >= 0; i--) {
                address payable jugador = betsPassNotPassAddress[uint256(i)];
                if(haApostadoATipo(apuestas[jugador], PassOrNotPass.PassLine)){
                    PrimeraTiradaPass(jugador, sumaDados);   
                }
                if(haApostadoATipo(apuestas[jugador], PassOrNotPass.NotPassLine)){
                    primeraTiradaDontPass(jugador, sumaDados);
                }
            }

        }else{
            for(int256 i = int256(betsPassNotPassAddress.length) - 1; i >= 0; i--){
                address payable jugador1 = betsPassNotPassAddress[uint256(i)];
            //Siguientes tiradas 
                if(haApostadoATipo(apuestas[jugador1], PassOrNotPass.PassLine)){
                    gestionarApuestasPass(jugador1, sumaDados);   
                }
                if(haApostadoATipo(apuestas[jugador1], PassOrNotPass.NotPassLine)){
                    gestionarApuestasDontPassLine(jugador1, sumaDados);
                }

                if(sumaDados == 7 || sumaDados == punto){
                    punto = 0;
                    primeraTirada = false;
                }
            }

            for(int256 i = int256(betsComeNotComeAddress.length) - 1; i >= 0; i--){
                address payable jugador2 = betsComeNotComeAddress[uint256(i)];
                
                if(haApostadoATipo(apuestas[jugador2], PassOrNotPass.Come)){
                    gestionarApuestasCome(jugador2, sumaDados);   
                }
                if(haApostadoATipo(apuestas[jugador2], PassOrNotPass.NotCome)){
                    gestionarApuestasDontCome(jugador2, sumaDados);
                }
            }

            for(int256 i = int256(betsFieldAddress.length) - 1; i >= 0; i--){
                address payable jugador3 = betsFieldAddress[uint256(i)];
                if(primeraTirada){
                    gestionarApuestasField(jugador3, sumaDados);
                }
            }
        }  
    }

    function PrimeraTiradaPass(address payable jugador, uint256 resDados) private {
        infoApuesta storage apuesta = apuestas[jugador];
        if(resDados == 7 || resDados == 11){
            uint256 montoGanado = apuesta.cantidades[PassOrNotPass.PassLine];
            jugador.transfer(montoGanado * 2);
            emit apuestaSucces("Ganan Pass Line numero 7 o 11 en 1 tirada", jugador, montoGanado);
            eliminarApuesta(jugador, PassOrNotPass.PassLine);
        }else if(resDados == 2 || resDados == 3 || resDados == 12){
            emit craps("Apuestas Pass Line pierden");
            eliminarApuesta(jugador, PassOrNotPass.PassLine);
        }else if(punto == 0){
            emit nuevoPunto("El punto es el numero: ", resDados);
            punto = resDados;
            primeraTirada=true;
        }
    }

    function primeraTiradaDontPass(address payable jugador, uint256 resDados) private {
        infoApuesta storage apuesta = apuestas[jugador];

        if(resDados == 7 || resDados == 11){
            emit craps("Apuestas Not pass line pierden");
            eliminarApuesta(jugador, PassOrNotPass.NotPassLine);
        }else if(resDados == 2 || resDados == 3){
            //Se paga 1:1
            uint256 montoGanado = apuesta.cantidades[PassOrNotPass.NotPassLine];
            jugador.transfer(montoGanado * 2);
            emit apuestaSucces("Ganan Not Pass Line numero 2 o 3 en 1 tirada", jugador, montoGanado);
            eliminarApuesta(jugador, PassOrNotPass.NotPassLine);
        }else if(resDados == 12){
            emit apuestaSucces("Empate en apuestas Dont Pass Line, se devuelve el dinero", jugador, apuesta.cantidades[PassOrNotPass.NotPassLine]);
            jugador.transfer(apuesta.cantidades[PassOrNotPass.NotPassLine]);
            eliminarApuesta(jugador, PassOrNotPass.NotPassLine); 
        }else if(punto == 0){
            emit nuevoPunto("El punto es el numero: ", resDados);
            punto = resDados;
            primeraTirada=true;
        }
    }

    function gestionarApuestasPass(address payable jugador, uint256 resDados) private {
        infoApuesta storage apuesta = apuestas[jugador];

        if(resDados == 7){
            emit craps("Apuestas Pass Line pierden");
            eliminarApuesta(jugador,PassOrNotPass.PassLine);
        }else if(resDados == punto){
            uint256 montoGanado;
            if(punto == 4 || punto == 10 ){ //Se paga 2:1
                montoGanado = apuesta.cantidades[PassOrNotPass.PassLine] * 3;
            }else if(punto == 5 || punto == 9){ //Se paga 3:2
                montoGanado = (apuesta.cantidades[PassOrNotPass.PassLine] * 3)/2;
            }else if(punto == 6 || punto == 8){ //Se paga 6:5
                montoGanado = (apuesta.cantidades[PassOrNotPass.PassLine] * 6)/5;
            }
            jugador.transfer(montoGanado);
            emit apuestaSucces("Ganan apuestas Pass Line salio el punto", jugador, montoGanado);
            eliminarApuesta(jugador,PassOrNotPass.PassLine);
        }
    }

    function gestionarApuestasDontPassLine(address payable jugador, uint256 resDados) private {
        infoApuesta storage apuesta = apuestas[jugador];

        if(resDados == 7){
            uint256 montoGanado = apuesta.cantidades[PassOrNotPass.NotPassLine];
                if(punto == 4 || punto == 10 ){ //Se paga 2:1
                    montoGanado = apuesta.cantidades[PassOrNotPass.NotPassLine] * 3;
                    //Se le devuelve lo que apuesta, mas lo que gana
                }else if(punto == 5 || punto == 9){ //Se paga 3:2
                    montoGanado = (apuesta.cantidades[PassOrNotPass.NotPassLine] * 3)/2;
                }else if(punto == 6 || punto == 8){ //Se paga 6:5
                    montoGanado = (apuesta.cantidades[PassOrNotPass.NotPassLine] * 6)/5;
                }
            jugador.transfer(montoGanado);
            emit apuestaSucces("Ganan Not Pass numero 7 en la tirada", jugador, montoGanado);
            eliminarApuesta(jugador,PassOrNotPass.NotPassLine);
        }else if(resDados == punto){
            emit craps("Apuestas Dont Pass Line pierden");
            eliminarApuesta(jugador,PassOrNotPass.NotPassLine);
        }
    }

    function gestionarApuestasCome(address payable jugador, uint256 resDados) private {
        infoApuesta storage apuesta = apuestas[jugador];
        if(resDados == 7){
            //Tiene asignado un punto, la apuesta come
            if(apuesta.puntoCraps[PassOrNotPass.Come] > 0){
                emit craps("Apuesta Come pierde, 7 antes que su punto");
            }else{
                uint256 montoGanado2 = apuesta.cantidades[PassOrNotPass.Come];
                jugador.transfer(montoGanado2 * 2);
                emit apuestaSucces("Ganan apuestas Come numero 7 en la tirada", jugador, montoGanado2);
            }
        eliminarApuesta(jugador, PassOrNotPass.Come);
        }else if(resDados == 11){
            //No tiene asignado punto
            if(apuesta.puntoCraps[PassOrNotPass.Come] == 0){
            uint256 montoGanado2 = apuesta.cantidades[PassOrNotPass.Come];
            jugador.transfer(montoGanado2 * 2);
            emit apuestaSucces("Ganan apuestas Come numero 11 en la tirada", jugador, montoGanado2);
            eliminarApuesta(jugador,PassOrNotPass.Come);
            }

        }else if(resDados == 2 || resDados == 3 || resDados == 12){
            if(apuesta.puntoCraps[PassOrNotPass.Come] == 0){
                emit craps("Craps, apuestas Come pierden");
                eliminarApuesta(jugador,PassOrNotPass.Come);
            }
        }else{ 
            if(apuesta.puntoCraps[PassOrNotPass.Come] > 0){
                uint256 montoGanado;
                uint256 p = apuesta.puntoCraps[PassOrNotPass.Come];
                if(p == resDados){
                    if(p == 4 || p == 10 ){ //Se paga 2:1
                        montoGanado = apuesta.cantidades[PassOrNotPass.Come] * 3;
                    }else if(p == 5 || p == 9){ //Se paga 3:2
                        montoGanado = (apuesta.cantidades[PassOrNotPass.Come] * 3)/2;
                    }else if(p == 6 || p == 8){ //Se paga 6:5
                        montoGanado = (apuesta.cantidades[PassOrNotPass.Come] * 6)/5;
                    }
                jugador.transfer(montoGanado);
                emit apuestaSucces("Ganan apuestas Come salio el punto de su apuesta", jugador, montoGanado);
                eliminarApuesta(jugador,PassOrNotPass.Come);
                }
            }else{
                apuesta.puntoCraps[PassOrNotPass.Come] = resDados;
                emit puntoApuestasComeNotCome("Apuesta Come punto:", apuesta.puntoCraps[PassOrNotPass.Come]);
            }
        } 
    }

    function gestionarApuestasDontCome(address payable jugador, uint256 resDados) private {
        infoApuesta storage apuesta = apuestas[jugador];
        if(resDados == 7){
            //Tiene asignado un punto la apuesta DONT COME, se paga en  funcion del punto asginado
            if(apuesta.puntoCraps[PassOrNotPass.NotCome]>0){
                uint256 pDontCome = apuesta.puntoCraps[PassOrNotPass.NotCome];
                uint256 montoGanado3 = apuesta.cantidades[PassOrNotPass.NotCome];
                if(pDontCome == 4 || pDontCome == 10 ){ //Se paga 2:1
                    montoGanado3 = apuesta.cantidades[PassOrNotPass.NotCome] * 3;
                    //Se le devuelve lo que apuesta, mas lo que gana
                }else if(pDontCome == 5 || pDontCome == 9){ //Se paga 3:2
                    montoGanado3 = (apuesta.cantidades[PassOrNotPass.NotCome] * 3)/2;
                }else if(pDontCome == 6 || pDontCome == 8){ //Se paga 6:5
                    montoGanado3 = (apuesta.cantidades[PassOrNotPass.NotCome] * 6)/5;
                }
                jugador.transfer(montoGanado3);
                emit apuestaSucces("Ganan Dont Come numero 7 antes que su punto", jugador, montoGanado3); 
            }else{
                 emit craps("Apuesta Dont Come pierde, numero 7");
            }
            eliminarApuesta(jugador,PassOrNotPass.NotCome);
        }else if(resDados == 11){
            if(apuesta.puntoCraps[PassOrNotPass.NotCome] == 0){
                emit craps("Apuestas Dont Come pierden numero 11 en la tirada");
                eliminarApuesta(jugador,PassOrNotPass.NotCome);
            }
        }else if(resDados == 2 || resDados == 3 || resDados == 12){
            if(apuesta.puntoCraps[PassOrNotPass.NotCome] == 0){
                uint256 montoGanado4 = apuesta.cantidades[PassOrNotPass.NotCome];
                jugador.transfer(montoGanado4 * 2);
                emit apuestaSucces("Ganan Dont Come numero 2,3 o 12", jugador, montoGanado4);
                 eliminarApuesta(jugador,PassOrNotPass.NotCome);
            }
        }else{
            if(apuesta.puntoCraps[PassOrNotPass.NotCome] == 0){
                apuesta.puntoCraps[PassOrNotPass.NotCome] = resDados;
                emit puntoApuestasComeNotCome("Apuesta Dont Come Punto:", apuesta.puntoCraps[PassOrNotPass.NotCome]);
            }
        }
    }

    function gestionarApuestasField(address payable jugador, uint256 resDados) private {
        infoApuesta storage apuesta = apuestas[jugador];

        if(resDados == 3 || resDados == 4 || resDados == 9 || resDados == 10 || resDados == 11){
            uint256 montoGanado = apuesta.cantidades[PassOrNotPass.Field] * 2;
            jugador.transfer(montoGanado);
            emit apuestaSucces("Apuesta Field ganada", jugador, montoGanado);
        }else if(resDados == 2 || resDados == 12){
            uint256 montoGanado = apuesta.cantidades[PassOrNotPass.Field] * 3;
            jugador.transfer(montoGanado);
            emit apuestaSucces("Apuesta Field ganada", jugador, montoGanado);
        }else{
            emit craps("Apuestas field perdieron");
        }
        eliminarApuesta(jugador,PassOrNotPass.Field);
        
    }   

    function hacerApuesta(PassOrNotPass tipoApst, uint256 cantidad, address player) private {
        infoApuesta storage apuesta = apuestas[player];
        if(apuesta.cantidades[tipoApst] > 0){
            //El jugador ya tiene apuesta de este tipo
            apuesta.cantidades[tipoApst] += cantidad;
        }else{
            //Primera apuesta del jugador a este tipo de Apuesta
            apuesta.tipoApuesta.push(tipoApst);
            apuesta.cantidades[tipoApst] = cantidad;
        }
    }

    function passLine(address player) public validarApuesta payable {
        require(!primeraTirada, "La primera tirada ya se realizo");
        bool yaAposto = haApostadoATipo(apuestas[player], PassOrNotPass.PassLine);
        hacerApuesta(PassOrNotPass.PassLine, msg.value, player);
        
        if (!yaAposto) {
            betsPassNotPassAddress.push(payable(player));
        }

        emit apuestaSucces("Apuesta Pass Line realizada: ", player, msg.value);
    }

    function notPassLine(address player) public validarApuesta payable {
        require(!primeraTirada, "La primera tirada ya se realizo");
        bool yaAposto = haApostadoATipo(apuestas[player], PassOrNotPass.NotPassLine);
        hacerApuesta(PassOrNotPass.NotPassLine, msg.value, player);

        if (!yaAposto) {
            betsPassNotPassAddress.push(payable(player));
        }
        
        emit apuestaSucces("Apuesta Not Pass Line realizada: ", player, msg.value);
    }

    function dontComeBet(address player) public validarApuesta payable {
        require(primeraTirada, "Debe haberse realizado la primera tirada");
        require(apuestas[player].puntoCraps[PassOrNotPass.NotCome] == 0, "Ya tienes una apuesta Dont Come realizada");

        bool yaAposto = haApostadoATipo(apuestas[player], PassOrNotPass.NotCome);
        hacerApuesta(PassOrNotPass.NotCome, msg.value, player);

        if(!yaAposto){
            bool addressEnArray = false;
            for (uint256 i = 0; i < betsComeNotComeAddress.length; i++) {
                if (betsComeNotComeAddress[i] == payable(player)) {
                    addressEnArray = true;
                    break;
                }
        }

        if (!addressEnArray) {
            betsComeNotComeAddress.push(payable(player));
        }
        }
        emit apuestaSucces("Apuesta Dont Come realizada: ", player, msg.value);
    }

    function comeBet(address player) public validarApuesta payable {
        require(primeraTirada, "Debe haberse realizado la primera tirada");
        require(apuestas[player].puntoCraps[PassOrNotPass.Come] == 0, "Ya tienes una apuesta Come realizada");
        

        bool yaAposto = haApostadoATipo(apuestas[player], PassOrNotPass.Come);
        hacerApuesta(PassOrNotPass.Come, msg.value, player);

        if(!yaAposto){
            bool addressEnArray = false;
            for (uint256 i = 0; i < betsComeNotComeAddress.length; i++) {
                if (betsComeNotComeAddress[i] == payable(player)) {
                    addressEnArray = true;
                    break;
                }
        }

        if (!addressEnArray) {
            betsComeNotComeAddress.push(payable(player));
        }
        }

        emit apuestaSucces("Apuesta Come realizada: ", player, msg.value);
    }

    function fieldBet(address player) public validarApuesta payable{
        require(primeraTirada, "Debe haberse realizado la primera tirada");

        bool yaAposto = haApostadoATipo(apuestas[player], PassOrNotPass.Field);
        hacerApuesta(PassOrNotPass.Field, msg.value, player);

        if(!yaAposto){
            betsFieldAddress.push(payable(player));
        }

        emit apuestaSucces("Apuesta Field realizada: ", player, msg.value);
    }

    // Función para obtener la información de apuesta de un jugador
    function obtenerInfoApuesta(address jugador) public view returns (PassOrNotPass[] memory, uint256[] memory) {
        infoApuesta storage apuesta = apuestas[jugador];
        uint256 tiposDeApuestas = apuesta.tipoApuesta.length;

        PassOrNotPass[] memory tipoApuesta = new PassOrNotPass[](tiposDeApuestas);
        uint256[] memory cantidades = new uint256[](tiposDeApuestas);

        for (uint256 i = 0; i < tiposDeApuestas; i++) {
            tipoApuesta[i] = apuesta.tipoApuesta[i];
            cantidades[i] = apuesta.cantidades[apuesta.tipoApuesta[i]];
        }

        return (tipoApuesta, cantidades);
    }

    function eliminarApuesta(address payable jugador, PassOrNotPass tipoApuesta) private {
        // Elimina la apuesta específica del jugador
        infoApuesta storage apuesta = apuestas[jugador];

        // Encuentra la posición del tipo de apuesta en el array
        uint256 indexToDelete;
        for (uint256 i = 0; i < apuesta.tipoApuesta.length; i++) {
            if (apuesta.tipoApuesta[i] == tipoApuesta) {
                indexToDelete = i;
                break;
            }
        }

        // Elimina la dirección del array
        if (indexToDelete < apuesta.tipoApuesta.length) {
            // Mueve el último elemento al lugar del que se va a eliminar
            apuesta.tipoApuesta[indexToDelete] = apuesta.tipoApuesta[apuesta.tipoApuesta.length - 1];
            apuesta.cantidades[tipoApuesta] = 0; // Establece la cantidad en 0
            apuesta.tipoApuesta.pop(); // Elimina el último elemento del array
        }

        if(tipoApuesta == PassOrNotPass.Come || tipoApuesta == PassOrNotPass.NotCome){
            apuesta.puntoCraps[tipoApuesta] = 0;
        }

        // Elimina la dirección del array correspondiente
        address payable[] memory betsAddress;

        if (tipoApuesta == PassOrNotPass.PassLine || tipoApuesta == PassOrNotPass.NotPassLine) {
            betsAddress = betsPassNotPassAddress;
        } else if (tipoApuesta == PassOrNotPass.Come || tipoApuesta == PassOrNotPass.NotCome) {
            betsAddress = betsComeNotComeAddress;
        } else if (tipoApuesta == PassOrNotPass.Field) {
            betsAddress = betsFieldAddress;
        }

        // Encuentra la posición de la dirección en el array
        uint256 indexToDeleteAddress;
        for (uint256 i = 0; i < betsAddress.length; i++) {
            if (betsAddress[i] == jugador) {
                indexToDeleteAddress = i;
                break;
            }
        }

        // Elimina la dirección del array
        if (indexToDeleteAddress < betsAddress.length) {
            // Mueve el último elemento al lugar del que se va a eliminar
            betsAddress[indexToDeleteAddress] = betsAddress[betsAddress.length - 1];
            betsAddress = eliminarUltimoElemento(betsAddress); // Elimina el último elemento del array
        }

        // Actualiza el array de estado con las direcciones actualizadas
        if (tipoApuesta == PassOrNotPass.PassLine || tipoApuesta == PassOrNotPass.NotPassLine) {
         betsPassNotPassAddress = betsAddress;
        } else if (tipoApuesta == PassOrNotPass.Come || tipoApuesta == PassOrNotPass.NotCome) {
            betsComeNotComeAddress = betsAddress;
        } else if (tipoApuesta == PassOrNotPass.Field) {
         betsFieldAddress = betsAddress;
        }
    }

// Función auxiliar para eliminar el último elemento de un array dinámico de direcciones
    function eliminarUltimoElemento(address payable[] memory array) private pure returns (address payable[] memory) {
        require(array.length > 0, "El array esta vacio");
        address payable[] memory nuevoArray = new address payable[](array.length - 1);
        for (uint256 i = 0; i < array.length - 1; i++) {
            nuevoArray[i] = array[i];
        }
        return nuevoArray;
    }
}