--SELECT *
--FROM  CovidDeaths
--order by 3,4

--SELECT *
--FROM portfolioproject..CovidDeaths

SELECT cast(total_cases_per_million as int)
FROM [Portfolio project].dbo.CovidDeaths$


--SELECT *
--FROM [Portfolio project].dbo.CovidVaccinations$
--Order by 3,4

--select the data that we are going to be using

select location, date, total_cases_per_million, new_cases, total_deaths, population_density
FROM [Portfolio project].dbo.CovidDeaths$
Order by 1,2

--Looking at total cases vs total deaths
-- shows likehood of dying if you contract covid in your country

select location, date, total_cases_per_million, total_deaths, (total_deaths/total_cases_per_million)
FROM [Portfolio project].dbo.CovidDeaths$
where location like '%states%'
Order by 1,2

--looking at total cases vs population
--shows what percentage of population has got covid

select location, date, total_cases_per_million, population_density, (total_cases_per_million/population_density)*100 as percentpopulationinfections
FROM [Portfolio project].dbo.CovidDeaths$
where location like '%states%'
Order by 1,2

--Looking at countries with the highest infection rate compared to population

select location, population_density, MAX(cast(total_cases_per_million as int)), (total_cases_per_million/population_density)
FROM [Portfolio project].dbo.CovidDeaths$
where location like '%states%'
Group by Location,population_density


--showing countries with highest death count per population

select location, Max(cast(total_deaths as int)) as TotalDeathcount
FROM [Portfolio project].dbo.CovidDeaths$
--where location like '%state%'
Group by Location
Order by TotalDeathcount desc

--lets break things down by continent

select Location, Max(cast(total_deaths as int)) as TotalDeathcount
FROM [Portfolio project].dbo.CovidDeaths$
--where location like '%state%'
Where continent is not  NULL
Group by Location
Order by TotalDeathcount desc

--global numbers

select date, total_deaths, new_cases
FROM [Portfolio project].dbo.CovidDeaths$
--where location like '%state%'
Where continent is not  NULL
Order by 1,2

select *
From [Portfolio project].dbo.CovidVaccinations$


--looking at total population vs vaccination

select dea.continent,dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
,
From [Portfolio project].dbo.CovidDeaths$ dea
Join [Portfolio project].dbo.CovidVaccinations$ vac
      On dea.location = vac.location
	  and dea.date = vac.date 
where dea.continent is not NULL
order by 2,3

--use CTE
With popvsvac(continent,location,date,population_density,new_vaccinations, Rollingpeoplevaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
From [Portfolio project].dbo.CovidDeaths$ dea
Join [Portfolio project].dbo.CovidVaccinations$ vac
      On dea.location = vac.location
	  and dea.date = vac.date 
where dea.continent is not NULL
)
select*,(Rollingpeoplevaccinated/population_density)*100
From popvsvac

--TEMP TABLE
Drop Table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar (255),
location nvarchar(255),
date datetime,
population_density numeric,
new_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
Insert into #percentpopulationvaccinated
select dea.continent,dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
From [Portfolio project].dbo.CovidDeaths$ dea
Join [Portfolio project].dbo.CovidVaccinations$ vac
      On dea.location = vac.location
	  and dea.date = vac.date 
where dea.continent is not NULL
--order by 2,3
select *, (Rollingpeoplevaccinated/population_density)*100
From #percentpopulationvaccinated

--create view to store data for later visualization

CREATE VIEW percentpopulationvaccinated as
select dea.continent,dea.location, dea.date, dea.population_density, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as Rollingpeoplevaccinated
From [Portfolio project].dbo.CovidDeaths$ dea
Join [Portfolio project].dbo.CovidVaccinations$ vac
      On dea.location = vac.location
	  and dea.date = vac.date 
where dea.continent is not NULL

select *
From percentpopulationvaccinated






