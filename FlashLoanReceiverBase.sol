pragma solidity ^0.8.0;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IDyDx} from "./IDyDx.sol";

contract FlashLoanReceiverBase {
    IDyDx public constant DYDX = IDyDx(DYDX_ADDRESS);
    address public constant DYDX_ADDRESS = 0x1E0447b19BB6EcFdAe1e4AE1694b0C3659614e4e;
    address public constant WETH_ADDRESS = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    constructor(address _dydx) {
        require(_dydx != address(0), "Invalid dYdX address");
        DYDX = IDyDx(_dydx);
    }

    function initiateFlashLoan(address _token, uint256 _amount) internal {
        address receiverAddress = address(this);
        address[] memory markets = new address[](1);
        markets[0] = DYDX.getMarketIdByTokenAddress(_token);

        // Approve the dYdX contract to spend the loan amount
        IERC20(_token).approve(DYDX_ADDRESS, _amount);

        // Initiate the flash loan
        DYDX.flashLoan(receiverAddress, _token, _amount, "");
    }

    function transferFundsBackToDyDx(address _token, uint256 _amount) internal {
        // Transfer the funds back to dYdX to repay the flash loan
        IERC20(_token).transfer(DYDX_ADDRESS, _amount);
    }

    function handleProfit(uint256 _profit) internal {
        // Handle the profit as needed (e.g., transfer to a specific address)
        // For simplicity, we'll log the profit amount here
        emit Profit(_profit);
    }

    event Profit(uint256 amount);
}
