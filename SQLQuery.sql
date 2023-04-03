select*
from potfolioproject.dbo.Covidvaccination$

select*
from potfolioproject.dbo.CovidDeaths$

select date, population, location, total_cases, total_deaths, (total_deaths/total_cases)*100 as parcentage_deaths
from potfolioproject.dbo.CovidDeaths$
where location like '%africa%'
order by 1,2

select date, population, location, total_cases, total_deaths, (total_cases/population)*100 as parcentage-of_population_infected
from potfolioproject.dbo.CovidDeaths$
where location is not null
order by 1,2

select population, location, max(total_cases) as highest_infection, max((total_cases/population))*100 as parcentage_of_population_infected
from potfolioproject.dbo.CovidDeaths$
where location is not null
group by location, population
order by parcentage_of_population_infected desc

select location, max(cast(total_deaths as int)) as totaldeaths
from potfolioproject.dbo.CovidDeaths$
where continent is not null
group by location
order by totaldeaths desc

select date, sum(new_cases)
from potfolioproject.dbo.CovidDeaths$
where continent is not null
group by date
order by 1,2

select*
from potfolioproject.dbo.CovidDeaths$ dea
join potfolioproject.dbo.Covidvaccination$ vac
     on dea.location = vac.location
     and dea.date = vac.date
order by 1,2,3

select dea.date, dea.population, dea.location, vac.continent, vac.new_vaccinations_smoothed, sum(CONVERT(int, vac.new_vaccinations_smoothed))
over(partition by dea.location order by dea.location, dea.date) as Rollingvaccinationcount
from potfolioproject.dbo.CovidDeaths$ dea
join potfolioproject.dbo.Covidvaccination$ vac
     on dea.location = vac.location
     and dea.date = vac.date
where vac.continent is not null
order by 1,2,3
--using cte
with popvac( date, population, location, continent, new_vaccinations_smoothed, Rollingvaccinationcount)
as
(
select dea.date, dea.population, dea.location, vac.continent, vac.new_vaccinations_smoothed, sum(CONVERT(int, vac.new_vaccinations_smoothed))
over(partition by dea.location order by dea.location, dea.date) as Rollingvaccinationcount
from potfolioproject.dbo.CovidDeaths$ dea
join potfolioproject.dbo.Covidvaccination$ vac
     on dea.location = vac.location
     and dea.date = vac.date
where vac.continent is not null
)
select*,(Rollingvaccinationcount/population)*100 as parcentagevaccinated
from popvac

drop table if exists #parcentagevaccinated

create table #parcentagevaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations_smoothed numeric,
rollingvaccinationcount numeric
)
insert into #parcentagevaccinated
select dea.date, dea.population, dea.location, vac.continent, vac.new_vaccinations_smoothed, sum(CONVERT(int, vac.new_vaccinations_smoothed))
over(partition by dea.location order by dea.location, dea.date) as Rollingvaccinationcount
from potfolioproject.dbo.CovidDeaths$ dea
join potfolioproject.dbo.Covidvaccination$ vac
     on dea.location = vac.location
     and dea.date = vac.date
where vac.continent is not null


select*,(Rollingvaccinationcount/population)*100 
from #parcentagevaccinated

create view parcentagevaccinated as
select dea.date, dea.population, dea.location, vac.continent, vac.new_vaccinations_smoothed, sum(CONVERT(int, vac.new_vaccinations_smoothed))
over(partition by dea.location order by dea.location, dea.date) as Rollingvaccinationcount
from potfolioproject.dbo.CovidDeaths$ dea
join potfolioproject.dbo.Covidvaccination$ vac
     on dea.location = vac.location
     and dea.date = vac.date
where vac.continent is not null

select*
from parcentagevaccinated
