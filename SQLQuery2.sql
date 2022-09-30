select*
from [Portfolio Project]..CovidDeaths
order by 3,4;


select location, date, total_cases, new_cases, population
from [Portfolio Project]..CovidDeaths
order by 1,2;

--looking at total cases vs total deaths
--shows liklihood of dying if you contract covid in India

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from [Portfolio Project]..CovidDeaths
where location like'%India%'
order by 1,2;

--looking at total cases vs population
--shows what percentage of people got covid

select location, date, population, total_cases, (total_cases/population)*100 as covid_percentage
from [Portfolio Project]..CovidDeaths
where location like'%India%'
order by 1,2;

-- Countries with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as covid_percentage
from [Portfolio Project]..CovidDeaths
group by location, population
order by covid_percentage desc;

--Showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project]..CovidDeaths
where continent is not null 
group by location
order by totaldeathcount desc;

--showing continent with highest death count per population

select continent, max(cast(total_deaths as int)) as totaldeathcount
from [Portfolio Project]..CovidDeaths
where continent is not null 
group by continent
order by totaldeathcount desc;

-- GLOBAL Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as percentagedeath 
from [Portfolio Project]..CovidDeaths
where continent is not null
group by date
order by 1,2;

--total population vs total vaccination

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3;

--USE CTE

with popvsvac (continent, location, date, population, new_vaccinations, RollingPeoplevaccinated)
as
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select *, (RollingPeoplevaccinated/population)*100
from popvsvac;


--Temp Table

DROP table #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeoplevaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
select *, (RollingPeoplevaccinated/population)*100
from #PercentPopulationVaccinated

--Creating view to store data for later visualization

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations$ vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select*
from PercentPopulationVaccinated
