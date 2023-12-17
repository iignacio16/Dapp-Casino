const Casino = artifacts.require("Casino");
const Ruleta = artifacts.require("Ruleta");
const Dados = artifacts.require("Dados");

module.exports = async function (deployer) {
  const valueRuleta = web3.utils.toWei('0.3', 'ether');
  const valueDados = web3.utils.toWei('0.2', 'ether');

  // Desplegar contrato Ruleta y enviar 0.3 ether
  await deployer.deploy(Ruleta, { value: valueRuleta });
  const ruletaInstance = await Ruleta.deployed();

  // Desplegar contrato Dados y enviar 0.2 ether
  await deployer.deploy(Dados, { value: valueDados });
  const dadosInstance = await Dados.deployed();

  // Desplegar contrato Casino con direcciones de Ruleta y Dados
  await deployer.deploy(Casino, ruletaInstance.address, dadosInstance.address);
};
