/* Lido - Treasury total value by Day, for 1 Week
   Runtime: 18sec */

SELECT 
     CAST(TIME_STAMP AS date) AS BLOCK_DATE, 
     CASE 
        WHEN TOKEN_ADDRESS = '0xae7ab96520de3a18e5e111b5eaab095312d7fe84' THEN 'STETH'
        WHEN TOKEN_ADDRESS = '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48' THEN 'USDC'
        WHEN TOKEN_ADDRESS = '0x6b175474e89094c44da98b954eedeac495271d0f' THEN 'DAI'
        WHEN TOKEN_ADDRESS = '0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0' THEN 'MATIC'
        WHEN TOKEN_ADDRESS = '0xdac17f958d2ee523a2206206994597c13d831ec7' THEN 'USDT'
    END AS Token,
    BALANCE as Treasury_total_value, 
    WALLET_ADDRESS as Lido_treasury_address
FROM (
    SELECT 
        TIME_STAMP,
        BALANCE,
        TOKEN_ADDRESS,
        WALLET_ADDRESS,
        ROW_NUMBER() OVER (
            PARTITION BY TOKEN_ADDRESS, DATE_TRUNC('day', TIME_STAMP)
            ORDER BY TIME_STAMP DESC
        ) AS row_num
    FROM ethereum.FUNGIBLETOKEN_WALLETS
    WHERE TOKEN_ADDRESS IN (
            '0xae7ab96520de3a18e5e111b5eaab095312d7fe84',  -- STETH
            '0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48',  -- USDC
            '0x6b175474e89094c44da98b954eedeac495271d0f',  -- DAI
            '0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0',  -- MATIC
            '0xdac17f958d2ee523a2206206994597c13d831ec7'   -- USDT
        )
        AND WALLET_ADDRESS = '0x3e40d73eb977dc6a537af587d48316fee66e9c8c'--LIDO Treasury address
        AND time_stamp BETWEEN current_date - 7 AND current_date
) AS daily_snapshots
WHERE row_num = 1
ORDER BY BLOCK_DATE;
