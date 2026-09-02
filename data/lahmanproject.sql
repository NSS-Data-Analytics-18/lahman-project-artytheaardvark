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
ORDER BY total_salary DESC; --"David"	"Price"	245553888

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
GROUP BY position; --"Battery"	41424
				   --"Infield"	52273
		           --"Outfield"	29560
                   --"unknown"	6661


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
 -- strike outs and home runs increase by deacade 

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

SELECT teamid,name, yearid, w
FROM teams
WHERE yearid >='1970'
     AND WSWin ='N'
GROUP BY teamid,name,yearid,w
ORDER BY w DESC; --SEATTLE MARINERS 2001 116


SELECT name, yearid, w AS total_wins
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
     AND WSWin ='Y'
	 AND yearid != 1981
GROUP BY name,yearid,w
ORDER BY w ASC; 

--1981 season did not have as many games 
                                                    
-- smallest number of games won outside strike year STL Cardinals 83 games

--How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? 
--What percentage of the time?

SELECT  name,yearid, w, wswin --- WORLD SERIES WINNERS.. ONLY 46
FROM teams
WHERE yearid BETWEEN 1970 AND 2016
	AND wswin = 'Y';

WITH max_games AS 
	(SELECT yearid, MAX(w) as max_wins 
	FROM teams 
	WHERE yearid BETWEEN 1970 AND 2016
	GROUP BY yearid
	order by yearid)
 SELECT teams.name, teams.yearid, teams.w,teams.WSWin
FROM teams INNER JOIN max_games AS mg
			ON teams.yearid = mg.yearid
			AND teams.w = mg.max_wins;

	


WITH max_games AS      ---final 
	(SELECT yearid, MAX(w) as max_wins 
	FROM teams 
	WHERE yearid BETWEEN 1970 AND 2016
	GROUP BY yearid
	order by yearid),
 teams_max_overall AS
(SELECT teams.name, teams.yearid, teams.w,teams.WSWin
FROM teams INNER JOIN max_games AS mg
			ON teams.yearid = mg.yearid
			AND teams.w = mg.max_wins)
SELECT COUNT (CASE WHEN WSWin = 'Y' THEN yearid END) AS WSwinners,COUNT(DISTINCT yearid) AS total_years,
ROUND(COUNT (CASE WHEN WSWin = 'Y' THEN yearid END)::numeric / COUNT(DISTINCT yearid)::numeric*100,2) as percenta_wins_by_max
FROM teams_max_overall;




--8. Using the attendance figures from the homegames table, find the teams and parks which had the 
--top 5 average attendance per game in 2016 (where average attendance is defined as total attendance 
--divided by number of games). Only consider parks where there were at least 10 games played. Report
--the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT park_name, teams.name, ROUND(homegames.attendance::numeric/homegames.games::numeric,2) AS avg_attendance
FROM homegames INNER JOIN parks USING (park)
			   INNER JOIN teams ON homegames.team = teams.teamid
WHERE year='2016'
    AND games >= '10'
GROUP BY park_name, 
	     teams.name,
		 homegames.attendance,
		 homegames.games
ORDER BY avg_attendance DESC
		 LIMIT 5; --"Dodger Stadium"	"Los Angeles Dodgers"	45719.90
                  --"Busch Stadium III"	"St. Louis Cardinals"	42524.57
                  --"Busch Stadium III"	"St. Louis Browns"	42524.57
                  --"Busch Stadium III"	"St. Louis Perfectos"	42524.57
                  --"Rogers Centre"	"Toronto Blue Jays"	41877.77


SELECT park_name, teams.name, ROUND(homegames.attendance::numeric/homegames.games::numeric,2) AS avg_attendance
FROM homegames INNER JOIN parks USING (park)
			   INNER JOIN teams ON homegames.team = teams.teamid
WHERE year='2016'
    AND games >= '10'
GROUP BY park_name, 
	     teams.name,
		 homegames.attendance,
		 homegames.games
