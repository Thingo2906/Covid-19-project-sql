/*queries used for Tableau Project
*/
--1. Total new cases, total new deaths and the percent of new deaths comparing to new cases
SELECT SUM(new_cases) as total_new_cases, SUM(CAST(new_deaths as int)) as total_new_deaths,
ROUND(SUM(CAST(new_deaths as int))/SUM(new_cases)*100,2) as death_percentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--2 Collect toatal new deaths that location is not in World, European Union, and International

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null and
location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

--3 Showing which location has highest total_cases, and highest percentPopulationInfected of Covid

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  ROUND(Max((total_cases/population))*100,2) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

--4 Showing which location has highest total_cases, and highest percentPopulationInfected of Covid by date

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount, ROUND(Max((total_cases/population))*100,2) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

