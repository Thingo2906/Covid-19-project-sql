-- We will check the data at first
SELECT * FROM PortfolioProject..CovidDeaths ORDER BY 3,4 
--Select the data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population FROM PortfolioProject..CovidDeaths ORDER BY 1,2

--looking at the total cases vs total deaths 
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as deathPercentage 
FROM PortfolioProject..CovidDeaths ORDER BY 1,2

--looking at the total cases vs total deaths in the United States
-- Showing what percent of death
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) as deathPercentage 
FROM PortfolioProject..CovidDeaths 
--WHERE location LIKE '%States%'
ORDER BY 1,2

--Looking at total cases vs population
-- Shows what percentage of population got covid
SELECT location, date, population, total_cases, ROUND((total_cases/population)*100,2) AS CasePercentage 
FROM PortfolioProject..CovidDeaths 
--WHERE location LIKE '%States%'
ORDER BY 1,2

-- Looking at at Countries with highest infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount , MAX(ROUND((total_cases/population)*100,2)) AS HighestCasePercentage 
FROM PortfolioProject..CovidDeaths 
--WHERE location LIKE '%States%'
GROUP BY location, population
ORDER BY HighestCasePercentage DESC

--Showing the countries highest death count per population
SELECT location, MAX(total_deaths) AS HighestDeathCount
FROM portfolioProject..CovidDeaths 
--WHERE location LIKE '%States%'
GROUP BY location
ORDER BY HighestDeathCount DESC

-- The order went wrong because the data type of total_deaths column is varchar not int
-- Thus,convert it into integer by use CAST()
SELECT location, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths 
--WHERE location LIKE '%States%'
GROUP BY location
ORDER BY HighestDeathCount DESC

--Showing country which is higgest death
--For world,the continent is NULL. 
SELECT location, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths 
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL
--WHERE continent <>'NULL'
GROUP BY location
ORDER BY HighestDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT, THERE ARE SOME CONTINENT IS NULL VALUE,
--SO WE NEED TO SHOW THE LOCATION TO KNOW WHERE IT IS
SELECT continent, location, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths 
--WHERE location LIKE '%States%'
--WHERE continent IS NULL 
GROUP BY continent,location
ORDER BY HighestDeathCount DESC

SELECT continent, MAX(CAST(total_deaths AS INT)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths 
--WHERE location LIKE '%States%'
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY HighestDeathCount DESC

--Compare total case and total death of global
SELECT date, SUM(new_cases) as total_new_cases, SUM(CAST(new_deaths as int)) as total_new_deaths,
ROUND(SUM(CAST(new_deaths as int))/SUM(new_cases)*100,2) as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Showing the total new cases and total new death
SELECT SUM(new_cases) as total_new_cases, SUM(CAST(new_deaths as int)) as total_new_deaths,
ROUND(SUM(CAST(new_deaths as int))/SUM(new_cases)*100,2) as death_percentage
FROM PortfolioProject..CovidDeaths
--WHERE continent is not null
--GROUP BY date
--ORDER BY 1,2

--Work with CovidVaccinations table
--Join it with CovidDeaths table
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations FROM PortfolioProject..CovidDeaths as dea
JOIN PortfolioProject..CovidVaccinations as vac ON dea.date=vac.date AND dea.location=vac.location
ORDER BY 2,3

--Looking at total population vs Vaccination
--WE divide the query result into partition, order by location and date
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea JOIN PortfolioProject..CovidVaccinations as vac ON
dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Create a template table with "With" clause
With pop_vs_vac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea JOIN PortfolioProject..CovidVaccinations as vac ON
dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent is not null)
SELECT *, ROUND((RollingPeopleVaccinated/population)*100,2) FROM pop_vs_vac

--Create a TEMPALTE table with "CREATE TABLE" clause
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric)
Insert into  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea JOIN PortfolioProject..CovidVaccinations as vac ON
dea.location=vac.location 
AND dea.date=vac.date
--WHERE dea.continent is not null
SELECT *, ROUND((RollingPeopleVaccinated/population)*100,2) AS percent_new_vaccinated FROM  #PercentPopulationVaccinated

--Create view to store date for later visualization
CREATE View Percent_PopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths as dea JOIN PortfolioProject..CovidVaccinations as vac ON
dea.location=vac.location 
AND dea.date=vac.date
WHERE dea.continent is not null

SELECT * FROM Percent_PopulationVaccinated