ORDER BY avg_attendance ASC
		 LIMIT 5; --"Tropicana Field"	"Tampa Bay Devil Rays"	15878.56
                  --"Tropicana Field"	"Tampa Bay Rays"	15878.56
                  --"Oakland-Alameda County Coliseum"	"Oakland Athletics"	18784.02
                  --"Progressive Field"	"Cleveland Bronchos"	19650.21
                  --"Progressive Field"	"Cleveland Naps"	19650.21



--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the
--American League (AL)? Give their full name and the teams that they were managing when they won the 
--award.

WITH w_mgrs AS
(SELECT  *
FROM awardsmanagers AS nl INNER JOIN  awardsmanagers AS al
 						USING (playerid)
WHERE nl.awardid = 'TSN Manager of the Year' AND nl.lgid = 'NL'
		AND al.awardid = 'TSN Manager of the Year' AND al.lgid = 'AL'),
tp AS
	(SELECT name,playerid,yearid
	 FROM managers INNER JOIN teams USING (teamid,yearid))	
SELECT namefirst, namelast,tp.name,aw.yearid
FROM awardsmanagers AS aw INNER JOIN w_mgrs ON aw.playerid = w_mgrs.playerid
						  INNER JOIN people ON aw.playerid = people.playerid
						  INNER JOIN tp ON aw.playerid = tp.playerid AND aw.yearid = tp.yearid 
GROUP BY namefirst, namelast,tp.name,aw.yearid
ORDER BY yearid;     

--JIM LEYLAND PITTSBURGH PIRATES 1988,1990,1992
-- DAVEY JOHNSON BALTIMORE ORIOLES 1997 
-- JIM LEYLAND DETROIT TIGERS 2006
-- DAVEY JOHNSON WASHINGTON NATIONALS 2012

--10. Find all players who hit their career highest number of home runs in 2016. Consider only 
--players who have played in the league for at least 10 years, and who hit at least one home run in 2016. 
--Report the players' first and last names and the number of home runs they hit in 2016.

WITH p2016 AS 
(SELECT playerid, yearid, hr
FROM batting
WHERE hr >= 1
	AND yearid = 2016)
SELECT *
FROM batting INNER JOIN p2016 USING (playerid)
	;


--11. Is there any correlation between number of wins and team salary? 
--Use data from 2000 and later to answer this question. As you do this analysis,
--keep in mind that salaries across the whole league tend to increase together,
--so you may want to look on a year-by-year basis.

SELECT name, yearid, SUM(salary::numeric) AS team_salary,t.w, ROUND(SUM(salary::numeric)/w::numeric,2) AS pay_per_win
FROM salaries AS s INNER JOIN teams AS t USING (yearid, teamid)
WHERE yearid >= 2000
GROUP BY t.name, s.yearid,t.w
ORDER BY yearid;



--12. In this question, you will explore the connection between number of wins and attendance.
      --Does there appear to be any correlation between attendance at home games and number of wins?
      --Do teams that win the world series see a boost in attendance the following year?
	  --What about teams that made the playoffs? Making the playoffs means either being a division winner 
	  --or a wild card winner.


SELECT name, yearid, w,ghome,attendance 
FROM teams
WHERE attendance IS NOT NULL
	AND ghome IS NOT NULL
ORDER BY name,yearid;

SELECT *
FROM teams
WHERE WSWin = 'Y'
	AND attendance IS NOT NULL --WSWINNERS 
-- DID ATTENDANCE INCREASE AFTER WSWIN     PERCENT OF ATTENDANCE FROM WSW YEAR TO NEXT 
-- SAME FOR DIVISION WINNER OR WILD CARD WINNER 





-- WHEN WSWIN Y THEN ATTENDANE THEN INCREASE IN ATTENDANCE  NEXT YEAR 


--13.  It is thought that since left-handed pitchers are more rare, causing batters to face them less
--often, that they are more effective. Investigate this claim and present evidence to either support or 
--dispute this claim. First, determine just how rare left-handed pitchers are compared with right-handed 
--pitchers. Are left-handed pitchers more likely to win the Cy Young Award? Are they more likely to make it
--into the hall of fame?

