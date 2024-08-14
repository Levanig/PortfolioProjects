/*
Covid-19 Data Exploration

Skills used: Joins, CTEs, Temp Tables, Window Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- Initial data selection from the CovidDeath table
-- Filtering out records where the continent is NULL
-- Sorting by location and date
SELECT 
    Location, 
    date, 
    total_cases, 
    new_cases, 
    total_deaths, 
    population
FROM 
    CovidDeath
WHERE 
    continent IS NOT NULL 
ORDER BY 
    Location, date;

-- Analysis of Total Cases vs Total Deaths
-- Calculating the likelihood of dying if you contract Covid-19 in a specific country (e.g., Georgia)
SELECT 
    Location, 
    date, 
    total_cases, 
    total_deaths, 
    CASE 
        WHEN total_cases = 0 THEN 0 
        ELSE ROUND((CAST(total_deaths AS FLOAT) / CAST(total_cases AS FLOAT)) * 100, 2) 
    END AS DeathPercentage
FROM 
    CovidDeath
WHERE 
    location = 'Georgia'
ORDER BY 
    Location, date;

-- Analysis of Total Cases vs Population
-- Determining the percentage of the population infected with Covid-19
SELECT 
    Location, 
    date, 
    Population, 
    total_cases, 
    ROUND((CAST(total_cases AS FLOAT) / CAST(population AS FLOAT)) * 100, 2) AS PercentPopulationInfected
FROM 
    CovidDeath
ORDER BY 
    Location, date;

-- Identifying countries with the highest infection rate compared to their population
-- Grouping by location and population, then sorting by the percentage of the population infected
SELECT 
    Location, 
    MAX(date) AS date, 
    Population, 
    MAX(total_cases) AS total_cases, 
    ROUND((CAST(MAX(total_cases) AS FLOAT) / CAST(Population AS FLOAT)) * 100, 2) AS PercentPopulationInfected
FROM 
    CovidDeath
GROUP BY 
    Location, 
    Population
ORDER BY 
    PercentPopulationInfected DESC;

-- Identifying countries with the highest death count per population
-- Grouping by location and population, then sorting by total deaths
SELECT 
    Location, 
    MAX(date) AS date, 
    Population, 
    MAX(CAST(total_deaths AS INT)) AS total_deaths, 
    ROUND((CAST(MAX(total_deaths) AS FLOAT) / CAST(Population AS FLOAT)) * 100, 2) AS PercentPopulationInfected
FROM 
    CovidDeath
WHERE 
    continent IS NOT NULL
GROUP BY 
    Location, 
    Population
ORDER BY 
    total_deaths DESC;

-- Analysis of continents with the highest death count per population
-- Summing population and total deaths, then calculating the percentage of deaths per population
SELECT 
    continent, 
    MAX(date) AS date, 
    SUM(CAST(Population AS BIGINT)) AS Population, 
    SUM(CAST(total_deaths AS BIGINT)) AS total_deaths, 
    ROUND((CAST(SUM(total_deaths) AS FLOAT) / CAST(SUM(Population) AS FLOAT)) * 100, 2) AS PercentPopulationInfected
FROM 
    CovidDeath
WHERE 
    continent IS NOT NULL
GROUP BY 
    continent
ORDER BY 
    total_deaths DESC;

-- Analysis of Total Population vs Vaccinations
-- Determining the percentage of the population that has received at least one Covid-19 vaccine
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM 
    CovidDeath dea
JOIN 
    CovidVactinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL 
ORDER BY 
    dea.location, dea.date;

-- Using a Common Table Expression (CTE) to perform calculations on partitioned data
WITH PopvsVac AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations, 
        SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM 
        CovidDeath dea
    JOIN 
        CovidVactinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL 
)
SELECT 
    *, 
    ROUND((CAST(RollingPeopleVaccinated AS FLOAT) / CAST(Population AS FLOAT)) * 100, 2) AS PercentPopulationVaccinated
FROM 
    PopvsVac
ORDER BY 
    Location, Date;

-- Using a Temporary Table to perform calculations on partitioned data
-- Dropping the temporary table if it exists
DROP TABLE IF EXISTS #PercentPopulationVaccinated;

-- Creating the temporary table with appropriate data types
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Inserting data into the temporary table
INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
FROM 
    CovidDeath dea
JOIN 
    CovidVactinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date;

-- Selecting data from the temporary table with the calculated percentage
SELECT 
    *, 
    ROUND((RollingPeopleVaccinated / Population) * 100, 2) AS PercentPopulationVaccinated
FROM 
    #PercentPopulationVaccinated;
