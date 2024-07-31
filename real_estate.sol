// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RealEstate {
    address public seller;
    address public buyer;
    string public propertyAddress;
    uint256 public finalPrice;
    uint256 public downPayment;
    uint256 public downPaymentDeadline;
    uint256 public transferDeadline;
    bool public downPaymentMade;
    bool public propertyTransferred;

    event DownPaymentMade(address indexed buyer, uint256 amount);
    event PropertyTransferred(address indexed seller, address indexed buyer, uint256 amount);

    constructor(
        address _seller,
        address _buyer,
        string memory _propertyAddress,
        uint256 _finalPrice,
        uint256 _downPayment,
        uint256 _downPaymentDeadline,
        uint256 _transferDeadline
    ) {
        seller = _seller;
        buyer = _buyer;
        propertyAddress = _propertyAddress;
        finalPrice = _finalPrice;
        downPayment = _downPayment;
        downPaymentDeadline = _downPaymentDeadline;
        transferDeadline = _transferDeadline;
        downPaymentMade = false;
        propertyTransferred = false;
    }

    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only the buyer can call this function.");
        _;
    }

    modifier onlySeller() {
        require(msg.sender == seller, "Only the seller can call this function.");
        _;
    }

    function makeDownPayment() public payable onlyBuyer {
        require(block.timestamp <= downPaymentDeadline, "Down payment deadline has passed.");
        require(msg.value == downPayment, "Incorrect down payment amount.");
        require(!downPaymentMade, "Down payment has already been made.");

        downPaymentMade = true;
        emit DownPaymentMade(buyer, msg.value);
    }

    function transferProperty() public onlySeller {
        require(downPaymentMade, "Down payment has not been made.");
        require(block.timestamp <= transferDeadline, "Transfer deadline has passed.");
        require(!propertyTransferred, "Property has already been transferred.");

        propertyTransferred = true;
        payable(seller).transfer(finalPrice - downPayment);
        emit PropertyTransferred(seller, buyer, finalPrice);
    }

    function refundDownPayment() public onlySeller {
        require(block.timestamp > downPaymentDeadline, "Down payment deadline has not passed.");
        require(!downPaymentMade, "Down payment has already been made.");

        payable(buyer).transfer(downPayment);
    }

    function finalizeSale() public onlyBuyer {
        require(downPaymentMade, "Down payment has not been made.");
        require(propertyTransferred, "Property has not been transferred.");
        
        payable(seller).transfer(finalPrice - downPayment);
    }
}
