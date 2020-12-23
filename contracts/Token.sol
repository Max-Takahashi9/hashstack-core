// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import ".././contracts/util/SafeMath.sol";
import "contracts/util/ReentrancyGuard.sol";

contract Token is ReentrancyGuard {

  using SafeMath for uint256;
  address public admin;

  string public name;
  string public symbol;
  uint256 public _totalSupply; 
  uint256 public decimals;

  mapping(address => uint256) _balances; 
  mapping(address => mapping(address => uint256)) _allowances;

  event Transfer(
      address indexed _from,
      address indexed _to,
      uint256 indexed _value, 
      uint256 _timeStamp
  );

  event Approval (
      address indexed _owner,
      address indexed _spender,
      uint256 indexed _value,
      uint256 _timeStamp
  );

  constructor(string memory _name, uint256 _decimals, string memory _symbol, uint256 _initialSupply,address _admin){
    name = _name;
    symbol = _symbol;
    decimals = _decimals;
    _balances[msg.sender] = _initialSupply; 
    _totalSupply = _initialSupply;
    admin = _admin;
  }


  function balanceOf(address _account) public view returns (uint256)  {
    return _balances[_account];
  }

  function allowances(address _owner,address _spender) public view returns(uint256)  {
      return _allowances[_owner][_spender];
  }

    function transfer(address _to, uint256 _value)  public nonReentrant() returns(bool success){
       require(_balances[msg.sender] >= _value, "Insufficient balance"); // check if there are enough tokens in the account.
       
       _balances[msg.sender] = _balances[msg.sender].sub(_value);
       _balances[_to] =_balances[_to].add(_value);
       
       emit Transfer(msg.sender, _to, _value, block.timestamp);
       return true;
   }

   function approve(address _spender, uint256 _value) public returns(bool) {
       
       _allowances[msg.sender][_spender] = 0;
       
       require(_balances[msg.sender] >= _value , "Insuffficient balance, or you do not have necessary permissions");
       _allowances[msg.sender][_spender] =_allowances[msg.sender][_spender].add(_value);

       emit Approval(msg.sender, _spender, _value, block.timestamp);
       return true;

   }

   function transferFrom(address _from, address _to, uint256 _value) public nonReentrant() returns (bool success)  {
      //  require(_allowances[_from][msg.sender]>=_value, "Insufficient allowances");
       require(_allowances[_from][msg.sender]>=_value && _balances[_from]>= _value, "Insufficient allowances, or ownership balance");

       _balances[_from] = _balances[_from].sub(_value);
       _balances[_to] = _balances[_to].add(_value);

       _allowances[_from][msg.sender] = _allowances[_from][msg.sender].sub(_value);

       emit Transfer(_from, _to, _value, block.timestamp);

       return true;
   }

   
   function mint(address _to, uint256 amount) public onlyAdmin() returns(bool)   {
       require(amount !=0, "you can not mint 0 tokens");

       _balances[_to] = _balances[_to].add(amount);
       _totalSupply = _totalSupply.add(amount);

       return true;
   }

   function burn(address account,uint256 amount) public onlyAdmin() returns(bool success)  {
       require(account !=address(0), "You can not burn tokens from this address");

       _balances[account] = _balances[account].sub(amount);
       _totalSupply = _totalSupply.sub(amount);

       return true;
   }

   modifier onlyAdmin()	{
	   require(msg.sender == admin, "Inadequate permission");
	   _;
   }

  }