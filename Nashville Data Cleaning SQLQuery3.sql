

--Cleaning NasvilleHousing Data 

Select *
From "PORTFOLIO PROJECTS"..NasvilleHousing

--I had to query the data to have a standard date format in a new Column named NewSalesDate

Select SaleDate, convert(Date,SaleDate)
From "PORTFOLIO PROJECTS"..NasvilleHousing

update NasvilleHousing
set SaleDate = convert(Date,SaleDate)

Alter table NasvilleHousing
Add NewSalesDate Date

update NasvilleHousing
set NewSalesDate = convert(Date,SaleDate)

--So the Property Address Data is not in order 
--I have to Query and clean it up so i can populate the property address data properly


Select PropertyAddress
From "PORTFOLIO PROJECTS".dbo.NasvilleHousing
where PropertyAddress is NULL

--So i decided to check the entire data set for NULL values

Select *
From "PORTFOLIO PROJECTS".dbo.NasvilleHousing
where PropertyAddress is NULL

--Since there are lots of null values in the data set
--i decided to populate reference points to generate data sets 
--to replace the Null values for the property address


Select *
From "PORTFOLIO PROJECTS".dbo.NasvilleHousing
--where PropertyAddress is NULL
order by ParcelID

Using self joins to join the tables

Select *
From "PORTFOLIO PROJECTS".dbo.NasvilleHousing one
join "PORTFOLIO PROJECTS".dbo.NasvilleHousing two
on one.ParcelID = two.ParcelID
and one.[UniqueID ] <> two.[UniqueID ]

--selecting columns of interest

Select one.ParcelID, two.ParcelID, one.PropertyAddress, two.PropertyAddress, Isnull(one.PropertyAddress,two.PropertyAddress)
From "PORTFOLIO PROJECTS".dbo.NasvilleHousing one
join "PORTFOLIO PROJECTS".dbo.NasvilleHousing two
on one.ParcelID = two.ParcelID
and one.[UniqueID ] <> two.[UniqueID ]
where one.PropertyAddress is NULL

--Replacing the desired information into the affected column

update one
set PropertyAddress =  Isnull(one.PropertyAddress,two.PropertyAddress)
From "PORTFOLIO PROJECTS".dbo.NasvilleHousing one
join "PORTFOLIO PROJECTS".dbo.NasvilleHousing two
on one.ParcelID = two.ParcelID
and one.[UniqueID ] <> two.[UniqueID ]
where one.PropertyAddress is NULL

--To confirm if the query above has been successful



Select one.ParcelID, two.ParcelID, one.PropertyAddress, two.PropertyAddress, Isnull(one.PropertyAddress,two.PropertyAddress)
From "PORTFOLIO PROJECTS".dbo.NasvilleHousing one
join "PORTFOLIO PROJECTS".dbo.NasvilleHousing two
on one.ParcelID = two.ParcelID
and one.[UniqueID ] <> two.[UniqueID ]
where one.PropertyAddress is NULL

--Null Error cleared.
 
 --I Now have to segment the property address column into individual columns (Address, city and state)
 --Looking at the PropertyAddress again

 Select PropertyAddress
From "PORTFOLIO PROJECTS".dbo.NasvilleHousing
--where PropertyAddress is NULL
--order by ParcelID

--Segmenting the column

select SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress ) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, len(PropertyAddress)) as Address

From "PORTFOLIO PROJECTS".dbo.NasvilleHousing


Alter table "PORTFOLIO PROJECTS".dbo.NasvilleHousing
Add PropertySplitAddress nvarchar (225);

update "PORTFOLIO PROJECTS".dbo.NasvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

 
Alter table "PORTFOLIO PROJECTS".dbo.NasvilleHousing
Add PropertySplitCity nvarchar (225);

update "PORTFOLIO PROJECTS".dbo.NasvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

select *
from "PORTFOLIO PROJECTS".dbo.NasvilleHousing

-- Looking at the owner address column 
-- I also need to do some splitting to have a more useable data


select OwnerAddress
from "PORTFOLIO PROJECTS".dbo.NasvilleHousing

select 
PARSENAME(replace(OwnerAddress, ',','.'),3)
,PARSENAME(replace(OwnerAddress, ',','.'),2)
,PARSENAME(replace(OwnerAddress, ',','.'),1)
from "PORTFOLIO PROJECTS".dbo.NasvilleHousing


ALTER TABLE "PORTFOLIO PROJECTS".dbo.NasvilleHousing
ADD OwnerSplitAddress NVARCHAR (255);

UPDATE "PORTFOLIO PROJECTS".dbo.NasvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',','.'),3)

ALTER TABLE "PORTFOLIO PROJECTS".dbo.NasvilleHousing
ADD OwnerSplitCity NVARCHAR (255);

UPDATE "PORTFOLIO PROJECTS".dbo.NasvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',','.'),2)

ALTER TABLE "PORTFOLIO PROJECTS".dbo.NasvilleHousing
ADD OwnerSplitState NVARCHAR (255);

UPDATE "PORTFOLIO PROJECTS".dbo.NasvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress, ',','.'),1)

select *
from "PORTFOLIO PROJECTS".dbo.NasvilleHousing

--Looking at the "Sold as Vaacant" field
--I have to change "Y" and "N" to Yes and No for accurate visuals
--I have to query to see the total incorrect data

select Distinct(SoldAsVacant), count(SoldAsVacant)
from "PORTFOLIO PROJECTS".dbo.NasvilleHousing
group by SoldAsVacant
Order by 2

--Using a case statement to organise the data

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from "PORTFOLIO PROJECTS".dbo.NasvilleHousing

update "PORTFOLIO PROJECTS".dbo.NasvilleHousing
set SoldAsVacant =  case when SoldAsVacant = 'Y' then 'Yes'
					 when SoldAsVacant = 'N' then 'No'
					 else SoldAsVacant
					 end

--To confirm the data cleaning query

select Distinct(SoldAsVacant), count(SoldAsVacant)
from "PORTFOLIO PROJECTS".dbo.NasvilleHousing
group by SoldAsVacant
Order by 2

--I do not need duplicate data from my database so i am going to delete them
--Note: I rarely delete data from my database because it is not professional.

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From "PORTFOLIO PROJECTS".dbo.NasvilleHousing
--order by ParcelID
)
SELECT *
--DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



--Deleting unused columns

select *
from "PORTFOLIO PROJECTS".dbo.NasvilleHousing

ALTER TABLE "PORTFOLIO PROJECTS".dbo.NasvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

--Here is the Final cleaned data

select *
from "PORTFOLIO PROJECTS".dbo.NasvilleHousing




