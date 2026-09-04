--1--
SELECT
    MIN(yearid) AS first_year,
    MAX(yearid) AS last_year,
    MAX(yearid) - MIN(yearid) AS year_range
FROM appearances;
--2--
SELECT 
	namegiven,height,g_all as total_games,name
FROM people 
INNER JOIN appearances USING (playerid)
INNER JOIN teams USING (teamid)
WHERE height IS NOT NULL
ORDER BY height
LIMIT 1;
--3--
with vandy_players as (SELECT*
FROM schools
INNER JOIN collegeplaying USING (schoolid)
INNER JOIN people USING (playerid)
INNER JOIN salaries USING (playerid)
where schoolid = 'vandy')

select namegiven,sum(salary) as total_salary
from vandy_players
group by namegiven
order by total_salary desc;
--4--
SELECT
    CASE
        WHEN pos = 'OF' THEN 'Outfield'
        WHEN pos IN ('SS', '1B', '2B','3B') THEN 'Infield'
        WHEN pos IN ('P', 'C') THEN 'Battery'
    END AS position_group,
    SUM(po) AS total_putouts
FROM fielding
WHERE yearid = 2016
GROUP BY
    CASE
        WHEN pos = 'OF' THEN 'Outfield'
        WHEN pos IN ('SS', '1B', '2B','3B') THEN 'Infield'
        WHEN pos IN ('P', 'C') THEN 'Battery'
    END;
--5--	
Select round(sum(so)::numeric/sum(g)::numeric,2) as Strikeouts_per_game,
round(sum(hr)::numeric/sum(g)::numeric,2) as homeruns_per_game,
(yearid / 10) * 10 as decade
from teams
where (yearid / 10) * 10>=1920
group by decade
order by decade;


--6--
SELECT
    namegiven,
    SUM(sb) AS stolen_bases,
    SUM(cs) AS caught_stealing,
    ROUND(SUM(sb)::numeric / (SUM(sb) + SUM(cs)) * 100,2) AS success_percentage
FROM batting
INNER JOIN people USING (playerid)
WHERE yearid = 2016
GROUP BY namegiven
HAVING SUM(sb) >= 20
ORDER BY success_percentage DESC;
--7--
--From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? --
select yearid,name,w,wswin
from teams
where yearid >=1970
and wswin = 'N'
order by w desc;
--seattle mariners 116W--
--What is the smallest number of wins for a team that did win the world series?--
select yearid,name,w,wswin
from teams
where yearid between 1970 and 2016
and wswin = 'Y'
order by w;
--los Angeles dodgers 63w--
--Doing this will probably result in an unusually small number of wins for a world series champion
-- determine why this is the case. Then redo your query, excluding the problem year.--
select yearid,name,w,wswin
from teams
where yearid between 1970 and 2016
and wswin = 'Y'
and name = 'Los Angeles Dodgers'
order by w;
--problem year identified as 1981--
--Then redo your query, excluding the problem year--
select yearid,name,w,wswin
from teams
where yearid between 1970 and 2016
and yearid <>1981
and wswin = 'Y'
and name = 'Los Angeles Dodgers'
order by w;
--How often from 1970 – 2016 
--was it the case that a team with the most wins also won the world series? 
--What percentage of the time?--
with max_wins as (select yearid,max(w) as max_wins 
from teams
where yearid between 1970 and 2016
group by yearid)

select max_wins.yearid,name,w,wswin
from max_wins
inner join teams
	on teams.yearid = max_wins.yearid
where max_wins.yearid between 1970 and 2016
and wswin = 'Y'
order by w desc;

WITH max_wins AS (
    SELECT
        yearid,
        MAX(w) AS max_wins
    FROM teams
    WHERE yearid BETWEEN 1970 AND 2016
    GROUP BY yearid
),
winningest_teams AS 
    (SELECT
        teams.yearid,teams.name,teams.w,teams.wswin
    FROM teams
    INNER JOIN max_wins
        ON teams.yearid = max_wins.yearid
        AND teams.w = max_wins.max_wins)
SELECT
    COUNT(*) AS years_winningest_team_won_ws,
    COUNT(*) * 100.0 / 47 AS percentage
FROM winningest_teams
WHERE wswin = 'Y';
--8--
--Using the attendance figures from the homegames table,-- 
--find the teams and parks which had the top 5 average attendance per game in 2016-- 
--(where average attendance is defined as total attendance divided by number of games).-- 
--Only consider parks where there were at least 10 games played. --
--Report the park name, team name, and average attendance--
select park_name,teams.name,round(sum(homegames.attendance::numeric)/homegames.games,2)::numeric as average_attendance
from homegames
inner join parks using (park)
inner join teams on teams.teamid = homegames.team 
where year = 2016
and homegames.games >= 10
group by parks.park_name,teams.name,homegames.games
order by average_attendance desc
limit 5;
--Repeat for the lowest 5 average attendance--
select park_name,teams.name,round(sum(homegames.attendance::numeric)/homegames.games,2)::numeric as average_attendance
from homegames
inner join parks using (park)
inner join teams on teams.teamid = homegames.team 
where year = 2016
and homegames.games >= 10
group by parks.park_name,teams.name,homegames.games
order by average_attendance
limit 5;

--9--
--Which managers have won the TSN Manager of the Year award in both the National League (NL)--
--and the American League (AL)?-- 
--Give their full name and the teams that they were managing when they won the award.--
WITH award_winners AS (
    SELECT playerid
    FROM awardsmanagers
    WHERE awardid = 'TSN Manager of the Year'
        AND lgid = 'AL'

    INTERSECT

    SELECT playerid
    FROM awardsmanagers
    WHERE awardid = 'TSN Manager of the Year'
        AND lgid = 'NL'
)

