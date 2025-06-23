// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SimpleSwap is ERC20 {
    address public tokenA;
    address public tokenB;
    uint256 public reserveA;
    uint256 public reserveB;

    modifier validTokens(address _tokenA, address _tokenB) {
        require(
            (_tokenA == tokenA && _tokenB == tokenB) ||
            (_tokenA == tokenB && _tokenB == tokenA),
            "Invalid tokens."
        );
        _;
    }

    constructor(address _tokenA, address _tokenB) ERC20("Liquidity", "LIQ") {
        require(_tokenA != _tokenB, "Tokens must be different.");
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function addLiquidity(
        address _tokenA,
        address _tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external validTokens(_tokenA, _tokenB) returns (uint amountA, uint amountB, uint liquidity) {
        require(block.timestamp <= deadline, "Time limit exceeded.");

        bool matchTokens = (_tokenA == tokenA);
        amountA = matchTokens ? amountADesired : amountBDesired;
        amountB = matchTokens ? amountBDesired : amountADesired;

        require(amountA >= amountAMin && amountB >= amountBMin, "Amount less than minimum expected.");

        // Guardar localmente
        uint256 _totalSupply = totalSupply();

        // Transferir tokens
        ERC20(tokenA).transferFrom(msg.sender, address(this), amountA);
        ERC20(tokenB).transferFrom(msg.sender, address(this), amountB);

        if (_totalSupply == 0) {
            liquidity = amountA + amountB;
        } else {
            uint256 liquidityA = (amountA * _totalSupply) / reserveA;
            uint256 liquidityB = (amountB * _totalSupply) / reserveB;
            liquidity = liquidityA < liquidityB ? liquidityA : liquidityB;
        }

        require(liquidity > 0, "Zero liquidity.");

        _mint(to, liquidity);

        reserveA += amountA;
        reserveB += amountB;

        return (amountA, amountB, liquidity);
    }

    function removeLiquidity(
        address _tokenA,
        address _tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external validTokens(_tokenA, _tokenB) returns (uint256 amountA, uint256 amountB) {
        require(block.timestamp <= deadline, "Time limit exceeded.");
        require(to != address(0), "Invalid recipient.");

        uint256 userBalance = balanceOf(msg.sender);
        require(userBalance >= liquidity, "Insufficient liquidity.");

        uint256 _totalSupply = totalSupply();

        amountA = (liquidity * reserveA) / _totalSupply;
        amountB = (liquidity * reserveB) / _totalSupply;

        require(amountA >= amountAMin && amountB >= amountBMin, "Amount less than minimum expected.");

        _burn(msg.sender, liquidity);

        ERC20(tokenA).transfer(to, amountA);
        ERC20(tokenB).transfer(to, amountB);

        reserveA -= amountA;
        reserveB -= amountB;

        return (amountA, amountB);
    }

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts) {
        require(block.timestamp <= deadline, "Time limit exceeded.");
        require(path.length == 2, "Expected an input and an output token.");
        require(to != address(0), "Invalid recipient.");
        require(amountIn > 0, "Zero input.");

        bool isAToB = path[0] == tokenA;

        uint256 reserveIn = isAToB ? reserveA : reserveB;
        uint256 reserveOut = isAToB ? reserveB : reserveA;

        uint256 amountOut = getAmountOut(amountIn, reserveIn, reserveOut);
        require(amountOut >= amountOutMin, "Resulting amount is below the acceptable limit.");

        ERC20(path[0]).transferFrom(msg.sender, address(this), amountIn);
        ERC20(path[1]).transfer(to, amountOut);

        if (isAToB) {
            reserveA += amountIn;
            reserveB -= amountOut;
        } else {
            reserveB += amountIn;
            reserveA -= amountOut;
        }

        amounts = new uint[](2) ;
        amounts[0] = amountIn;
        amounts[1] = amountOut;

        return amounts;
    }

    function getPrice(address _tokenA, address _tokenB) external view validTokens(_tokenA, _tokenB) returns (uint256 price) {
        if (_tokenA == tokenA) {
            price = (reserveB * 1e18) / reserveA;
        } else {
            price = (reserveA * 1e18) / reserveB;
        }
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) public pure returns (uint256) {
        require(amountIn > 0 && reserveIn > 0 && reserveOut > 0, "Invalid input or reserves.");
        return (amountIn * reserveOut) / (reserveIn + amountIn);
    }

    function getReserves() external view returns (uint256 reserveA_, uint256 reserveB_) {
        return (reserveA, reserveB);
    }
}
