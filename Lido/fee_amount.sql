/* Lido - Fee Amount by Day, for 2 Weeks 
   Runtime: 30sec
   TODO: see if better performance using the SCI: Agent_EVT_VaultTransfer (or VaultDeposit)
*/
SELECT
  cast(Time_stamp as date) as Fee_Date
, case 
  when Token_address = LOWER('0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84') then 'stETH'
  when Token_address = LOWER('0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0') then 'Matic'
  end as Fee_Collection_Locations
, sum(Balance) as Fee_Amount
FROM (
    SELECT 
        Time_stamp,
        Balance,
        Token_address,
        Wallet_address,
        ROW_NUMBER() OVER (
            PARTITION BY Token_address, substr(time_stamp,1,10) 
            ORDER BY Time_stamp DESC
        ) AS row_num
    FROM ethereum.FUNGIBLETOKEN_WALLETS
    WHERE time_stamp between current_date-7 and current_date
    AND (
           (Token_address) = LOWER('0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84') 
        OR (Token_address) = LOWER('0x7d1afa7b718fb893db30a3abc0cfc608aacfebb0')
    ) 
    AND (Wallet_address) = LOWER('0x3e40D73EB977Dc6a537aF587D48316feE66E9C8c')
) AS daily_snapshots
WHERE row_num = 1
group by 1,2  order by 1,2
