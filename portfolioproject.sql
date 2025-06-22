select *
from portfolioproject..CovidDeaths
where continent  is not null
order by 3,4

-- comment out وضع الأمر التالي في الملاحظات ووقف تنفيذه مؤقتا
--select *
--from portfolioproject..covidvaccinations
--order by 3,4


select location,date, total_cases, new_cases, total_deaths, population
from portfolioproject..CovidDeaths
where continent  is not null
order by 1,2


-- looking to total cases vc total death
-- shoe liklihood of dying if you contract covid in ur country

select location,date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from portfolioproject..CovidDeaths
where location like '%saudi%'
and continent  is not null
order by 1,2

--looking at the total cases vs the population
-- shows what percentage of population got covid

select location,date, total_cases,  population, (total_cases/population)*100 as deathpercentage
from portfolioproject..CovidDeaths
--where location like '%saudi%'
order by 1,2

-- lookinng to countries with highest infection rate compared to population

select location,population, max(total_cases)as highestinfectioncount, max((total_cases/population))*100 as
precentagepopulationinfected
from portfolioproject..CovidDeaths
--where location like '%saudi%'
group  by location,population
order by precentagepopulationinfected desc

-- showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..CovidDeaths
where continent  is not null
--where location like '%saudi%'
group  by location
order by totaldeathcount desc

--let's break things down by continent

select continent, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..CovidDeaths
where continent  is not null
--where location like '%saudi%'
group  by continent
order by totaldeathcount desc

--showing the continents with highest death count per population

select continent, max(cast(total_deaths as int)) as totaldeathcount
from portfolioproject..CovidDeaths
where continent  is not null
--where location like '%saudi%'
group  by continent
order by totaldeathcount desc

-- global numbers

select  sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_deathes ,sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
from portfolioproject..CovidDeaths
--where location like '%saudi%'
where continent  is not null
--group by date
order by 1,2

select *
from portfolioproject..CovidDeaths dea
join portfolioproject..covidvaccinations vac
    on dea.location=vac.location
	and dea.date= vac.date

	--looking at total population vc  vaccination
	select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
	,sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
	--,(rollingpeoplevaccinated/population)*100 
	-- convert int ممكن تستخدم بدل cast as int
	--convert(int.........
from portfolioproject..CovidDeaths dea
join portfolioproject..covidvaccinations vac
    on dea.location=vac.location
	and dea.date= vac.date
	where dea.continent  is not null
	order by 2,3

	--use etc

with popvcvac (countinent, location, date, population,  new_vaccinations, rollingpeoplevaccinated)
as
(

select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
	,sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..covidvaccinations vac
    on dea.location=vac.location
	and dea.date= vac.date
	where dea.continent  is not null 

	--order by 2,3
	)
	select * ,(rollingpeoplevaccinated/population)*100
	from popvcvac

	--temp table
	drop table if exists  #percentagepopulationvaccinated

	create table #percentagepopulationvaccinated
	(
	continent nvarchar(255),
	location  nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	 rollingpeoplevaccinated numeric,
	 )

	insert into #percentagepopulationvaccinated
	select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
	,sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..covidvaccinations vac
    on dea.location=vac.location
	and dea.date= vac.date
	--where dea.continent  is not null 
	--order by 2,3
	
	select * ,(rollingpeoplevaccinated/population)*100
	from #percentagepopulationvaccinated

	-- creating to store data for later vc visualizations
	create view percentagepopulationvaccinated as
	select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
	,sum(cast(vac.new_vaccinations as int)) over(partition by dea.location order by dea.location,dea.date) as rollingpeoplevaccinated
from portfolioproject..CovidDeaths dea
join portfolioproject..covidvaccinations vac
    on dea.location=vac.location
	and dea.date= vac.date
	--where dea.continent  is not null 
	--order by 2,3

	select *
	from percentagepopulationvaccinated