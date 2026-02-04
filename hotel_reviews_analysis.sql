CREATE database hotel_reviews;
use hotel_reviews;

select count(*) from hotel_reviews;

SELECT COUNT(DISTINCT Hotel_Name) AS total_unique_hotels
FROM hotel_reviews;

# Approximate reviewer count 
SELECT COUNT(DISTINCT Reviewer_Nationality) AS reviewer_nationalities
FROM hotel_reviews;

SELECT
    SUM(CASE WHEN Hotel_Name IS NULL THEN 1 ELSE 0 END) AS Hotel_Name_missing,
    SUM(CASE WHEN Review_Date IS NULL THEN 1 ELSE 0 END) AS Review_Date_missing,
    SUM(CASE WHEN Reviewer_Score IS NULL THEN 1 ELSE 0 END) AS Reviewer_Score_missing,
    SUM(CASE WHEN Reviewer_Nationality IS NULL THEN 1 ELSE 0 END) AS Reviewer_Nationality_missing,
    SUM(CASE WHEN Positive_Review IS NULL THEN 1 ELSE 0 END) AS Positive_Review_missing,
    SUM(CASE WHEN Negative_Review IS NULL THEN 1 ELSE 0 END) AS Negative_Review_missing
FROM hotel_reviews;

SELECT 
    MIN(Reviewer_Score) AS min_score,
    MAX(Reviewer_Score) AS max_score
FROM hotel_reviews;

SELECT *
FROM hotel_reviews
WHERE Reviewer_Score < 0 OR Reviewer_Score > 10;

# Calculate average Reviewer_Score per hotel
SELECT hotel_name, avg(Reviewer_Score) as avg_score
FROM hotel_reviews
GROUP BY hotel_name; 

# Rank hotels by average reviewer score.
SELECT hotel_name, avg(Reviewer_Score) as avg_score, RANK() OVER(ORDER BY AVG(Reviewer_Score) DESC) as rank_of_hotel
FROM hotel_reviews
GROUP BY hotel_name; 

# List top 10 hotels by average reviewer score (minimum review threshold).
SELECT hotel_name, avg(Reviewer_Score) as avg_score, count(*) as review_count
FROM hotel_reviews
GROUP BY hotel_name
HAVING count(*) >= 5 and avg(reviewer_score) > 5
ORDER BY avg(reviewer_score) DESC
LIMIT 10;

# List bottom 10 hotels by average reviewer score (minimum review threshold).
SELECT hotel_name, avg(reviewer_score) as avg_score, count(*) as review_count
FROM hotel_reviews
GROUP BY hotel_name
HAVING count(*) >= 20
ORDER BY avg(reviewer_score) 
LIMIT 10;

# Identify hotels with highest number of reviews.
SELECT hotel_name, max(total_number_of_reviews) as total_reviews
FROM hotel_reviews
GROUP BY hotel_name
ORDER BY total_reviews DESC
LIMIT 10;

# Find hotels with high review volume but below-average scores.
SELECT AVG(Reviewer_Score) FROM hotel_reviews;

SELECT 
    hotel_name,
    COUNT(*) AS review_count,
    AVG(Reviewer_Score) AS avg_score
FROM hotel_reviews
GROUP BY hotel_name
HAVING COUNT(*) >= 50  -- high review volume threshold
   AND AVG(Reviewer_Score) < (SELECT AVG(Reviewer_Score) FROM hotel_reviews)  -- below overall average
ORDER BY review_count DESC;

# Compare Average_Score vs calculated average Reviewer_Score per hotel.
SELECT
    hotel_name,
    AVG(Reviewer_Score) AS avg_reviewer_score,
    MIN(Average_Score) AS advertised_score
FROM hotel_reviews
GROUP BY hotel_name;

# Compute expectation gap per hotel (Reviewer_Score – Average_Score).
SELECT
    hotel_name,
    AVG(Reviewer_Score) AS avg_reviewer_score,
    MIN(Average_Score) AS advertised_score,
    AVG(Reviewer_Score) - MIN(Average_Score) AS expectation_gap
