---------------------------------------------------------------------------
--- COVID 19 Data Exploration using Sql   ---
----------------------------------------------------------------------------


Select *
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
Order By 3,4



---Select the Data --> Which will be used for our Analysis

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
Order By 1,2

--Total Covid cases of India

Select MAX(total_cases)
From PortfolioProject..CovidDeaths
Where continent is NOT NULL


-- Total Cases vs Total Deaths
-- Probability of dying after getting Covid 

Select location, date, total_cases,total_deaths,  (total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
Order By 1,2


-- USA
-- Shows likelihood of dying if we contract with covid in USA

Select location, date, total_cases,total_deaths,  (total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'and  continent is NOT NULL
Order By 1,2


-- Total Cases vs Population
--Shows What Percentage % of Population get Covid

Select location, date, population, total_cases,  (total_cases/population)* 100 as CovidPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%' and continent is NOT NULL
Order By 1,2


Select location, date, population, total_cases,  (total_cases/population)* 100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is NOT NULL
Order By 1,2


-- Looking at Countries with highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX(total_cases/population)* 100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is NOT NULL
Group By location,population
Order By PercentagePopulationInfected DESC  


-- Showing Countries with Highest Death Count per Population

Select location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is NOT NULL
Group By location
Order By TotalDeathCount DESC


-- Lets break down by Continents 
--> Continents with Highest Death Count per Population

Select continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is NOT NULL
Group By continent
Order By TotalDeathCount DESC



-- GLOBAL NUMBERS
-- Total Cases vs Total Deaths

Select location, date, total_cases,total_deaths,  (total_deaths/total_cases)* 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
Order By 1,2



Select SUM(new_cases) as TotalCases, SUM(Cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where continent is NOT NULL
Order By 1,2



--  Join TWO Tables 


-- Looking at Total Populations VS Vaccinations
-- It shows what percentage of population have recieved atleast One Covid Vaccine.

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT NULL
Order By 2,3





-- USE CTE
-- To perform Calculation on Partition By in previous query

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order By dea.Location,
	dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT NULL
--Order By 2,3
)

Select *, (RollingPeopleVaccinated/population) * 100
From PopvsVac



-- TEMP TABLE
-- To perform Calculation on Partition By in previous query


DROP Table If Exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order By dea.Location,
	dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT NULL
--Order By 2,3

Select *, (RollingPeopleVaccinated/population) * 100
From #PercentPopulationVaccinated



-- Views for storing data
--> Future Visualizations

Create View PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order By dea.Location,
	dea.Date) as RollingPeopleVaccinated

From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is NOT NULL
--Order By 2,3


Select *
From  #PercentPopulationVaccinated


