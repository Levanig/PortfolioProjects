-- Cleaning Data in SQL Queries.

Select *
From PortfolioProject..NashvilleHousing

-- Standardize Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing -- I used Wizard import so it does not need to change the Data format.

-- Populate Property Address Data

SELECT *
From NashvilleHousing

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID 
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID 
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is null

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
FROM NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as Address
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress VARCHAR(90)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',',PropertyAddress)-1)
 

ALTER TABLE NashvilleHousing
Add PropertySplitCity VARCHAR(90)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))

SELECT *
FROM NashvilleHousing

-- Same for Column name OwnerAddress USING PARSENAME AND REPLACE functions. (for seperate PHARSENAME NEED '.' So we will replace ',' to '.' and will seperate from right to left.)

SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(Replace(OwnerAddress, ',', '.'),3) 
,PARSENAME(Replace(OwnerAddress, ',', '.'),2) 
,PARSENAME(Replace(OwnerAddress, ',', '.'),1) 
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress VARCHAR(90)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'),3) 

ALTER TABLE NashvilleHousing
Add OwnerSplitCity VARCHAR(90)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'),2) 

ALTER TABLE NashvilleHousing
Add OwnertySplitState VARCHAR(90)

UPDATE NashvilleHousing
SET OwnertySplitState = PARSENAME(Replace(OwnerAddress, ',', '.'),1) 

Select *
From NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), count(SoldAsVacant)
From NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY SoldAsVacant

SELECT SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
When SoldAsVacant = 'N' then 'No'
ELSE SoldAsVacant
END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'Yes'
When SoldAsVacant = 'N' then 'No'
ELSE SoldAsVacant
END


-- Remove Duplicates

WITH RowNumCTE AS(
    SELECT *, 
    ROW_NUMBER() OVER(
        PARTITION BY ParcelID,
                     PropertyAddress,
                     SalePrice,
                     SaleDate,
                     LegalReference
                     ORDER BY UniqueID   
    ) row_num
FROM NashvilleHousing
)

select * -- I deleted this. Then Checked with select *
FROM RowNumCTE
Where row_num >1

-- Delete Unused Columns

Select *
From NashvilleHousing

ALTER Table  NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress
