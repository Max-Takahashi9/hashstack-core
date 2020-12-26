// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import ".././contracts/util/Context.sol";
import ".././contracts/util/ReentrancyGuard.sol";

contract Token is Context, ReentrancyGuard {
	address admin;

	string _name;
	string _symbol;
	uint256 _decimals;
	uint256 _totalSupply; 

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

	constructor(string memory name_, uint256 decimals_, string memory symbol_, uint256 initialSupply_)  {
		_name = name_;
		_symbol = symbol_;
		_decimals = decimals_;
    admin = _msgSender();
		_balances[msg.sender] = initialSupply_; 
		_totalSupply = initialSupply_;
	}

	function name() external view returns (string memory)	{
		return _name;
	}
	
	function symbol() external view returns (string memory){
		return _symbol;
	}

	function decimals() external view returns(uint256)	{
		return _decimals;
	}

	function totalSupply() external view returns(uint256)	{
		return _totalSupply;
	}

	function balanceOf(address _account) external view returns (uint256)  {
		return _balances[_account];
	}

	function allowances(address _owner,address _spender) external view returns(uint256)  {
		return _allowances[_owner][_spender];
	}

	function transfer(address _to, uint256 _value)  external nonReentrant() returns(bool){
		require(_balances[msg.sender] >= _value, "Insufficient balance"); 
		
		_balances[msg.sender] -= _value;
		_balances[_to] += _value;
		
		emit Transfer(msg.sender, _to, _value, block.timestamp);
		return true;
	}

	function approve(address _spender, uint256 _value) external returns(bool) {
		
		_allowances[msg.sender][_spender] = 0;
		
		require(_balances[msg.sender] >= _value , "Insuffficient balance, or you do not have necessary permissions");
		_allowances[msg.sender][_spender] = _allowances[msg.sender][_spender].add(_value);

		emit Approval(msg.sender, _spender, _value, block.timestamp);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _value) external nonReentrant() returns (bool)  {
		require(_allowances[_from][msg.sender]>=_value && _balances[_from]>= _value, "Insufficient allowances, or balance");

		_balances[_from] -= _value;
		_balances[_to] += _value;

		_allowances[_from][msg.sender] -= _value;

		emit Transfer(_from, _to, _value, block.timestamp);

		return true;
	}


	function mint(address _to, uint256 amount) external onlyAdmin()  nonReentrant() returns(bool)   {
		require(amount !=0, "you can not mint 0 tokens");

		_balances[_to] = _balances[_to].add(amount);
		_totalSupply = _totalSupply.add(amount);

		return true;
	}

	function burn(address account,uint256 amount) external onlyAdmin() nonReentrant() returns(bool)  {
		require(account !=address(0), "You can not burn tokens from this address");

		_balances[account] = _balances[account].sub(amount);
		_totalSupply = _totalSupply.sub(amount);

		return true;
	}
  fallback() external payable {}

  receive() external payable {}

	modifier onlyAdmin()	{
		require(msg.sender == admin, "Inadequate permission");
		_;
	}

}