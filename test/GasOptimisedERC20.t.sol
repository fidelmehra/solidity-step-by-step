// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../contracts/03_GasOptimisedERC20.sol";

/**
 * @title GasOptimisedERC20Test
 * @notice Foundry test suite with gas snapshots.
 *
 * Run:  forge test --gas-report -vv
 * Snap: forge snapshot
 */
contract GasOptimisedERC20Test is Test {

    GasOptimisedERC20 public token;
    address internal alice = makeAddr("alice");
    address internal bob   = makeAddr("bob");

    uint256 constant INITIAL = 1_000_000e18;

    function setUp() public {
        token = new GasOptimisedERC20("GasToken", "GAS", 18, INITIAL);
        // Fund alice for transfer tests
        token.transfer(alice, 10_000e18);
    }

    // ------------------------------------------------------------------
    // Basic correctness
    // ------------------------------------------------------------------
    function test_metadata() public view {
        assertEq(token.name(),     "GasToken");
        assertEq(token.symbol(),   "GAS");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), INITIAL);
    }

    function test_transfer() public {
        uint256 prevBob = token.balanceOf(bob);
        vm.prank(alice);
        token.transfer(bob, 1_000e18);
        assertEq(token.balanceOf(bob), prevBob + 1_000e18);
    }

    function test_transferRevert_insufficientBalance() public {
        vm.prank(alice);
        vm.expectRevert();
        token.transfer(bob, 999_999e18);  // more than alice has
    }

    function test_zeroTransfer_doesNotChangeState() public {
        uint256 before = token.balanceOf(alice);
        vm.prank(alice);
        bool ok = token.transfer(bob, 0);
        assertTrue(ok);
        assertEq(token.balanceOf(alice), before);  // unchanged
    }

    function test_approve_and_transferFrom() public {
        vm.prank(alice);
        token.approve(address(this), 500e18);
        token.transferFrom(alice, bob, 500e18);
        assertEq(token.balanceOf(bob), 500e18);
        assertEq(token.allowance(alice, address(this)), 0);
    }

    function test_infiniteApproval_notDecremented() public {
        vm.prank(alice);
        token.approve(address(this), type(uint256).max);
        token.transferFrom(alice, bob, 100e18);
        // Infinite allowance should stay unchanged
        assertEq(token.allowance(alice, address(this)), type(uint256).max);
    }

    function test_mint_onlyOwner() public {
        token.mint(bob, 1e18);
        assertEq(token.balanceOf(bob), 1e18);
    }

    function test_mint_revertIfNotOwner() public {
        vm.prank(alice);
        vm.expectRevert();
        token.mint(bob, 1e18);
    }

    function test_burn() public {
        uint256 before = token.totalSupply();
        vm.prank(alice);
        token.burn(1_000e18);
        assertEq(token.totalSupply(), before - 1_000e18);
    }

    // ------------------------------------------------------------------
    // Gas benchmark helpers  (run forge test --gas-report)
    // ------------------------------------------------------------------
    function test_gas_transfer() public {
        vm.prank(alice);
        token.transfer(bob, 1e18);
    }

    function test_gas_approve() public {
        vm.prank(alice);
        token.approve(bob, 1e18);
    }

    function test_gas_transferFrom() public {
        vm.prank(alice);
        token.approve(address(this), type(uint256).max);
        token.transferFrom(alice, bob, 1e18);
    }
}
