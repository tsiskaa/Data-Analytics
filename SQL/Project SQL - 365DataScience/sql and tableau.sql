USE albums;

/*Obtaining an output of 3 columns containing the following information:
	1. This year's artists signed contracts with their record labels.
    2. The number of record label contracts initiated in each year.
    3. A string 'record label artist' that indicates the relevant type of dependency.*/
SELECT 
    YEAR(record_label_contract_start_date) AS start_year,
    COUNT(*) AS n_contracts,
    'record label artist' AS artist_type
FROM
    artists
WHERE 
    record_label_contract_start_date IS NOT NULL
GROUP BY 
    YEAR(record_label_contract_start_date)
ORDER BY 
    start_year;

/*Expending the output obtained in question 1 by adding records with the number 
	of independent artist that have started their careers in a given year.*/
SELECT 
    YEAR(record_label_contract_start_date) AS start_year,
    COUNT(*) AS n_contracts,
    'record label artist' AS artist_type
FROM
    artists
WHERE 
    record_label_contract_start_date IS NOT NULL
GROUP BY 
    YEAR(record_label_contract_start_date)

UNION ALL

SELECT 
    YEAR(start_date_ind_artist) AS start_year,
    COUNT(*) AS n_contracts,
    'independent artist' AS artist_type
FROM
    artists
WHERE 
    start_date_ind_artist IS NOT NULL
GROUP BY 
    YEAR(start_date_ind_artist)
ORDER BY 
    start_year;

/*When the first album of each particular genre has been released?*/
SELECT 
    genre_id,
    MIN(release_date) AS first_release_date
FROM 
    albums
GROUP BY 
    genre_id
ORDER BY 
    genre_id;

/*Using subquery from before question to use release_date after January 1, 2005.*/
SELECT
    g.genre_name,
    COUNT(a.album_name) AS n_produced_albums
FROM
    albums a
JOIN
    genres g ON a.genre_id = g.genre_id
JOIN 
    (
        SELECT 
            genre_id,
            MIN(release_date) AS release_date
        FROM 
            albums
        WHERE 
            release_date >= '2005-01-01'
        GROUP BY 
            genre_id
    ) s ON g.genre_id = s.genre_id
GROUP BY 
    g.genre_name
ORDER BY 
    g.genre_name;

/*The result set with information about the genre code and earliest release date 
	of an album associated with that genre.*/
SELECT
    g.genre_id,
    g.genre_name,
    COUNT(a.album_name) AS n_produced_albums,
    s.release_date AS earliest_release_date
FROM
    albums a
JOIN
    genre g ON a.genre_id = g.genre_id
JOIN 
    (
        SELECT 
            genre_id,
            MIN(release_date) AS release_date
        FROM 
            albums
        WHERE 
            release_date >= '2005-01-01'
        GROUP BY 
            genre_id
    ) s ON g.genre_id = s.genre_id
GROUP BY 
    g.genre_id, g.genre_name, s.release_date
ORDER BY 
    g.genre_id, g.genre_name;
