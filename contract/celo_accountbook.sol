// SPDX-License-Identifier: MIT  
pragma solidity >=0.7.0 <0.9.0;


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
    address contractOwner = 0x0000000000000000000000000000000000000000;

    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    uint internal productsLength = 0;

    struct Product {
        address owner;
        string item;
        string description;
        string date;
        uint price;
    }

    struct Account {
        address owner;
        uint week;
        uint fund;
        bool exist;
    }

    mapping (uint => Product) internal products;
    mapping (bytes32 => Account) internal accounts;
    mapping (bytes32 => uint[]) internal accTOpro;

    function writeAccount (uint _week, uint _fund) public {
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            contractOwner,
            _fund
          ),
          "Transfer failed."
        );
        bytes32 hashedKey = keccak256(abi.encodePacked(msg.sender, _week));
        require(accounts[hashedKey].exist!=true);
        accounts[hashedKey] = Account(msg.sender, _week, _fund, true);
    }

    function writeProduct(string memory _item, string memory _description, string memory _date, uint _price) public {
        uint _week = 10; //datetoweek(_date);
        bytes32 hashedKey = keccak256(abi.encodePacked(msg.sender, _week));
        products[productsLength] = Product(msg.sender, _item, _description, _date, _price);
        accTOpro[hashedKey].push(productsLength);
        productsLength++;
	  }

    function readAccount(uint _week) public view returns (
        address,
        uint,
        uint
    )
    {
        bytes32 hashedKey = keccak256(abi.encodePacked(msg.sender, _week));
        return (
          accounts[hashedKey].owner, 
          accounts[hashedKey].week, 
          accounts[hashedKey].fund 
        );
    }

    function readProduct(uint _index) public view returns (
      address,
      string memory, 
      string memory, 
      string memory, 
      uint
    ) 
    {
      return (
        products[_index].owner,
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
