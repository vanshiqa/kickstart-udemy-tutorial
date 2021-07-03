pragma solidity ^0.4.17;

contract CampaignFactory{
    address[] public deployedCampaigns;

    //CREATE A NEW CAMPAIGN WITH THE MINIMUM CONTRIBUTION VALUE
    function createCampaign(uint minimum) public {
        address newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
        //MSG.SENDER OF THIS CONTRACT IS NOW THE FACTORY'S ADDRESS BUT
        //SHOULD BE THE PERSON WHO WANTS TO CREATE NEW CAMPAIGN
    }

    //NEED TO CREATE A VIEW FUNCTION FOR ARRAYS
    function getDeployedCampaigns() public view returns (address[]){
        return deployedCampaigns;
    }
}

contract Campaign {

    //THESE ARE ALL STORAGE VARIABLES
    address public manager;
    uint public minimumContribution;
    //APPROVERS IS A MAP TO REDUCE TIME AND GAS
    mapping(address=> bool) public approvers;
    uint approversCount;

    //REQUEST STRUCT - ALLOWS MANAGERS TO MAKE REQUEST TO SPEND MONEY
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount; //number of approvals rcvd
        mapping(address => bool) approvals; //people who have approved Request
    }
    Request[] public requests;

    function Campaign(uint minimum, address creator) public {
        // manager = msg.sender;
        manager = creator;
        minimumContribution = minimum;
        approversCount = 0;
    }

    //MSG.VALUE =-> AMT IN WEI SOMEONE SENDS INTO CONTRACT
    function contribute() public payable {
        require(msg.value > minimumContribution);
        approvers[msg.sender] = true;
        approversCount++;
    }

    //ONLY CALLABLE BY MANAGER
    function createRequest(string description, uint value, address recipient) public restricted {
        //create Request and add to array
        //REQUIRE TO BE APPROVER
        require(approvers[msg.sender]);
        // Use memory --> the new Request created is a memory variable, newRequest cannot be a storage variable.
       Request memory newRequest = Request({
           description: description,
           value: value,
           recipient:recipient,
           complete:false,
           approvalCount:0
          //don't need to initialise a map (approvals) cause it is a ref type vs
       });
       requests.push(newRequest);
    }

    modifier restricted() {
        require(msg.sender == manager);
        _;
    }

    function approveRequest(uint index) public {
        require(approvers[msg.sender]);
        require(requests.length >= index);
        Request storage request = requests[index]; //need storage so it points to actual thing
        require(!request.approvals[msg.sender]); //check sender has not alr voted
        request.approvals[msg.sender] = true;
        request.approvalCount++;

    }

    function finalizeRequest(uint index) public restricted {
        Request storage request = requests[index];
        require(!requests[index].complete);
        //CHECK THAT 50% OF CONTRIBUTORS approved
        require(request.approvalCount > (approversCount/2));

        //SEND TO VENDOR
        request.recipient.transfer(request.value);
        request.complete = true;
    }
}