SELECT
   namefirst,namelast, people.namegiven,
    awardsmanagers.yearid,
    teams.name AS team_name
FROM award_winners
INNER JOIN awardsmanagers
    ON award_winners.playerid = awardsmanagers.playerid
INNER JOIN managers
    ON awardsmanagers.playerid = managers.playerid
    AND awardsmanagers.yearid = managers.yearid
INNER JOIN people
    ON award_winners.playerid = people.playerid
INNER JOIN teams
    ON managers.teamid = teams.teamid
WHERE awardsmanagers.awardid = 'TSN Manager of the Year'
GROUP BY namefirst,namelast,Namegiven,awardsmanagers.yearid,teams.name
ORDER BY people.namegiven, awardsmanagers.yearid;

--10--
--Find all players who hit their career highest number of home runs in 2016. --
--Consider only players who have played in the league for at least 10 years,-- 
--and who hit at least one home run in 2016.-- 
--Report the players' first and last names and the number of home runs they hit in 2016.--
WITH career_high AS (
    SELECT
        playerid,
        MAX(hr) AS career_high_hr
    FROM batting
    GROUP BY playerid
),
hr_2016 AS (
    SELECT
        playerid,
        hr
    FROM batting
    WHERE yearid = 2016
),
player_years AS (
    SELECT
        playerid,
        COUNT(DISTINCT yearid) AS years_played
    FROM batting
    GROUP BY playerid
)
SELECT
    namefirst,namelast,
    hr_2016.hr
FROM hr_2016
INNER JOIN career_high
    ON hr_2016.playerid = career_high.playerid
INNER JOIN player_years
    ON hr_2016.playerid = player_years.playerid
INNER JOIN people
	ON hr_2016.playerid = people.playerid
WHERE hr_2016.hr = career_high.career_high_hr
    AND hr_2016.hr >= 1
	AND player_years.years_played >= 10;

--11--
--Is there any correlation between number of wins and team salary?--
--Use data from 2000 and later to answer this question. As you do this analysis,--
--keep in mind that salaries across the whole league tend to increase together,--
--so you may want to look on a year-by-year basis.--
SELECT teams.name,teams.yearid,teams.teamid,teams.w,
    SUM(salaries.salary)::numeric::money AS team_salary,SUM(salaries.salary::numeric / teams.w)::money AS cost_per_win
FROM salaries
INNER JOIN teams
    ON salaries.teamid = teams.teamid
   AND salaries.yearid = teams.yearid
WHERE teams.yearid >= 2000
GROUP BY teams.name,teams.yearid,teams.teamid,teams.w
ORDER BY teams.name,teams.yearid, teams.w DESC;
--Although there is not a direct point for point causation there is strong--
--evidence that salary fluctuations within teams and W/L Ratio are connected--

--12--
--In this question, you will explore the connection between number of wins and attendance.--
--Does there appear to be any correlation between attendance at home games and number of wins?--
--Do teams that win the world series see a boost in attendance the following year?--
--What about teams that made the playoffs?--
--Making the playoffs means either being a division winner or a wild card winner.--
SELECT yearid,name,w,ghome,attendance,wswin,divwin,wcwin
From teams
WHERE attendance IS NOT NULL AND ghome IS NOT NULL
group by yearid,name,w,ghome,attendance,wswin,divwin,wcwin
order by name,yearid;
--Although outliers do occur World Series wins do historically bring an increase--
--in attendance for the following year, Division and Wildcard Wins also trend in a positive direction--
--attendance wise but do not have as drastic of an effect as a World series win--

--13--
--It is thought that since left-handed pitchers are more rare, causing batters to face them less often,-- 
--that they are more effective. Investigate this claim and present evidence to-- 
--either support or dispute this claim. --
--First, determine just how rare left-handed pitchers are compared with right-handed pitchers.-- 
SELECT
    CASE
    WHEN throws = 'L' THEN 'Left'
    WHEN throws = 'R' THEN 'Right'
    END AS throwing_hand,
    COUNT(*) AS player_count
FROM people
WHERE throws IN ('L', 'R')
GROUP BY
    CASE
    WHEN throws = 'L' THEN 'Left'
    WHEN throws = 'R' THEN 'Right'
    END
ORDER BY player_count DESC;
--14480 R 3654 L--
--Are left-handed pitchers more likely to win the Cy Young Award? --

Select playerid,awardid,throws
from people
inner join awardsplayers using (playerid)
where awardid ='Cy Young Award'
and throws = 'R'
group by throws,playerid,awardid;
Select playerid,awardid,throws
from people
inner join awardsplayers using (playerid)
where awardid ='Cy Young Award'
and throws = 'L'
group by throws,playerid,awardid;
--53 right handed 24 Left handed--


--Are they more likely to make it into the hall of fame?--
SELECT
    CASE
        WHEN halloffamers.throws = 'L' THEN 'Left'
        WHEN halloffamers.throws = 'R' THEN 'Right'
    END AS throwing_hand,
    COUNT(*) AS player_count
FROM (
    SELECT playerid, throws
    FROM people
    INNER JOIN halloffame USING (playerid)
) AS halloffamers
GROUP BY
    CASE
        WHEN halloffamers.throws = 'L' THEN 'Left'
        WHEN halloffamers.throws = 'R' THEN 'Right'
    END;















