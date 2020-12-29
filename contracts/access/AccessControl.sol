pragma solidity ^0.8.0;

import "contracts/util/Address.sol";
import "contracts/util/Context.sol";

contract AccessControl is Context {

  using Address for address;

  address private adminAddress;
  bytes32 private adminAccess;

  struct RoleData  {
    mapping(bytes32 => address) _roleRegistry; //mapping of all roles & addresses
    mapping (bytes32 => uint256) _indexes;
    bytes32[] _roleList; 
  }

  mapping(bytes32 => RoleData) private _roles;

  struct AdminRegistry  {
    mapping(bytes32 => address) _adminRegistry; // List of roles & addresses
    mapping(bytes32 => uint256) _adminIndex; 
    bytes32[] _adminRoleList;
  }

  event AdminRoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
  event AdminRoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

  event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
  event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

  constructor(address account_) {
    adminAddress = account_;
    _addAdmin(adminAccess, adminAddress);
  }

  function hasRole(bytes32 role, address account) external view returns(bool)  {
    return _hasRole(role, account);(role, account);
  }

  function addRole(bytes32 role, address account) external onlyAdmin(adminAccess, adminAddress) {
    require(!hasRole(role, account), "Role already exists. Please create a different role");
    _addRole(role, account);
  }
  function removeRole(bytes32 role, address account) external onlyAdmin(adminAccess, adminAddress) {
    require(hasRole(role, account), "Role does not exist.");

    _revokeRole(role, account);

  }
  function renounceRole(bytes32 role, address account) external {
    require(hasRole(role, account), "Role does not exist.");
    require(_msgSender() == account, "Inadequate permissions");

    _revokeRole(role, account);
  }

  function transferRole(bytes32 role, address oldAccount, address newAccount)  external {
    require(hasRole(role, oldAccount) && _msgSender() == oldAccount, "Role does not exist.");

    _revokeRole(role, oldAccount);
    _addRole(role, newAccount);
  }

  function hasAdminRole(bytes32 role, address account) external view returns(bool)  {
    return _hasAdminRole(role, account);
  }
  function addAdmin(bytes32 role, address account) external onlyAdmin(adminAccess, adminAddress) {
    require(!hasAdminRole(role, account), "Role already exists. Please create a different role");
    _addAdmin(role, account);
  }

  function removeAdmin(bytes32 role, address account) external onlyAdmin(adminAccess, adminAddress)  {
    require(hasAdminRole(role, account), "Role does not exist.");

    _revokeAdmin(role, account);
  }

  function adminRoleTransfer(bytes32 role, address oldAccount, address newAccount)  external onlyAdmin(adminAccess, adminAddress)  {
    require(hasAdminRole(role, oldAccount), "Role already exists. Please create a different role");

    _revokeAdmin(role, oldAccount);
    _addAdmin(role, newAccount);
  }

  function _hasRole(bytes32 role, address account) private view returns(bool)  {
    if (_roles[role]._indexes[role] !=0)  {
      return true;
    }
    return false;
  }
  function _addRole(bytes32 role, address account) private {

    _roles[role]._roleRegistry[role] = account;
    _roles[role]._roleList.push(role);
    _roles[role]._indexes[role] = _roles[role]._roleList.length;

    emit RoleGranted(role, account, _msgSender());
  }
  function _revokeRole(bytes32 role, address account) private {

    delete _roles[role]._roleRegistry[role];

    uint256 _value = _roles[role]._indexes[role];
    uint256 _toDeleteIndex = _value - 1;

    uint256 _lastValue = _roles[role]._roleList.length;
    uint256 _lastValueIndex = _lastValue - 1;

    bytes32 lastRole = _roles[role]._roleList[_lastValueIndex];

    _roles[role]._roleList[_toDeleteIndex] = lastRole; // Index assignment
    _roles[role]._indexes[lastRole] = _toDeleteIndex+1;

    _roles[role]._roleList.pop();
    delete _roles[role]._indexes[role];

    emit RoleRevoked(role, account, _msgSender());

  }
  

  function _hasAdminRole(bytes32 role, address account) private view returns(bool)  {
    if (AdminRegistry._adminIndex[role]!=0)  {
      return true;
    }
    return false;
  }
  function _addAdmin(bytes32 role, address account) private {
    AdminRegistry._adminRegistry[role] = account;
    AdminRegistry._adminRoleList.push(role);

    AdminRegistry._adminIndex[role] = AdminRegistry._adminRoleList.length;
    
    emit AdminRoleGranted(role, account, _msgSender());
  }
  function _revokeAdmin(bytes32 role, address account) private {

    delete AdminRegistry._adminRegistry[role];

    uint256 _value = AdminRegistry._adminIndex[role];
    uint256 _toDeleteIndex = _value - 1;

    uint256 _lastValue = AdminRegistry._adminRoleList.length;
    uint256 _lastValueIndex = _lastValue - 1;

    bytes32 lastRole = AdminRegistry._adminRoleList[_lastValueIndex];

    AdminRegistry._adminRoleList[_toDeleteIndex] = lastRole; // Index assignment

    AdminRegistry._adminIndex[lastRole] = _toDeleteIndex+1;

    AdminRegistry._adminRoleList.pop();
    delete AdminRegistry._adminIndex[role];

    emit AdminRoleRevoked(role, account, _msgSender());

  }

  modifier onlyAdmin(bytes32 role, address account)  {
    require(hasAdminRole(role, account), "Role does not exist.");
    _;
  }
}