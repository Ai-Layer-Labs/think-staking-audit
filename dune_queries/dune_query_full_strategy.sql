-- This query calculates the totalPoolWeight for a pool governed by the updated FullStakingStrategy.
-- It finds all stakes created within the grace period that were held until the pool ended, and multiplies their amount by 90.

WITH
-- 1. Find all stakes and join them with their corresponding unstake event
StakesWithUnstake AS (
    SELECT
        s.amount,
        s."stakeDay",
        u."unstakeDay"
    FROM think_staking_ethereum.stakingvault_evt_staked s
    LEFT JOIN think_staking_ethereum.stakingvault_evt_unstaked u ON s."stakeId" = u."stakeId"
),

-- 2. Filter for stakes that are eligible based on the FullStakingStrategy rules
EligibleStakes AS (
    SELECT
        s.amount
    FROM StakesWithUnstake s
    WHERE
        -- Condition 1: Stake must be created within the 14-day grace period
        s."stakeDay" <= (CAST({{pool_start_day}} AS INT) + 14)

        -- Condition 2: Stake must have been held until after the pool ended
        AND (s."unstakeDay" IS NULL OR s."unstakeDay" > CAST({{pool_end_day}} AS INT))
)

-- 3. Sum the weight for each eligible stake (amount * 90) to get the total pool weight
SELECT
    COALESCE(SUM((amount / 1e18) * 90), 0) AS total_pool_weight
FROM EligibleStakes