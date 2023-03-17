SELECT * FROM CovidDeaths$;

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population FROM CovidDeaths
order by location, date;

-- Total Cases vs Total Deaths

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage FROM CovidDeaths
where location like '%states%' and continent is not null
order by location, date;

-- Total Cases vs Population

SELECT Location, date, total_cases, population, (total_cases/population)*100 as contraction_rate FROM CovidDeaths
where location like '%states%' and continent is not null
order by location, date;

-- Countries with the highest contraction rate

SELECT location, MAX(total_cases) as TotalCases, MAX(total_cases/population)*100 as contraction_rate FROM CovidDeaths
Where continent is not null
Group by location
order by contraction_rate desc;

-- Countries with the highest deaths 

SELECT Location, MAX(cast(total_deaths as int)) as total_death_count FROM CovidDeaths
Where continent is not null
Group by location
order by total_death_count desc;

-- Continents with the highest deaths

SELECT continent, MAX(cast(total_deaths as int)) as total_death_count FROM CovidDeaths
Where continent is not null
Group by continent
order by total_death_count desc;

--Global death rate numbers

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathRate FROM CovidDeaths
Where continent is not null
Group by date
order by DeathRate desc;

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathRate FROM CovidDeaths
Where continent is not null
--Group by date
order by DeathRate desc;


Select * From [Portfolio Project]..CovidVaccinations

-- Table Join, covid deaths + covid vaccinations
Select coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, CovidVaccinations.new_vaccinations 
From [Portfolio Project]..CovidDeaths
Join CovidVaccinations
	ON coviddeaths.location = CovidVaccinations.location and coviddeaths.date = covidvaccinations.date
Where coviddeaths.continent is not null and covidvaccinations.new_vaccinations is not null
order by coviddeaths.location, coviddeaths.date



With PopulationVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated) as
(
Select coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, CovidVaccinations.new_vaccinations, 
SUM(CAST(covidvaccinations.new_vaccinations as int)) OVER (Partition by coviddeaths.location Order by coviddeaths.location, coviddeaths.date) as PeopleVaccinated 
From [Portfolio Project]..CovidDeaths
Join CovidVaccinations
	ON coviddeaths.location = CovidVaccinations.location and coviddeaths.date = covidvaccinations.date
Where coviddeaths.continent is not null
-- order by coviddeaths.location, coviddeaths.date
)
Select *, (PeopleVaccinated/Population)*100 from PopulationVac
Where New_Vaccinations is not null
Order by location


-- TEMPORARY TABLE

DROP Table if exists PercentVaccinationsPerCountry 
CREATE TABLE PercentVaccinationsPerCountry 
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into PercentVaccinationsPerCountry
Select coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, CovidVaccinations.new_vaccinations, 
SUM(CAST(covidvaccinations.new_vaccinations as int)) OVER (Partition by coviddeaths.location Order by coviddeaths.location, coviddeaths.date) as PeopleVaccinated 
From [Portfolio Project]..CovidDeaths
Join CovidVaccinations
	ON coviddeaths.location = CovidVaccinations.location and coviddeaths.date = covidvaccinations.date
Where coviddeaths.continent is not null
-- order by coviddeaths.location, coviddeaths.date

Select *, (PeopleVaccinated/Population)*100 as PercentVaccinated from PercentVaccinationsPerCountry
Where New_Vaccinations is not null
Order by location


-- Creating Views

-- View 1 for Percent Vaccinations Per Country
Create View PercentVaccinationsPerCountryView as
Select coviddeaths.continent, coviddeaths.location, coviddeaths.date, coviddeaths.population, CovidVaccinations.new_vaccinations, 
SUM(CAST(covidvaccinations.new_vaccinations as int)) OVER (Partition by coviddeaths.location Order by coviddeaths.location, coviddeaths.date) as PeopleVaccinated 
From [Portfolio Project]..CovidDeaths
Join CovidVaccinations
	ON coviddeaths.location = CovidVaccinations.location and coviddeaths.date = covidvaccinations.date
Where coviddeaths.continent is not null


-- View 2 for Global Death Rate
Create View GlobalDeathRate as
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathRate FROM CovidDeaths
Where continent is not null
-- Group by date
-- order by DeathRate desc;

-- View 3 for Continents with the highest deaths

Create View DeathsPerContinent as
SELECT continent, MAX(cast(total_deaths as int)) as total_death_count FROM CovidDeaths
Where continent is not null
Group by continent
-- order by total_death_count desc;

-- View 4 for Countries with the highest deaths 

Create View DeathsPerCountry as
SELECT Location, MAX(cast(total_deaths as int)) as total_death_count FROM CovidDeaths
Where continent is not null
Group by location
-- order by total_death_count desc;

-- View 5 for Countries with the highest contraction rate
Create View ContractionRatePerCountry as
SELECT location, MAX(total_cases) as TotalCases, MAX(total_cases/population)*100 as contraction_rate FROM CovidDeaths
Where continent is not null
Group by location
-- order by contraction_rate desc;