// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

import "./Ruleta.sol";
import "./Dados.sol";
import "./Tipos.sol";

contract Casino{
    Ruleta public ruletaContract;
    Dados public crapsContract;
    address public manager;

    modifier onlyManager() {
        require(msg.sender == manager, "Solo el manager puede llamar a esta funcion");
        _;
    }

    modifier notManager(){
        require(msg.sender != manager, "El manager no puede apostar");
        _;
    }

    constructor(address _ruletaAddress, address _dadosAddress) payable{
        manager = msg.sender;
        //Inicializar instancias de los contratos
        ruletaContract = Ruleta(_ruletaAddress);
        crapsContract =  Dados(_dadosAddress);
    }

    function apostarNumeroEnRuleta(uint8 num) public notManager payable{
    // Llamamos a la función apuestaNumero del contrato Ruleta con la dirección del jugador
    ruletaContract.apuestaNumero{value: msg.value}(num, msg.sender);
    }

    function apostarColorEnRuleta(string memory col) public notManager payable{
        ruletaContract.apuestaColor{value: msg.value}(col, msg.sender);
    }

    function apostarParOImparRuleta(string memory par) public notManager payable{
        ruletaContract.apuestaPar{value: msg.value}(par, msg.sender);
    }

    function obtenerApuestasJug() public view notManager returns (    
        uint256[] memory numbers,
        uint[] memory cantidadesNumeros,
        string[] memory colores,
        uint[] memory cantidadesColores,
        string[] memory paridades,
        uint[] memory cantidadesParidades) {
        return ruletaContract.obtenerApuestasJugador(msg.sender);
    }

    function lanzarBolaRuleta() public onlyManager returns (uint256, string memory, string memory){
        return ruletaContract.girarRuleta();
    }

    //Funciones relacionadas con Craps
    function lanzarDadosCraps() public notManager {
        crapsContract.lanzarDados(msg.sender);
    }

    function apostarPassLine() public notManager payable{
        crapsContract.passLine{value: msg.value}(msg.sender);
    }

    function apostarDontPassLine() public notManager payable{
        crapsContract.notPassLine{value: msg.value}(msg.sender);
    }

    function apostarCome() public notManager payable{
        crapsContract.comeBet{value: msg.value}(msg.sender);
    }

    function apostarDontCome() public notManager payable{
        crapsContract.dontComeBet{value: msg.value}(msg.sender);
    }

    function apostarField() public notManager payable {
        crapsContract.fieldBet{value: msg.value}(msg.sender);
    }

    function obtenerApuestasJugadorCraps() public view notManager returns (PassOrNotPass[] memory, uint256[] memory){
        return crapsContract.obtenerInfoApuesta(msg.sender);
    }

}