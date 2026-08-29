1. What range of years for baseball games played does the provided database cover? 
-----2016-------
SELECT *
FROM homegames
ORDER BY year DESC;
-------1871-------
SELECT *
FROM homegames
ORDER BY year;
------
SELECT MAX(year) AS most_recent_year, 
		MIN(year) AS earliest_year
FROM homegames;
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
----inner joit teams table to get the name of team---
SELECT *
FROM people INNER JOIN appearances
		USING (playerid)
			JOIN teams 
    		ON appearances.teamID = teams.teamID
    		AND appearances.yearID = teams.yearID
WHERE height IS NOT NULL AND playerid = 'gaedeed01';
--ORDER BY height;
-------He played 1 game---team name: St.Louis Browns


----------------------------------------------------------------
3. Find all players in the database who played at 
Vanderbilt University. Create a list showing 
each player’s first and last names as well as 
the total salary they earned in the major leagues. 
Sort this list in descending order by the total salary earned.
Which Vanderbilt player earned the most money in the majors?
-------------David Price----------------------------------------------------
----started with people table and joined collegeplaying and schools table-
---and also sored it with school name-----

SELECT *
FROM people INNER JOIN collegeplaying
			USING (playerid)
			INNER JOIN schools
			USING (schoolid)
WHERE schoolname = 'Vanderbilt University';

----joining  salaries table------

SELECT namefirst, namelast, salary
FROM people INNER JOIN collegeplaying
			USING (playerid)
			INNER JOIN schools
			USING (schoolid)
			INNER JOIN salaries
			USING (playerid)
WHERE schoolname = 'Vanderbilt University';

-----SUM of salary----order by total salary desc----

SELECT namefirst, namelast, SUM(salary) AS total_salary
FROM people INNER JOIN collegeplaying
			USING (playerid)
			INNER JOIN schools
			USING (schoolid)
			INNER JOIN salaries
			USING (playerid)
WHERE schoolname = 'Vanderbilt University'
GROUP BY namefirst, namelast 
ORDER BY total_salary DESC;



SELECT *
FROM collegeplaying;

SELECT *
FROM schools;

			
-------------------------------------------------------------------
4. Using the fielding table, group players into 
three groups based on their position: 
label players with position OF as "Outfield", 
those with position "SS", "1B", "2B", and "3B" as "Infield", 
and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these 
three groups in 2016.
----------------------------------------------------------------------------

SELECT *
FROM fielding;

