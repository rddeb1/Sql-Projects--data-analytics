/* data cleaning in sql queries */

select * from PortfolioProject.dbo.NashvileHousing

--> standerdizing date

select  SaleDateConverted,CONVERT(date,SaleDate)
from PortfolioProject.dbo.NashvileHousing

update NashvileHousing
set SaleDate = CONVERT(date,SaleDate)

ALTER table NashvileHousing
add SaleDateConverted date;

update NashvileHousing
set SaleDateConverted= CONVERT(date,SaleDate)


--->Populate property address data

select *
from PortfolioProject.dbo.NashvileHousing
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvileHousing   a
join PortfolioProject.dbo.NashvileHousing   b
on a.ParcelID =b.ParcelID
and a.[UniqueID ] <>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvileHousing   a
join PortfolioProject.dbo.NashvileHousing   b
on a.ParcelID =b.ParcelID
and a.[UniqueID ] <>b.[UniqueID ]
where a.PropertyAddress is null



---->>> Breking out  into individual  coloumns (address , city ,state)

select PropertyAddress
from PortfolioProject.dbo.NashvileHousing


select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address --->> it is used for finding address from index 1 to  these comma " , "
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvileHousing



ALTER table NashvileHousing
add PropertySplitAddress nvarchar(255);

update NashvileHousing
set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER table NashvileHousing
add PropertySplitCity nvarchar(255);

update NashvileHousing
set PropertySplitCity= SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

select * from PortfolioProject.dbo.NashvileHousing




select OwnerAddress 
from PortfolioProject.dbo.NashvileHousing

select 
PARSENAME(replace(OwnerAddress,',','.'),3),       ---->>>it is simple to used to seperate(data cleaning) the data ,also can be add to as a column ( most easiest one commands then substring)
PARSENAME(replace(OwnerAddress,',','.'),2),
PARSENAME(replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvileHousing


ALTER table NashvileHousing
add OwnerSplitAddress nvarchar(255);

update NashvileHousing
set OwnerSplitAddress=PARSENAME(replace(OwnerAddress,',','.'),3)

ALTER table NashvileHousing
add OwnerSplitCity nvarchar(255);

update NashvileHousing
set OwnerSplitCity= PARSENAME(replace(OwnerAddress,',','.'),2)

ALTER table NashvileHousing
add OwnerSplitState nvarchar(255);

update NashvileHousing
set OwnerSplitState= PARSENAME(replace(OwnerAddress,',','.'),1)

select * from PortfolioProject.dbo.NashvileHousing


---> change Y and N to yes and No in "Sold vacent" field

select distinct(SoldAsvacant),COUNT(SoldAsVacant)
from PortfolioProject.dbo.NashvileHousing
group by SoldAsVacant
order by SoldAsVacant

select SoldAsVacant
,case when SoldAsVacant='Y' then 'yes'
      when SoldAsVacant='N' then 'No'
	  else SoldAsVacant
	  end
from PortfolioProject.dbo.NashvileHousing

update NashvileHousing
set SoldAsVacant=case when SoldAsVacant='Y' then 'yes'
      when SoldAsVacant='N' then 'No'
	  else SoldAsVacant
	  end


-->> Removing Duplicates


with ROW_NUMCTE as(
select *,
   ROW_NUMBER() over(
   partition by ParcelID,
             PropertyAddress,
			 SalePrice,
			 LegalReference
			 order by UniqueID)ROW_NUM


from PortfolioProject.dbo.NashvileHousing
--order by ParcelID
)

select*
from ROW_NUMCTE
where ROW_NUM > 1
order by PropertyAddress



--->> delete Unused Columns

select * from PortfolioProject.dbo.NashvileHousing

alter table PortfolioProject.dbo.NashvileHousing
drop Column OwnerAddress,TaxDistrict,PropertyAddress

alter table PortfolioProject.dbo.NashvileHousing
drop Column SaleDate