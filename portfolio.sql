SELECT * 
FROM portfolio_project.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


-- SELECT DATA THAT WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (NullIF(total_deaths, 0)/ total_cases) * 100 DeathPercentage
FROM portfolio_project.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


-- Total Cases vs Population
-- What percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/ population) * 100 DeathPercentage
FROM portfolio_project.dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2



-- Countries with Highest infection Rate compared to Population
SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/ population) * 100) PercentPopulationInfected
FROM portfolio_project.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Countries with highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCounts
FROM portfolio_project.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCounts DESC

-- BY CONTINENTS

SELECT location, MAX(total_deaths) as TotalDeathCounts
FROM portfolio_project.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCounts DESC



-- Showing continents with the highest death count


SELECT continent, MAX(total_deaths) as TotalDeathCounts
FROM portfolio_project.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCounts DESC



-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) AS Total Cases, SUM(new_deaths) AS TotalDeaths, SUM(New_deaths)/NULLIF(SUM(New_Cases), 0)*100 as DeathPercentage
FROM portfolio_project.dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2



-- Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition BY dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolio_project..CovidDeaths as dea
JOIN portfolio_project..CovidVaccinations as vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <> ' '
ORDER BY 1,2,3


WITH popVsVac (continent, location,date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition BY dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolio_project..CovidDeaths as dea
JOIN portfolio_project..CovidVaccinations as vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL AND dea.continent <> ' '
-- ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)* 100
FROM popVsVac

-- Creating view for later vizualization

CREATE VIEW PercentpopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition BY dea.location Order BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolio_project..CovidDeaths as dea
JOIN portfolio_project..CovidVaccinations as vac
	ON dea.location=vac.location 
	AND dea.date=vac.date
WHERE dea.continent IS NOT NULL


SELECT * FROM PercentpopulationVaccinated