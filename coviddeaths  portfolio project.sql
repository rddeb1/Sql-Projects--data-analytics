/* Data visulisation of country */



select * from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 3,4

--select * from PortfolioProject.dbo.CovidVactination
--order by 3,4

-->>>select the data that we are going to be using

select Location, date, total_cases,new_cases,total_deaths,population 
from PortfolioProject.dbo.CovidDeaths
where continent is not null
order by 1,2

-->> loking at total cases vs total deaths
--showes the likelihood of dying if you contract covid  in your country

select Location, date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage 
from PortfolioProject.dbo.CovidDeaths
where location like '%india%'
order by 1,2


-->> looking at total_cases vs population
--showes what percentage of population got covid

select Location, date,population, total_cases,(total_cases/population)*100 as PercentagePopulationInfect 
from PortfolioProject.dbo.CovidDeaths
where location like '%india%'
and continent is not null
order by 1,2

--->>all over the country covid cases etc

select Location, date,population, total_cases,(total_cases/population)*100 as AlloverCountryPercentage 
from PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
order by 1,2


--> looking at india with highest indfection rate compared to population


select Location,population, max(total_cases)as HighestInfectionCount,max((total_cases/population))*100 as
PercentagePopulationInfectedIndia 
from PortfolioProject.dbo.CovidDeaths
where location like '%india%'
group by Location,population
order by PercentagePopulationInfectedIndia desc


-->> looking at coutries with highest infection rate compared to population 

select Location,population, max(total_cases)as HighestInfectionCount,max((total_cases/population))*100 as
PercentagePopulationInfected 
from PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
group by Location,population
order by PercentagePopulationInfected desc


--> Showing countries with highest death count per population 
select Location, max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
where continent is not null
group by Location
order by Totaldeathcount desc


-->lets BREAK things down by content Deaths
select location, max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
where continent is  null
group by location
order by Totaldeathcount desc


-->>showing highest deaths of continent

select continent, max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by Totaldeathcount desc


--->> GLOBAL NUMBERS

select  date, sum(new_cases) as Total_Cases,sum(cast(new_deaths as int)) as Total_Deaths,sum(cast(new_deaths as int))/sum
(new_cases)*100 as GlobalDeathPercentage
from PortfolioProject.dbo.CovidDeaths
--where location like '%india%'
where continent is not null
group by date
order by 1,2




----->>>>Looking at total population vs vactination 

select death.continent,death.location,death.date,death.population,vac.new_vaccinations,
SUM(convert(int,new_vaccinations)) over (partition by death.location order by death.location,death.date) as Rollingpeoplevaccinated
from PortfolioProject.dbo.CovidDeaths death
join PortfolioProject.dbo.CovidVactination vac
on death.location=vac.location 
and death.date=vac.date
where death.continent is not null
order by 2,3


--->using cte
with PopvsVac (Continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(
select death.continent,death.location,death.date,death.population,vac.new_vaccinations,
SUM(convert(int,new_vaccinations)) over (partition by death.location order by death.location,death.date) as Rollingpeoplevaccinated
from PortfolioProject.dbo.CovidDeaths death
join PortfolioProject.dbo.CovidVactination vac
on death.location=vac.location 
and death.date=vac.date
where death.continent is not null
--order by 2,3
 )
 select * ,(Rollingpeoplevaccinated/population)*100
 from PopvsVac


 -->temp table
 drop table if exists #PercentPopulationVactinated
 create table #PercentPopulationVactinated
 (continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vactinations numeric,
 Rollingpeoplevaccinated numeric)
  
insert into #PercentPopulationVactinated
select death.continent,death.location,death.date,death.population,vac.new_vaccinations,
SUM(convert(int,new_vaccinations)) over (partition by death.location order by death.location,death.date) as Rollingpeoplevaccinated
from PortfolioProject.dbo.CovidDeaths death
join PortfolioProject.dbo.CovidVactination vac
on death.location=vac.location 
and death.date=vac.date
where death.continent is not null
--order by 2,3

select * ,(Rollingpeoplevaccinated/population)*100
from #PercentPopulationVactinated


-->>>creattng view to store data for later visualizations

create view  PercentPopulationVactinated as
select death.continent,death.location,death.date,death.population,vac.new_vaccinations,
SUM(convert(int,new_vaccinations)) over (partition by death.location order by death.location,death.date) as Rollingpeoplevaccinated
from PortfolioProject.dbo.CovidDeaths death
join PortfolioProject.dbo.CovidVactination vac
on death.location=vac.location 
and death.date=vac.date
where death.continent is not null
--order by 2,3
