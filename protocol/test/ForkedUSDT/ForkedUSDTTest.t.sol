// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Test, console } from "forge-std/Test.sol";

// Interface pour inclure addBlackList
interface ICustomERC20 is IERC20 {
    function addBlackList(address _evilUser) external;
    function getBlackListStatus(address _evilUser) external view returns (bool);
}

contract ForkedUSDTTest is Test {
    using SafeERC20 for ICustomERC20;
    ICustomERC20 token;
    // IERC20 token;
   address user = makeAddr('user');
   address secondUser = makeAddr('secondUser');
   address evilUser = makeAddr('evilUser');
   address owner = address(0xC6CDE7C39eB2f0F0095F41570af89eFC2C1Ea828);
   address pedroAddress = address(0x3BbeAEaA984Af99197888fC2EA7A78037732b4eA);
   address pedroTestAddress = address(0xe6F2d327dF0c20F7f87bfBaF6eF34Be18587e135);


   function setUp() public {
      token = ICustomERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
    }

   function test_TotalSupply() public view {
       uint256 totalSupply = token.totalSupply();
       console.log("Total Supply: ", totalSupply);
       uint256 pedroBalance = token.balanceOf(pedroAddress);
       console.log("Binance Balance: ", pedroBalance);
   }

   function test_AddUserToBlacklist() public {
    vm.prank(owner);
    console.log("Im here");
    token.addBlackList(address(evilUser));
    bool isBlackList = token.getBlackListStatus(address(evilUser));
    console.log("User added to blacklist: ", isBlackList);
   }

   function test_UserTrytoTransferFunds() public {

    uint256 transferAmount = 5 * 10 ** 6;
    uint256 pedroBalance = token.balanceOf(pedroAddress);
    console.log("Pedro's Balance: ", pedroBalance);
    vm.startPrank(pedroAddress);
    token.safeTransfer(user, transferAmount);
    vm.stopPrank();
    uint256 userBalance = token.balanceOf(user);
    console.log("User's Balance: ", userBalance);
    assertEq(token.balanceOf(user), transferAmount);
   }

   function test_BlacklistedUserTryToTransferFunds() public {
    uint256 transferAmount = 5 * 10 ** 6;
    uint256 pedroBalance = token.balanceOf(pedroAddress);
    console.log("Pedro's Balance: ", pedroBalance);

    vm.prank(owner);
    token.addBlackList(address(evilUser));
    bool isBlackList = token.getBlackListStatus(address(evilUser));
    console.log("User added to blacklist: ", isBlackList);

    uint256 evilUserInitialBalance = token.balanceOf(evilUser);
    console.log("evilUser's Balance: ", evilUserInitialBalance);

    vm.startPrank(pedroAddress);
    token.safeTransfer(evilUser, transferAmount);
    vm.stopPrank();

    uint256 evilUserCurrentBalance = token.balanceOf(evilUser);
    console.log("evilUser's Balance: ", evilUserCurrentBalance);
    uint256 userInitialBalance = token.balanceOf(user);
    console.log("User's Balance: ", userInitialBalance);

    vm.prank(evilUser);
    vm.expectRevert();
    token.safeTransfer(user, transferAmount);
    uint256 userCurrentBalance = token.balanceOf(user);
    console.log("User's Balance: ", userCurrentBalance);
    assertEq(token.balanceOf(user), 0);

    vm.startPrank(pedroAddress);
    token.safeTransfer(user, transferAmount);
    vm.stopPrank();

   }
}


// forge test --mt test_BlacklistedUserTryToTransferFunds --fork-url https://eth-mainnet.g.alchemy.com/v2/EpZP8JQoYSfaphUJz3SMqUxXj5s8rkVX  --fork-block-number 20133469 -vvvvv
