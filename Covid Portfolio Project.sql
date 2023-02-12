Select *
from PortfolioProject..CovidDeaths
WHERE continent is not null
order by 3,4


-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contrat covid in your country
Select Location,date, total_cases, total_deaths, 
ROUND ((total_deaths/total_cases) *100, 2) AS DeathPercentages
from PortfolioProject..CovidDeaths
Where Location like '%states%'
and continent is not null
order by 1, 2

--Looking at Total cases vs Population
--Shows what percentage of population got Covid

Select Location,date,  Population,  total_cases, 
ROUND ((total_cases/ population) *100,2) AS PopulationPercentages
from PortfolioProject..CovidDeaths
order by PopulationPercentages DESC


--Looking at Countries with Highest Infection Rate compared to Population
Select Location, Population, 
MAX(total_cases) AS HighestInfectionCount, 
ROUND (MAX((total_cases/ population)) *100, 2) AS PercentagePopulationInfected
from PortfolioProject..CovidDeaths
Group by Location, Population
order by PercentagePopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

Select Location, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
WHERE continent is not null
Group by Location
order by TotalDeathCount DESC

--Showing the Continents with the Highest death per Population

Select continent, MAX(CAST(total_deaths AS INT)) AS TotalDeathCount
from PortfolioProject..CovidDeaths
WHERE continent is not null
Group by continent
order by TotalDeathCount DESC


--Global Numbers 

Select  SUM( new_cases) AS TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
ROUND (SUM(CAST(New_deaths as int))/ SUM (NEW_CASES) *100,2) AS DeathPercentages
from PortfolioProject..CovidDeaths
Where continent is not null
order by 1, 2

--- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinnations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--CTE
--Total Population, New Vaccinations, Rolling People Vaccinated and Percentage of Rolling People Vaccinated 
 WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
 as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM (CONVERT ( int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as  RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinnations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

Select * , ( RollingPeopleVaccinated /Population) *100 AS PercentageRollingPeopleVaccinated
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
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinnations vac
on dea.location = vac.location
and dea.date = vac.date

Select * , ( RollingPeopleVaccinated /Population) *100 
from #PercentPopulationVaccinated

--CREATING VIEW to store data for later visualization

drop view [PercentPopulationVaccinated];

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM (CONVERT ( int, vac.new_vaccinations)) OVER (PARTITION BY dea.location order by dea.location, dea.date)
as  RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVacinnations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null


Select *
from PercentPopulationVaccinated
