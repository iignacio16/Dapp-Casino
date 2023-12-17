export const Casino = [
  {
    "inputs": [
      {
        "internalType": "address",
        "name": "_ruletaAddress",
        "type": "address"
      },
      {
        "internalType": "address",
        "name": "_dadosAddress",
        "type": "address"
      }
    ],
    "stateMutability": "payable",
    "type": "constructor",
    "payable": true
  },
  {
    "inputs": [],
    "name": "crapsContract",
    "outputs": [
      {
        "internalType": "contract Dados",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "inputs": [],
    "name": "manager",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "inputs": [],
    "name": "ruletaContract",
    "outputs": [
      {
        "internalType": "contract Ruleta",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "inputs": [
      {
        "internalType": "uint8",
        "name": "num",
        "type": "uint8"
      }
    ],
    "name": "apostarNumeroEnRuleta",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function",
    "payable": true
  },
  {
    "inputs": [
      {
        "internalType": "string",
        "name": "col",
        "type": "string"
      }
    ],
    "name": "apostarColorEnRuleta",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function",
    "payable": true
  },
  {
    "inputs": [
      {
        "internalType": "string",
        "name": "par",
        "type": "string"
      }
    ],
    "name": "apostarParOImparRuleta",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function",
    "payable": true
  },
  {
    "inputs": [],
    "name": "obtenerApuestasJug",
    "outputs": [
      {
        "internalType": "uint256[]",
        "name": "numbers",
        "type": "uint256[]"
      },
      {
        "internalType": "uint256[]",
        "name": "cantidadesNumeros",
        "type": "uint256[]"
      },
      {
        "internalType": "string[]",
        "name": "colores",
        "type": "string[]"
      },
      {
        "internalType": "uint256[]",
        "name": "cantidadesColores",
        "type": "uint256[]"
      },
      {
        "internalType": "string[]",
        "name": "paridades",
        "type": "string[]"
      },
      {
        "internalType": "uint256[]",
        "name": "cantidadesParidades",
        "type": "uint256[]"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  },
  {
    "inputs": [],
    "name": "lanzarBolaRuleta",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      },
      {
        "internalType": "string",
        "name": "",
        "type": "string"
      },
      {
        "internalType": "string",
        "name": "",
        "type": "string"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "lanzarDadosCraps",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "apostarPassLine",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function",
    "payable": true
  },
  {
    "inputs": [],
    "name": "apostarDontPassLine",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function",
    "payable": true
  },
  {
    "inputs": [],
    "name": "apostarCome",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function",
    "payable": true
  },
  {
    "inputs": [],
    "name": "apostarDontCome",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function",
    "payable": true
  },
  {
    "inputs": [],
    "name": "apostarField",
    "outputs": [],
    "stateMutability": "payable",
    "type": "function",
    "payable": true
  },
  {
    "inputs": [],
    "name": "obtenerApuestasJugadorCraps",
    "outputs": [
      {
        "internalType": "enum PassOrNotPass[]",
        "name": "",
        "type": "uint8[]"
      },
      {
        "internalType": "uint256[]",
        "name": "",
        "type": "uint256[]"
      }
    ],
    "stateMutability": "view",
    "type": "function",
    "constant": true
  }
];