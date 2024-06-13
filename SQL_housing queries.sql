Select *
From [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]

--Standardize saldate

Select SaleDate, convert (Date, SaleDate)
From [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]

update [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
set SaleDate = convert (Date, SaleDate)

Alter table [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
Add SaleDateConverted Date; 

update [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
set SaleDateConverted = convert (Date, SaleDate)


--- Populate propertyaddress data

Select *
From [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
---Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,  b.PropertyAddress)
From [Portfolio prac] ..[Nashville Housing Data for Data Cleaning] a
Join [Portfolio prac] ..[Nashville Housing Data for Data Cleaning] b
on a.parcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
SET  PropertyAddress = isnull(a.PropertyAddress,  b.PropertyAddress)
From [Portfolio prac] ..[Nashville Housing Data for Data Cleaning] a
Join [Portfolio prac] ..[Nashville Housing Data for Data Cleaning] b
on a.parcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

----Break address into individual columns

Select PropertyAddress
From [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
---Where PropertyAddress is null
---order by ParcelID

Select
SUBSTRING(PropertyAddress, 1 , CHARINDEX( ',', PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX( ',', PropertyAddress)+ 1, len(PropertyAddress)) as Address
From [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]

Alter table [Nashville Housing Data for Data Cleaning]
Add propertysplitaddress Nvarchar(255); 

update [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
set propertysplitaddress = SUBSTRING(PropertyAddress, 1 , CHARINDEX( ',', PropertyAddress)-1)

Alter table [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
Add propertysplitcity Nvarchar(255); 

update [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
set propertysplitcity = SUBSTRING(PropertyAddress, CHARINDEX( ',', PropertyAddress)+ 1, len(PropertyAddress)) 

Select OwnerAddress
From [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]

Select
PARSENAME(replace (OwnerAddress,',','.'), 3),
PARSENAME(replace (OwnerAddress,',','.'), 2),
PARSENAME(replace (OwnerAddress,',','.'), 1)
From [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]

Alter table [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
Add ownersplitaddress Nvarchar(255); 

update [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
set ownersplitaddress = PARSENAME(replace (OwnerAddress,',','.'), 3)

Alter table [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
Add ownersplitcity Nvarchar(255); 

update [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
set ownersplitcity = PARSENAME(replace (OwnerAddress,',','.'), 2) 

Alter table [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
Add ownersplitstate Nvarchar(255); 

update [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
set ownersplitstate = PARSENAME(replace (OwnerAddress,',','.'), 1)




----- Change Y and N to yes and No in "soldasvacant" column

Select Distinct (SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
Group by SoldAsVacant


SELECT SoldAsVacant, CASE  when SoldAsVacant = 'Y' then 'yes'
						   when SoldAsVacant = 'N' then 'No'
						   Else SoldAsVacant
						   END 
From [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]


update [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
set SoldAsVacant = CASE  when SoldAsVacant = 'Y' then 'yes'
						   when SoldAsVacant = 'N' then 'No'
						   Else SoldAsVacant
						   END 


						   
------Remove duplicates

WITH row_numCTE as(
SELECT *,
ROW_NUMBER () OVER ( PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
			ORDER BY UniqueID) ROW_NUM
From [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
--ORDER BY ParcelID
)

SELECT *
--DELETE (TO DELETE DUPLICATES)
from row_numCTE
where ROW_NUM > 1
order by PropertyAddress





-----Delete unused columns

SELECT *
From [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]

ALTER TABLE [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio prac] ..[Nashville Housing Data for Data Cleaning]
DROP COLUMN SaleDate