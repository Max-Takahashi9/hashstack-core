// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import ".././contracts/util/Context.sol";
// import ".././contracts/access/AccessControl.sol";
import "contracts/access/AccessControl";

contract Token is Context{

  AccessControl private access;

  string  public  _name = "Open protocol";
  string  public  _symbol = "OSO";
  uint256 public  _decimals = 6;

  uint256 public _totalSupply; 
  uint256 public  _cappedSupply;

  bool public _paused;
  bool internal _reentrant = false;

  
  address private adminAddress;
  bytes32 private adminToken;

  address private minterAddress;
  address private burnerAddress;
  address private pauserAddress;

  bytes32 private minter;
  bytes32 private burner;
  bytes32 private pauser;


  mapping(address => uint256) _balances; 
  mapping(address => mapping(address => uint256)) _allowances;

  event Transfer(address indexed _from,address indexed _to,uint256 indexed _value, uint256 _timeStamp);
  event Approved (address indexed _owner,address indexed _spender,uint256 indexed _value,uint256 _timeStamp);

  event PauseState (address indexed _pauser, _paused, uint256 _timeStamp);
  event Minted(address indexed _from, address indexed _to, uint256 amount);
  event Burned(address indexed _from, address _to, uint256 amount);

  constructor(address admin_, address pauser_, address minter_, address burner_, uint256 initialSupply_, uint256 cappedSupply_, AccessControl access_)  {
    _totalSupply = initialSupply_;
    _cappedSupply = cappedSupply_;

    _balances[adminAddress] = initialSupply_;

    adminAddress = admin_;
    minterAddress = minter_;
    burnerAddress = burner_;
    pauserAddress = pauser_;

    access._addAdmin(adminToken, adminAddress);
    access._addRole(minter, minterAddress);
    access._addRole(burner, burnerAddress);
    access._addRole(pauser, pauserAddress);

    _paused = false;

    _totalSupply = initialSupply_;
    _cappedSupply = cappedSupply_;

    _balances[adminAddress] = initialSupply_;

    access = access_;
  }

  fallback() external payable {
    adminAddress.transfer(_msgValue());
  }

  receive() external payable {
    adminAddress.transfer(_msgValue());
  }

  function balanceOf(address _account) external view returns (uint256)  {
    return _balances[_account];
  }

  function allowances(address _owner,address _spender) external view returns(uint256)  {
    return _allowances[_owner][_spender];
  }

  function transfer(address _to, uint256 _value)  external nonReentrant() returns(bool){
    require(_preTransferCheck(), "This contract is temporarily paused. Regret the inconvenience");
    require(_balances[_msgSender()] >= _value, "Insufficient balance"); 
    
    _balances[_msgSender()] -= _value;
    _balances[_to] += _value;
    
    emit Transfer(_msgSender(), _to, _value, block.timestamp);

    return true;
  }

  function approve(address _spender, uint256 _value) external returns(bool) {
    require(_preTransferCheck(), "This contract is temporarily paused. Regret the inconvenience");
    _allowances[_msgSender()][_spender] = 0;
    
    require(_balances[_msgSender()] >= _value , "Insuffficient balance, or you do not have necessary permissions");
    _allowances[_msgSender()][_spender] +=_value;

    emit Approved(_msgSender(), _spender, _value, block.timestamp);
    return true;
  }

  function transferFrom(address _from, address _to, uint256 _value) external nonReentrant() returns (bool)  {
    require(_preTransferCheck(), "This contract is temporarily paused. Regret the inconvenience");
    require(_allowances[_from][_msgSender()]>=_value && _balances[_from]>= _value, "Insufficient allowances, or balance");

    _balances[_from] -= _value;
    _balances[_to] += _value;

    _allowances[_from][_msgSender()] -= _value;

    emit Transfer(_from, _to, _value, block.timestamp);

    return true;
  }

  function mint(address _to, uint256 amount) external onlyMinter() nonReentrant() returns(bool)   {
    require(_totalSupply <= _cappedSupply, "Exceeds capped supply");
    require(amount !=0 & _to != address(0), "you can not mint 0 tokens");

    _balances[_to] += amount;
    _totalSupply += amount;

    return true;
  }

  function burn(address account,uint256 amount) external onlyBurner() nonReentrant() returns(bool)  {
    require(account !=address(0), "You can not burn tokens from this address");

    _balances[account] -= amount;
    _totalSupply -= amount;
    
    emit Transfer(account, address(0), amount);

    return true;
  }
  
  function pause() external onlyPauser() {
    _pause();
  }

  function unPause() external onlyPauser()  {
    _unPause();
  }

  function _pause() internal  {
    require(_paused == false, 'The contract is already paused');

    _paused = true;

    emit PauseState(_msgSender(), true, block.timestamp);
  }

  function _unPause() internal  {
    require(_paused == true, 'The contract is not paused');

    _paused = false;
    emit PauseState(_msgSender(), false, block.timestamp);
  }

  function _preTransferCheck() internal view {
    require(!_paused == true, 'The contract is paused. Token transfers are temporarily disabled');
    this;
  }

  modifier nonReentrant() {
    require(_reentrant == false, "ReentrancyGuard: reentrant call");
    _reentrant = true;
    _;
    _reentrant = false;
  }
  function removeRole(bytes32 role, address account) external onlyAdmin(adminToken,adminAddress)  {
    access._revokeRole(role, account);
  }
  function transferRole(bytes32 role, address oldAccount, address newAccount) external  {
    access.transferRole(role,oldAccount,newAccount) ;
  }

  function renounceRole(bytes32 role, address oldAccount) external {
    access.renounceRole(role, account);
  }

  function hasAdminRole(bytes32 role, address account) private view returns(bool) {
    require(access.hasAdminRole(role, account), "Does not have an admin role.");
  }

  modifier onlyAdmin()  {
    require(access.hasAdminRole(adminToken, adminAddress), "Role does not exist.");
    _;
  }

  modifier onlyPauser()  {
    require(access.hasRole(pauser, pauserAddress) || access.hasAdminRole(adminToken, adminAddress), "Role does not exist.");
    _;
  }

  modifier onlyMinter() {
    require(access.hasRole(minter, minterAddress) || access.hasAdminRole(adminToken, adminAddress), "Role does not exist.");
    _;
  }

  modifier onlyBurner() {
    require(access.hasRole(burner, burnerAddress) || access.hasAdminRole(adminToken, adminAddress), "Role does not exist.");
    _;
  }
}