WITH
-- 1. Find all stakes and join them with their corresponding unstake event
StakesWithUnstake AS (
    SELECT
        s."stakeId",
        s.amount,
        s."stakeDay",
        u."unstakeDay"
    FROM think_staking_ethereum.stakingvault_evt_staked s
    LEFT JOIN think_staking_ethereum.stakingvault_evt_unstaked u ON s."stakeId" = u."stakeId"
),

-- 2. For all stakes active during the period, calculate their effective days
ActivePeriodStakes AS (
    SELECT
        amount,
        -- The effective start is the later of the actual stakeDay or the period's startDay
        GREATEST(s."stakeDay", CAST({{startDay}} AS INT)) as effective_start,
        -- The effective end is the earlier of the actual unstakeDay or the period's endDay
        LEAST(COALESCE(s."unstakeDay", CAST({{endDay}} AS INT)), CAST({{endDay}} AS INT)) as effective_end
    FROM StakesWithUnstake s
    -- Filter for stakes that were active at any point during the interval
    WHERE s."stakeDay" <= CAST({{endDay}} AS INT)
      AND (s."unstakeDay" IS NULL OR s."unstakeDay" >= CAST({{startDay}} AS INT))
)

-- 3. Calculate the weight for each stake (amount * effective_days) and sum them up
SELECT
    COALESCE(SUM(
        (amount / 1e18) * (effective_end - effective_start)
    ), 0) AS total_period_weight
FROM ActivePeriodStakes
WHERE effective_end > effective_start -- Ensure we only count stakes with a positive duration