Select *
From CoronaVirusSQLproject..CovidDeath
Where continent is not null

Select Location, date, total_cases, new_cases, total_deaths, population
From CoronaVirusSQLproject..CovidDeath

-- Looking at Total Cases vs Total Deaths
-- Shows likelihod of dying if you are contacted with Corona Virus
Select Location, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CoronaVirusSQLproject..CovidDeath
Where location like '%malaysia%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
Select Location, population, total_cases, (total_cases/population)*100 as CasePercentage
From CoronaVirusSQLproject..CovidDeath
Where location like '%malaysia%'
Order by 1,2

-- Looking at Countries wth Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectedCountry, MAX((total_cases/population))*100 as PercentPopulationAffected
From CoronaVirusSQLproject..CovidDeath
--Where location like '%malaysia%'
Group by location, population
Order by PercentPopulationAffected desc

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From CoronaVirusSQLproject..CovidDeath
Where continent is not null
--Where location like '%malaysia%'
Group by location
Order by TotalDeathCount desc

----Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
----From CoronaVirusSQLproject..CovidDeath
----Where continent is null
------Where location like '%malaysia%'
----Group by Location
----Order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CoronaVirusSQLproject..CovidDeath
Where continent is not null
--Where location like '%malaysia%'
Group by continent
Order by TotalDeathCount desc

-- Break down data by continent

-- Showing continents with the highest deat count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CoronaVirusSQLproject..CovidDeath
Where continent is not null
--Where location like '%malaysia%'
Group by continent
Order by TotalDeathCount desc

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From CoronaVirusSQLproject..CovidDeath
Where continent is not null 
Order by 1,2


Select *
From CoronaVirusSQLproject..CovidVaccination

-- Lookina at Total population va vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
From CoronaVirusSQLproject..CovidDeath dea
Join CoronaVirusSQLproject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

-- Use CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
From CoronaVirusSQLproject..CovidDeath dea
Join CoronaVirusSQLproject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- Temp table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
From CoronaVirusSQLproject..CovidDeath dea
Join CoronaVirusSQLproject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER(Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
From CoronaVirusSQLproject..CovidDeath dea
Join CoronaVirusSQLproject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
----Order by 2,3

Select *
From PercentPopulationVaccinated

