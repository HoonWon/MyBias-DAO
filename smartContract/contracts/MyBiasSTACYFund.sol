pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MyBiasSTACYFund is Ownable {
    address payable public _withdrawalAddress;
    IERC20 public _WETH;

    event WithdrawMatic(uint256 amount, address to);
    event DepositMatic(uint256 amount);
    event WithdrawWETH(uint256 amount, address to);
    event WithdrawAllWETH(uint256 amount, address to);
    event DepositWETH(uint256 amount);

    constructor(address payable withdrawalAddress, IERC20 weth) {
        _withdrawalAddress = withdrawalAddress;
        _WETH = weth;
    }

    function getMaticBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getWETHBalance() external view returns (uint256) {
        return _WETH.balanceOf(address(this));
    }

    function withdrawMatic(uint256 amount) external onlyOwner {
        require(
            address(this).balance >= amount,
            "withdrawMatic: insufficient balance"
        );

        _withdrawalAddress.transfer(amount);

        emit WithdrawMatic(amount, _withdrawalAddress);
    }

    function withdrawAllMatic() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "There is no matic");

        _withdrawalAddress.transfer(amount);

        emit WithdrawMatic(amount, _withdrawalAddress);
    }

    function withdrawWETH(uint256 amount) external onlyOwner {
        require(
            _WETH.balanceOf(address(this)) >= amount,
            "withdrawWETH: insufficient balance"
        );

        _WETH.transfer(_withdrawalAddress, amount);

        emit WithdrawWETH(amount, _withdrawalAddress);
    }

    function withdrawAllWETH() external onlyOwner {
        uint256 amount = _WETH.balanceOf(address(this));
        require(amount > 0, "There is no WETH");

        _WETH.transfer(_withdrawalAddress, amount);

        emit WithdrawAllWETH(amount, _withdrawalAddress);
    }

    function depositMatic() external payable onlyOwner {
        require(msg.value > 0);

        payable(address(this)).transfer(msg.value);

        emit DepositMatic(msg.value);
    }

    function depositWETH(uint256 amount) external onlyOwner {
        require(amount > 0);

        _WETH.transferFrom(msg.sender, address(this), amount);

        emit DepositWETH(amount);
    }

    receive() external payable {}
}
