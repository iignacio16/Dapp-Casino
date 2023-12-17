// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Ruleta {
    struct Numero {
        uint256 numero;
        string color;
    }

    struct ApuestaNums {
        uint256[] numero;
        uint[] cantidad;
    }

    struct ApuestaPar {
        string[] paridad;
        uint[] cantidad;
    }

    struct ApuestaColor {
        string[] color;
        uint[] cantidad;
    }

    Numero[] private numeros;

    mapping(address => ApuestaNums) private BetsNum;
    mapping(address => ApuestaPar) private BetsPar;
    mapping(address => ApuestaColor) private BetsColor;

    address payable[] private jugadores; //Array con las address de los jugadores que apuestan
    mapping(address => bool) private apuestaJugador; //Para controlar si el jugador ya ha apostado

    uint8 private numApuestas;
    uint8 private colorApuestas;
    uint8 private parApuestas;

    address public manager;

    modifier validarApuesta() {
        require(msg.value > 0, "Debes apostar una cantidad");
        require(msg.value <= 1000, "Apuesta maxima 1000 Wei");
        _;
    }

    constructor() payable {
        require(
            msg.value >= 0.3 ether,
            "Debes introducir 0.3 ether para desplegar el contrato"
        );
        manager = msg.sender;
        numeros.push(Numero(0, "verde"));
        numeros.push(Numero(32, "rojo"));
        numeros.push(Numero(15, "negro"));
        numeros.push(Numero(19, "rojo"));
        numeros.push(Numero(4, "negro"));
        numeros.push(Numero(21, "rojo"));
        numeros.push(Numero(2, "negro"));
        numeros.push(Numero(25, "rojo"));
        numeros.push(Numero(17, "negro"));
        numeros.push(Numero(34, "rojo"));
        numeros.push(Numero(6, "negro"));
        numeros.push(Numero(27, "rojo"));
        numeros.push(Numero(13, "negro"));
        numeros.push(Numero(36, "rojo"));
        numeros.push(Numero(11, "negro"));
        numeros.push(Numero(30, "rojo"));
        numeros.push(Numero(8, "negro"));
        numeros.push(Numero(23, "rojo"));
        numeros.push(Numero(10, "negro"));
        numeros.push(Numero(5, "rojo"));
        numeros.push(Numero(24, "negro"));
        numeros.push(Numero(16, "rojo"));
        numeros.push(Numero(33, "negro"));
        numeros.push(Numero(1, "rojo"));
        numeros.push(Numero(20, "negro"));
        numeros.push(Numero(14, "rojo"));
        numeros.push(Numero(31, "negro"));
        numeros.push(Numero(9, "rojo"));
        numeros.push(Numero(22, "negro"));
        numeros.push(Numero(18, "rojo"));
        numeros.push(Numero(29, "negro"));
        numeros.push(Numero(7, "rojo"));
        numeros.push(Numero(28, "negro"));
        numeros.push(Numero(12, "rojo"));
        numeros.push(Numero(35, "negro"));
        numeros.push(Numero(3, "rojo"));
        numeros.push(Numero(26, "negro"));
    }

    event GiroRuleta(uint256 numero, string color, string par);
    event ApuestaNumero(uint256 numero, uint cantidad);
    event ApuestaColorPar(string nombre, uint cantidad);
    event ApuestaGanadora(string apuesta, address jugador, uint cantidad);

    function Paridad(uint256 num) private pure returns (string memory) {
        return num % 2 == 0 ? "par" : "impar";
    }

    function apuestaNumero(
        uint8 num,
        address jugador
    ) public payable validarApuesta {
        require(num < 37, "Debe ser un numero entre 0 y 36");

        bool existeApuesta = false;

        for (uint i = 0; i < BetsNum[jugador].numero.length; i++) {
            if (BetsNum[jugador].numero[i] == num) {
                // Si ya ha apostado a este número, actualiza la cantidad apostada
                BetsNum[jugador].cantidad[i] += msg.value;
                existeApuesta = true;
                break;
            }
        }

        if (!existeApuesta) {
            // Si no ha apostado a este número, agrega una nueva apuesta
            BetsNum[jugador].numero.push(num);
            BetsNum[jugador].cantidad.push(msg.value);
        }

        // Si es la primera apuesta del jugador, agrégalo a la lista de jugadores
        if (!apuestaJugador[jugador]) {
            jugadores.push(payable(jugador));
            apuestaJugador[jugador] = true;
        }

        numApuestas += 1;
        emit ApuestaNumero(num, msg.value);
    }

    function apuestaColor(
        string memory col,
        address jugador
    ) public payable validarApuesta {
        require(
            keccak256(abi.encodePacked(col)) ==
                keccak256(abi.encodePacked("rojo")) ||
                keccak256(abi.encodePacked(col)) ==
                keccak256(abi.encodePacked("negro")),
            "El color debe ser rojo o negro"
        );

        if (BetsColor[jugador].color.length == 0) {
            BetsColor[jugador].color.push(col);
            BetsColor[jugador].cantidad.push(msg.value);
        } else {
            bool encontrada = false;
            for (uint i = 0; i < BetsColor[jugador].color.length; i++) {
                if (
                    keccak256(abi.encodePacked(BetsColor[jugador].color[i])) ==
                    keccak256(abi.encodePacked(col))
                ) {
                    BetsColor[jugador].cantidad[i] += msg.value;
                    encontrada = true;
                    break;
                }
            }

            if (!encontrada) {
                BetsColor[jugador].color.push(col);
                BetsColor[jugador].cantidad.push(msg.value);
            }
        }

        if (!apuestaJugador[jugador]) {
            jugadores.push(payable(jugador));
            apuestaJugador[jugador] = true;
        }

        colorApuestas += 1;
        emit ApuestaColorPar(col, msg.value);
    }

    function apuestaPar(
        string memory par,
        address jugador
    ) public payable validarApuesta {
        require(
            keccak256(abi.encodePacked(par)) ==
                keccak256(abi.encodePacked("par")) ||
                keccak256(abi.encodePacked(par)) ==
                keccak256(abi.encodePacked("impar")),
            "par o impar"
        );

        if (BetsPar[jugador].paridad.length == 0) {
            BetsPar[jugador].paridad.push(par);
            BetsPar[jugador].cantidad.push(msg.value);
        } else {
            for (uint i = 0; i < BetsPar[jugador].paridad.length; i++) {
                if (
                    keccak256(abi.encodePacked(BetsPar[jugador].paridad[i])) ==
                    keccak256(abi.encodePacked(par))
                ) {
                    uint256 totalApuesta = msg.value;
                    totalApuesta += BetsPar[jugador].cantidad[i] += msg.value;
                    require(
                        totalApuesta < 1000,
                        "La apuesta supera el limite permitido"
                    );
                } else {
                    BetsPar[jugador].paridad.push(par);
                    BetsPar[jugador].cantidad.push(msg.value);
                }
            }
        }

        if (!apuestaJugador[jugador]) {
            jugadores.push(payable(jugador));
            apuestaJugador[jugador] = true;
        }
        parApuestas += 1;
        emit ApuestaColorPar(par, msg.value);
    }

    function girarRuleta()
        public
        payable
        returns (uint256, string memory, string memory)
    {
        require(
            numApuestas > 0 || colorApuestas > 0 || parApuestas > 0,
            "Debe haberse realizado alguna apuesta"
        );
        uint256 indice = uint256(
            keccak256(
                abi.encodePacked(block.difficulty, block.timestamp, jugadores)
            )
        ) % numeros.length;
        string memory par = Paridad(numeros[indice].numero);

        emit GiroRuleta(numeros[indice].numero, numeros[indice].color, par);

        for (uint i = 0; i < jugadores.length; i++) {
            address payable jugadorAddress = jugadores[i];

            // Almacena las apuestas ganadoras para este jugador
            uint256 ganancias = 0;

            for (uint j = 0; j < BetsNum[jugadorAddress].numero.length; j++) {
                if (
                    BetsNum[jugadorAddress].numero[j] == numeros[indice].numero
                ) {
                    ganancias += BetsNum[jugadorAddress].cantidad[j] * 36;
                    emit ApuestaGanadora(
                        "apuesta a numero",
                        jugadorAddress,
                        BetsNum[jugadorAddress].cantidad[j] * 36
                    );
                }
            }

            for (uint k = 0; k < BetsColor[jugadorAddress].color.length; k++) {
                if (
                    keccak256(
                        abi.encodePacked(BetsColor[jugadorAddress].color[k])
                    ) == keccak256(abi.encodePacked(numeros[indice].color))
                ) {
                    ganancias += BetsColor[jugadorAddress].cantidad[k] * 2;
                    emit ApuestaGanadora(
                        "apuesta a color",
                        jugadorAddress,
                        BetsColor[jugadorAddress].cantidad[k] * 2
                    );
                }
            }

            for (uint l = 0; l < BetsPar[jugadorAddress].paridad.length; l++) {
                if (
                    keccak256(
                        abi.encodePacked(BetsPar[jugadorAddress].paridad[l])
                    ) == keccak256(abi.encodePacked(par))
                ) {
                    ganancias += BetsPar[jugadorAddress].cantidad[l] * 2;
                    emit ApuestaGanadora(
                        "Apuesta a par o impar",
                        jugadorAddress,
                        BetsPar[jugadorAddress].cantidad[l] * 2
                    );
                }
            }

            // Realiza el pago de las ganancias al jugador
            if (ganancias > 0) {
                jugadorAddress.transfer(ganancias);
            }

            // Elimina las apuestas para este jugador
            delete BetsNum[jugadorAddress];
            delete BetsColor[jugadorAddress];
            delete BetsPar[jugadorAddress];
            apuestaJugador[jugadorAddress] = false;
        }

        // Restablece los contadores de apuestas después del bucle
        numApuestas = 0;
        colorApuestas = 0;
        parApuestas = 0;

        // Restablece la lista de jugadores después de procesar todos
        jugadores = new address payable[](0);

        return (numeros[indice].numero, numeros[indice].color, par);
    }

    // Función para obtener todas las apuestas de un jugador
    function obtenerApuestasJugador(
        address jugador
    )
        external
        view
        returns (
            uint256[] memory numbers,
            uint[] memory cantidadesNumeros,
            string[] memory colores,
            uint[] memory cantidadesColores,
            string[] memory paridades,
            uint[] memory cantidadesParidades
        )
    {
        numbers = BetsNum[jugador].numero;
        cantidadesNumeros = BetsNum[jugador].cantidad;

        colores = BetsColor[jugador].color;
        cantidadesColores = BetsColor[jugador].cantidad;

        paridades = BetsPar[jugador].paridad;
        cantidadesParidades = BetsPar[jugador].cantidad;
    }
}
