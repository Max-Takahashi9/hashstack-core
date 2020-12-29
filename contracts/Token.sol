// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import ".././contracts/util/Context.sol";
import ".././contracts/TokenAccess.sol";

contract Token is Context, TokenAccess {
	address admin;

	string  _name;
	string  _symbol;
	uint256 _decimals;

	uint256 _totalSupply; 
  uint256 _cappedSupply;

  bool private _paused;
  bool internal _reentrant = false;

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

  event PauseEvent  (
    address indexed _pauser
  );

	constructor(string memory name_, uint256 decimals_, string memory symbol_, uint256 cappedSupply_, uint256 initialSupply_)  {
		_name = name_;
		_symbol = symbol_;
		_decimals = decimals_;
		admin = TokenAccess.admin;

		_totalSupply = initialSupply_;
    _cappedSupply = cappedSupply_;

    _paused = false;
		_balances[msg.sender] = initialSupply_; 
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

  function contractState() external view returns(bool)  {
    return _paused;
  }

	function balanceOf(address _account) external view returns (uint256)  {
		return _balances[_account];
	}

	function allowances(address _owner,address _spender) external view returns(uint256)  {
		return _allowances[_owner][_spender];
	}

	function transfer(address _to, uint256 _value)  external nonReentrant() returns(bool){
    _preTransferCheck();

		require(_balances[msg.sender] >= _value, "Insufficient balance"); 
		
		_balances[msg.sender] -= _value;
		_balances[_to] += _value;
		
		emit Transfer(msg.sender, _to, _value, block.timestamp);
		return true;
	}

	function approve(address _spender, uint256 _value) external returns(bool) {
    _preTransferCheck();
		
		_allowances[msg.sender][_spender] = 0;
		
		require(_balances[msg.sender] >= _value , "Insuffficient balance, or you do not have necessary permissions");
		_allowances[msg.sender][_spender] +=_value;

		emit Approval(msg.sender, _spender, _value, block.timestamp);
		return true;
	}

	function transferFrom(address _from, address _to, uint256 _value) external nonReentrant() returns (bool)  {
    _preTransferCheck();
    
		require(_allowances[_from][msg.sender]>=_value && _balances[_from]>= _value, "Insufficient allowances, or balance");

		_balances[_from] -= _value;
		_balances[_to] += _value;

		_allowances[_from][msg.sender] -= _value;

		emit Transfer(_from, _to, _value, block.timestamp);

		return true;
	}

	function mint(address _to, uint256 amount) external onlyAdmin()  nonReentrant() returns(bool)   {
		require(_totalSupply <= _cappedSupply, "Exceeds capped supply");
    require(amount !=0 & _to != address(0), "you can not mint 0 tokens");

		_balances[_to] += amount;
		_totalSupply += amount;

		return true;
	}

	function burn(address account,uint256 amount) external onlyAdmin() nonReentrant() returns(bool)  {
		require(account !=address(0), "You can not burn tokens from this address");

		_balances[account] -= amount;
		_totalSupply -= amount;

		return true;
	}
  
  fallback() external payable {}

  receive() external payable {}

  function pause() external pauser() {
    require(_paused == false, 'The contract is already paused');
    _paused = true;

    emit PauseEvent(_msgSender());
  }


  function unpause() external pauser() {
    require(_paused == true, 'The contract is not paused');
    _paused = false;

    emit PauseEvent(_msgSender());
  }


  function _preTransferCheck() internal view {
    require(_paused == false, 'Sorry, the contract is paused. Token transfers are temporarily disabled');
    this;
  }

  modifier pauser()	{
		require(_msgSender() == TokenAccess.pauser, "Inadequate permission");
		_;
	}

  modifier onlyAdmin()	{
		require(_msgSender() == TokenAccess.admin, "Inadequate permission");
		_;
	}

  modifier nonReentrant() {
    require(_reentrant = false, "ReentrancyGuard: reentrant call");
    _reentrant = true;
    _;
    _reentrant = false;
  }
}


// What's pending
// // 1. Capped tokens
// // 2. AccessManagement.sol
// // 3. Minter, Burner roles - Is it necessary?
// // 4. Unit tests in Mocha, Chai
// // 5. Deploy to public test-net, validate
// // 6. Deploy to main-net