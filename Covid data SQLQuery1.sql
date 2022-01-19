select *
from "PORTFOLIO PROJECTS".."Covid Deaths" 
where continent is not null 
order by 3,4



--select *
--from "PORTFOLIO PROJECTS".."Covid Vaccinations"
--order by 3,4

--Selecting the datas needed


Select location, date, total_cases, new_cases, total_deaths, population
from "PORTFOLIO PROJECTS".."Covid Deaths"
order by 1,2


--comparing total_cases vs total_deaths
--To show the likelihood of dying if one contacts covid in his/her country e.g Nigeria

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from "PORTFOLIO PROJECTS".."Covid Deaths"
where location like '%Nigeria%' and continent is not null
order by 1,2


--Considering total_cases vs Population
--To show the total population percentage of Nigerians with Covid

Select location, date, total_cases, population, (total_cases/population)*100 as Population_Percentage
from "PORTFOLIO PROJECTS".."Covid Deaths"
where location like '%Nigeria%' and continent is not null
order by 1,2


--Comparing countries with highest infection rates to their populatio
--To tell countries with the highest % of covid infections

Select location, population, MAX(total_cases) as Highest_Infection_Count, MAX(total_cases/population)*100 as Infected_Population_Percentage
from "PORTFOLIO PROJECTS".."Covid Deaths"
--where location like '%Nigeria%' and continent is not null
Group by location, population
order by Infected_Population_Percentage desc


--Considering countries with highest death count per population
--To show countries with highest number of deaths

Select location, MAX(cast(total_deaths as int)) as Total_deaths_count
from "PORTFOLIO PROJECTS".."Covid Deaths"
--where location like '%Nigeria%' 
where continent is not null
Group by location, population
order by Total_deaths_count desc


--Breaking it down further to continents
--Considering continents with highest death counts per population


Select continent, MAX(cast(total_deaths as int)) as Total_deaths_count
from "PORTFOLIO PROJECTS".."Covid Deaths"
--where location like '%Nigeria%' 
where continent is not null
Group by continent
order by Total_deaths_count desc


--Looking at the numbers across the world

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from "PORTFOLIO PROJECTS".."Covid Deaths"
--where location like '%Nigeria%' 
where continent is not null
Group by date
order by 1,2

--Taking out the date grouping to get a sungle number across the world, we have;

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
from "PORTFOLIO PROJECTS".."Covid Deaths"
--where location like '%Nigeria%' 
where continent is not null
--Group by date
order by 1,2


--LOOKING AT THE VACCINATIONS TABLE

select *
from "PORTFOLIO PROJECTS".."Covid Vaccinations"

--Joining both covid death and vaccinaton tables together

select *
from "PORTFOLIO PROJECTS".."Covid Deaths" dea
join "PORTFOLIO PROJECTS".."Covid Vaccinations" vacc
on dea.location = vacc.location
and dea.date = vacc.date

--Considering the total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(bigint,vacc.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
--(Rolling_people_vaccinated/population)*100
from "PORTFOLIO PROJECTS".."Covid Deaths" dea
join "PORTFOLIO PROJECTS".."Covid Vaccinations" vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
order by 2,3


--Using CTE

with popvsvacc (continent, location, date, population, new_vaccinations, Rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(bigint,vacc.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
--(Rolling_people_vaccinated/population)*100
from "PORTFOLIO PROJECTS".."Covid Deaths" dea
join "PORTFOLIO PROJECTS".."Covid Vaccinations" vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
--order by 2,3
)
select*,(Rolling_people_vaccinated/population)*100 as Rolling_percentage
from popvsvacc


--Applying TEMP TABLE

Drop table if exists percentage_population_vaccinated
create table percentage_population_vaccinated
(continent nvarchar (225),
location nvarchar (225),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_vaccinated numeric
)
insert into  percentage_population_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(bigint,vacc.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
--(Rolling_people_vaccinated/population)*100
from "PORTFOLIO PROJECTS".."Covid Deaths" dea
join "PORTFOLIO PROJECTS".."Covid Vaccinations" vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
--order by 2,3

select*,(Rolling_people_vaccinated/population)*100 as Rolling_percentage
from percentage_population_vaccinated


--Considering views for visualizations

create view percent_populationvaccinated 
as
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(bigint,vacc.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
--(Rolling_people_vaccinated/population)*100
from "PORTFOLIO PROJECTS".."Covid Deaths" dea
join "PORTFOLIO PROJECTS".."Covid Vaccinations" vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
--order by 2,3

create view population_against_vaccine
as
select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations
, SUM(CONVERT(bigint,vacc.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
--(Rolling_people_vaccinated/population)*100
from "PORTFOLIO PROJECTS".."Covid Deaths" dea
join "PORTFOLIO PROJECTS".."Covid Vaccinations" vacc
on dea.location = vacc.location
and dea.date = vacc.date
where dea.continent is not null
--order by 2,3
