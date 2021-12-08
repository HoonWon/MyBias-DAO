pragma solidity ^0.8.2;

interface IDragonLair {
    function QUICKBalance(address _account)
        external
        view
        returns (uint256 quickAmount_);

    function QUICKForDQUICK(uint256 _quickAmount)
        external
        view
        returns (uint256 dQuickAmount_);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function dQUICKForQUICK(uint256 _dQuickAmount)
        external
        view
        returns (uint256 quickAmount_);

    function decimals() external view returns (uint8);

    function decreaseAllowance(address spender, uint256 subtractedValue)
        external
        returns (bool);

    function enter(uint256 _quickAmount) external;

    function increaseAllowance(address spender, uint256 addedValue)
        external
        returns (bool);

    function leave(uint256 _dQuickAmount) external;

    function name() external view returns (string memory);

    function quick() external view returns (address);

    function symbol() external view returns (string memory);

    function totalSupply() external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}
