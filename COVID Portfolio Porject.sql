SELECT *
FROM Portfolio_Project_1.coviddeaths
WHERE continent is not null
ORDER by 3,4;

-- SELECT *
-- FROM Portfolio_Project_1.covidvaccinations
-- ORDER by 3,4;

SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    Portfolio_Project_1.coviddeaths
ORDER BY 1 , 2;

-- Looking at Total Cases vs Total Deaths
-- Shows the likelyhood of dying if you contract covid in your country
SELECT 
    location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM
    Portfolio_Project_1.coviddeaths
Where location like '%canada%'
ORDER BY 1,2;

-- Looking at the total cases vs populations 
-- Shows what percentage of population got Covid

SELECT 
    location, date, population, total_cases, (total_cases/population)*100 as PercentageContracted 
FROM
    Portfolio_Project_1.coviddeaths
-- Where location like '%canada%'
ORDER BY 1,2;

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));
-- Using the above code to the bypass Error code 1055
-- Looking at countries with Highest Infection Rate compared to Population 

SELECT 
    location, date, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases)/population)*100 as PercentPopulationInfected
FROM
    Portfolio_Project_1.coviddeaths
-- Where location like '%canada%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Showing the Countries with Highest Death Count per Population 
ALTER TABLE `Portfolio_Project_1`.`coviddeaths` 
CHANGE COLUMN `total_deaths` `total_deaths` INT NULL DEFAULT NULL ,
CHANGE COLUMN `new_deaths` `new_deaths` INT NULL DEFAULT NULL ;

SELECT 
    location, MAX(total_deaths) as TotalDeathCount
FROM
    Portfolio_Project_1.coviddeaths
-- Where location like '%canada%'
GROUP BY location
ORDER BY 1;


-----------------------------------------------------------------------------------

-- Global numbers 

SELECT 
    SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM
    Portfolio_Project_1.coviddeaths
-- Where location like '%canada%'
-- GROUP BY date
ORDER BY 1,2;




-- Looking at Total Population vs Vaccinations 


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccinationCount 
    -- (RollingVaccination/population)*100  AS PercentageVaccinated  * Can't use this because we just created this column, column is unrecognized. Need to create CTE 
FROM Portfolio_Project_1.coviddeaths AS dea
JOIN Portfolio_Project_1.covidvaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not NULL 
ORDER BY 2, 3;





-- USE CTE Common Table Expression. 

WITH
  PopvsVac AS (
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingVaccination
  FROM
    Portfolio_Project_1.coviddeaths AS dea
  JOIN
   Portfolio_Project_1.covidvaccinations AS vac
  ON
    dea.location = vac.location
    AND dea.date = vac.date
  WHERE
    dea.continent IS NOT NULL )

SELECT *, ROUND((RollingVaccination/population)*100, 4) AS PercentageVaccinated
FROM
PopvsVac;



-- TEMP TABLE

-- DROP TABLE Portfolio_project_1.PercentPopulationVaccinated;
DROP Table IF EXISTS Portfolio_project_1.PercentPopulationVaccinated; 
CREATE TEMPORARY TABLE Portfolio_project_1.PercentPopulationVaccinated 
(	continent NVARCHAR(225), 
    location NVARCHAR(225),
    date datetime, 
    population NUMERIC,
	new_vaccinations NUMERIC,
    RollingVaccination NUMERIC
);


INSERT INTO Portfolio_project_1.PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingVaccination
  FROM
    Portfolio_Project_1.coviddeaths AS dea
  JOIN
    Portfolio_Project_1.covidvaccinations  AS vac
  ON
    dea.location = vac.location
    AND dea.date = vac.date
  WHERE
    dea.continent IS NOT NULL;


SELECT *, ROUND((RollingVaccination/population)*100, 4) AS PercentageVaccinated
FROM
Portfolio_project_1.PercentPopulationVaccinated; 


-- Creating View to stroe data for later visualizations

CREATE VIEW Portfolio_project_1.PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingVaccination
  FROM
    Portfolio_Project_1.coviddeaths AS dea
  JOIN
    Portfolio_Project_1.covidvaccinations  AS vac
  ON
    dea.location = vac.location
    AND dea.date = vac.date
  WHERE
    dea.continent IS NOT NULL
ORDER by 2, 3;

