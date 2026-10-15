create database Analytics_present;
use Analytics_present;

drop database analytics_present;

select * from HR_Analytics_Dashboard;
alter table HR_Analytics_Dashboard rename to HR_D;

select * from HR_D;
select count(*) from HR_D;


-- Display the first 10 rows from the table. 
select * from HR_D limit 10;

-- Find the total number of employees in the company.
select count(*) from HR_D;

-- List all unique departmenT
select distinct(Department) from HR_D;
-- Show how many employees have left the company and how many are still working. 
select Attrition, count(Attrition) as Attrition_Status from HR_D group by Attrition;

-- Retrieve the list of employees who work overtime. 
select OverTime, count(OverTime) from HR_D group by OverTime;

-- Find the average monthly income of all employees. 
select avg(MonthlyIncome) from HR_D;

-- Identify employees whose number of companies worked is missing (NULL).
select * from HR_D where NumCompaniesWorked=NULL; 

-- Find the employee(s) with the maximum monthly income. 
select * from HR_D where MOnthlyIncome> 19700;
select count(*) from HR_D where MOnthlyIncome> 19700;

-- Count the number of employees by gender. 
select Gender, count(Gender) from HR_D group by Gender;

-- List all employees who have just joined (YearsAtCompany = 0).
select  * from HR_D where YearsAtCompany=0;
select count(*) from HR_D where YearsAtCompany=0;

-- Calculate the attrition rate (%) by department. 
select Department,
	count(*) as total_employee,
	sum(case when Attrition="Yes" then 1 else 0 end) as Attrition_count,
	sum(case when Attrition="Yes" then 1 else 0 end)/count(*)*100 as Attrition_Rate 
	from HR_D group by Department;
    
    
-- List the top 10 employees with the highest total working years.
select * from HR_D order by TotalWorkingYears desc limit 10; 

-- Group employees into tenure categories (<1yr, 1–3yr, 4–6yr, 7+yr) and count employees in each. 
select 
	case 
		when YearsAtCompany <1 then "<1yr"
		when YearsAtCompany >=1 and YearsAtCompany<3 then "1-3yr"
		when YearsAtCompany >=4 and YearsAtCompany<6 then "4-6yr"
		else "7+yr"
	end as Tenure_Cat,
count(*) as employee_count
from HR_D group by Tenure_cat order by MIN(YearsAtCompany);

-- Find the average monthly income by job level and attrition status. 
select JobLevel,Attrition,avg(MonthlyIncome) from HR_D  group by JobLevel,Attrition  order by JobLevel ;

-- Identify the top 5 job roles with the highest number of employees who left. 
select JobRole,count(*) as Total_Emp from HR_D where Attrition="Yes" group by JobRole order by Total_Emp desc   limit 5;

-- List employees who left the company within their first year. 
select * from HR_D where Attrition="Yes" and YearsAtCompany <1;
select count(*) from HR_D where Attrition="Yes" and YearsAtCompany <1;

-- Calculate each employee’s approximate new monthly compensation after applying their salary hike percentage. 
select 
	EmployeeNumber,
	MonthlyIncome,
	PercentSalaryHike,
    round((MonthlyIncome*PercentSalaryHike/100),2) as hike_value,
	round(MonthlyIncome+(MonthlyIncome*PercentSalaryHike/100),2) as new_monthly_compensation
from HR_D;

-- Count employees grouped by overtime status and attrition. 
select OverTime,Attrition,count(*) from HR_D group by OverTime,Attrition;

-- Display the top 10 employees who attended the most training sessions last year.
select * from HR_D order by TrainingTimesLastYear desc limit 10;

-- Rank employees by total working years (most experienced = rank 1). 
select EmployeeNumber,TotalWorkingYears,
case when TotalWorkingYears<=2 then "fresher"
when TotalWorkingYears >2 and TotalWorkingYears <=5 then "Rank 3"
when TotalWorkingYears >5 and TotalWorkingYears <=20 then "Rank 2"
else "Rank 1"
end as Experience
from HR_D order by EmployeeNumber;

-- For each department, find employees whose monthly income is in the top 25% of that department. 
select 
	Department,
	EmployeeNumber,
    MonthlyIncome from
		(select *, cume_dist() over (partition by Department order by MonthlyIncome)as cd from HR_D) t 
where cd >=0.75  order by Department, monthlyIncome desc;

 /* Here there is 369 employees are present whose monthly income is in the top 25% of th department.*/

-- Divide employees into 10 income deciles and find attrition rate for each decile.


 
-- Create a simple risk score based on tenure, performance, overtime, and work-life balance — and list the top 50 high-risk employees. 
select 
EmployeeNumber,
YearsAtCompany,
PerformanceRating,
OverTime,
WorkLifeBalance,
(
(case when YearsAtCompany<2 then 1 else 0 end)
+(case when PerformanceRating<=2 then 1 else 0 end)
+(case when OverTime='Yes' then 1 else 0 end)
+(case when WorkLifeBalance<=2 then 1 else 0 end)
) as risk_score
from HR_D order by risk_score desc, YearsAtCompany asc limit 50;

-- Create a summary view showing, for each department and job level: total employees,number of leavers, attrition rate, and average monthly income.
create view dept_attrition as
select 
	Department,
	JobLevel,
	count(*) as total_employee,
	sum(case when Attrition='Yes' then 1 else o end) as leavers,
	round(100.0*sum(case when Attrition='Yes' then 1 else o end)/count(*),2) as attrition_ate_ptcg,
	round(avg(MonthlyIncome),2) as avg_monthly_income
group by Department, JobLevel ;

select * from dept_attrition;
