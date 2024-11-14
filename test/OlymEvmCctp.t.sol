// SPDX-License-Identifier: UNLICENSED

pragma solidity 0.7.6;

import "../src/messages/Message.sol";
import "../src/TokenMinter.sol";
import "./TestUtils.sol";
import "./mocks/MockMintBurnToken.sol";
import "../lib/forge-std/src/Test.sol";
import { OlympixUnitTest } from "./OlympixUnitTest.sol";

contract OlymEvmCctp is OlympixUnitTest("TokenMinter") {

    address minter1 = 0xbb00DDa2832850a43840A3A86515E3Fe226865F2;
    address minter2 = 0x87787389BB2Eb2EC8Fe4aA6a2e33D671d925A60f;

    // EVENTS FROM TokenMinter.sol
    event TokenPairLinked(address localToken, uint32 remoteDomain,bytes32 remoteToken);

    event TokenPairUnlinked(address localToken, uint32 remoteDomain, bytes32 remoteToken);

    event SetBurnLimitPerMessage(address indexed token, uint256 burnLimitPerMessage);

    event SetTokenController(address tokenController);

    uint32 remoteDomain = 0;

    IMintBurnToken localToken;
    IMintBurnToken remoteToken;
    TokenMinter tokenMinter;

    address localTokenAddress;
    bytes32 remoteTokenBytes32;
    address mintRecipientAddress = address(vm.addr(1506));
    address localTokenMessenger = address(vm.addr(1507));
    address nonTokenMessenger = address(vm.addr(1508));
    address pauser = vm.addr(1509);
    address tokenController = vm.addr(1510);

    function setUp() public {
        vm.startPrank(minter1);
        tokenMinter = new TokenMinter(tokenController);
        localToken = new MockMintBurnToken();
        localTokenAddress = address(localToken);
        remoteToken = new MockMintBurnToken();
        remoteTokenBytes32 = Message.addressToBytes32(address(remoteToken));
        tokenMinter.addLocalTokenMessenger(localTokenMessenger);
        tokenMinter.updatePauser(pauser);

        vm.stopPrank();

   }


    function test_mint_FailWhenCallerIsNotLocalTokenMessenger() public {
        vm.startPrank(nonTokenMessenger);
    
        vm.expectRevert("Caller not local TokenMessenger");
        tokenMinter.mint(remoteDomain, remoteTokenBytes32, mintRecipientAddress, 1);
    
        vm.stopPrank();
    }

    function test_mint_FailWhenMintTokenIsNotSupported() public {
        vm.startPrank(localTokenMessenger);
    
        vm.expectRevert("Mint token not supported");
        tokenMinter.mint(remoteDomain, remoteTokenBytes32, mintRecipientAddress, 1);
    
        vm.stopPrank();
    }

    function test_addLocalTokenMessenger_FailWhenNewLocalTokenMessengerIsZeroAddress() public {
        vm.startPrank(minter1);
    
        vm.expectRevert("Invalid TokenMessenger address");
        tokenMinter.addLocalTokenMessenger(address(0));
    
        vm.stopPrank();
    }

    function test_removeLocalTokenMessenger_FailWhenLocalTokenMessengerIsNotSet() public {
        vm.startPrank(minter1);
    
        tokenMinter.removeLocalTokenMessenger();
    
        vm.expectRevert("No local TokenMessenger is set");
        tokenMinter.removeLocalTokenMessenger();
    
        vm.stopPrank();
    }

    function test_setTokenController_SuccessfulSetTokenController() public {
        vm.startPrank(minter1);
    
        address newTokenController = address(vm.addr(1511));
        tokenMinter.setTokenController(newTokenController);
    
        assertEq(tokenMinter.tokenController(), newTokenController);
    
        vm.stopPrank();
    }

    function test_getLocalToken_SuccessfulGetLocalToken() public {
        vm.startPrank(tokenController);
    
        tokenMinter.linkTokenPair(localTokenAddress, remoteDomain, remoteTokenBytes32);
    
        address localTokenResult = tokenMinter.getLocalToken(remoteDomain, remoteTokenBytes32);
    
        assertEq(localTokenResult, localTokenAddress);
    
        vm.stopPrank();
    }
}