--------case statement--------- adding cloumn
SELECT *,
	CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ( 'SS','1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
		ELSE 'none' 
	END AS pos_groups
FROM fielding;

------adding where clause for year 2016----

SELECT *, 
	CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ( 'SS','1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
		ELSE 'none' 
	END AS pos_groups
FROM fielding
WHERE yearid = 2016;

-----adding SUM of po as total putouts---

SELECT playerid, pos, po,
	CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ( 'SS','1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
		ELSE 'none' 
	END AS pos_groups,
	SUM(po) AS total_putouts
FROM fielding
WHERE yearid = 2016
GROUP BY playerid, pos, po,
	CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ( 'SS','1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
		ELSE 'none'
	END;
-------------------------------------------------------------
-------trying to do total putouts by these 3 groups only-----
SELECT 
	CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ( 'SS','1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
		ELSE 'none' 
	END AS pos_groups,
	SUM(po) AS total_putouts
FROM fielding
WHERE yearid = 2016
GROUP BY 
	CASE WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ( 'SS','1B', '2B', '3B') THEN 'Infield'
		WHEN pos IN ('P', 'C') THEN 'Battery'
		ELSE 'none'
	END;
	
-----------------------------------------------------------


------------------------------------------------------------------------------------------------------------
5. Find the average number of strikeouts per game 
by decade since 1920. Round the numbers you report 
to 2 decimal places. Do the same for home runs per game. 
Do you see any trends?

----------------------------------------------------------------------

-------home run--------

SELECT (yearid/10 *10) AS decade, ROUND(SUM(hr):: numeric/SUM(g):: numeric, 2) AS avg_so_game
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade DESC;
--------strike outs-------------------

SELECT (yearid/10 *10) AS decade, ROUND(SUM(so):: numeric/SUM(g):: numeric, 2) AS avg_so_game
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade DESC;


---------------------------------------------------------------------
6. Find the player who had the most success stealing bases 
in 2016, where __success__ is measured as the percentage 
of stolen base attempts which are successful. 
(A stolen base attempt results either in a stolen base 
or being caught stealing.) Consider only players who 
attempted _at least_ 20 stolen bases.
---------------------------------------------------------

SELECT *
FROM batting
WHERE yearid = 2016;

------Success = sb successfully/sb success + cs unsuccess

SELECT playerid, sb, cs --(sb/NULLIF((sb + cs), 0)) AS percentage_success_sb
FROM batting
WHERE yearid = 2016 AND sb >=20
ORDER BY sb DESC;

-------trying to find percentage of success sb----

SELECT playerid, sb, cs, sb * 100.0/NULLIF((sb + cs), 0)  AS percentage_success_sb
FROM batting
WHERE yearid = 2016 AND (sb + cs)>=20
ORDER BY percentage_success_sb DESC;


--------------------------------------------------
SELECT PlayerID, SB, CS,
    CASE
        WHEN COALESCE(SB, 0) + COALESCE(CS, 0) = 0 THEN 0
        ELSE COALESCE(SB, 0) * 100.0 / (COALESCE(SB, 0) + COALESCE(CS, 0))
    END AS Percentage_Success_SB
FROM Batting
WHERE YearID = 2016 AND (COALESCE(SB, 0) + COALESCE(CS, 0)) >= 20
ORDER BY Percentage_Success_SB DESC;

--------------------------------------------------------------------------------

7.  From 1970 – 2016, what is the largest number of wins 
for a team that did not win the world series? 
What is the smallest number of wins for a team that did win
the world series? Doing this will probably result in 
an unusually small number of wins for a world series 
champion – determine why this is the case. 
Then redo your query, excluding the problem year. 
How often from 1970 – 2016 was it the case that a team with
the most wins also won the world series? 
What percentage of the time?



-------------------------------------------------------------------------------

SELECT *
FROM teams;
--------teams that did not win world series with largest
----- wins is 116----yearid 2001 and team name Seattle Mariners
SELECT *
FROM teams
WHERE wswin = 'N' 
	AND wswin IS NOT NULL 
	AND yearid BETWEEN 1970 AND 2016
ORDER BY w DESC;

-----did sum of wins to get total_win by team that did not win 
----world series --largest w Seatles Mariners 116-----


SELECT teamid, yearid, name, w AS total_win
FROM teams
WHERE wswin = 'N' 
	AND wswin IS NOT NULL 
	AND yearid BETWEEN 1970 AND 2016
ORDER BY total_win DESC;

--------team that did win world series with smallest
----- wins is 90---- team name Atlanta Braves---

SELECT teamid, yearid, name, w AS total_win
FROM teams
WHERE wswin = 'Y' 
	AND wswin IS NOT NULL 
	AND yearid BETWEEN 1970 AND 2016
ORDER BY total_win;

-----Exluding outlier 1981------

SELECT teamid, yearid, name, w AS total_win
FROM teams
WHERE wswin = 'Y' 
	AND wswin IS NOT NULL 
	AND yearid BETWEEN 1970 AND 2016
	AND yearid <> 1981
ORDER BY total_win;


    INNER JOIN max_wins
        ON teams.yearid = max_wins.yearid
        AND teams.w = max_wins.max_wins)
SELECT
    COUNT(*) AS years_winningest_team_won_ws,
    COUNT(*) * 100.0 / 47 AS percentage
FROM winningest_teams
WHERE wswin = 'Y';

---------------------------------------------------------------
 8. Using the attendance figures from the homegames table, 
 find the teams and parks which had the top 5 
 average attendance per game in 2016 
 (where average attendance is defined as total 
 attendance divided by number of games). 
 Only consider parks where there were at least 10 games played. 
 Report the park name, team name, and average attendance. 
 Repeat for the lowest 5 average attendance.

 --------------------------------------------------------------
 ---park with year 2016 and games >=10-----
 
 SELECT park
 FROM homegames
 WHERE games >=10 and year = 2016;
 
 
 ----highest top 5 avg attendance----
 
 SELECT name, parks.park_name, ROUND(SUM(homegames.attendance):: numeric/SUM(homegames.games):: numeric, 2) AS avg_attendance
 FROM homegames INNER JOIN parks 
 				ON homegames.park = parks.park
				 INNER JOIN teams
				 ON homegames.team = teams.teamid
 WHERE year = 2016 AND games >=10
 GROUP BY name, parks.park_name
 ORDER BY avg_attendance DESC
 LIMIT 5;

 ----lowest top 5 avg attendance----
 
 SELECT name, parks.park_name, ROUND(SUM(homegames.attendance):: numeric/SUM(homegames.games):: numeric, 2) AS avg_attendance
 FROM homegames INNER JOIN parks 
 				ON homegames.park = parks.park
				 INNER JOIN teams
				 ON homegames.team = teams.teamid
 WHERE year = 2016 AND games >=10
 GROUP BY name, parks.park_name
 ORDER BY avg_attendance
 LIMIT 5;

 -------------------------------------------------------------------------------------

 9. Which managers have won the TSN Manager of the Year award
 in both the National League (NL) and the American League (AL)?
 Give their full name and the teams that they were managing 
 when they won the award.

 --------------------------------------------------------------

SELECT a.playerid, a.yearid, p.namegiven, a.awardid, t.name, a.lgid
FROM awardsmanagers a INNER JOIN people p
 						ON a.playerid = p.playerid
					INNER JOIN appearances ap
						ON p.playerid = ap.playerid
					INNER JOIN teams t
						ON ap.teamid = t.teamid AND ap.yearid = t.yearid
WHERE awardid = 'TSN Manager of the Year'
   AND (a.lgid = 'NL' OR a.lgid = 'AL');




SELECT playerid
FROM awardsmanagers 
WHERE awardid = 'TSN Manager of the Year'
	AND lgid IN ('AL', 'NL')
GROUP BY playerid
HAVING COUNT(DISTINCT lgid)=2;



SELECT DISTINCT(playerid)
FROM awardsmanagers AS S1 INNER JOIN awardsmanagers AS S2
							USING (playerid)
WHERE S1.awardid = 'TSN Manager of the Year'
	AND S2.awardid = 'TSN Manager of the Year'
	AND S1.lgid = 'AL'
	AND S2.lgid = 'NL';

-----checking for players------gives me NL for 3 diff years
SELECT *
FROM awardsmanagers
WHERE playerid = 'leylaji99' AND awardid = 'TSN Manager of the Year' 
	AND lgid IN ('AL', 'NL');
-------this gives only 2 results so this looks correct---
SELECT *
FROM awardsmanagers
WHERE playerid = 'johnsda02' AND awardid = 'TSN Manager of the Year' 
	AND lgid IN ('AL', 'NL');

---------------

SELECT DISTINCT(playerid)
FROM awardsmanagers AS S1 INNER JOIN awardsmanagers AS S2
							USING (playerid)
WHERE S1.awardid = 'TSN Manager of the Year'
	AND S2.awardid = 'TSN Manager of the Year'
	AND S1.lgid = 'AL'
	AND S2.lgid = 'NL';


SELECT DISTINCT people.playerid, 
				people.namefirst, 
				people.namelast,
				name,
				teams.yearid
FROM awardsmanagers AS S1 INNER JOIN awardsmanagers AS S2
							USING (playerid)
							INNER JOIN people
							USING (playerid)
							INNER JOIN managers
							USING (playerid)
							INNER JOIN teams
							ON managers.yearid = teams.yearid
							 AND managers.teamid = teams.teamid
							 AND S1.yearid = managers.yearid
WHERE S1.awardid = 'TSN Manager of the Year'
	AND S2.awardid = 'TSN Manager of the Year'
	AND S1.lgid = 'AL'
	AND S2.lgid = 'NL';

--------

SELECT *
FROM awardsmanagers
WHERE lgid = 'AL' and awardid = 'TSN Manager of the Year')

SELECT *
FROM awardsmanagers
WHERE lgid = 'NL' and awardid = 'TSN Manager of the Year';






--------------------------------------------------------------------------------------------

10. Find all players who hit their career highest number of home runs 
in 2016. Consider only players who have played in the league 
for at least 10 years, and who hit at least one home run in  2016. 
Report the players' first and last names and the number of home runs 
they hit in 2016.


SELECT *
FROM teams
WHERE yearid = 2016 AND g>=10 and hr >=1;

SELECT *
FROM appearances INNER JOIN teams
					USING (yearid, teamid)
WHERE yearid = 2016 AND g_all >= 10 AND hr >=1;





