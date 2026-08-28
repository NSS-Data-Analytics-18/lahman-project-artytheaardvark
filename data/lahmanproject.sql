--1. What range of years for baseball games played does the provided database cover?
--*WHERE TO GET DATA FROM?
SELECT MIN(yearid) as first_year,
       MAX(yearid) as last_year
FROM appearances; --1871-2016

--2. Find the name and height of the shortest player in the database. 
--How many games did he play in? What is the name of the team for which he played?
SELECT playerid
FROM people
ORDER BY height ASC 
LIMIT 1; --shortest height


SELECT namefirst,namelast, height, g_all,name
FROM appearances INNER JOIN people USING (playerid)
				 INNER JOIN teams USING (teamid)
ORDER BY height ASC 
LIMIT 1;

--3. Find all players in the database who played at Vanderbilt University. 
--Create a list showing each player’s first and last names as well as the total salary they earned in 
--the major leagues. Sort this list in descending order by the total salary earned.
--Which Vanderbilt player earned the most money in the majors?

SELECT DISTINCT namefirst, namelast, SUM(salary) AS total_salary
FROM collegeplaying INNER JOIN schools USING (schoolid)
				    INNER JOIN people USING (playerid)
					INNER JOIN salaries USING (playerid)
WHERE schoolname = 'Vanderbilt University' ---vanderbilt players
GROUP BY namefirst, namelast
ORDER BY total_salary DESC;

--4. Using the fielding table, group players into three groups based on their position: label players 
--with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", 
--and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of 
--these three groups in 2016. 


SELECT 
CASE WHEN pos = 'OF' THEN 'Outfield'
		    WHEN pos IN ('ss','1B','2B','3B') THEN 'Infield'
			WHEN pos IN ('P','C') THEN 'Battery' 
			ELSE 'unknown' END AS position,
	SUM(po) AS total_po
FROM fielding
WHERE yearid = '2016'
GROUP BY position;


--5. Find the average number of strikeouts per game by decade since 1920. 
--Round the numbers you report to 2 decimal places. 
--Do the same for home runs per game. Do you see any trends?

SELECT (yearid / 10) *10 AS decade,ROUND(SUM(SO::numeric)/SUM(G::numeric),2) AS avg_so_per_game
FROM teams
WHERE  (yearid / 10) *10>='1920'
GROUP BY decade
ORDER BY decade;

SELECT (yearid / 10) *10 AS decade,ROUND(SUM(HR::numeric)/SUM(G::numeric),2) AS avg_so_per_game
FROM teams
WHERE(yearid / 10) *10 >='1920'
GROUP BY decade
ORDER BY decade;


--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured 
--as the percentage of stolen base attempts which are successful. (A stolen base attempt results either
--in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen 
--bases.

--% OF STOLEN BASE ATTEMPTS THAT ARE SUCCESSFUL 
--LOOK AT PLAYERS >=20 ATTEMPTS and attempt is sb + cs


--ATTEMPT 1
WITH sb_attempts AS
(SELECT yearid,playerid,sb,cs,(sb::NUMERIC + cs::NUMERIC) AS total_attempts
FROM batting
WHERE (sb + cs) >='20'
	   AND yearid = '2016'
GROUP BY yearid,playerid, sb, cs)
SELECT playerid, ROUND(sb_attempts.sb::numeric/sb_attempts.total_attempts::numeric*100,2) AS sbs
FROM batting INNER JOIN sb_attempts USING (playerid)
WHERE batting.yearid = '2016'
ORDER BY sbs DESC;

--ATTEMPT 2
SELECT yearid,playerid,ROUND(sb::numeric/(sb::numeric + cs::numeric),2) *100 AS ssb
FROM batting
WHERE (sb + cs) >='20'
	   AND yearid = '2016'
GROUP BY yearid,playerid, sb, cs
ORDER BY ssb DESC;



--7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series?
--What is the smallest number of wins for a team that did win the world series? Doing this will probably
--result in an unusually small number of wins for a world series champion – determine why this is the 
--case. Then redo your query, excluding the problem year. 

SELECT name, yearid,SUM(w) AS total_wins
FROM teams
WHERE yearid >='1970'
     AND WSWin ='N'
GROUP BY name,yearid
ORDER BY total_wins DESC; --SEATTLE MARINERS 2001 116


SELECT name, yearid, SUM(W) AS total_wins
FROM teams
WHERE yearid>='1970'
     AND WSWin ='Y'
	 AND yearid != 1981
GROUP BY name,yearid
ORDER BY total_wins ASC; --1981 season was cut short by a strike. LA Dogers had 63 total wins and went 
                                                                   -- on to win World Series
-- smallest number of games won outside strike year STL Cardinals 83 games


--8. Using the attendance figures from the homegames table, find the teams and parks which had the 
--top 5 average attendance per game in 2016 (where average attendance is defined as total attendance 
--divided by number of games). Only consider parks where there were at least 10 games played. Report
--the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the
--American League (AL)? Give their full name and the teams that they were managing when they won the 
--award.

--10. Find all players who hit their career highest number of home runs in 2016. Consider only 
--players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
--Report the players' first and last names and the number of home runs they hit in 2016.

---- THIS IS INCORRECT --

WITH min1_2016 AS (
SELECT playerid,namefirst, namelast
FROM batting INNER JOIN people USING (playerid)
WHERE HR >= '1'
	  AND yearid = '2016'
GROUP BY  playerid,namefirst, namelast, hr) -- TABLE W/ AT LEAST 1 HR IN 2016
SELECT playerid,namefirst,namelast, SUM(batting.hr) AS hr_total
FROM batting INNER JOIN min1_2016 USING (playerid)
GROUP BY  playerid,namefirst,namelast
HAVING COUNT(yearid)>=10
ORDER BY hr_total DESC; -- TABLE TOTAL HOME RUNS AND AT LEASE 10 YEARS AT BAT // PLAYERS CAN PLAY A SEASON 
-- AND NEVER BE AT BAT... 









    
