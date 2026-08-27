1. What range of years for baseball games played does the provided database cover? 
-----2016-------
SELECT *
FROM homegames
ORDER BY year DESC;
-------1871-------
SELECT *
FROM homegames
ORDER BY year;
------------------------------------------------------------------------------
2. Find the name and height of the shortest player in the 
database. How many games did he play in? 
What is the name of the team for which he played?

---------shortest player: Eddie/gaedeed01 43 inches, 1951------
SELECT *
FROM people 
WHERE height IS NOT NULL
ORDER BY height
LIMIT 1;
--------teamid 'SLA' and year 1951
SELECT *
FROM people INNER JOIN appearances
		USING (playerid)
WHERE height IS NOT NULL AND playerid = 'gaedeed01'
ORDER BY height;
-------He played 52 games-----------

SELECT playerid, appearances.teamid, COUNT(teams.yearid) AS no_years_played
FROM people INNER JOIN appearances
			  USING (playerid)
			INNER JOIN teams
			ON appearances.teamid = teams.teamid
WHERE height IS NOT NULL AND playerid = 'gaedeed01'
GROUP BY playerid, appearances.teamid
ORDER BY height;

----------------------------------------------------------------
3. Find all players in the database who played at 
Vanderbilt University. Create a list showing 
each player’s first and last names as well as 
the total salary they earned in the major leagues. 
Sort this list in descending order by the total salary earned.
Which Vanderbilt player earned the most money in the majors?
-------------David Price----------------------------------------------------

SELECT *
FROM people INNER JOIN collegeplaying
			USING (playerid);

SELECT namefirst, namelast, SUM(salary) AS total_salary
FROM schools INNER JOIN collegeplaying
				USING (schoolid)
				INNER JOIN people 
				USING (playerid)
				INNER JOIN salaries
				USING (playerid)
WHERE schoolname = 'Vanderbilt University'
GROUP BY namefirst, namelast
ORDER BY total_salary DESC;
-------------------------------------------------------------------
4. Using the fielding table, group players into 
three groups based on their position: 
label players with position OF as "Outfield", 
those with position "SS", "1B", "2B", and "3B" as "Infield", 
and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these 
three groups in 2016.
----------------------------------------------------------------------------


SELECT 
	CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ( 'SS','1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
		ELSE 'none' 
	END AS pos_groups,
	SUM(po) AS total_putouts
FROM fielding
WHERE yearid = 2016 
		AND pos IN ('OF','SS','1B', '2B', '3B', 'P', 'C')
GROUP BY 
		CASE WHEN pos = 'OF' THEN 'Outfield'
									WHEN pos IN ( 'SS','1B', '2B', '3B') THEN 'Infield'
									WHEN pos IN ('P', 'C') THEN 'Battery'
									ELSE 'none' 
		END;

------------------------------------------------------------------------------------------------------------
5. Find the average number of strikeouts per game 
by decade since 1920. Round the numbers you report 
to 2 decimal places. Do the same for home runs per game. 
Do you see any trends?

----------------------------------------------------------------------
SELECT playerid, yearid, avg(so) AS avg_strikouts
FROM pitching
Where yearid >= 1920
GROUP BY playerid, yearid;

SELECT *
FROM pitching;

