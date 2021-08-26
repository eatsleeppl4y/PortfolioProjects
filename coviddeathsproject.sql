use Portfolio;

SELECT *
FROM CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM Portfolio..CovidVacs
--order by 3,4

-- select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Portfolio..CovidDeaths
order by 1, 2

-- looking at total cases vs total deaths
-- shows the likelihoodof dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
where location = 'United States'
order by 1, 2

-- looking at total cases vs populaion
-- shows what percentage of population contracted covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
where location = 'South Korea'
order by 1, 2

-- looking at countries with the highest infection rate compared to population

Select 
	location, 
	max(total_cases) as HighestInfectionCount, 
	max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
-- where location = 'South Korea'
Group by population, location
order by PercentPopulationInfected desc

-- shows countries with the highest death count per population

Select 
	Location, 
	max(cast(total_deaths as int)) as TotalDeathCount,
	max(total_deaths/population)*100 as TotalDeathPercent
From Portfolio..CovidDeaths
where continent is not null
group by location, population
order by TotalDeathCount

-- break things down by continent
-- showing continents with the highest death count per population

Select 
	Continent,
	max(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- global numbers

Select 
	sum(new_cases) as Total_Cases,
	sum(cast(new_deaths as int)) as Total_Deaths,
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
	--total_cases, 
	--total_deaths, 
	--(total_deaths/total_cases)*100 as DeathPercentage
From Portfolio..CovidDeaths
where continent is not null
--group by date
order by 1, 2

-- total population vs vaccinations

With popvsvac (continent, location, date, population, new_vaccinations, rollingpeoplevacs) as (

select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacs
from CovidDeaths dea
Join CovidVacs vac
	on dea.location = vac.location and
	   dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)

select *, (rollingpeoplevacs/population) * 100
from popvsvac

-- temp table

create table #percentpopulationvaccinated
(
	continent varchar(255),
	location varchar(255),
	date datetime,
	population int,
	new_vaccinations int,
	rollingpeoplevacs int
)

insert into #percentpopulationvaccinated
select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacs
from CovidDeaths dea
Join CovidVacs vac
	on dea.location = vac.location and
	   dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

select *, (rollingpeoplevacs/population) * 100
from #percentpopulationvaccinated

-- creating view to store data for later visualtions

create view percentpopulationvaccinated as
select 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVacs
from CovidDeaths dea
Join CovidVacs vac
	on dea.location = vac.location and
	   dea.date = vac.date
where dea.continent is not null
--order by 2, 3