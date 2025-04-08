// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "../src/CounterLogic.sol";
import "../src/CounterProxy.sol";

contract CounterTest is Test {
    CounterLogic public logic;
    CounterProxy public proxy;

    function setUp() public {
        logic = new CounterLogic();
        proxy = new CounterProxy(address(logic));
    }

    function testStorageLayout() public view {
        // 验证存储槽布局一致
        assertEq(
            vm.load(address(proxy), bytes32(uint256(0))),
            vm.load(address(logic), bytes32(uint256(0)))
        );
    }

    function testIncrementViaProxy() public {
        // 通过代理调用increment()
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Call failed");

        // 验证代理合约的count被更新
        assertEq(proxy.count(), 1);
        // 验证逻辑合约的count保持不变
        assertEq(logic.count(), 0);
    }

    function testGetCountViaProxy() public {
        // 先增加一次
        testIncrementViaProxy();

        // 通过代理调用getCount()
        (bool success, bytes memory data) = address(proxy).call(
            abi.encodeWithSignature("getCount()")
        );
        require(success, "Call failed");

        uint256 count = abi.decode(data, (uint256));
        assertEq(count, 1);
    }

    function testContextPreservation() public {
        // 通过代理调用increment()
        (bool success, ) = address(proxy).call(
            abi.encodeWithSignature("increment()")
        );
        require(success, "Call failed");

        // 验证msg.sender在逻辑合约中仍然是原始调用者
        // 需要通过修改逻辑合约来验证，这里简化测试
        assertEq(proxy.count(), 1);
    }
}
