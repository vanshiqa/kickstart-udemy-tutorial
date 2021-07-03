const path = require('path');
const solc = require('solc');
const fs = require('fs-extra'); //fs - file system. fs-extra --> extra funs

const buildPath = path.resolve(__dirname, 'build');
//REMOVE BUILD FOLDER
fs.removeSync(buildPath);
//READ CAMPAIGN.SOL file
const campaignPath = path.resolve(__dirname, 'contracts', 'Campaign.sol');
console.log("got campaignPath");
//GET CONTENTS OF FILE
const source = fs.readFileSync(campaignPath, 'utf8');
console.log("got source");
//COMPILE AND JUST GET CONTRACT PROPERTY FROM OUTPUT
const output = solc.compile(source, 1).contracts; //contains Campaign and CampaignFactory contracts
console.log("got output")
//RECREATE BUILD FOLDER
fs.ensureDirSync(buildPath);

//OUTPUT IS A MAP - USE KEY (e.g :Campaign) TO CREATE A NEW FILE IN BUILD FOLDER
//VALUE IS THE CONTENT OF THE FILE
for (let contract in output){
  //BUILD NEW FILE PATH
  fs. outputJsonSync(
    path.resolve(buildPath, contract.replace(':', '') + '.json'),
    output[contract]
  );
}
