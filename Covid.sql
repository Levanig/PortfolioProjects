Select *
FROM PortfolioProject..CovidDeaths1
Where continent is not null
Order by 3,4

-- Select DAta that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths1
Where continent is not null
order by 1,2

-- Looking at total Cases vs Total Deats
-- Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths1
Where continent is not null
Where location like 'Georgia'
order by 1,5

-- Looking at the Total cases vs Populations
--Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as CasePopulation
FROM PortfolioProject..CovidDeaths1
Where continent is not null
Where location like 'Georgia'
order by 1,2

-- Looking at cointries with Highest infection Rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths1
Where continent is not null
Group by location, Population
order by PercentPopulationInfected desc

-- Showing Countries with highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths1
Where continent is not null
Group by  location
order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths1
Where continent is not null
Group by  continent
order by TotalDeathCount desc

-- Showing continents with the highest death count per population

SELECT continent,  MAX(total_deaths) as TotalDeathCount
FROM PortfolioProject..CovidDeaths1
Where continent is not null
Group by  continent
order by TotalDeathCount desc


-- Global numbers

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths1
where continent is not null
order by 1,2

-- Looking at total Population vs Vaccinations

Select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations 
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths1 dea
JOIN  PortfolioProject..CovidVaccinations vac
    ON dea.[location] = vac.[location]
    and dea.date = vac.[date]
where dea.continent is not null
order by 2



-- Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations 
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths1 dea
JOIN  PortfolioProject..CovidVaccinations vac
    ON dea.[location] = vac.[location]
    and dea.date = vac.[date]
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- TEMP TABLE

DROP TABLE if exists  #PercentPopulationVaccinated
Create TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
DATE nvarchar(255),
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated NUMERIC
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations 
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths1 dea
JOIN  PortfolioProject..CovidVaccinations vac
    ON dea.[location] = vac.[location]
    and dea.date = vac.[date]
where dea.continent is not null

Select *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.[location], dea.date, dea.population, vac.new_vaccinations 
, SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths1 dea
JOIN  PortfolioProject..CovidVaccinations vac
    ON dea.[location] = vac.[location]
    and dea.date = vac.[date]
where dea.continent is not null
