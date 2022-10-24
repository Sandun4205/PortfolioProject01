select * from CovidDeaths 
order by 3,4
select Location, Date, Total_cases, new_cases, Total_deaths, population
from CovidDeaths
order by 1,2

-- Total Cases vs Total Deaths
select Location, Date, Total_cases,Total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths
where location like '%states%'
order by 1,2

-- total cases vs population
select Location, Date, Total_cases,population, (total_cases/population)*100 as Cases_per_capita
from CovidDeaths
--where content is not null
order by 1,2

--looking at the countries with highest infection rate compared to population
select Location, Max(Total_cases) as Highest_infection_count,population, Max(total_cases/population)*100 as Cases_per_capita
from CovidDeaths
--where location like '%states%'
Group by Location, population
order by Cases_per_capita desc

-- Showing countries with the highest number of death count
select Location, Max (cast(total_deaths as int)) as Highest_death_count,population
from CovidDeaths
Where continent is not null
--where location like '%states%'
Group by Location, population
order by Highest_death_count desc


--BREAKING DOWN BY CONTINENT
select location, Max (cast(total_deaths as int)) as Total_death_count
from CovidDeaths
Where continent is null
--where location like '%states%'
Group by location
order by Total_death_count desc

--Showing the continent with the highset death count to population
select location, Max (cast(total_deaths as int)/population) as highset_death_per_capita
from CovidDeaths
Where continent is null
--where location like '%states%'
Group by location
order by highset_death_per_capita desc

--Showing Global Numbers
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/ SUM(New_Cases)*100 as Death_Percentage
From CovidDeaths
WHERE continent is not null
Group by date
order by 1,2


-- Total population vs vaccination by Location
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date ) as rolling_people_vaccinated
--,(rolling_people_vaccinated/dea.population)*100
from CovidVaccinations vac
join CovidDeaths dea
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- use cte
with peoplvsVac 
 (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
 as(

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date ) as rolling_people_vaccinated
--,(rolling_people_vaccinated/dea.population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rolling_people_vaccinated/population)*100
From peoplvsVac
order by 2,3

--Temp Table
Create Table #PercentpopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #PercentpopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date ) as rolling_people_vaccinated
--,(rolling_people_vaccinated/dea.population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
select*
from #PercentpopulationVaccinated
order by 2,3

-- creating view for later vizs
create view PercentpopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date ) as rolling_people_vaccinated
--,(rolling_people_vaccinated/dea.population)*100
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentpopulationVaccinated