USE albums;

-- Number 1: Set containing the earliest release date for each artist --
SELECT a.artist_id,
       MIN(release_date) AS earliest_date
FROM (
    SELECT artist_id,
           release_date,
           row_number() OVER w AS row_num
    FROM albums
    WINDOW w AS (PARTITION BY artist_id, release_date)
) AS a
GROUP BY artist_id;

-- Number 2: Set containing the earliest release date for each artist --
SELECT a.artist_id,
       a.release_date AS earliest_release_date
FROM (
    SELECT artist_id,
           release_date,
           row_number() OVER w AS row_num
    FROM albums
    WINDOW w AS (PARTITION BY artist_id ORDER BY release_date)
) AS a
WHERE a.row_num = 1;

-- Number 3: The number of days between the latest and previously released album --
SELECT artist_first_name,
       artist_last_name,
       record_label_contract_start_date,
       LAG(record_label_contract_start_date) OVER w AS prev_label_contract,
       LEAD(record_label_contract_start_date) OVER w AS next_label_contract,
       datediff(record_label_contract_start_date, LAG(record_label_contract_start_date) OVER w) AS diff_current_before,
       datediff(LEAD(record_label_contract_start_date) OVER w, record_label_contract_start_date) AS diff_next_current
FROM artists
WHERE start_date_ind_artist IS NULL
WINDOW w AS (ORDER BY record_label_contract_start_date);

-- Number 4: The last available contract end date --
SELECT a1.artist_id,
       a.artist_first_name,
       a.artist_last_name,
       a.record_label_contract_start_date,
       a.record_label_contract_end_date
FROM artists a
JOIN (
    SELECT artist_id, MAX(record_label_contract_end_date) AS end_date
    FROM artists
    GROUP BY artist_id
) AS a1 
	ON a.artist_id = a1.artist_id
WHERE a.record_label_contract_end_date > SYSDATE()
   AND a.record_label_contract_end_date = a1.end_date;

-- Number 5: How many artists had albums at the top 100 charts for fewer weeks than the average? --
WITH cte AS (
    SELECT AVG(no_weeks_top_100) AS avg_no_weeks_top_100
    FROM artists
)
SELECT SUM(CASE WHEN a.no_weeks_top_100 < c.avg_no_weeks_top_100 THEN 1 ELSE 0 END) AS no_artist_below_average
FROM artists AS a
JOIN cte AS c;

WITH cte AS (
    SELECT AVG(no_weeks_top_100) AS avg_no_weeks_top_100
    FROM artists
)
SELECT COUNT(CASE WHEN a.no_weeks_top_100 < c.avg_no_weeks_top_100 THEN a.no_weeks_top_100 ELSE NULL END) AS artist_below_average,
       COUNT(a.no_weeks_top_100) AS no_of_salary_contract
FROM artists AS a
JOIN cte AS c;
