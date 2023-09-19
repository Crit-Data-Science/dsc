/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 1 of the case study, which means that there'll be more guidance for you about how to 
setup your local SQLite connection in PART 2 of the case study. 

The questions in the case study are exactly the same as with Tier 2. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/ ->  https://frankfletcher.co/springboard_phpmyadmin/index.php
Username: student -> admin_springboard
Password: learn_sql@springboard -> springboardbackup

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT facid FROM `Facilities` WHERE `membercost` > 0
 facid 	
0
1
4
5
6

/* Q2: How many facilities do not charge a fee to members? */

5

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance 
FROM `Facilities` 
WHERE (`membercost` / monthlymaintenance) < .2

 facid 	name 	membercost 	monthlymaintenance 	
0 	Tennis Court 1 	5.0 	200
1 	Tennis Court 2 	5.0 	200
2 	Badminton Court 	0.0 	50
3 	Table Tennis 	0.0 	10
4 	Massage Room 1 	9.9 	3000
5 	Massage Room 2 	9.9 	3000
6 	Squash Court 	3.5 	80
7 	Snooker Table 	0.0 	15
8 	Pool Table 	0.0 	15

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT * 
FROM `Facilities` 
WHERE facid IN (1,5)

 facid 	name 	membercost 	guestcost 	initialoutlay 	monthlymaintenance 	expense_label 	
1 	Tennis Court 2 	5.0 	25.0 	8000 	200 	expensive
5 	Massage Room 2 	9.9 	80.0 	4000 	3000 	expensive

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT facid, monthlymaintenance
FROM Facilities
WHERE monthlymaintenance > 100

 facid 	monthlymaintenance 	
0 	200
1 	200
4 	3000
5 	3000

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT MAX(joindate),firstname, surname
FROM Members


MAX(joindate) 	firstname 	surname 	
2012-09-26 18:08:45 	GUEST 	GUEST


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

WITH cte_names AS
( SELECT CONCAT_WS(' ', firstname, surname) AS fname, memid FROM Members)
SELECT b.starttime, f.name, n1.fname,
         CASE b.memid
         WHEN 0 THEN CONVERT(b.slots, DECIMAL) * f.guestcost
         ELSE CONVERT(b.slots, DECIMAL) * f.membercost
         END AS cost
FROM Bookings AS b
LEFT JOIN Facilities as f
ON b.facid = f.facid
LEFT JOIN Members as m
ON b.memid = m.memid
LEFT JOIN cte_names as n1
ON b.memid = n1.memid
HAVING starttime LIKE '2012-09-14%' AND cost > 30
	

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */


 SELECT b.starttime, f.name, CONCAT_WS(' ', m.firstname, m.surname) as name, b.bookid,
	CASE b.memid
	WHEN 0 THEN CONVERT(b.slots, DECIMAL) * f.guestcost
	ELSE CONVERT(b.slots, DECIMAL) * f.membercost
    END AS cost
FROM
	Facilities f
    INNER JOIN Bookings b ON b.facid = f.facid
    INNER JOIN Members m ON b.memid = m.memid
WHERE b.starttime LIKE "2012-09-14%"
HAVING cost > 30
ORDER by cost DESC



/* Q9: This time, produce the same result as in Q8, but using a subquery. */

WITH cte_names AS
( SELECT CONCAT_WS(' ', firstname, surname) AS fname, memid FROM Members)
SELECT starttime, name, fname, cost
FROM 
    (SELECT b.starttime, f.name, n1.fname,
             CASE b.memid
             WHEN 0 THEN CONVERT(b.slots, DECIMAL) * f.guestcost
             ELSE CONVERT(b.slots, DECIMAL) * f.membercost
             END AS cost
    FROM Bookings AS b
    LEFT JOIN Facilities as f
    ON b.facid = f.facid
    LEFT JOIN Members as m
    ON b.memid = m.memid
    LEFT JOIN cte_names as n1
    ON b.memid = n1.memid) AS subq
WHERE starttime LIKE '2012-09-14%' AND cost > 30

