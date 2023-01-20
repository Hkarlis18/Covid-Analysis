Select *
from PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4

--Select *
--from PortfolioProject..CovidVacinnations
--order by 3,4

--Select Location,date, total_cases, new_cases, total_deaths, population 
--from PortfolioProject..CovidDeaths
--WHERE continent is not null
--order by 1, 2

-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contrat covid in your country
Select Location,date, total_cases, total_deaths, 
(total_deaths/total_cases) *100 AS DeathPercentages
from PortfolioProject..CovidDeaths
Where Location like '%states%'
and continent is not null
order by 1, 2

--Looking at Total cases vs Population
--Shows what percentage of population got Covid

Select Location,date,  Population,  total_cases, 
(total_cases/ population) *100 AS PopulationPercentages
from PortfolioProject..CovidDeaths
--Where Location like '%states%'
order by 1, 2


--Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/ population)) *100 AS PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--Where Location like '%states%'
Group by Location, Population
order by PercentagePopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
--Where Location like '%states%'
WHERE continent is not null
Group by Location
order by TotalDeathCount DESC

--Let's Break things down by Continent 

--Select location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
--from PortfolioProject..CovidDeaths
----Where Location like '%states%'
--WHERE continent is not null
--Group by location
--order by TotalDeathCount DESC

Select continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
--Where Location like '%states%'
WHERE continent is not null
Group by continent
order by TotalDeathCount DESC

--Showing the Continents with the Highest death per Population

Select continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
--Where Location like '%states%'
WHERE continent is not null
Group by continent
order by TotalDeathCount DESC


--Global Numbers 

Select  SUM( new_cases) AS TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(CAST(New_deaths as int))/ SUM (NEW_CASES) *100 AS DeathPercentages
from PortfolioProject..CovidDeaths
--Where Location like '%states%'
Where continent is not null
--Group by date
order by 1, 2

--- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinnations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
--Select *
--from PortfolioProject..CovidDeaths dea
--Join PortfolioProject..CovidVacinnations vac
--on dea.location = vac.location
--and dea.date = vac.date

--CTE
 WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM (CONVERT ( int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) *100

from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinnations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select * , ( RollingPeopleVaccinated /Population) *100
from PopvsVac 

--Temporal Table 
drop table if exists #PercentPopulationVaccinated

Create table #PercentPopulationVaccinated
( Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM (CONVERT ( int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) *100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinnations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select * , ( RollingPeopleVaccinated /Population) *100
from #PercentPopulationVaccinated

--CREATING VIEW to store data for later visualization

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM (CONVERT ( int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as  RollingPeopleVaccinated
--, (RollingPeopleVaccinated / population) *100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinnations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from PercentPopulationVaccinated