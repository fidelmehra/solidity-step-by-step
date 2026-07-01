// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleToken - Step 2: ERC-20-like Token from Scratch
/// @author Fidel Mehra
/// @notice Demonstrates mappings, modifiers, events, transfer logic
contract SimpleToken {
    string public name;
    string public symbol;
    uint8  public decimals = 18;
    uint256 public totalSupply;

    address public owner;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner_, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        name   = _name;
        symbol = _symbol;
        owner  = msg.sender;
        _mint(msg.sender, _initialSupply * 10 ** decimals);
    }

    function transfer(address _to, uint256 _value) external returns (bool) {
        require(_to != address(0), "Zero address");
        require(balanceOf[msg.sender] >= _value, "Insufficient balance");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to]        += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) external returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) external returns (bool) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Allowance exceeded");
        allowance[_from][msg.sender] -= _value;
        balanceOf[_from]             -= _value;
        balanceOf[_to]               += _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function mint(address _to, uint256 _amount) external onlyOwner {
        _mint(_to, _amount);
    }

    function burn(uint256 _amount) external {
        require(balanceOf[msg.sender] >= _amount, "Insufficient balance");
        balanceOf[msg.sender] -= _amount;
        totalSupply           -= _amount;
        emit Burn(msg.sender, _amount);
    }

    function _mint(address _to, uint256 _amount) internal {
        require(_to != address(0), "Zero address");
        totalSupply    += _amount;
        balanceOf[_to] += _amount;
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
    }
}
