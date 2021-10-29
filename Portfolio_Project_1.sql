/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From PortfolioProject..CovidDeaths
Order By 3,4;

-- Select *
-- From PortfolioProject..CovidVaccinations
-- Order By 3,4


-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1,2;


-- Looking at total Cases vs Total Deaths 
-- Shows the likelyhood of dying if you contract covid in your country 

Select location, date, total_cases, total_deaths, population, ROUND((total_cases/population)*100, 4) as InfectedPercentage, ROUND((total_deaths/total_cases)*100, 4) AS DeathPercentage 
From PortfolioProject..CovidDeaths
Where location like '%canada%'
Order By 1,2;


--Looking at Total Cases vs Population 
--Shows what percentage of population got Covid 

Select location, date, total_cases, total_deaths, population, ROUND((total_cases/population)*100, 4) as InfectedPercentage 
From PortfolioProject..CovidDeaths
Where location like '%canada%'
Order By 1,2;


--Looking at countries with highest infection rate compared to population 

Select location, population, MAX(total_cases) as HighestInfectionCount, ROUND(MAX((total_cases/population))*100,2) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%canada%'
Group by population, location
Order By PercentPopulationInfected DESC


--LET'S BREAK THIS DOWN BY CONTINENT 
--Showing the continents with the highest death count per population

Select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%canada%'
Where continent IS NOT NULL
Group by continent
Order By TotalDeathCount DESC


-- Global Numbers

Select date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as INT)) AS Total_Deaths, ROUND(SUM(CAST(new_deaths as INT))/SUM(new_cases)*100, 2) AS DeathPerentage
From PortfolioProject..CovidDeaths
--Where location like '%canada%'
Where continent is not null
Group by date
Order By 1,2

-- Global Death Percentage

Select SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths as INT)) AS Total_Deaths, ROUND(SUM(CAST(new_deaths as INT))/SUM(new_cases)*100, 2) AS DeathPerentage
From PortfolioProject..CovidDeaths
--Where location like '%canada%'
Where continent is not null
--Group by date
Order By 1,2



-- Looking at Total Population vs Vaccinations 

 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
 From PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3




-- USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated 
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac



-- TEMP TABLE


DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric,
)

INSERT INTO #PercentPopulationVaccinated
 SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated 
 FROM PortfolioProject..CovidDeaths dea
 JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
FROM #PercentPopulationVaccinated



-- Creating View to store data for later visulizations 


DROP VIEW IF EXISTS PercentPopulationVaccinated
Create view PercentPopulationVaccinated 
AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, 
	dea.date) AS RollingPeopleVaccinated 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3



SELECT *
FROM PercentPopulationVaccinated
ORDER BY 2
