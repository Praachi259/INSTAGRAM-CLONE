/*We want to reward our users who have been around the longest.  
Find the 5 oldest users.*/
SELECT * FROM users
ORDER BY created_at
LIMIT 5;


/*What day of the week do most users register on?
We need to figure out when to schedule an ad campgain*/
SELECT date_format(created_at,'%W') AS 'day of the week', COUNT(*) AS 'total registration'
FROM users
GROUP BY 1
ORDER BY 2 DESC;

/*version 2*/
SELECT 
    DAYNAME(created_at) AS day,
    COUNT(*) AS total
FROM users
GROUP BY day
ORDER BY total DESC
LIMIT 2;


/*We want to target our inactive users with an email campaign.
Find the users who have never posted a photo*/
SELECT username
FROM users
LEFT JOIN photos ON users.id = photos.user_id
WHERE photos.id IS NULL;


/*We're running a new contest to see who can get the most likes on a single photo.
WHO WON??!!*/
SELECT 
    username,
    photos.id,
    photos.image_url, 
    COUNT(*) AS total
FROM photos
INNER JOIN likes
    ON likes.photo_id = photos.id
INNER JOIN users
    ON photos.user_id = users.id
GROUP BY photos.id
ORDER BY total DESC
LIMIT 1;


/*Our Investors want to know...
How many times does the average user post?*/
/*total number of photos/total number of users*/
SELECT ROUND((SELECT COUNT(*)FROM photos)/(SELECT COUNT(*) FROM users),2);


/*user ranking by postings higher to lower*/
SELECT users.username,COUNT(photos.image_url)
FROM users
JOIN photos ON users.id = photos.user_id
GROUP BY users.id
ORDER BY 2 DESC;


/*Total Posts by users (longer versionof SELECT COUNT(*)FROM photos) */
SELECT SUM(user_posts.total_posts_per_user)
FROM (SELECT users.username,COUNT(photos.image_url) AS total_posts_per_user
		FROM users
		JOIN photos ON users.id = photos.user_id
		GROUP BY users.id) AS user_posts;


/*total numbers of users who have posted at least one time */
SELECT COUNT(DISTINCT(users.id)) AS total_number_of_users_with_posts
FROM users
JOIN photos ON users.id = photos.user_id;


/*A brand wants to know which hashtags to use in a post
What are the top 5 most commonly used hashtags?*/
SELECT tag_name, COUNT(tag_name) AS total
FROM tags
JOIN photo_tags ON tags.id = photo_tags.tag_id
GROUP BY tags.id
ORDER BY total DESC;


/*We have a small problem with bots on our site...
Find users who have liked every single photo on the site*/
SELECT users.id,username, COUNT(users.id) As total_likes_by_user
FROM users
JOIN likes ON users.id = likes.user_id
GROUP BY users.id
HAVING total_likes_by_user = (SELECT COUNT(*) FROM photos);


/* List the top 5 users with the most uploaded photos.*/ 

SELECT users.username, COUNT(photos.id) AS photo_count
FROM users
JOIN photos ON users.id = photos.user_id
GROUP BY users.id
ORDER BY photo_count DESC
LIMIT 5;

/* Write a query to find the number of followers for each user.*/

SELECT followee_id AS user_id, COUNT(follower_id) AS follower_count
FROM follows
GROUP BY followee_id;

/*  Identify the users who have the highest number of mutual followers (users following each other).*/

SELECT u1.username AS user1, u2.username AS user2, COUNT(*) AS mutual_follow_count
FROM follows AS f1
JOIN follows AS f2 
    ON f1.follower_id = f2.followee_id AND f1.followee_id = f2.follower_id
JOIN users AS u1 ON f1.follower_id = u1.id
JOIN users AS u2 ON f1.followee_id = u2.id
GROUP BY u1.username, u2.username
ORDER BY mutual_follow_count DESC;

/* Find users who have never liked their own photos.*/

SELECT u.username
FROM users AS u
WHERE NOT EXISTS (
    SELECT 1 
    FROM likes AS l
    JOIN photos AS p ON l.photo_id = p.id
    WHERE p.user_id = u.id AND l.user_id = u.id
);

/* List all users who have received no likes on their photos but have liked other photos.*/

SELECT u.username
FROM users AS u
WHERE NOT EXISTS (
    SELECT 1
    FROM likes AS l
    JOIN photos AS p ON l.photo_id = p.id
    WHERE p.user_id = u.id
)
AND EXISTS (
    SELECT 1
    FROM likes AS l
    WHERE l.user_id = u.id
);