/* PART 2: SQLite
/* We now want you to jump over to a local instance of the database on your machine. 

Copy and paste the LocalSQLConnection.py script into an empty Jupyter notebook, and run it. 

Make sure that the SQLFiles folder containing thes files is in your working directory, and
that you haven't changed the name of the .db file from 'sqlite\db\pythonsqlite'.

You should see the output from the initial query 'SELECT * FROM FACILITIES'.

Complete the remaining tasks in the Jupyter interface. If you struggle, feel free to go back
to the PHPMyAdmin interface as and when you need to. 

You'll need to paste your query into value of the 'query1' variable and run the code block again to get an output.
 
QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SQL lite code:
'
SELECT f.name,
	SUM(CASE b.memid
	WHEN 0 THEN b.slots * f.guestcost
	ELSE b.slots * f.membercost
    END) AS revenue
FROM
	Facilities f
    INNER JOIN Bookings b ON b.facid = f.facid
    INNER JOIN Members m ON b.memid = m.memid
GROUP BY f.facid
HAVING revenue < 1000
ORDER BY revenue
'


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SQLite code:
'SELECT m1.surname, m1.firstname, m2.surname || ' ' || m2.firstname as 'recommended by'
FROM Members as m1
INNER JOIN Members AS m2
ON m1.recommendedby = m2.memid
ORDER BY m1.surname, m1.firstname'


/* Q12: Find the facilities with their usage by member, but not guests */

SQLite code:
'WITH cte_names AS
( SELECT firstname || ' ' || surname AS fname, memid FROM Members)
SELECT fname AS member_name, f.name AS fac_name, SUM(b.facid) AS fac_usage
FROM Bookings AS b
LEFT JOIN Facilities AS f
ON b.facid = f.facid
LEFT JOIN CTE_names AS n1
ON b.memid = n1.memid
WHERE b.memid > 0
GROUP BY b.facid, fname
ORDER BY fname'


/* Q13: Find the facilities usage by month, but not guests */

SQLite Code:
'WITH cte_names AS
( SELECT firstname || ' ' || surname AS fname, memid FROM Members),
cte_july AS (SELECT n1.fname, f.name, COUNT(b.starttime) AS july
FROM Bookings AS b
LEFT JOIN Facilities AS f
ON b.facid = f.facid
LEFT JOIN Members AS m
ON b.memid = m.memid
LEFT JOIN cte_names as n1
ON b.memid = n1.memid
WHERE b.memid > 0 AND b.starttime LIKE '2012-07%'
GROUP BY n1.fname, f.name),
cte_aug AS (SELECT n1.fname, f.name, COUNT(b.starttime) AS aug
FROM Bookings AS b
LEFT JOIN Facilities AS f
ON b.facid = f.facid
LEFT JOIN Members AS m
ON b.memid = m.memid
LEFT JOIN cte_names as n1
ON b.memid = n1.memid
WHERE b.memid > 0 AND b.starttime LIKE '2012-08%'
GROUP BY n1.fname, f.name),
cte_sep AS (SELECT n1.fname, f.name, COUNT(b.starttime) AS sep
FROM Bookings AS b
LEFT JOIN Facilities AS f
ON b.facid = f.facid
LEFT JOIN Members AS m
ON b.memid = m.memid
LEFT JOIN cte_names as n1
ON b.memid = n1.memid
WHERE b.memid > 0 AND b.starttime LIKE '2012-09%'
GROUP BY n1.fname, f.name)

SELECT DISTINCT n1.fname, f.name, IFNULL(j.july,0) AS july, IFNULL(a.aug,0) AS aug, IFNULL(s.sep,0) AS sep
FROM cte_names AS n1
LEFT JOIN Bookings AS b
ON n1.memid = b.memid
LEFT JOIN Facilities AS f
ON b.facid = f.facid
LEFT JOIN cte_july AS j
ON j.name = f.name AND j.fname = n1.fname
LEFT JOIN cte_aug AS a
ON a.name = f.name AND a.fname = n1.fname
LEFT JOIN cte_sep AS s
ON s.name = f.name AND s.fname = n1.fname
WHERE b.memid > 0
GROUP BY n1.fname, f.name'

