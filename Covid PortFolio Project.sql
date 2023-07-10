SELECT *
FROM PortFolioProject..CovidDeaths$
Where continent is not Null
ORDER BY 3,4



SELECT *
FROM PortFolioProject..CovidVaccinations
ORDER BY 3,4

--Select Data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
From PortFolioProject..CovidDeaths$
Order by 1,2

--Looking at total cased vs total deaths
--Shows  the likelyhood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortFolioProject..CovidDeaths$
Where location like '%india%'
Order by 1,2
 

 --Looking at Total cases vs population
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
From PortFolioProject..CovidDeaths$
--Where location like '%states%'
Where continent is not Null
Order by 1,2
 

 --Looking at Countries with Highest Infection rate compared to population

select location, population, MAX(total_cases) as HighestInfectionCount,  MAX(total_cases/population)*100 as PercentPopulationInfected
From PortFolioProject..CovidDeaths$
Where continent is not Null
Group By location, population
Order by PercentPopulationInfected Desc


--Showing the countries with highest death count per popualtion

Select location, MAX(cast(total_deaths  as int)) as TotalDeathCount
From PortFolioProject..CovidDeaths$
Where continent is not Null
Group By location
order by TotalDeathCount Desc


--LETS BREAK THINGS DOWN BY CONTINENT

--Showing continent with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortFolioProject..CovidDeaths$
Where continent is not null
Group By continent
Order By TotalDeathCount Desc

--GLOBAL NUMBERS

Select  SUM(new_cases) as TotalCases,SUM(Cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage--,total_deaths, (total_deaths/total_cases)*100 DeathPercentage
From PortFolioProject..CovidDeaths$
Where continent is not null
--Group By date
Order By 1,2


--Looking at total population vs vaccinations

Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(cast(new_vaccinations as int)) OVER (Partition By CD.location Order By CD.location,CD.date) as RollingPeopleVaccinated
From PortFolioProject..CovidDeaths$ CD
Join PortFolioProject..CovidVaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
Order By 2,3


--USE CTE
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) 
as
(
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(cast(new_vaccinations as int)) OVER (Partition By CD.location Order By CD.location,CD.date) as RollingPeopleVaccinated
From PortFolioProject..CovidDeaths$ CD
Join PortFolioProject..CovidVaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
--Order By 2,3
)

Select *, (RollingPeopleVaccinated/population)*100 as VaccinationPercentage
From PopvsVac

Order By VaccinationPercentage Desc


--TEMP TABLE
Drop Table  If Exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(cast(new_vaccinations as int)) OVER (Partition By CD.location Order By CD.location,CD.date) as RollingPeopleVaccinated
From PortFolioProject..CovidDeaths$ CD
Join PortFolioProject..CovidVaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
--Order By 2,3


Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated
Order By 2,3


--Creating view to store data for later visualization

Create View PercentPopulationVaccinated as
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
SUM(cast(new_vaccinations as int)) OVER (Partition By CD.location Order By CD.location,CD.date) as RollingPeopleVaccinated
From PortFolioProject..CovidDeaths$ CD
Join PortFolioProject..CovidVaccinations CV
	On CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
--Order By 2,3

select *
From PercentPopulationVaccinated