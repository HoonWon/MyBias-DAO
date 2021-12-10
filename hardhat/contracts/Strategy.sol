pragma solidity ^0.8.2;

import "./library/Ownable.sol";
import "./library/TransferHelper.sol";
import "./interface/IUniswapV2ERC20.sol";
import "./interface/IStakingRewards.sol";
import "./interface/IUniswapV2Router02.sol";
import "./interface/IERC20.sol";
import "./interface/IDragonLair.sol";

contract Strategy is Ownable {
    address payable public fundContract;

    // Polygon mainnet
    IERC20 public MaticWETH =
        IERC20(0x7ceB23fD6bC0adD59E62ac25578270cFf1b9f619);
    IERC20 public WMATIC = IERC20(0x0d500B1d8E8eF31E21C99d1Db9A6444d3ADf1270);

    IERC20 public USDC = IERC20(0x2791Bca1f2de4661ED88A30C99A7a9449Aa84174);
    IERC20 public USDT = IERC20(0xc2132D05D31c914a87C6611C10748AEb04B58e8F);
    IERC20 public QUICK = IERC20(0x831753DD7087CaC61aB5644b308642cc1c33Dc13);

    IUniswapV2ERC20 public lpToken =
        IUniswapV2ERC20(0x2cF7252e74036d1Da831d11089D326296e64a728);
    IStakingRewards public stakingRewards =
        IStakingRewards(0xAFB76771C98351Aa7fCA13B130c9972181612b54);
    IUniswapV2Router02 public swapRouter =
        IUniswapV2Router02(0xa5E0829CaCEd8fFDD4De3c43696c57F7D7A678ff);
    IDragonLair public dragonLair =
        IDragonLair(0xf28164A485B0B2C90639E47b0f377b4a438a16B1);

    event WithdrawMatic(uint256 amount, address to);
    event DepositMatic(uint256 amount);
    event WithdrawMaticWETH(uint256 amount, address to);
    event WithdrawAllMaticWETH(uint256 amount, address to);
    event DepositMaticWETH(uint256 amount);
    event Staked(uint256 amount);
    event Unstaked();
    event WithdrawDQUICK(uint256 amount);
    event ClaimDQUICK();
    event WithdrawUSDC(uint256 amount, address to);
    event WithdrawUSDT(uint256 amount, address to);

    constructor(address ownerAddress, address payable _fundContract) {
        fundContract = _fundContract;

        TransferHelper.safeApprove(
            address(USDC),
            address(swapRouter),
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );
        TransferHelper.safeApprove(
            address(USDT),
            address(swapRouter),
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );
        TransferHelper.safeApprove(
            address(QUICK),
            address(swapRouter),
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );
        TransferHelper.safeApprove(
            address(lpToken),
            address(stakingRewards),
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );
        TransferHelper.safeApprove(
            address(lpToken),
            address(swapRouter),
            0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
        );

        _transferOwnership(ownerAddress);
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        uint256 deadline
    ) external onlyOwner returns (uint256[] memory) {
        return
            swapRouter.swapExactTokensForTokens(
                amountIn,
                amountOutMin,
                path,
                address(this),
                deadline
            );
    }

    function swapMaticToUsdc(
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 deadline
    ) external onlyOwner {
        address[] memory path = new address[](2);
        path[0] = address(WMATIC);
        path[1] = address(USDC);

        swapRouter.swapExactETHForTokens{value: amountIn}(
            amountOutMin,
            path,
            address(this),
            deadline
        );
    }

    function swapMaticToUsdt(
        uint256 amountIn,
        uint256 amountOutMin,
        uint256 deadline
    ) external onlyOwner {
        address[] memory path = new address[](2);
        path[0] = address(WMATIC);
        path[1] = address(USDT);

        swapRouter.swapExactETHForTokens{value: amountIn}(
            amountOutMin,
            path,
            address(this),
            deadline
        );
    }

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    )
        external
        onlyOwner
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        )
    {
        return
            swapRouter.addLiquidity(
                tokenA,
                tokenB,
                amountADesired,
                amountBDesired,
                amountAMin,
                amountBMin,
                address(this),
                deadline
            );
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        uint256 deadline
    ) external onlyOwner returns (uint256 amountA, uint256 amountB) {
        return
            swapRouter.removeLiquidity(
                tokenA,
                tokenB,
                liquidity,
                amountAMin,
                amountBMin,
                address(this),
                deadline
            );
    }

    function stakeLpToken(uint256 amount) external onlyOwner {
        stakingRewards.stake(amount);

        emit Staked(amount);
    }

    function unstakeLpToken() external onlyOwner {
        stakingRewards.exit();

        emit Unstaked();
    }

    function getMaticBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getMaticWETHBalance() external view returns (uint256) {
        return MaticWETH.balanceOf(address(this));
    }

    function getUsdcBalance() external view returns (uint256) {
        return USDC.balanceOf(address(this));
    }

    function getUsdtBalance() external view returns (uint256) {
        return USDT.balanceOf(address(this));
    }

    function getLpTokenBalance() external view returns (uint256) {
        return lpToken.balanceOf(address(this));
    }

    function getQuickBalance() external view returns (uint256) {
        return QUICK.balanceOf(address(this));
    }

    function getDQUICKBalance() external view returns (uint256) {
        return dragonLair.balanceOf(address(this));
    }

    function getStakedBalance() external view returns (uint256) {
        return stakingRewards.balanceOf(address(this));
    }

    function getEarned() external view returns (uint256) {
        return stakingRewards.earned(address(this));
    }

    function depositMatic() external payable onlyOwner {
        require(msg.value > 0);

        payable(address(this)).transfer(msg.value);

        emit DepositMatic(msg.value);
    }

    function depositMaticWETH(uint256 amount) external onlyOwner {
        require(amount > 0);

        MaticWETH.transferFrom(msg.sender, address(this), amount);

        emit DepositMaticWETH(amount);
    }

    function withdrawMatic(uint256 amount) external onlyOwner {
        require(
            address(this).balance >= amount,
            "withdrawMatic: insufficient balance"
        );

        fundContract.transfer(amount);

        emit WithdrawMatic(amount, fundContract);
    }

    function withdrawUSDC(uint256 amount) external onlyOwner {
        require(
            USDC.balanceOf(address(this)) >= amount,
            "withdrawUSDC: insufficient balance"
        );

        USDC.transfer(fundContract, amount);

        emit WithdrawUSDC(amount, fundContract);
    }

    function withdrawUSDT(uint256 amount) external onlyOwner {
        require(
            USDT.balanceOf(address(this)) >= amount,
            "withdrawUSDT: insufficient balance"
        );

        USDT.transfer(fundContract, amount);

        emit WithdrawUSDT(amount, fundContract);
    }

    function withdrawAllMatic() external onlyOwner {
        uint256 amount = address(this).balance;
        require(amount > 0, "There is no matic");

        fundContract.transfer(amount);

        emit WithdrawMatic(amount, fundContract);
    }

    function withdrawMaticWETH(uint256 amount) external onlyOwner {
        require(
            MaticWETH.balanceOf(address(this)) >= amount,
            "withdrawMaticWETH: insufficient balance"
        );

        MaticWETH.transfer(fundContract, amount);

        emit WithdrawMaticWETH(amount, fundContract);
    }

    function withdrawAllMaticWETH() external onlyOwner {
        uint256 amount = MaticWETH.balanceOf(address(this));
        require(amount > 0, "There is no MaticWETH");

        MaticWETH.transfer(fundContract, amount);

        emit WithdrawAllMaticWETH(amount, fundContract);
    }

    function withdrawDQUICK(uint256 amount) external onlyOwner {
        dragonLair.leave(amount);

        emit WithdrawDQUICK(amount);
    }

    function withdrawAllDQUICK() external onlyOwner {
        uint256 balance = dragonLair.balanceOf(address(this));
        dragonLair.leave(balance);

        emit WithdrawDQUICK(balance);
    }

    function claimDQUICK() external onlyOwner {
        stakingRewards.getReward();

        emit ClaimDQUICK();
    }

    receive() external payable {}
}
