// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Roles  {
  
  mapping(bytes32 => address[]) private accessRegistry;
  mapping(address => uint256) private accessCheck;

  address private admin;
  
  constructor(address _minter, address _pauser, address _burn, address _admin)  {
    admin = _admin;
  }

  function addRole(address _member, bytes32 _role)  external onlyAdmin() {
    
    require(msg.sender == admin,'Inadequate permissions);
    accessRegistry[_role].push(_member);
    accessCheck[_member] == accessCheck.length + 1;
    
  }

}