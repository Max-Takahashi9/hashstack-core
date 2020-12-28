pragma solidity ^0.8.0;

import "contracts/util/Address.sol";
import "contracts/util/Context.sol";

contract AccessControl is Context{

  using Address for address;

  struct RoleData  {
    mapping(bytes32 => address) _roleRegistry; //mapping of all roles & addresses
    mapping (bytes32 => uint256) _indexes;
    bytes32[] _roleList; //list of roles
  }

  address adminAddress;
  bytes32 adminAccessRegistry;

  struct AdminRegistry  {
    mapping(bytes32 => address) _adminRegistry; //There can not be multiple admins for a contract.
    mapping(bytes32 => uint256) _adminIndex;
    bytes32[] _adminRoleList;
  }

  mapping (bytes32 => RoleData) private _roles;


  event RoleAdminChanged(bytes32 indexed role, address indexed previousAdmin, address indexed newAdmin);

  event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

  event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);
  
  event AdminRoleGranted(bytes32 indexed role, address indexed account, address indexed sender);
  event AdminRoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

  constructor(address account_) {
    adminAddress = account_;
    _addAdmin(adminAccessRegistry, adminAddress);
  }

  function _addAdmin(bytes32 role, address account) internal {
    AdminRegistry._adminRegistry[role] = account;
    AdminRegistry._adminRoleList.push(role);
    AdminRegistry._adminIndex[role] = AdminRegistry._adminRoleList.length;
    emit AdminRoleGranted(role, account, _msgSender());
  }

  function addAdmin(bytes32 role, address account) public adminAccess() {
    require(!hasAdminRole(role, account), "Role already exists. Please create a different role");
    _addAdmin(role, account);
  }

  function hasAdminRole(bytes32 role, address account) external view returns (bool)  {
    _hasAdminRole(role, account);
  }

  function _hasAdminRole(bytes32 role, address account) internal view returns (bool)  {
    if (AdminRegistry._adminIndex[role]!=0)  {
      return true;
    }
    return false;
  }

  function removeAdmin(bytes32 role, address account) public adminAccess()  {
    require(hasAdminRole(role, account), "Role does not exist.");

    _revokeAdmin(role, account);
  }


  function _revokeAdmin(bytes32 role, address account) internal {

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

  function adminRoleTransfer(bytes32 role, address oldOwner, address newOwner)  public adminAccess()  {
    _addAdmin(role, newOwner);

    //Needs working
  }


  function addMember()  {}
  function removeMember() {}
  function renounceMemberRole() {}


  modifier adminAccess()  {
    require(_msgSender() == adminAddress, "Inadequate permissions brother");
    _;
  }
}