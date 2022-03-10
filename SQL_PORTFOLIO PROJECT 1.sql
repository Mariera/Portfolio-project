---Explore the data(see how the data looks like and if you have imported the correct data)

select *
from [Portfolio project]..coviddeaths
where continent is null
order by 3,4

select *
from [Portfolio project]..covidvaccinations
where continent is null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from [Portfolio project]..coviddeaths
where continent is null
order by 1,2



--looking at the total cases vs the total deaths
--shows the likelihood of dyin of you contract covid in your country

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as deathperc
from [Portfolio project]..coviddeaths
--where continent is not null
where location like '%states%'
order by 1,2


--looking at total cases vs the population

select location, date, population, total_cases,(total_cases/population)*100 as deathperc
from [Portfolio project]..coviddeaths
--where continent is null 
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) AS HighestinfectionCount,MAX((total_cases/population))*100 as percOfPouplationInfected
from [Portfolio project]..coviddeaths
--where continent is  null
--where location like '%states%'
Group by location, population
order by percOfPouplationInfected desc

--looking at countries with highest death count per population

select location, MAX(cast(total_deaths as int)) as TotalDeathsCount
from [Portfolio project]..coviddeaths
where continent is not null
--where location like '%states%'
Group by location
order by TotalDeathsCount desc



--LETS BREAK THINGS DOWN BY CONTINENT
select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
from [Portfolio project]..coviddeaths
where continent is not null
--where location like '%states%'
Group by continent
order by TotalDeathsCount desc

---showing the continents with the highest deathcount per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathsCount
from [Portfolio project]..coviddeaths
where continent is not null
--where location like '%states%'
Group by continent
order by TotalDeathsCount desc


--Global numbers

select date, SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio project]..coviddeaths
where continent is not null
--where location like '%states%'
Group by date
order by 1,2

select   SUM(new_cases)as total_cases, SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio project]..coviddeaths
where continent is not null
--where location like '%states%'
--Group By date
order by 1,2

--looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(int,vac.new_vaccinations))OVER(partition by dea.location Order By dea.location, dea.date) as rollingpeoplevaccinated

From [Portfolio project]..coviddeaths dea
Join [Portfolio project]..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE

with popvvac (continent, location, date, population, New_Vaccinations, Rollingpeoplevaccinated) 
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(int,vac.new_vaccinations))OVER(partition by dea.location Order By dea.location, dea.date) as rollingpeoplevaccinated

From [Portfolio project]..coviddeaths dea
Join [Portfolio project]..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(Rollingpeoplevaccinated/population)*100
from popvvac

--TEMP TABLE
DROP Table if exists #percentPopulationvaccinated
Create Table #percentPopulationvaccinated
(
continent nvarchar (255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)

Insert into #percentPopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location Order by dea.location, dea.date) as Rollingpeoplevaccinated

From [Portfolio project]..coviddeaths dea
Join [Portfolio project]..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
select *, (Rollingpeoplevaccinated/Population)*100
from #percentPopulationvaccinated

--creating view to store data for later visulaizations

CREATE VIEW
 rollingpeoplevaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations ,
SUM(CONVERT(int,vac.new_vaccinations))OVER(partition by dea.location Order By dea.location, dea.date) as rollingpeoplevaccinated

From [Portfolio project]..coviddeaths dea
Join [Portfolio project]..covidvaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from percentPopulationvaccinated