/*

Cleaning Data in SQL Queries

*/

Select *
From NashvilleHousing


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

-- Step 1: Select all records from the NashvilleHousing table

SELECT *
FROM NashvilleHousing
ORDER BY ParcelID;

-- Step 2: Identify records with missing PropertyAddress using a self-join
-- The query compares records with the same ParcelID but different UniqueIDs
-- If a record has a missing PropertyAddress, it attempts to find a matching record with the same ParcelID but a non-null PropertyAddress
SELECT 
    a.ParcelID, 
    a.PropertyAddress, 
    b.ParcelID, 
    b.PropertyAddress, 
    ISNULL(a.PropertyAddress, b.PropertyAddress) AS ResolvedPropertyAddress
FROM NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID -- Ensures we're not joining the same record with itself
WHERE a.PropertyAddress IS NULL;

-- Step 3: Update the NashvilleHousing table to fill in missing PropertyAddress values
-- This update operation assigns the non-null PropertyAddress from the matching record to the record with a null PropertyAddress
UPDATE a
SET 
    a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID -- Ensures we're not updating the record with itself
WHERE a.PropertyAddress IS NULL;





--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


-- Select all PropertyAddress values from the NashvilleHousing table
SELECT PropertyAddress
FROM NashvilleHousing;

-- Split PropertyAddress into two parts: Address and City
SELECT
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS City
FROM NashvilleHousing;

-- Add a new column to store the split address
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

-- Update the new column with the address portion of PropertyAddress
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

-- Add a new column to store the split city
ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

-- Update the new column with the city portion of PropertyAddress
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

-- Select all columns from NashvilleHousing to review updates
SELECT *
FROM NashvilleHousing;

-- Select all OwnerAddress values from the NashvilleHousing table
SELECT OwnerAddress
FROM NashvilleHousing;

-- Split OwnerAddress into three parts: Address, City, State using PARSENAME
SELECT
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS OwnerAddress,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS OwnerCity,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS OwnerState
FROM NashvilleHousing;

-- Add a new column to store the split owner address
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

-- Update the new column with the address portion of OwnerAddress
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

-- Add a new column to store the split owner city
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

-- Update the new column with the city portion of OwnerAddress
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

-- Add a new column to store the split owner state
ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

-- Update the new column with the state portion of OwnerAddress
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

-- Select all columns from NashvilleHousing to review the updates
SELECT *
FROM NashvilleHousing;



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


-- Display distinct values in the "SoldAsVacant" field and count occurrences
SELECT DISTINCT
    SoldAsVacant,
    COUNT(SoldAsVacant) AS Count
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY Count;

-- Preview how "SoldAsVacant" values will be changed from 'Y'/'N' to 'Yes'/'No'
SELECT 
    SoldAsVacant,
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS UpdatedSoldAsVacant
FROM NashvilleHousing;

-- Update "SoldAsVacant" values from 'Y' to 'Yes' and 'N' to 'No'
UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

-- Step 1: Create a Common Table Expression (CTE) to assign row numbers
WITH RowNumCTE AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY 
                ParcelID, 
                PropertyAddress, 
                SalePrice, 
                SaleDate, 
                LegalReference
            ORDER BY 
                UniqueID
        ) AS row_num
    FROM NashvilleHousing
)

-- Step 2: Select all rows where row number is greater than 1
-- This helps to identify potential duplicates based on the specified columns
SELECT 
    *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

-- Step 3: Select all data from the NashvilleHousing table
-- This provides a complete view of the dataset
SELECT 
    *
FROM NashvilleHousing;



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


-- Select all records from the NashvilleHousing table to review the current data
SELECT *
FROM NashvilleHousing;

-- Drop specific columns from the NashvilleHousing table: OwnerAddress, TaxDistrict, PropertyAddress, and SaleDate
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;