FROM hotel_reviews
GROUP BY hotel_name
ORDER BY expectation_gap;

# Count reviews per year
SELECT
    YEAR(STR_TO_DATE(review_date, '%m/%d/%Y')) AS review_year,
    COUNT(*) AS review_count
FROM hotel_reviews
GROUP BY review_year
ORDER BY review_year;

# Calculate average Reviewer_Score per year
SELECT 
	YEAR(str_to_date(review_date, '%m/%d/%Y')) as review_year,
    avg(reviewer_score) as avg_review
FROM hotel_reviews
GROUP BY review_year
ORDER BY review_year; 

# Calculate average Reviewer_Score per month
SELECT
    YEAR(STR_TO_DATE(review_date, '%m/%d/%Y')) AS review_year,
    MONTH(STR_TO_DATE(review_date, '%m/%d/%Y')) AS review_month,
    AVG(reviewer_score) AS avg_review
FROM hotel_reviews
GROUP BY review_year, review_month
ORDER BY review_year, review_month;

# Identify months with lowest average Reviewer_Score
SELECT
    YEAR(STR_TO_DATE(review_date, '%m/%d/%Y')) AS review_year,
    MONTH(STR_TO_DATE(review_date, '%m/%d/%Y')) AS review_month,
    AVG(reviewer_score) AS avg_review
FROM hotel_reviews
GROUP BY review_year, review_month
ORDER BY avg_review
LIMIT 5;

# Compare recent vs older reviews using days_since_review
SELECT
    CASE 
        WHEN days_since_review <= 30 THEN 'Last 30 days'
        WHEN days_since_review <= 90 THEN 'Last 3 months'
        WHEN days_since_review <= 180 THEN 'Last 6 months'
        WHEN days_since_review <= 365 THEN 'Last 1 year'
        ELSE 'Older than 1 year'
    END AS review_recency,
    COUNT(*) AS review_count,
    AVG(reviewer_score) AS avg_score
FROM hotel_reviews
GROUP BY review_recency;

# Reviews by nationality (not individual reviewers)
SELECT
    Reviewer_Nationality,
    COUNT(*) AS review_count
FROM hotel_reviews
GROUP BY Reviewer_Nationality
ORDER BY review_count DESC;


# Average negative word count by Reviewer_Score bucket
SELECT
    CASE
        WHEN Reviewer_Score < 4 THEN '0-4'
        WHEN Reviewer_Score < 6 THEN '4-6'
        WHEN Reviewer_Score < 8 THEN '6-8'
        ELSE '8-10'
    END AS score_bucket,
    COUNT(*) AS review_count,
    AVG(Review_Total_Negative_Word_Counts) AS avg_negative_words
FROM hotel_reviews
GROUP BY score_bucket
ORDER BY score_bucket;

# Hotels with highest average negative word counts
SELECT 
	hotel_name,
    AVG(Review_Total_Negative_Word_Counts) AS avg_negative_words
FROM hotel_reviews
GROUP BY hotel_name
ORDER BY avg_negative_words DESC
LIMIT 5;

# Calculate Reviewer_Score variance per hotel
SELECT 
    hotel_name,
    COUNT(*) AS review_count,
    VARIANCE(Reviewer_Score) AS variance_
FROM hotel_reviews
GROUP BY hotel_name
HAVING review_count >= 5
ORDER BY variance_;

# Recent vs historical score deviation per hotel
SELECT
    hotel_name,
    AVG(CASE WHEN days_since_review <= 180 THEN Reviewer_Score END) AS recent_score,
    AVG(CASE WHEN days_since_review > 180 THEN Reviewer_Score END) AS old_score,
    AVG(CASE WHEN days_since_review <= 180 THEN Reviewer_Score END)
      - AVG(CASE WHEN days_since_review > 180 THEN Reviewer_Score END) AS score_change
FROM hotel_reviews
GROUP BY hotel_name
HAVING COUNT(*) >= 50
ORDER BY score_change DESC;























