Select * 
from PortfolioProject..NashvilleHousing

--Populate Property Address where PropertyAddress is Null based on ParcelID
Select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress) AS Address
from PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

--Breaking out address into seperate columns using substring

Select PropertyAddress
from PortfolioProject..NashvilleHousing

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add PropertyStreetAddress NVARCHAR(255);

Update NashvilleHousing
Set PropertyStreetAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


Alter Table NashvilleHousing
Add PropertyCity NVARCHAR(255);

Update NashvilleHousing
Set PropertyCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

Select *
from PortfolioProject..NashvilleHousing

--Seprating Owner Address using ParseNames

Select 
PARSENAME(Replace(OwnerAddress,',','.'),3) As OwnerStreetAddress,
PARSENAME(Replace(OwnerAddress,',','.'),2) As OwnerCity,
PARSENAME(Replace(OwnerAddress,',','.'),1) As OwnerState
from PortfolioProject..NashvilleHousing

Alter Table NashvilleHousing
Add OwnerStreetAddress NVARCHAR(255),
	OwnerCity NVARCHAR(255),
	OwnerState NVARCHAR(255);

Update NashvilleHousing
Set OwnerStreetAddress = PARSENAME(Replace(OwnerAddress,',','.'),3),
	OwnerCity = PARSENAME(Replace(OwnerAddress,',','.'),2),
	OwnerState = PARSENAME(Replace(OwnerAddress,',','.'),1)

Select *
from PortfolioProject..NashvilleHousing

--Change 'Y' and 'N' to 'Yes' and 'No' in SoldAsVacant Column

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant,
CASE When SoldAsVacant = 'N' Then 'No'
	 When SoldAsVacant = 'Y' Then 'Yes'
	 Else SoldAsVacant
End AS NEWSoldAsVacant
from PortfolioProject..NashvilleHousing
WHERE SoldAsVacant IN ('N','Y')

Update NashvilleHousing
Set SoldAsVacant = 
	CASE When SoldAsVacant = 'N' Then 'No'
	 When SoldAsVacant = 'Y' Then 'Yes'
	 Else SoldAsVacant
	End 

--Delete Duplicate Rows
With RowNumCTE AS(
Select *, 
ROW_NUMBER()OVER(
		PARTITION BY ParcelID,
			     PropertyAddress,
			     SaleDate,
			     SalePrice,
		             LegalReference
		         Order By UniqueID
		)RowNum
from PortfolioProject..NashvilleHousing
--Order By ParcelID
)

DELETE  from RowNumCTE
Where RowNum > 1

--To Verify
With RowNumCTE AS(
Select *, 
ROW_NUMBER()OVER(
		 PARTITION BY ParcelID,
		 PropertyAddress,
		 SaleDate,
		 SalePrice,
		 LegalReference
		 Order By UniqueID
		 )RowNum
from PortfolioProject..NashvilleHousing
--Order By ParcelID
)

SELECT * 
from RowNumCTE
Where RowNum > 1

--Delete Unused Columns

Alter Table PortfolioProject..NashvilleHousing
Drop Column PropertyAddress, OwnerAddress

SELECT * 
from PortfolioProject..NashvilleHousing
