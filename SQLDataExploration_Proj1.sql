/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/
Select *
From PortfolioProj1..covid_deaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProj1..covid_vaccinations
--order by 3,4

-- selecting data
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProj1..covid_deaths
Where continent is not null
order by 1,2

--Total cases vs. total deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percent_deaths
From PortfolioProj1..covid_deaths
Where location like '%India%'
and continent is not null
order by 1,2

-- Total cases vs population
Select Location, date, total_cases, population , (total_cases/population)*100 as percent_pop
From PortfolioProj1..covid_deaths
--Where location like '%India%'
Where continent is not null
order by 1,2

--Max Infection rate compared to population for a country

Select Location, population, MAX(cast(total_cases as int)) as MaxInfection, MAX((total_cases/population))*100 as percent_pop
From PortfolioProj1..covid_deaths
Where continent is not null
Group by Location, population
order by percent_pop desc

Select Location, MAX(cast(total_cases as int)) as MaxDeaths
From PortfolioProj1..covid_deaths
Where continent is not null
Group by Location
order by MaxDeaths desc

--By Continent
Select continent, MAX(cast(total_cases as int)) as MaxDeaths
From PortfolioProj1..covid_deaths
Where continent is not null
Group by continent
order by MaxDeaths desc



--Checking for Global

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as percent_deaths
From PortfolioProj1..covid_deaths
--Where location like '%India%'
Where continent is not null
Group by date
order by 1,2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProj1..covid_deaths dea
Join PortfolioProj1..covid_vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 