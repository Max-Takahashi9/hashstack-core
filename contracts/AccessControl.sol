pragma solidity ^0.8.0;

import "contracts/util/Address.sol";
import "contracts/util/Context.sol";

contract AccessControl is Context{

  using Address for address;

  struct RoleData  {
    mapping(bytes32 => address) _roleRegistry; //mapping of all roles & addresses
    bytes32[] _roleList; //list of roles
    address[] _accountList; // list of addresses with a role.
    mapping (address => uint256) _indexes;
  }

  mapping (bytes32 => RoleData) private _roles;

  address private adminAddress;
  bytes32 admin;

  event RoleAdminChanged(bytes32 indexed role, address indexed previousAdmin, address indexed newAdmin);

  event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

  event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

  constructor(address account) {
    adminAddress = account;
    _updateRoleData(admin, adminAddress);
    emit RoleAdminChanged(admin, address(0), adminAddress);
  }


  function hasRole(bytes32 role, address account) external view returns (bool)  {
    if (_roles[role]._indexes[account]!=0)  {
      return true;
    }
    return false;
  }

  //Decide on the below functio
  function getRoleMemberCount(bytes32 role) external view returns (uint256) {
    return RoleData._rolesLists.length;
  }

  
  // Fetch the address of the role member
  function getRoleMember(bytes32 role, uint256 index) external view returns (address) {
    return _roles[role]._roleRegistry[_roleList[index]]; // returns address,which is _accountList[index].
  }

  function getAdmin() external view returns (address) {
    return adminAddress;
  }


  function addRole(bytes32 role, address account) external adminAccess() {
    require(_roles[role]._indexes[account]!=0, "Address already has a role");
    
    return _addRole(role, account);
  }

  function _addRole(bytes32 role, address account) internal {
    _roles[role]._indexes[account] = RoleData._accountList.length;
    _roles[role]._roleList[RoleData._accountList.length]; // updates _roleList
    _roles[role]._accountList[RoleData._accountList.length]; // updates _accountList
    _roles[role]._roleRegistry[_roleList[RoleData._accountList.length]] = _roles[role]._accountList[RoleData._accountList.length];

    emit RoleGranted(role, account, _msgSender());
  }


  modifier adminAccess()  {
    require(_msgSender() == admin, "Inadequate permissions brother");
    _;
  }
}

// struct RoleData  {
//     mapping(bytes32 => address) _roleRegistry; //mapping of all roles & addresses
//     bytes32[] _roleList; //list of roles
//     address[] _accountList; // list of addresses with a role.
//     mapping (address => uint256) _indexes;
//   }

//   mapping (bytes32 => RoleData) private _roles;