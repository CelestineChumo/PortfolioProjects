
SELECT *
FROM PortfoloProjects..CovidVaccinations
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PortfoloProjects..CovidDeaths
--ORDER BY 3, 4

--Dataset exploration

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfoloProjects..CovidDeaths
ORDER BY 1, 2


--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying from COVID  
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfoloProjects..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2


--Looking at the Total Cases vs Population
--Show what percentage of population got COVID

SELECT location, date, population, total_cases,  (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfoloProjects..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1, 2


--Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfoloProjects..CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Showing Countries with the Highest Death Count Per Population

SELECT location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfoloProjects..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfoloProjects..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing the Continetns with ther highest death counts per population
SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM PortfoloProjects..CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfoloProjects..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


--Total Cases Worldwide per Death percentage
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) as total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfoloProjects..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- Joining both tables

SELECT *
FROM PortfoloProjects..CovidDeaths dea
JOIN PortfoloProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Looking at Total Populations vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS  RollingPeopleVaccinated
FROM PortfoloProjects..CovidDeaths dea
JOIN PortfoloProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Population per Country that are vacinnated
-- USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS  RollingPeopleVaccinated
FROM PortfoloProjects..CovidDeaths dea
JOIN PortfoloProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(INT, vac.new_vaccinations)) 
OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS  RollingPeopleVaccinated
FROM PortfoloProjects..CovidDeaths dea
JOIN PortfoloProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated



--Creating view to store data for later vizualization


CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS  RollingPeopleVaccinated
FROM PortfoloProjects..CovidDeaths dea
JOIN PortfoloProjects..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated




