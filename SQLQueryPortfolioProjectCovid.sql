create database Portfolioproject

use Portfolioproject

select *from Portfolioproject..CovidDeaths
where continent is not null
order by 3,4

--select *from Portfolioproject..CovidVaccination
--order by 3,4

--select the data we are going to use

select location,date,total_cases,new_cases,total_deaths,population
from Portfolioproject..CovidDeaths
order by 1,2

--lokking at Total cases vs Total deaths

 select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from Portfolioproject..CovidDeaths
order by 1,2

--loking at Total cases vs Population

select location,date,total_cases,population,(total_cases/population)*100 as PercentagePopulationaffected
from Portfolioproject..CovidDeaths
order by 1,2

--Looking at countries with highest infection rate compared to population

select location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as 
PercentagePopulationaffected
from Portfolioproject..CovidDeaths
--where location like '%India%'
Group by location,population
order by PercentagePopulationaffected desc

--Showing Countries with highest death count per population

select location,population,MAX(cast(total_deaths as int)) as TotalDeathCount
from Portfolioproject..CovidDeaths
where continent is not null
Group by location,population
order by TotalDeathCount desc

--Lets Break Things Down by Continenet 

select continent,MAX(cast(Total_deaths as int))as TotalDeathCount
from Portfolioproject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc

--showing continent with the highest death count per population

select continent,MAX(cast(Total_deaths as int))as TotalDeathCount,MAX(total_deaths/population)*100
as ContinentDeathCountPerPopulation
from Portfolioproject..CovidDeaths
where continent is not null
Group by continent
order by ContinentDeathCountPerPopulation desc

--Global Numbers

select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int))as total_deaths,
SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From Portfolioproject..CovidDeaths
where continent is not null
--Group by date
order by 1,2

--Looking at Total Population vs Vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,
dea.date) as RollingPopleVaccinated
--(RollingPopleVaccinated/population)*100
from Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE

with PopvsVac(Continent,location,DAte,Population,new_vaccination,RollingPopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,
dea.date) as RollingPopleVaccinated
--(RollingPopleVaccinated/population)*100
from Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)select*,((RollingPopleVaccinated/population)*100)
from PopvsVac


--Temp Table

Create Table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentagePopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(Cast(vac.new_vaccinations as bigint)) over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
--(RollingPopleVaccinated/population)*100
from Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccination vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*,(RollingPeopleVaccinated/population)*100
from #PercentagePopulationVaccinated

Drop table if exists #PercentagePopulationVaccinated

--create View

Use Portfolioproject
Go
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint))over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
from Portfolioproject..CovidDeaths dea
join Portfolioproject..CovidVaccination vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null

select *from PercentPopulationVaccinated

Drop view if exists PercentPopulationVaccinated
