import React, { useState, useEffect } from "react";
import { Casino } from "./abi/abi";
import Web3 from "web3";
import "./App.css";

const web3 = new Web3(window.ethereum);
const casinoContractAddress = "0xF3A7c5E65357eFE9C348c05803120dDd53b7CBD5";
const casinoContract = new web3.eth.Contract(Casino, casinoContractAddress);

function App() {
  const [number, setUint] = useState(0);
  const [color, setColor] = useState("");
  const [paridad, setParidad] = useState("");
  const [apuestaAmountWei, setApuestaAmountWei] = useState("0");
  const [getResults, setResults] = useState("");
  const [getResultsRuleta, setResultsRuleta] = useState("");
  const [getHash, setHash] = useState(" ");
  const [getHashCraps, setHashCraps] = useState(" ");
  const [selectedAccount, setSelectedAccount] = useState("");


  useEffect(() => {
    // Configura un event listener para detectar cambios en la cuenta de MetaMask
    const updateSelectedAccount = async () => {
      const accounts = await web3.eth.getAccounts();
      setSelectedAccount(accounts[0]);
    };
    // Llama a la función una vez para establecer la cuenta inicial
    updateSelectedAccount();
    // Configura el event listener
    window.ethereum.on("accountsChanged", updateSelectedAccount);
    // Limpia el event listener al desmontar el componente
    return () => {
      window.ethereum.removeListener("accountsChanged", updateSelectedAccount);
    };
  }, []);

  const apostarColorEnRuleta = async (e) => {
    e.preventDefault();
    try {
      // Obtener la cantidad de apuesta en Wei
      const apuestaAmountWeiInt = parseInt(apuestaAmountWei, 10);
      // Estimar gas manualmente
      const gas = 300000;
      // Realizar la transacción
      const result = await casinoContract.methods
        .apostarColorEnRuleta(color)
        .send({
          from: selectedAccount,
          gas,
          value: apuestaAmountWeiInt,
        });

      setResultsRuleta(`Apuesta realizada con éxito`);
      setHash(`Hash de la transaccion: ${result.transactionHash}`);
    } catch (error) {
      console.error("Error al realizar la apuesta:", error);
      setResultsRuleta(`Error al realizar la apuesta: ${error.message}`);
      setHash(`Error en la transaccion`);
    }
  };

  const apostarNumeroEnRuleta = async (e) => {
    e.preventDefault();
    try {
      const apuestaAmountWeiInt = parseInt(apuestaAmountWei, 10);
      const numeroSeleccionado = parseInt(number, 10);
      const gas = 300000;

      const result = await casinoContract.methods
        .apostarNumeroEnRuleta(numeroSeleccionado)
        .send({
          from: selectedAccount,
          gas,
          value: apuestaAmountWeiInt,
        });

      setResultsRuleta(`Apuesta realizada con éxito`);
      setHash(`Hash de la transaccion: ${result.transactionHash}`);
    } catch (error) {
      console.error("Error al realizar la apuesta:", error);
      setResultsRuleta(`Error al realizar la apuesta: ${error.message}`);
      setHash(`Error en la transaccion`);
    }
  };

  const apostarParOImparRuleta = async (e) => {
    e.preventDefault();
    try {
      const apuestaAmountWeiInt = parseInt(apuestaAmountWei, 10);
      const paridadSeleccionada = paridad.toLowerCase(); // Convertir a minúsculas para coincidir con la función del contrato
      const gas = 300000;

      const result = await casinoContract.methods
        .apostarParOImparRuleta(paridadSeleccionada)
        .send({
          from: selectedAccount,
          gas,
          value: apuestaAmountWeiInt,
        });

      setResultsRuleta(`Apuesta realizada con éxito`);
      setHash(`Hash de la transaccion: ${result.transactionHash}`);
    } catch (error) {
      console.error("Error al realizar la apuesta:", error);
      setResultsRuleta(`Error al realizar la apuesta: ${error.message}`);
      setHash(`Error en la transaccion`);
    }
  };

  const checkNetworkAndAccounts = async () => {
    const accounts = await window.ethereum.request({
      method: "eth_requestAccounts",
    });
    setSelectedAccount(accounts[0]);
    const networkId = await web3.eth.net.getId();
    if (networkId !== 11155111) {
      console.warn("Conectese a la red de pruebas Sepolia");
    }
  };

  const lanzarBolaRuleta = async () => {
    try {
      const result = await casinoContract.methods
        .lanzarBolaRuleta()
        .send({ from: selectedAccount, gas: 300000 });
      setResultsRuleta(`Bolita Lanzada`);
      setHash(`Hash de la transaccion: ${result.transactionHash}`);
      console.log(result.transactionHash);
    } catch (error) {
      console.error("Error al lanzar la bola en la ruleta:", error);
      setResultsRuleta(`Error al lanzar la bola en la ruleta: ${error.message}`);
    }
  };

  const obtenerApuestasJug = async () => {
    try {
      await checkNetworkAndAccounts();
      const result = await casinoContract.methods
        .obtenerApuestasJug()
        .call({ from: selectedAccount });

      const numbers = result[0];
      const cantidadesNumeros = result[1];
      const colores = result[2];
      const cantidadesColores = result[3];
      const paridades = result[4];
      const cantidadesParidades = result[5];

      const formattedResults = `
        Números: ${numbers.join(", ")}
        Cantidades Números: ${cantidadesNumeros.join(", ")}
        Colores: ${colores.join(", ")}
        Cantidades Colores: ${cantidadesColores.join(", ")}
        Paridades: ${paridades.join(", ")}
        Cantidades Paridades: ${cantidadesParidades.join(", ")}
      `;

      setResultsRuleta(formattedResults);
    } catch (error) {
      console.error("Error al obtener las apuestas del jugador:", error);
      setResultsRuleta(`Error al obtener las apuestas del jugador: ${error.message}`);
    }
  };

  const apostarPassLine = async (e) => {
    e.preventDefault();
    try {
      const apuestaAmountWeiInt = parseInt(apuestaAmountWei, 10);
      const gas = 300000;
  
      const result = await casinoContract.methods
        .apostarPassLine()
        .send({
          from: selectedAccount,
          gas,
          value: apuestaAmountWeiInt,
        });
  
      setResults(`Apuesta Pass Line en Craps realizada con éxito`);
      setHashCraps(`Hash de la transacción: ${result.transactionHash}`);
    } catch (error) {
      console.error("Error al realizar la apuesta Pass Line en Craps:", error);
      setResults(`Error al realizar la apuesta Pass Line en Craps: ${error.message}`);
      setHashCraps(`Error en la transacción`);
    }
  };
  const apostarDontPassLine = async (e) => {
    e.preventDefault();
    try {
      const apuestaAmountWeiInt = parseInt(apuestaAmountWei, 10);
      const gas = 300000;
  
      const result = await casinoContract.methods
        .apostarDontPassLine()
        .send({
          from: selectedAccount,
          gas,
          value: apuestaAmountWeiInt,
        });
  
      setResults(`Apuesta Dont Pass Line en Craps realizada con éxito`);
      setHashCraps(`Hash de la transacción: ${result.transactionHash}`);
    } catch (error) {
      console.error("Error al realizar la apuesta Dont Pass Line en Craps:", error);
      setResults(`Error al realizar la apuesta Dont Pass Line en Craps: ${error.message}`);
      setHashCraps(`Error en la transacción`);
    }
  };
  const apostarCome = async (e) => {
    e.preventDefault();
    try {
      const apuestaAmountWeiInt = parseInt(apuestaAmountWei, 10);
      const gas = 300000;
  
      const result = await casinoContract.methods
        .apostarCome()
        .send({
          from: selectedAccount,
          gas,
          value: apuestaAmountWeiInt,
        });
  
      setResults(`Apuesta Come realizada con éxito`);
      setHashCraps(`Hash de la transacción: ${result.transactionHash}`);
    } catch (error) {
      console.error("Error al realizar la apuesta Come en Craps:", error);
      setResults(`Error al realizar la apuesta Come en Craps: ${error.message}`);
      setHashCraps(`Error en la transacción`);
    }
  };
  const apostarDontCome = async (e) => {
    e.preventDefault();
    try {
      const apuestaAmountWeiInt = parseInt(apuestaAmountWei, 10);
      const gas = 300000;
  
      const result = await casinoContract.methods
        .apostarDontCome()
        .send({
          from: selectedAccount,
          gas,
          value: apuestaAmountWeiInt,
        });
  
      setResults(`Apuesta Dont Come Craps realizada con éxito`);
      setHashCraps(`Hash de la transacción: ${result.transactionHash}`);
    } catch (error) {
      console.error("Error al realizar la apuesta Dont Come en Craps:", error);
      setResults(`Error al realizar la apuesta Dont Come en Craps: ${error.message}`);
      setHashCraps(`Error en la transacción`);
    }
  };
  const apostarField = async (e) => {
    e.preventDefault();
    try {
      const apuestaAmountWeiInt = parseInt(apuestaAmountWei, 10);
      const gas = 300000;
  
      const result = await casinoContract.methods
        .apostarField()
        .send({
          from: selectedAccount,
          gas,
          value: apuestaAmountWeiInt,
        });
  
      setResults(`Apuesta Field realizada con éxito`);
      setHashCraps(`Hash de la transacción: ${result.transactionHash}`);
    } catch (error) {
      console.error("Error al realizar la apuesta Field en Craps:", error);
      setResults(`Error al realizar la apuesta Field en Craps: ${error.message}`);
      setHashCraps(`Error en la transacción`);
    }
  };

  const lanzarDadosCraps = async () => {
    try{ 

      const result = await casinoContract.methods.lanzarDadosCraps().send({
        from: selectedAccount,
        gas: 300000,
      })
      console.log(result);
      setResults(`Dados lanzados,suerte`);
      setHashCraps(`Hash de la transacción: ${result.transactionHash}`);
    }catch(error){
      console.error("Error al lanzar dados en Craps:", error);
      setResults(`Error al lanzar dados en Craps: ${error.message}`);
      setHashCraps(`Error en la transacción`);
    }
  }

  const obtenerApuestasJugadorCraps = async () => {
    try {
      await checkNetworkAndAccounts();
      const result = await casinoContract.methods
        .obtenerApuestasJugadorCraps()
        .call({ from: selectedAccount });

      const tiposApuesta = result[0];
      const cantidades = result[1];

      const formattedResults = `
        Tipos de Apuesta: ${tiposApuesta.join(", ")}
        Cantidades: ${cantidades.join(", ")}
      `;

      setResults(`Apuestas del jugador en Craps:\n${formattedResults}`);
    } catch (error) {
      console.error("Error al obtener las apuestas del jugador en Craps:", error);
      setResults(`Error al obtener las apuestas del jugador en Craps: ${error.message}`);
    }
  };

  return (
    <div className="body">
  
    <div className="main">
      <div className="card">

        <div>Cuenta seleccionada: {selectedAccount}</div>
        <br />
        <form className="form" onSubmit={apostarNumeroEnRuleta}>
          <label>
            Apostar a un número en la ruleta:
            <input
              className="input"
              type="text"
              name="number"
              onChange={(e) => setUint(e.target.value)}
            />
          </label>
          <label>
            Cantidad de apuesta en Wei:
            <input
              className="input"
              type="text"
              name="apuestaAmountWei"
              onChange={(e) => setApuestaAmountWei(e.target.value)}
            />
          </label>
          <div>
            <button className="button" type="submit">
              Apostar Número en Ruleta
            </button>
          </div>
        </form>

        <form className="form" onSubmit={apostarColorEnRuleta}>
          <label>
            Apostar a un color en la ruleta:
            <input
              className="input"
              type="text"
              name="color"
              onChange={(e) => setColor(e.target.value)}
            />
          </label>
          <label>
            Cantidad de apuesta en Wei:
            <input
              className="input"
              type="text"
              name="apuestaAmountWei"
              onChange={(e) => setApuestaAmountWei(e.target.value)}
            />
          </label>
          <div>
            <button className="button" type="submit">
              Apostar Color en Ruleta
            </button>
          </div>
        </form>

        <form className="form" onSubmit={apostarParOImparRuleta}>
          <label>
            Apostar a par o impar en la ruleta:
            <input
              className="input"
              type="text"
              name="paridad"
              onChange={(e) => setParidad(e.target.value)}
            />
          </label>
          <label>
            Cantidad de apuesta en Wei:
            <input
              className="input"
              type="text"
              name="apuestaAmountWei"
              onChange={(e) => setApuestaAmountWei(e.target.value)}
            />
          </label>
          <div>
            <button className="button" type="submit">
              Apostar Par o Impar en Ruleta
            </button>
          </div>
        </form>

        <div style={{ whiteSpace: "pre-wrap" }}>{getResultsRuleta}</div>
        <div>{getHash}</div>
        <br />
        <div>
          <button className="buttonRuleta" onClick={lanzarBolaRuleta}>
            Lanzar Bola Ruleta
          </button>{" "}
          <button className="buttonRuleta" onClick={obtenerApuestasJug}>
            Obtener Apuestas del Jugador
          </button>
        </div>
      </div>
    </div>
    <div className="main">
      <div className="card">
      <form className="form" onSubmit={apostarPassLine}>
          <label>
            Apostar Pass Line en Craps:
            <input
              className="input"
              type="text"
              name="apuestaAmountWei"
              onChange={(e) => setApuestaAmountWei(e.target.value)}
            />
          </label>
          <div>
            <button className="button" type="submit">
              Apostar Pass Line en Craps
            </button>
          </div>
        </form>

        <form className="form" onSubmit={apostarDontPassLine}>
          <label>
            Apostar Don't Pass Line en Craps:
            <input
              className="input"
              type="text"
              name="apuestaAmountWei"
              onChange={(e) => setApuestaAmountWei(e.target.value)}
            />
          </label>
          <div>
            <button className="button" type="submit">
              Apostar Don't Pass Line en Craps
            </button>
          </div>
        </form>
  
        <form className="form" onSubmit={apostarCome}>
          <label>
            Apostar Come en Craps:
            <input
              className="input"
              type="text"
              name="apuestaAmountWei"
              onChange={(e) => setApuestaAmountWei(e.target.value)}
            />
          </label>
          <div>
            <button className="button" type="submit">
              Apostar Come 
            </button>
          </div>
        </form>
          
        <form className="form" onSubmit={apostarDontCome}>
          <label>
            Apostar Don't Come en Craps:
            <input
              className="input"
              type="text"
              name="apuestaAmountWei"
              onChange={(e) => setApuestaAmountWei(e.target.value)}
            />
          </label>
          <div>
            <button className="button" type="submit">
              Apostar Don't Come
            </button>
          </div>
        </form>
        <form className="form" onSubmit={apostarField}>
          <label>
            Apostar Field en Craps:
            <input
              className="input"
              type="text"
              name="apuestaAmountWei"
              onChange={(e) => setApuestaAmountWei(e.target.value)}
            />
          </label>
          <div>
            <button className="button" type="submit">
              Apostar Field
            </button>
          </div>
        </form>
          <br/>
          <button className="buttonRuleta" onClick={lanzarDadosCraps}>
            Lanzar Dados
          </button> {" "}
          <button className="buttonRuleta" onClick={obtenerApuestasJugadorCraps}>
            Obtener Apuestas del Jugador en Craps
          </button>
          <br/>
          <div style={{ whiteSpace: "pre-wrap" }}>{getResults}</div>
          <div style={{ whiteSpace: "pre-wrap" }}>{getHashCraps}</div>
      </div>
    </div>
    </div>
  );
}

export default App;
