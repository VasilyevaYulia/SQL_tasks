/*
Cleaning Data in SQL Queries
*/

use SQLTutorial

select *
from SQLTutorial.dbo.NashvilleHousing
-------------------------------------------------------------------------------------

--Standardize Date Format

select SaleDateConverted, convert(date, SaleDate)
from SQLTutorial.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date, SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)

--------------------------------------------------------------------------------------

--Populate Property Address data

select count(ParcelID), count(distinct ParcelID)
from SQLTutorial.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from SQLTutorial.dbo.NashvilleHousing a
join SQLTutorial.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from SQLTutorial.dbo.NashvilleHousing a
join SQLTutorial.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

-----------------------------------------------------------------------------------------------------

--Breaking out Address into Individual Columns (Adress, City, State)

select PropertyAddress
from SQLTutorial.dbo.NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from SQLTutorial.dbo.NashvilleHousing

alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))

select *
from SQLTutorial.dbo.NashvilleHousing

--Different way to sub data
select 
PARSENAME (replace(OwnerAddress, ',','.'),3)
, PARSENAME (replace(OwnerAddress, ',','.'),2)
, PARSENAME (replace(OwnerAddress, ',','.'),1)
from SQLTutorial.dbo.NashvilleHousing

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME (replace(OwnerAddress, ',','.'),3)

alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME (replace(OwnerAddress, ',','.'),2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME (replace(OwnerAddress, ',','.'),1)

select *
from SQLTutorial.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

select distinct (SoldAsVacant), count (SoldAsVacant)
from SQLTutorial.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from SQLTutorial.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

----------------------------------------------------------------------------------------------------

--Remove Duplicates

with RowNumCTE as(
select *,
	ROW_NUMBER() over(
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by UniqueID
				 ) row_num
from SQLTutorial.dbo.NashvilleHousing
--order by ParcelID 
)
delete
from RowNumCTE
where row_num > 1 
--order by PropertyAddress

select *
from SQLTutorial.dbo.NashvilleHousing

---------------------------------------------------------------------------------------------------

--Delete Unused Columns

alter table SQLTutorial.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table SQLTutorial.dbo.NashvilleHousing
drop column SaleDate

select *
from SQLTutorial.dbo.NashvilleHousing
