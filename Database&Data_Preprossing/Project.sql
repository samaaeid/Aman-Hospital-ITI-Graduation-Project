select * from [dbo].[Apointment]
select * from [dbo].[Departement]
select * from [dbo].[Doctor]
select * from [dbo].[Dr_View_Appointments]
select * from [dbo].[Medicine]
select * from [dbo].[Nurse]
select * from [dbo].[Nurse_Give_Med]
select * from [dbo].[Patient]
select * from [dbo].[Receptionist]

--------------Doctor----------------------------
--No of females and males
select Gender , count(Dr_ID) as No_Of_Dr
from Doctor
group by Gender

--City per dr
select city, count(Dr_ID) as No_Of_Dr
from Doctor
group by City

--Avg of age for drs
select avg(Age) as averag_Age
from Doctor

--View for dr full name and departement name where age is greater than 55
Create view VDoctor_retire
as
select concat(dr.Fname,' ',dr.Lname) as fullname, d.Dept_Name, dr.Age
from Doctor as dr, Departement as d
where dr.Dept_ID=d.Dept_ID and dr.Age>55


select * from VDoctor_retire

--Make a rule on age of dr is less than 8
Create rule r1 as @x<80
sp_bindrule r1,'Doctor.Age'
insert into Doctor(Dr_ID,Age) values(51,85)

--create data type and apply it on dep name
create type Dep FROM nvarchar(50)
create default d1 as 'internal_doctor'
sp_bindefault d1,Dep

create rule r2 as @y in ('Neurologist','Cardiologist','internal_doctor',
'Eye_doctor','dermatologist')
sp_bindrule r2,Dep

ALTER TABLE Departement
Alter column Dept_Name Dep


--stored procedure that display numbers of patients per departement
create proc Patient_Dept 
as
	select count(P.Patient_ID) as No_of_patients,Dept_Name
	from Patient p,Departement d,Doctor dr
	where p.Dr_ID=dr.Dr_ID and dr.Dept_ID=d.Dept_ID
	group by Dept_Name

Patient_Dept

create view Patient_per_Dept 
as
	select count(P.Patient_ID) as No_of_patients,Dept_Name
	from Patient p,Departement d,Doctor dr
	where p.Dr_ID=dr.Dr_ID and dr.Dept_ID=d.Dept_ID
	group by Dept_Name

--

create view ranks
as
select count(P.Patient_ID) as No_of_patients,Dept_Name
from Patient p,Departement d,Doctor dr
where p.Dr_ID=dr.Dr_ID and dr.Dept_ID=d.Dept_ID
group by Dept_Name
GO


--Ranking over departement for highest number of patients
select * from (select *,rank() over(order by No_of_patients  desc) RN
from ranks) as newtable
where RN=2

--trigger on doctor table that prevent insert in friday
create trigger t1
on [dbo].[Doctor]
after insert
as
	if format(GETDATE(),'dddd')='Friday'
	begin
		rollback
		select 'You can not insert a new record in Friday'
	end

insert into Doctor(Dr_ID) values(200)

--------------Departements----------------------

--Counts of departements name
select count(Dept_Id) as counts_of_dept from [dbo].[Departement] 

--Number of doctors per departement
select Dept_Name,count(Doctor.Dr_ID) as No_of_dr
from Departement ,Doctor
where Departement.Dept_ID=Doctor.Dept_ID
group by Dept_Name


--Add mr or mrs by gender--
declare c1 cursor
for
select d.Fname,d.Gender
from Doctor d
for update
declare @Fname nvarchar(50),@Gender nvarchar(50)
open c1
fetch c1 into @Fname,@Gender
while @@FETCH_STATUS=0
	begin 
	if @Gender='M'
		begin
		update Doctor set Fname='Mr '+Fname
		where current of c1
		end
	else
		begin 
		update Doctor set Fname='Mrs '+Fname
		where current of c1
		end
	fetch c1 into @Fname,@Gender
	end
select Fname,Gender from Doctor
close c1
deallocate c1


------------------Patient----------------------------
--- proc numbers of males and femals patient

create proc patient_gender
as
select Gender , count(Patient_ID) as No_Of_Patient
from Patient
group by Gender

patient_gender

--view
create view patient_operation 
as
select *
from Patient
where Patient_Case='operation'

select * from patient_operation 

--Avg of age for patients
select avg(Age) as averag_Age
from Patient

-- count numbers of patient doing check or operation

select count(Patient_ID), Patient_Case
from Patient
group by Patient_Case

--sum of total fees
 select  sum(Fees)
 from Patient

 -- sum fees per month

 select  sum(Fees) as total_fees, MONTH( Date) as total_per_month
 from Patient
 group by MONTH( Date)

 ------------Nurse----------

 select avg(Age) as averag_Age
from Nurse

----

create view nurse_retire
as
select Nurse_ID , Fname , Lname
from Nurse 
WHERE Age>55
select * from nurse_retire

--City per Nurse
select city, count(Nurse_ID) as No_Of_Nr
from Nurse
group by City


--No of females and males
select Gender , count(Nurse_ID) as No_Of_Nr
from Nurse
group by Gender

--



------Medicine----
--Quantity--
select sum(Quantity_Available) as Total_quantity
from medicine

select * from Medicine

Create procedure Medicine_with_the_min_exp_date
as
select Med_Name,Expiry_Date,Quantity_Available
from Medicine
where Expiry_Date<=2024

Medicine_with_the_min_exp_date

Create view Medicine_with_the_min_exp_date2
as
select Med_Name,Expiry_Date,Quantity_Available
from Medicine
where Expiry_Date<=2024
select * from (select *,rank() over(order by Quantity_Available  desc) RN
from Medicine_with_the_min_exp_date2) as newtable

-----Top 3 companies--
select top(3) COUNT (Med_Name) as Medicine_Name ,Company_Name 
from Medicine
Group by Company_Name
order by Medicine_Name desc



create trigger T3
on [dbo].[Receptionist]
After insert
as
select 'You Inserted Successfully'
	
insert into Receptionist(Recpt_ID) values(7)