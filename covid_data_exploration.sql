
select * from CovidDeaths where continent is not null
order by 1,2

--SELECTING THE COLUMNS THAT ARE GOING TO BE USED
select continent,location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

--DEATH PERCENTAGE
select continent,location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases) * 100,4) death_percentage
from CovidDeaths
where continent is not null
order by death_percentage desc

--PERCENTAGE OF POPULATION WHO GOT COVID
select continent,location, date,population,total_cases,round((total_cases/population) * 100, 4) percent_population_infected
from CovidDeaths
 where continent is not null
order by percent_population_infected desc

--COUNTRIES WITH HIGH INFECTION RATE
select continent,location,population,max(total_cases) highest_infection_count,
round(max(total_cases)/population * 100, 4) percent_population_infected
from CovidDeaths
where continent is not null
group by location, continent,population
order by percent_population_infected desc

--COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
select continent,location,MAX(cast(total_deaths as int)) highest_death_count
from CovidDeaths
where continent is not null
group by location,continent
order by highest_death_count desc

--CONTINENTS WITH HIGHEST DEATH COUNT
select continent,MAX(cast(total_deaths as int)) highest_death_count
from CovidDeaths
where continent is not null
group by continent
order by highest_death_count desc

--GLOBAL NUMBERS
select  SUM(new_cases) total_cases, SUM(cast(new_deaths as int)) total_deaths, 
ROUND((SUM(cast(new_deaths as int))/SUM(new_cases)) * 100,4) death_percentage
from CovidDeaths
where continent is not null





--TOTAL VACCINATIONS VS POPULATION
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
order by 2,3

--USING CTE
with Vaccinated_rate (continent,location,date,population,new_vaccinations,rolling_people_vaccinated) 
as 
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3
)
select *, round((rolling_people_vaccinated/population)*100,4) vaccination_percentage from Vaccinated_rate


--USING TEMP_TABLES
create table #Vaccinated 
(
  continent nvarchar(255),
  location nvarchar(255),
  date datetime,
  population numeric,
  new_vaccinations numeric,
  rolling_people_vaccinated numeric
)

insert into #Vaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location and d.date = v.date
--where d.continent is not null
--order by 2,3

select *, round((rolling_people_vaccinated/population)*100,4) vaccination_percentage  from #Vaccinated

--CREATING VIEWS
create view vaccinationpercentage as 
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date) as rolling_people_vaccinated
from CovidDeaths d
join CovidVaccinations v
on d.location = v.location and d.date = v.date
where d.continent is not null
--order by 2,3

select * ,round((rolling_people_vaccinated/population)*100,4) vaccination_percentage from vaccinationpercentage
