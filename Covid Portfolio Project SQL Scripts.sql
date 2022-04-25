Select * from Portfolio_Project..CovidDeaths
Where continent is not null
order by 3,4

--Select * from Portfolio_Project..CovidVaccinations 
--order by 3,4

--Selecting the data that we will be working upon
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project.dbo.CovidDeaths
Where continent is not null
ORDER BY 1,2

--Total cases vs total deaths
--Shows the likelihood of dying from covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_Project.dbo.CovidDeaths
Where continent is not null and Location = 'India'
ORDER BY 1,2

--Looking at total cases vs population
--shows what %age of population got covid
SELECT Location, date, population, total_cases, (total_cases/population)*100
FROM Portfolio_Project.dbo.CovidDeaths
Where continent is not null
--WHERE Location = 'India'
ORDER BY 1,2 

--Looking at countries with the highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 
AS PercentPopulationInfected
FROM Portfolio_Project.dbo.CovidDeaths
Where continent is not null
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC


--Looking at countries with the Highest death count per population
SELECT Location,MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..CovidDeaths
Where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount DESC

--Looking at continents with the Highest death count per population
SELECT continent,MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..CovidDeaths
Where continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global numbers
SELECT date, SUM(new_cases) as total_cases,SUM(CAST(new_deaths as INT)) as total_deaths,SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio_Project.dbo.CovidDeaths
Where continent is not null 
GROUP BY date
ORDER BY 1,2

--Global numbers - total cases and total deaths
SELECT  SUM(new_cases) as total_cases,SUM(CAST(new_deaths as INT)) as total_deaths,SUM(CAST(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio_Project.dbo.CovidDeaths
Where continent is not null 
--GROUP BY date
ORDER BY 1,2

--Covid vaccinations table
SELECT * FROM Portfolio_Project..CovidVaccinations

--Looking at Total Population VS Vaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location
,dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project.dbo.CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac 
	ON dea.location=vac.location 
	and dea.date=vac.date
Where dea.continent is not null
order by 2,3


--USE CTE

With PopVSVac (Continent, Location, Date, Population,New_vaccinations,RollingPeopleVaccinated)
as
(SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location
,dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project.dbo.CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac 
	ON dea.location=vac.location 
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/Population)*100 as percentVaccinated
From PopVSVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population int,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location
,dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project.dbo.CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac 
	ON dea.location=vac.location 
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3

Select *,(RollingPeopleVaccinated/Population)*100 as percentVaccinated
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location
,dea.date) as RollingPeopleVaccinated
FROM Portfolio_Project.dbo.CovidDeaths dea
JOIN Portfolio_Project..CovidVaccinations vac 
	ON dea.location=vac.location 
	and dea.date=vac.date
Where dea.continent is not null
--order by 2,3


Select * from PercentPopulationVaccinated