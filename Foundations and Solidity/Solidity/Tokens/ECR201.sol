// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/// @notice Minimal, compile-safe ERC20 with cap, fees (simple), rewards, locks & vesting.
///         Avoids overriding OZ internals so it compiles across OZ versions.
contract UltimateERC20 is ERC20, ERC20Burnable, AccessControl, ReentrancyGuard {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant TAX_MANAGER_ROLE = keccak256("TAX_MANAGER_ROLE");
    bytes32 public constant REWARD_MANAGER_ROLE = keccak256("REWARD_MANAGER_ROLE");

    // Tokenomics
    string private _tokenURI;
    uint256 public immutable cap; // max supply (raw units, includes decimals)
    uint256 public maxTransactionAmount;
    uint256 public maxWalletBalance;

    // fees (basis points)
    uint256 public taxFee = 200;       // 2.00%
    uint256 public liquidityFee = 100; // 1.00%
    uint256 public rewardFee = 100;    // 1.00%
    uint256 public burnFee = 50;       // 0.50%

    address public taxWallet;
    address public liquidityWallet;

    // Trading control
    bool public tradingEnabled;
    uint256 public tradingEnabledTime;

    mapping(address => bool) public isExcludedFromFee;
    mapping(address => bool) public isExcludedFromMaxTx;
    mapping(address => bool) public isExcludedFromMaxWallet;
    mapping(address => bool) public isBlacklisted;

    // Rewards
    mapping(address => uint256) public rewards;
    uint256 public totalRewardsDistributed;
    uint256 public rewardCycle = 7 days;
    mapping(address => uint256) public nextAvailableClaimDate;

    // Auto-liquidity stub
    bool public swapAndLiquifyEnabled = true;
    uint256 public swapTokensAtAmount;
    bool private _inSwapAndLiquify;

    // Locks & vesting
    struct LockInfo { uint256 amount; uint256 unlockTime; bool withdrawn; }
    mapping(address => LockInfo[]) public locks;

    struct VestingSchedule {
        uint256 totalAmount;
        uint256 releasedAmount;
        uint256 startTime;
        uint256 duration;
        uint256 cliff;
    }
    mapping(address => VestingSchedule[]) public vestingSchedules;

    // Events
    event RewardClaimed(address indexed account, uint256 amount);
    event TokensLocked(address indexed account, uint256 amount, uint256 unlockTime);
    event TokensUnlocked(address indexed account, uint256 amount);
    event VestingScheduleCreated(address indexed beneficiary, uint256 amount);
    event TokensVested(address indexed beneficiary, uint256 amount);
    event TaxUpdated(uint256 newTaxFee, uint256 newLiquidityFee, uint256 newRewardFee, uint256 newBurnFee);
    event TradingEnabled();
    event BlacklistUpdated(address indexed account, bool isBlacklisted);
    event AutoLiquidity(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);

    modifier lockTheSwap() {
        _inSwapAndLiquify = true;
        _;
        _inSwapAndLiquify = false;
    }

    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply_, // human units (not including decimals) e.g. 1_000_000
        uint256 cap_,           // same units as initialSupply_
        address owner_
    ) ERC20(name_, symbol_) {
        require(owner_ != address(0), "zero owner");
        require(initialSupply_ <= cap_, "initial > cap");

        // decimals() is from ERC20 and defaults to 18
        uint256 mul = 10 ** decimals();
        cap = cap_ * mul;

        _grantRole(DEFAULT_ADMIN_ROLE, owner_);
        _grantRole(MINTER_ROLE, owner_);
        _grantRole(TAX_MANAGER_ROLE, owner_);
        _grantRole(REWARD_MANAGER_ROLE, owner_);

        // exclusions
        isExcludedFromFee[owner_] = true;
        isExcludedFromFee[address(this)] = true;
        isExcludedFromMaxTx[owner_] = true;
        isExcludedFromMaxTx[address(this)] = true;
        isExcludedFromMaxWallet[owner_] = true;
        isExcludedFromMaxWallet[address(this)] = true;

        taxWallet = owner_;
        liquidityWallet = owner_;

        maxTransactionAmount = (initialSupply_ * mul * 2) / 100; // 2%
        maxWalletBalance = (initialSupply_ * mul * 3) / 100;     // 3%
        swapTokensAtAmount = (initialSupply_ * mul * 5) / 10000; // 0.05%

        // mint initial supply (respect cap)
        _mintInternal(owner_, initialSupply_ * mul);
    }

    // --- Internal mint helper that checks cap without overriding OZ _mint ---
    function _mintInternal(address to, uint256 amount) internal {
        require(totalSupply() + amount <= cap, "cap exceeded");
        _mint(to, amount); // call OZ _mint (no override)
    }

    // Public admin mint (checks cap)
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        _mintInternal(to, amount);
    }

    // --- Basic transfer wrappers with fee handling (simple) ---
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        _processTransfer(_msgSender(), to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _processTransfer(from, to, amount);
        return true;
    }

    function _processTransfer(address from, address to, uint256 amount) private {
        // basic checks
        require(!isBlacklisted[from] && !isBlacklisted[to], "blacklisted");
        if (!tradingEnabled) {
            require(from == address(0) || to == address(0) || hasRole(DEFAULT_ADMIN_ROLE, from), "trading disabled");
        }
        if (from != address(0) && !isExcludedFromMaxTx[from]) {
            require(amount <= maxTransactionAmount, "max tx");
        }
        if (to != address(0) && !isExcludedFromMaxWallet[to]) {
            require(balanceOf(to) + amount <= maxWalletBalance, "max wallet");
        }

        if (isExcludedFromFee[from] || isExcludedFromFee[to] || _inSwapAndLiquify) {
            _transfer(from, to, amount);
            return;
        }

        uint256 fees = _calculateFees(amount);
        uint256 transferAmount = amount - fees;

        if (fees > 0) {
            _transfer(from, address(this), fees);
            _distributeFees(fees);
        }
        _transfer(from, to, transferAmount);
    }

    function _calculateFees(uint256 amount) private view returns (uint256) {
        uint256 totalFee = taxFee + liquidityFee + rewardFee + burnFee; // basis points
        return (amount * totalFee) / 10000;
    }

    function _distributeFees(uint256 feeAmount) private {
        uint256 denom = taxFee + liquidityFee + rewardFee + burnFee;
        if (denom == 0) return;

        uint256 burnAmount = (feeAmount * burnFee) / denom;
        uint256 liquidityAmount = (feeAmount * liquidityFee) / denom;
        uint256 rewardAmount = (feeAmount * rewardFee) / denom;
        uint256 taxAmount = feeAmount - burnAmount - liquidityAmount - rewardAmount;

        if (burnAmount > 0) _burn(address(this), burnAmount);
        if (liquidityAmount > 0) _transfer(address(this), liquidityWallet, liquidityAmount);
        if (rewardAmount > 0) totalRewardsDistributed += rewardAmount; // keep in contract
        if (taxAmount > 0) _transfer(address(this), taxWallet, taxAmount);
    }

    function swapAndLiquify(uint256 contractTokenBalance) external lockTheSwap {
        // placeholder - implement DEX router integration in production
        emit AutoLiquidity(contractTokenBalance, 0, contractTokenBalance);
    }

    // --- Rewards ---
    function creditReward(address to, uint256 amount) external onlyRole(REWARD_MANAGER_ROLE) {
        require(to != address(0), "zero");
        require(amount > 0, "zero");
        require(balanceOf(address(this)) >= amount, "contract lacks funds");
        rewards[to] += amount;
        totalRewardsDistributed += amount;
    }

    function claimReward() public nonReentrant {
        require(nextAvailableClaimDate[msg.sender] <= block.timestamp, "not yet");
        uint256 rewardAmount = rewards[msg.sender];
        require(rewardAmount > 0, "no rewards");
        rewards[msg.sender] = 0;
        nextAvailableClaimDate[msg.sender] = block.timestamp + rewardCycle;
        _transfer(address(this), msg.sender, rewardAmount);
        emit RewardClaimed(msg.sender, rewardAmount);
    }

    // --- Locks (user-initiated) ---
    function lockMyTokens(uint256 amount, uint256 unlockTime) external {
        require(amount > 0, "amount>0");
        require(unlockTime > block.timestamp, "unlock future");
        _transfer(msg.sender, address(this), amount);
        locks[msg.sender].push(LockInfo(amount, unlockTime, false));
        emit TokensLocked(msg.sender, amount, unlockTime);
    }

    function adminLockTokens(address account, uint256 amount, uint256 unlockTime) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "zero account");
        require(amount > 0, "amount>0");
        require(unlockTime > block.timestamp, "unlock future");
        _spendAllowance(account, msg.sender, amount);
        _transfer(account, address(this), amount);
        locks[account].push(LockInfo(amount, unlockTime, false));
        emit TokensLocked(account, amount, unlockTime);
    }

    function unlockTokens(uint256 lockIndex) public {
        require(lockIndex < locks[msg.sender].length, "invalid index");
        LockInfo storage lock = locks[msg.sender][lockIndex];
        require(!lock.withdrawn, "withdrawn");
        require(block.timestamp >= lock.unlockTime, "still locked");
        lock.withdrawn = true;
        _transfer(address(this), msg.sender, lock.amount);
        emit TokensUnlocked(msg.sender, lock.amount);
    }

    // --- Vesting (admin funds contract) ---
    function createVestingSchedule(address beneficiary, uint256 amount, uint256 startTime, uint256 duration, uint256 cliff) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(beneficiary != address(0), "zero beneficiary");
        require(amount > 0, "amount>0");
        require(duration > 0, "duration>0");
        require(cliff <= duration, "cliff<=duration");
        _transfer(msg.sender, address(this), amount);
        vestingSchedules[beneficiary].push(VestingSchedule(amount, 0, startTime, duration, cliff));
        emit VestingScheduleCreated(beneficiary, amount);
    }

    function releaseVestedTokens(uint256 scheduleIndex) public {
        require(scheduleIndex < vestingSchedules[msg.sender].length, "invalid index");
        VestingSchedule storage s = vestingSchedules[msg.sender][scheduleIndex];
        uint256 vested = _calculateVestedAmount(s);
        uint256 releasable = vested - s.releasedAmount;
        require(releasable > 0, "nothing to release");
        s.releasedAmount += releasable;
        _transfer(address(this), msg.sender, releasable);
        emit TokensVested(msg.sender, releasable);
    }

    function _calculateVestedAmount(VestingSchedule memory s) internal view returns (uint256) {
        if (block.timestamp < s.startTime + s.cliff) return 0;
        if (block.timestamp >= s.startTime + s.duration) return s.totalAmount;
        return (s.totalAmount * (block.timestamp - s.startTime)) / s.duration;
    }

    // --- Admin utilities ---
    function enableTrading() external onlyRole(DEFAULT_ADMIN_ROLE) {
        tradingEnabled = true;
        tradingEnabledTime = block.timestamp;
        emit TradingEnabled();
    }

    function updateFees(uint256 newTaxFee, uint256 newLiquidityFee, uint256 newRewardFee, uint256 newBurnFee) external onlyRole(TAX_MANAGER_ROLE) {
        uint256 tot = newTaxFee + newLiquidityFee + newRewardFee + newBurnFee;
        require(tot <= 2500, "fees too high");
        taxFee = newTaxFee;
        liquidityFee = newLiquidityFee;
        rewardFee = newRewardFee;
        burnFee = newBurnFee;
        emit TaxUpdated(newTaxFee, newLiquidityFee, newRewardFee, newBurnFee);
    }

    function setBlacklist(address account, bool blacklisted) external onlyRole(DEFAULT_ADMIN_ROLE) {
        isBlacklisted[account] = blacklisted;
        emit BlacklistUpdated(account, blacklisted);
    }

    function excludeFromFee(address account, bool excluded) external onlyRole(DEFAULT_ADMIN_ROLE) {
        isExcludedFromFee[account] = excluded;
    }

    function excludeFromMaxTx(address account, bool excluded) external onlyRole(DEFAULT_ADMIN_ROLE) {
        isExcludedFromMaxTx[account] = excluded;
    }

    function excludeFromMaxWallet(address account, bool excluded) external onlyRole(DEFAULT_ADMIN_ROLE) {
        isExcludedFromMaxWallet[account] = excluded;
    }

    // token URI
    function setTokenURI(string calldata uri) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _tokenURI = uri;
    }
    function tokenURI() external view returns (string memory) { return _tokenURI; }

    // helpers
    function getLockCount(address account) external view returns (uint256) { return locks[account].length; }
    function getVestingScheduleCount(address b) external view returns (uint256) { return vestingSchedules[b].length; }

    // bridge-style helpers (admin)
    function bridgeBurn(address from, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) { _burn(from, amount); }
    function bridgeMint(address to, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) { _mintInternal(to, amount); }
}
