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
Select round(sum(so)::numeric/sum(g)::numeric,2) as Strikeouts_per_game,round(sum(hr)::numeric/sum(g)::numeric,2) as homeruns_per_game, (yearid / 10) * 10 as decade
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
select*
from teams
--























