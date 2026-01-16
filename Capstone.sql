CREATE DATABASE df;

--- Contract Management ---

--- Contract Expiration Risk (Within 6 months)

WITH RankedContracts AS ( SELECT player_name_x, current_club_id, contract_expiration_date, highest_market_value_in_eur,
        ROW_NUMBER() OVER (PARTITION BY player_name_x ORDER BY contract_expiration_date) AS rn
    FROM my_table
    WHERE contract_expiration_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 6 MONTH)
)
SELECT player_name_x, current_club_id, contract_expiration_date, highest_market_value_in_eur
FROM RankedContracts
WHERE rn = 1 and player_name_x IS NOT NULL
ORDER BY contract_expiration_date;

---  Contract Duration Analysis (Position - wise)

SELECT position_x, AVG(DATEDIFF(contract_expiration_date, date_of_birth)) AS avg_contract_length_days
FROM my_table
WHERE contract_expiration_date IS NOT NULL
GROUP BY position_x;

--- Market value vs Contract Expiration 

WITH RankedPlayers AS (
    SELECT 
        player_name_x, 
        highest_market_value_in_eur, 
        contract_expiration_date,
        ROW_NUMBER() OVER (PARTITION BY player_name_x ORDER BY highest_market_value_in_eur DESC, contract_expiration_date ASC) AS rn
    FROM my_table
    WHERE contract_expiration_date IS NOT NULL
)
SELECT player_name_x, highest_market_value_in_eur, contract_expiration_date
FROM RankedPlayers
WHERE rn = 1 and player_name_x is not null
ORDER BY highest_market_value_in_eur DESC, contract_expiration_date ASC
LIMIT 20;

--- Agent activity and contract volume

SELECT agent_name, COUNT(*) AS contract_count
FROM my_table
WHERE contract_expiration_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 1 YEAR) and agent_name is not null
GROUP BY agent_name
ORDER BY contract_count DESC;

--- Free agent analysis

SELECT COUNT(agent_name) AS free_agents
FROM my_table
WHERE contract_expiration_date < CURDATE() AND player_id IS NULL;

--- Contract value trend over time

SELECT last_season, AVG(highest_market_value_in_eur) AS avg_market_value
FROM my_table
WHERE contract_expiration_date IS NOT NULL
GROUP BY last_season
ORDER BY last_season DESC;

