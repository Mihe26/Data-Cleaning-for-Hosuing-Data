USE PortfolioProject

select *
from NashvilleHousing$


-- standardize date format

select SaleDate, CONVERT(date,SaleDate)
from NashvilleHousing$

update NashvilleHousing$
set SaleDate = CONVERT(date,SaleDate)

alter table NashvilleHousing$
add SaleDateConverted Date;

update NashvilleHousing$
set SaleDateConverted = CONVERT(date, SaleDate)


-- populate property address data

select * 
from NashvilleHousing$
--where PropertyAddress is null
order by ParcelID

select nha.ParcelID, nha.PropertyAddress, nhb.ParcelID, nhb.PropertyAddress, isnull(nha.PropertyAddress, nhb.PropertyAddress)
from NashvilleHousing$ NHa
join NashvilleHousing$ NHb 
	on NHa.ParcelID = NHb.ParcelID
	and NHa.[UniqueID ]<>NHb.[UniqueID ]
where nha.PropertyAddress is null

update nha
set PropertyAddress = ISNULL(nha.PropertyAddress, nhb.PropertyAddress)
from NashvilleHousing$ NHa
join NashvilleHousing$ NHb 
	on NHa.ParcelID = NHb.ParcelID
	and NHa.[UniqueID ]<>NHb.[UniqueID ]
where nha.PropertyAddress is null


-- breaking out address into address, city, and/or state

--1. Hard way
select PropertyAddress
from NashvilleHousing$

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from NashvilleHousing$

alter table NashvilleHousing$
add PropertySplittedAddress nvarchar(255),
	PropertySplittedCity nvarchar(255)

update NashvilleHousing$
set PropertySplittedAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1),
	PropertySplittedCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


--2. Easy way
select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing$

alter table NashVilleHousing$
add OwnerSplittedAddress nvarchar(255),
	OwnerSplittedCity nvarchar(255),
	OwnerSplittedState nvarchar(255)

update NashvilleHousing$
set OwnerSplittedAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3),
	OwnerSplittedCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerSplittedState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-- change Y and N to Yes and No in "Sold as Vacant" column

select distinct SoldAsVacant, count(SoldAsVacant)
from NashvilleHousing$
group by SoldAsVacant
order by SoldAsVacant

select SoldAsVacant,
CASE 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END
from NashvilleHousing$

update NashvilleHousing$
set SoldAsVacant = 
CASE 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	END


-- Removing duplicates

select *, 
		ROW_NUMBER() over(
		partition by ParcelID
					,PropertyAddress
					,SalePrice
					,SaleDate
					,LegalReference
					Order by UniqueID) row_num
from NashvilleHousing$
order by ParcelID

--create CTE (temporary table) to remove duplicate

with RowNumCTE as(
select *, 
		ROW_NUMBER() over(
		partition by ParcelID
					,PropertyAddress
					,SalePrice
					,SaleDate
					,LegalReference
					Order by UniqueID) row_num
from NashvilleHousing$
--order by ParcelID
)
delete
from RowNumCTE
where row_num > 1


-- remove unused columns

select * 
from NashvilleHousing$

alter table NashvilleHousing$
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate