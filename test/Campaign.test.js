//GENERATE A LOCAL NETWORK TO TEST AND DEPLOY TEST VERSION OF CONTRACT
const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3'); //Web3 is a CONSTRUCTOR (capitalised).
//Everytime you use web3, you need to call constructure ==> create instance ==> connect to local ganache network
const web3 = new Web3(ganache.provider()); //Replace pro vider to Rinkeby/wtvr upon deployment

const compiledFactory = require('../ethereum/build/CampaignFactory.json');
const compiledCampaign = require('../ethereum/build/Campaign.json');

let accounts;
let factory;
let campaignAddress;
let campaign;

beforeEach(async () => {
  accounts = await web3.eth.getAccounts();

  factory = await new web3.eth.Contract(JSON.parse(compiledFactory.interface))
  .deploy({ data: compiledFactory.bytecode })
  .send({ from: accounts[0], gas: '1000000' });

  await factory.methods.createCampaign('100').send({ from: accounts[0], gas: '1000000' });

  //GET LIST OF CAMPAIGN ADDRESS DEPLOYED
  // console.log(factory.methods.getDeployedCampaigns);
  [campaignAddress] = await factory.methods.getDeployedCampaigns().call();

  //INSTRUCT WEB3 ABOUT INSTANCE OF ALR DEPLOYED CONTRACT
  campaign = await new web3.eth.Contract(JSON.parse(compiledCampaign.interface),
                                          campaignAddress);

});

describe('Campaigns', () => {
  it('deploys a factory and campaign', () => {
    assert.ok(factory.options.address);
    assert.ok(campaign.options.address);
  });

  it('marks caller as campaign manager', async () => {
    const manager = await campaign.methods.manager().call();
    assert.equal(accounts[0], manager); //previously we called createCampaign sending from account[0]
  });
});
