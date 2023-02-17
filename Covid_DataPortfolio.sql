-- Table1 - covid_deaths

select * 
from 
CovidDeaths
-- where location = 'India'
order by date ; 

-- Table 2 - covid_vaccination

select *
from 
CovidVaccinations 
where location = 'India'
order by date ; 

-- Using Covideaths data to determine the following 


--Filtering data to be used 

select location , date , total_cases , new_cases , total_deaths , population 
from 
CovidDeaths 
where location = 'India'
order by 2 ;

-- Population VS Total Cases 

select location , population , total_cases , round(total_cases / population,9) * 100 as Infection_rate
from CovidDeaths 
--where location = 'India'  
group by location , population , total_cases 
order by 4 desc ; 


-- Total Cases VS Total Deaths 

select location , date , population , total_cases , total_deaths , (total_deaths / total_cases) * 100 as Mortality_rate 
from CovidDeaths 
where location = 'India' 
order by date ; 


 -- Countries with Highest infection rate 

select location, population , max(total_cases) as HighestInfection_count, round(max((total_cases / population )),3) * 100 as PopInfection_rate
from CovidDeaths
group by location , population  
order by PopInfection_rate desc ;


-- countries which had zero covid cases

select location , sum(total_cases) as covid_cases , population
from CovidDeaths
where continent is not null 
group by location , population 
having sum(total_cases) is null 


-- countries with highest death count per population 

select location , max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null 
group by location , population 
order by TotalDeathCount desc 

-- Break down by contient

select continent , max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null 
group by continent 
order by TotalDeathCount desc 


--	Global numbers

select sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as total_deaths , sum(cast(new_deaths as int))/ sum(new_cases) * 100 as Mortality_rate 
from CovidDeaths 
where continent is not null
order by 1 , 2 


-- Total population vs Vaccination

with PopVsVac ( continent , location , date, population , new_vaccinations , cumulative_freq) as 
(
select A.continent , A.location , A.date, A.population , B.new_vaccinations  ,	
sum(cast(new_vaccinations as int)) over(partition by A.location order by A.location , A.date) as cumulative_freq 
from CovidDeaths A
join
CovidVaccinations B
on A.location = B.location and A.date = B.date 
where A.continent is not null
)

select * , (cumulative_freq/population) * 100 as vaccinated_percentage 
from PopVsVac


-- Temp table

Drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated 
(continent nvarchar(255) ,
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric , 
cumulative_freq numeric )

insert into #PercentPopulationVaccinated 
select A.continent , A.location , A.date, A.population , B.new_vaccinations  ,	
sum(cast(new_vaccinations as int)) over(partition by A.location order by A.location , A.date) as cumulative_freq 
from CovidDeaths A
join
CovidVaccinations B
on A.location = B.location and A.date = B.date 
--where A.continent is not null
--order by 2 , 3 


-- creating view to store data for later visualizations 

create view PercentPopulationVaccinated  as 
select A.continent , A.location , A.date, A.population , B.new_vaccinations  ,	
sum(cast(new_vaccinations as int)) over(partition by A.location order by A.location , A.date) as cumulative_freq 
from CovidDeaths A
join
CovidVaccinations B
on A.location = B.location and A.date = B.date 
where A.continent is not null
--order by 2 , 3 


select *
from PercentPopulationVaccinated
