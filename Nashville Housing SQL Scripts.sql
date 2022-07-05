/*

Data Cleaning SQL Queries

*/

SELECT *
FROM PortfoloProjects.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------------------------------------------------------

--Date Format Standardization

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM PortfoloProjects..NashvilleHousing

--Update the Date Column

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

---Populate Property Address Data

--Showing Null PropertyAddress
SELECT PropertyAddress
FROM PortfoloProjects.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

SELECT *
FROM PortfoloProjects.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL

---Identifying Unique Identifier for address
SELECT *
FROM PortfoloProjects.dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


--Using a Self Join the table to connect null address to matching ParcelID

SELECT *
FROM PortfoloProjects.dbo.NashvilleHousing a
JOIN PortfoloProjects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID] <> b.[UniqueID]

--Exploring PropertyAddress on Self Join to Identify null values

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID , b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfoloProjects.dbo.NashvilleHousing a
JOIN PortfoloProjects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

--Update Nukk PropertyAddress

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM PortfoloProjects.dbo.NashvilleHousing a
JOIN PortfoloProjects.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID 
	AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address Into Individual Columns (Address, City, State)
	
SELECT PropertyAddress
FROM PortfoloProjects.dbo.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City

FROM PortfoloProjects.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = CONVERT(PropertyAddress, PropertySplitAddress)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT *
FROM PortfoloProjects.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Alternate for Address to 3 Columns (Address, City, State)

SELECT OwnerAddress
FROM PortfoloProjects.dbo.NashvilleHousing


SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM PortfoloProjects.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress  = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity  Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity  = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)


SELECT *
FROM PortfoloProjects.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Replace Y to Yes and N to No in "Sold as Vacant" field

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfoloProjects.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM PortfoloProjects.dbo.NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates using CTE

--Showing Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num

FROM PortfoloProjects.dbo.NashvilleHousing

)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--Deleting Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
				UniqueID
				) row_num

FROM PortfoloProjects.dbo.NashvilleHousing

)
DELETE 
FROM RowNumCTE
WHERE row_num > 1

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns

Select *
FROM PortfoloProjects.dbo.NashvilleHousing


ALTER TABLE PortfoloProjects.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PortfoloProjects.dbo.NashvilleHousing
DROP COLUMN SaleDate