SELECT *
FROM ProtflioProject ..CovidDeaths
where continent is not null
order by 3,4

--SELECT *
--FROM ProtflioProject ..CovidVaccination
--order by 3,4

--select data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM ProtflioProject ..CovidDeaths
order by 1,2

--looking at total cases vs total Deaths
--shows likelihood of dying if you contract covid in your country

select location, date, total_cases, new_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from ProtflioProject ..CovidDeaths
where location like '%states%'
order by 1,2


--looking at total cases vs population
--show what percentage of population got covid

select location,date, population,(total_cases) , (total_cases/population)*100 as percentpopulationinfection
from ProtflioProject ..CovidDeaths
--where location like '%states%'
order by 1,2

--Looking at countries with highest infection rate compared to population
select location, population,MAX(total_cases) AS HighestInfectionCount , Max (total_cases/population)*100 as percentpopulationinfection
from ProtflioProject ..CovidDeaths
--where location like '%states%'
group by Location, Population
order by percentpopulationinfection desc

 --shpwing counties with highest death count per population
select location,MAX(cast (total_deaths as int)) AS TotalDeathCount
from ProtflioProject ..CovidDeaths
--where location like '%states%'
group by Location
order by TotalDeathCount desc

--global numbers
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from ProtflioProject ..CovidDeaths
--where location like '%states%'
where continent is not null
order by 1,2

 --total population vs vaccinations
 --shows percentage of population that has recieved at least on covid vaccine
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from ProtflioProject ..CovidDeaths dea
join ProtflioProject ..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--using CTE to perform calculation on partition by in previous query
with popvsvac(continent, location,date,population,new_vaccinations,rollingpeoplevaccinated)
as(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from ProtflioProject ..CovidDeaths dea
join ProtflioProject ..CovidVaccination vac
     on dea.location = vac.location
     and dea.date = vac.date
where dea.continent is not null
)
select*,(rollingpeoplevaccinated/population)*100
from popvsvac

--using temp table to perform calculation on partition by in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from ProtflioProject ..CovidDeaths dea
join ProtflioProject ..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*,(rollingpeoplevaccinated/population)*100
from #PercentPopulationVaccinated


--creating view to store data for later visualizations
create view PercentPopulationvaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations))over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from ProtflioProject ..CovidDeaths dea
join ProtflioProject ..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null