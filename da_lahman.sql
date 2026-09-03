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
			INNER JOIN teams 
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

SELECT *
FROM teams;
-------
SELECT yearid, SUM(hr):: numeric/SUM(g):: numeric AS avg_so_game
FROM teams
group by yearid;


--------strike outs-------------------

SELECT (yearid/10 *10) AS decade, ROUND(SUM(so):: numeric/SUM(g):: numeric, 2) AS avg_so_game
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade DESC;

-------home run--------

SELECT (yearid/10 *10) AS decade, ROUND(SUM(hr):: numeric/SUM(g):: numeric, 2) AS avg_hr_game
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


-------trying to find percentage of success sb----

SELECT playerid, sb, cs, sb * 100.0/NULLIF((sb + cs), 0)  AS percentage_success_sb
FROM batting
WHERE yearid = 2016 AND (sb + cs)>=20
ORDER BY percentage_success_sb DESC;


---------------------another way-----------------------------
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

------team with most wins----


WITH most_wins AS (
		SELECT yearid, max(w) AS max_wins
		FROM teams
		WHERE yearid BETWEEN 1970 and 2016
		AND yearid <> 1981
		GROUP BY yearid),

 most_wins_teams AS (		
			SELECT teams.yearid, 
					teams.name, 
					teams.w,
					teams.wswin
			FROM teams INNER JOIN most_wins
			ON teams.yearid = most_wins.yearid
			AND teams.w = most_wins.max_wins)
			
SELECT COUNT (*) AS number_of_wins,
		COUNT (*)*100.0/46 AS percentage
FROM most_wins_teams
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

SELECT *
FROM awardsmanagers;


--finding distinct player using having count function-----

SELECT playerid
FROM awardsmanagers 
WHERE awardid = 'TSN Manager of the Year'
	AND lgid IN ('AL', 'NL')
GROUP BY playerid
HAVING COUNT(DISTINCT lgid)=2;

-----using selfjoin---------------------------

SELECT DISTINCT(playerid)
FROM awardsmanagers AS S1 INNER JOIN awardsmanagers AS S2
							USING (playerid)
WHERE S1.awardid = 'TSN Manager of the Year'
	AND S2.awardid = 'TSN Manager of the Year'
	AND S1.lgid = 'AL'
	AND S2.lgid = 'NL';



---------------


SELECT DISTINCT people.playerid, 
				CONCAT(people.namefirst, ' ', people.namelast) AS full_name,
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

-------approatch using CTE----------????


WITH both_league AS (
					SELECT DISTINCT
						S1.playerid,
						S1.yearid AS AL_year,
						S2.yearid AS NL_year
					FROM awardsmanagers AS S1 INNER JOIN awardsmanagers AS S2
							USING (playerid)
					WHERE S1.awardid = 'TSN Manager of the Year'
						AND S2.awardid = 'TSN Manager of the Year'
						AND S1.lgid = 'AL'
						AND S2.lgid = 'NL')




--------------------------------------------------------------------------------------------

10. Find all players who hit their career highest number of 
home runs 
in 2016. Consider only players who have played in the league 
for at least 10 years, and who hit at least one home run in  2016. 
Report the players first and last names and the number of home runs they hit in 2016.


---------------------

SELECT *
FROM batting;


---find max home run from batting table----


SELECT playerid, yearid, max(hr) AS max_season_hr
FROM batting
GROUP BY playerid, yearid
ORDER BY yearid;

---hr in 2016------

SELECT playerid, MAX(hr) AS total_hr
FROM batting
WHERE yearid = 2016 
GROUP BY playerid;




-----------------find distinct 10 or more years-----

SELECT playerid, COUNT(DISTINCT(yearid)) AS numbers_distinct_10years
FROM batting
group by playerid
HAving COUNT(DISTINCT(yearid)) >=10;






---------------------------------------------------------------------
WITH playing_10_years AS (
    					SELECT 
        					playerid,
        					COUNT(DISTINCT yearid) AS number_of_years
    					FROM batting
    					GROUP BY playerid
    					HAVING COUNT(DISTINCT yearid) >= 10),


	season_hr AS (
    			SELECT 
       	 			playerid,
        			yearid,
        			SUM(hr) AS season_hr
    			FROM batting
    			GROUP BY playerid, yearid),


	career_highest_hr AS (
    			SELECT 
        			playerid,
        			MAX(season_hr) AS career_high_hr
    			FROM season_hr
    			GROUP BY playerid),


	hr_2016 AS (
    		SELECT 
        		playerid,
        		MAX(hr) AS hr_2016
    		FROM batting
    		WHERE yearid = 2016
    		GROUP BY playerid)


