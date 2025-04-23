// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

contract Crowdfunding {

    enum STATUS {
        ACTIVE,
        DELETED,
        SUCCESSFUL,
        UNSUCCEEDED
    }
    uint public campaignCount = 0;
    uint public campaignId;
    address public owner;
    string public title;
    uint public targetAmount;
    uint public raisedAmount;
    uint public deadline;
    bool public active;
    Campaign[] public campaigns;

    struct Campaign {
        uint campaignId;
        address owner;
        string title;
        uint targetAmount;
        uint raisedAmount;
        uint deadline;
        STATUS status;
    }

    constructor() {
        owner = msg.sender;
    }

    event CampaignCreated(uint campaignId, address owner, uint targetAmount);
    event ContributionMade(uint campaignId, address contributer, uint amount);
    event CampaignClaimed(uint campaignId, address owner, uint raisedAmount, STATUS state);

    function createCampaign(string memory _title, uint _targetAmount, uint _duration) external  {
        require(bytes(_title).length > 0, 'Title must not be empty');
        require(_targetAmount > 0, "Target must be > 0");
        require(_duration > 0, "Duration must be > 0");

        uint _deadline = block.timestamp + _duration;
        campaigns.push(Campaign(
            campaignCount,
            msg.sender,
            _title,
            _targetAmount,
            0,
            _deadline,
            STATUS.ACTIVE
        ));

        emit CampaignCreated(campaignCount, msg.sender, _targetAmount);
        campaignCount++;
    }

    function contributeCampaign(uint _campaignId) payable external{
        require(_campaignId > 0, 'Invalid campaign');
        Campaign storage campaign = campaigns[_campaignId];

        require(campaign.deadline > block.timestamp, 'End date has come');
        require(msg.value > 0, "Contribution must be > 0");
        require(campaign.status == STATUS.ACTIVE, "Campaign is not active");

        campaign.raisedAmount += msg.value;

        emit ContributionMade(_campaignId, msg.sender, msg.value);

        if(campaign.raisedAmount >= campaign.targetAmount){
            campaign.status = STATUS.SUCCESSFUL;
        }
    }
    
    function claimCampaign (uint _campaignId) public{
        require(_campaignId > 0, 'Invalid campaign');
        require(msg.sender == campaigns[_campaignId].owner, "Not campaign owner");
        Campaign storage campaign = campaigns[_campaignId];

        if(campaign.status == STATUS.SUCCESSFUL){
            payable(msg.sender).transfer(campaign.raisedAmount);
            emit CampaignClaimed(_campaignId, msg.sender, campaign.raisedAmount, STATUS.SUCCESSFUL);
            campaign.raisedAmount = 0;

        }else if(campaign.status != STATUS.SUCCESSFUL && block.timestamp >= campaign.deadline){
            campaign.status = STATUS.UNSUCCEEDED;
            emit CampaignClaimed(_campaignId, campaign.owner, campaign.raisedAmount, STATUS.UNSUCCEEDED);
            revert("Campaign failed. Contributors should call refund()");
        }else {
            revert("Campaign is still active or invalid state");
        }
    }

}
