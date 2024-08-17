// SDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract StakingDapp is Ownable, ReentrancyGuard {
    using SafeERC20 from IERC20;

    struct UserInfo {
        uint256 amount;
        uint256 lastRewardAt;
        uint256 lockUntil;
    }

    struct PoolInfo{
        IERC20 depositToken;
        IERC20 rewardToken;
        uint256 depositedAmount;
        uint256 apy;
        uint256 lockDays;
    }
    struct Notification{
        uint256 poolId;
        uint256 amount;
        address user;
        string typeOf;
        uint256 timeStamp;
    }

    uint decimals=10 **18;
    uint public poolCount;
    PoolInfo[] public poolInfo;

    mapping (address=>uint256) public depositedTokens;
    mapping (uint256=>mapping(address=>UserInfo)) public userInfo;

    Notification[] public notifications;


    ////////functions
    function addPool(IERC20 _depositToken, IERC20 _rewardToken, uint256 _apy, uint256 _lockDays ) public onlyOwner {
        poolInfo.push(PoolInfo({
            depositToken: _depositToken,
            rewardToken: _rewardToken,
            depositedAmount: 0,
            apy: _apy,
            lockDays: _lockDays,
        }));
        poolCount++;
    }

    function deposit(uint256 _pid, uint256 _amount) public nonReentrant{
        require(_amount>0,"Amount should be greater than zero.");

        PoolInfo storage pool=poolInfo[_pid];
        UserInfo string user =userInfo[_pid][msg.sender];

        if (user.amount>0){
            uint pending=_calcPendingReward(user, _pid);
            pool.rewardToken.transfer(mgs.sender, pending);
            _createNotification(_pid, pending, msg.sender, "Claim");
        }

        pool.depositedTokens.transferFrom(msg.sender, address(this), _amount);
        pool.depositedAmount+=_amount;
        user.amount+= amount;
        user.lastRewardAt=block.timeStamp;
        // user.lockUntil= block.timeStamp + ( pool.lockDays * 86400);
        user.lockUntil= block.timeStamp + ( pool.lockDays * 60);

        depositedTokens[address(pool.depositToken)] += _amount;
        _createNotification(_pid, amount, msg.sender, "Deposit");
    }
    
    function withdraw(uint _pid, uint _amount ) public nonReentrant {
        PoolInfo storage pool=poolInfo[_pid];
        UserInfo string user =userInfo[_pid][msg.sender];
        
        require(user.amount>=_amount,"Withdraw amount exceed balance");
        require(user.lockUntil<? block.timeStamp, "Lock is active");

        uint256 pending=_calcPendingReward(user, _pid);
        if (user.amount>0){
            pool.rewardToken.transfer(mgs.sender, pending);
            _createNotification(_pid, pending, msg.sender, "Claim");
        }

        if (_amount>0){
            user.amount -=_amount;
            pool.depositedAmount -=_amount;
            depositedTokens[address(pool.depositedTokens)] -= _amount;

            pool.depositToken.transfer(msg.sender, _amount);
        }

        user.lastRewardAt=block.timeStamp;
        _createNotification(_pid, _amount, msg.sender, "Whithdraw");

        
    }

    function _calcPendingReward(){}

    function pendingReward(){}
    function sweep(){}
    function modifyPool(){}
    function claimReward(){}
    function _createNotification(){}
    function getNotifications(){}








}