SELECT
    p.namefirst AS first_name,
    p.namelast AS last_name,
    h.hr_2016 AS home_runs_2016
FROM playing_10_years y
	INNER JOIN career_highest_hr c
    ON y.playerid = c.playerid
	INNER JOIN hr_2016 h
    ON y.playerid = h.playerid
	INNER JOIN people p
    ON y.playerid = p.playerid
WHERE h.hr_2016 = c.career_high_hr
  AND h.hr_2016 >= 1
ORDER BY h.hr_2016 DESC, p.namelast;
-----------------------------------------------
--finding max hr from batting table-----

SELECT playerid, yearid, max(hr)
FROM batting
GROUP BY playerid, yearid
ORDER BY yearid;

---hr in 2016-----

SELECT playerid, yearid,  max(hr) AS hr_2016
FROM batting
WHERE yearid = 2016
GROUP by playerid, yearid;

---intersect-----

(SELECT playerid, yearid, max(hr)
FROM batting
GROUP BY playerid, yearid
ORDER BY yearid)
INTERSECT
(SELECT playerid, yearid,  max(hr) AS hr_2016
FROM batting
WHERE yearid = 2016
GROUP by playerid, yearid);

--------------------------------------------------------------------------

11. Is there any correlation between number of wins and 
team salary? Use data from 2000 and later to answer this question.
As you do this analysis, keep in mind that salaries across 
the whole league tend to increase together, 
so you may want to look on a year-by-year basis.
----------------------------------------------------------------------

SELECT yearid, teamid, W
FROM teams
order by yearid;

SELECT *
FROM salaries;

SELECT *
FROM teams;


SELECT yearid, teamid, w, SUM(salary) AS salary
FROM teams INNER JOIN salaries
			USING (yearid, teamid)
WHERE yearid >=2000
GROUP BY yearid, teamid, w
ORDER BY yearid, w DESC, salary;

------------------------------------------------------------------------------
12. In this question, you will explore the connection between 
number of wins and attendance.
    <ol type="a">
      <li>Does there appear to be any correlation between 
	  attendance at home games and number of wins? </li>
      <li>Do teams that win the world series see a boost 
	  in attendance the following year? What about teams 
	  that made the playoffs? Making the playoffs means 
	  either being a division winner or a wild card winner.</li>
    </ol> 
-----------------------------------------------------------------------------

1
SELECT name, yearid, w, ghome, attendance
FROM teams
WHERE attendance IS NOT NULL AND ghome IS NOT NULL
ORDER BY name, yearid; 

SELECT *
FROM teams;

2----yes there is a tred of inc in attendance the following year.

SELECT name, yearid, divwin, wcwin, wswin, ghome, w, attendance 
FROM teams
WHERE wswin IS NOT NULL 
			AND attendance IS NOT NULL
			AND divwin IS NOT NULL 
			AND wcwin IS NOT NULL
			AND ghome IS NOT NULL
ORDER BY name, yearid;

3 ----yes there is an in in attendance the following year---

SELECT name, yearid, divwin, wcwin, w, attendance
FROM teams
WHERE divwin IS NOT NULL 
		AND wcwin IS NOT NULL
ORDER BY name, yearid;

----------------------------------------------------------------------------

13. It is thought that since left-handed pitchers 
are more rare, causing batters to face them 
less often, that they are more effective. 
Investigate this claim and present evidence to 
either support or dispute this claim. 
First, determine just how rare left-handed pitchers
are compared with right-handed pitchers. 
Are left-handed pitchers more likely to win the 
Cy Young Award? Are they more likely to make it 
into the hall of fame?
--------------------------------------------------------------------------------------
---R handed pitcher 14480----
SELECT count(*)
FROM people
WHERE throws = 'R';

---L handed pitcher 3654---

SELECT count(*)
FROM people
WHERE throws = 'L';

-----Are they more likely to make it 
into the hall of fame?--------
----R handed pitchers in hall of fame  3335----
SELECT *
FROM halloffame INNER JOIN people
				USING (playerid)
WHERE throws ='R';

---L handed pitches in hall of fame 786---
SELECT *
FROM halloffame INNER JOIN people
				USING (playerid)
WHERE throws ='L';

