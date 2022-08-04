// SPDX-License-Identifier: MIT  
pragma solidity >=0.7.0 <0.9.0;
address contractOwner = 0x0000000000000000000000000000;

interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Marketplace {

    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    uint internal productsLength = 0;

    struct Product {
        address payable owner;
        string item;
        string description;
        string date;
        uint price;
    }

    struct Account {
        address payable owner;
        uint week;
        uint fund;
        uint[] productIds;
    }

    mapping (uint => Product) internal products;
    mapping (bytes32  => Account) internal accounts;

    function writeAccount (uint _week, uint _fund) public {
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            contractOwner,
            _fund
          ),
          "Transfer failed."
        );
        require(accounts[keccak256(msg.sender, _week)]);
        accounts[keccak256(msg.sender, _week)] = Account(_week, _fund, []);
    }

    function writeProduct(string memory _item, string memory _description, string memory _date, uint _price) public {
        uint _week = datetoweek(_date);
        products[productsLength] = Product(_item, _description, _date, _price);
        accounts[keccak256(msg.sender, _week)].productIds.push(productsLength);
        productsLength++;
	  }

    function readAccount(uint _week) public view returns (
        address payable,
        uint,
        uint,
        uint[] memory
    )
    {
        return (
          accounts[keccak256(msg.sender, _week)].owner, 
          accounts[keccak256(msg.sender, _week)].week, 
          accounts[keccak256(msg.sender, _week)].fund, 
          accounts[keccak256(msg.sender, _week)].productIds
        );
    }

    function readProduct(uint _index) public view returns (
      address payable,
      string memory, 
      string memory, 
      string memory, 
      uint
    ) 
    {
      return (
        products[_index].item, 
        products[_index].description, 
        products[_index].date,
        products[_index].price
      );
    }

    function getProductsLength() public view returns (uint) {
        return (productsLength);
    }

}