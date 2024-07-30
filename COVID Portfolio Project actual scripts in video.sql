Select *
From PortfolioProject.dbo.CovidDeaths
order by 3,4

--Select *
--From PortfolioProject.dbo.CovidVaccinations
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.CovidDeaths
Order by 1,2

-- Total Cases vs Total Deaths
ALTER TABLE PortfolioProject.dbo.CovidDeaths
ALTER COLUMN total_cases float

ALTER TABLE PortfolioProject.dbo.CovidDeaths
ALTER COLUMN total_deaths float

-- Shows likelihood of dying if you contract covid in Ghana
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
where location like '%ghana%'
Order by 1,2


-- Total Cases vs Population

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
where location like '%ghana%'
Order by 1,2

-- Countries with Highest Infection Rate

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.dbo.CovidDeaths
--where location like '%ghana%'
Group by Location, population
Order by PercentPopulationInfected desc

-- Countries with Highest Death Count Per Population

Select Location,MAX(total_deaths) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--where location like '%ghana%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

-- Continents with Highest Death Count Per Population

Select continent,MAX(total_deaths) as TotalDeathCount
From PortfolioProject.dbo.CovidDeaths
--where location like '%ghana%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL VIEW

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
, SUM(cast(new_deaths as int))/SUM(NULLIF(New_Cases, 0))*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--where location like '%ghana%'
Where continent is not null --AND new_cases is not null
Group By date
Order by 1,2

-- Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RolligPeopleVaccinated
--, (RolligPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations,RolligPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RolligPeopleVaccinated
--, (RolligPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RolligPeopleVaccinated/population)*100
From PopvsVac



-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RolligPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RolligPeopleVaccinated
--, (RolligPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RolligPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating Views for later Visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RolligPeopleVaccinated
--, (RolligPeopleVaccinated/population)*100
From PortfolioProject.dbo.CovidDeaths dea
Join PortfolioProject.dbo.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * 
From PercentPopulationVaccinated

-- View for Global Deaths
Create View GlobalDeaths as
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths
, SUM(cast(new_deaths as int))/SUM(NULLIF(New_Cases, 0))*100 as DeathPercentage
From PortfolioProject.dbo.CovidDeaths
--where location like '%ghana%'
Where continent is not null --AND new_cases is not null
Group By date
--Order by 1,2

Select *
From GlobalDeaths