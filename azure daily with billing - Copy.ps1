# Set date range for exported usage data
$reportedStartTime = "2018-03-20"
$reportedEndTime = "2018-03-28"
# Authenticate to Azure
$username = "azure@cloudfx.com"
$password = "CFX@2018" | ConvertTo-SecureString -AsPlainText -Force
#Login-AzureRmAccount
$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username, $password 
Add-AzurermAccount -Credential $credential 
# Switch to Azure Resource Manager mode
#Switch-AzureMode -Name AzureResourceManager
# Select an Azure Subscription for which to report usage data
$subscriptionId = 
    (Get-AzurermSubscription |
     Out-GridView `
        -Title "Select an Azure Subscription ..." `
        -PassThru).SubscriptionId

Select-AzurermSubscription -SubscriptionId $subscriptionId

Set-AzureRmContext -SubscriptionId $subscriptionId
# Set path to exported CSV file
$filename = ".\usageData-${subscriptionId}-${reportedStartTime}-${reportedEndTime}.csv"
# Set usage parameters
$granularity = "Daily" # Can be Hourly or Daily
$showDetails = $true
# Export Usage to CSV
$appendFile = $false
#$continuationToken = ""
       $usageData = Get-AzureRmConsumptionUsageDetail  | Export-Csv -Append:$appendFile -NoTypeInformation:$true -Path $filename
   


$Cpuprice =@()
$colStats=Import-Csv .\usageData-${subscriptionId}-${reportedStartTime}-${reportedEndTime}.csv | select-object Name, Type, Tags, UsageStart , UsageEnd, BillingPeriodName, InvoiceName, InstanceName, InstanceId, InstanceLocation, Currency, UsageQuantity, BillableQuantity, PretaxCost, IsEstimated, MeterId

#$colStats=Import-Csv .\Data.csv | select-object Name, Type, Tags, UsageStart, UsageEnd, BillingPeriodName, InvoiceName, InstanceName, InstanceId, InstanceLocation, Currency, UsageQuantity, BillableQuantity, PretaxCost, IsEstimated, MeterId 
#$UsageStart= (Get-Date).AddDays(-30)
#$UsageEnd= (Get-Date).AddDays(-30)

#$colStats= select Name, Type, Tags, UsageStart , UsageEnd, BillingPeriodName, InvoiceName, InstanceName, InstanceId, InstanceLocation, Currency, UsageQuantity, BillableQuantity, PretaxCost, IsEstimated, MeterId 
#$colStats |Where { (get-date $_.usagestart.split(" ")[0]) -gt (Get-Date).AddDays(-30) }
$colstats = $colStats |Where { (get-date $_.usagestart.split(" ")[0]) -gt (Get-Date).AddDays(-45) } 
#| select usagestart, Name, Type, Tags, UsageEnd, BillingPeriodName, InvoiceName, InstanceName, InstanceId, InstanceLocation, Currency, UsageQuantity, BillableQuantity, PretaxCost, IsEstimated, MeterId 

#$colstats= $colStats |Where { (get-date $_.usagestart.split(" ")[0]) -gt (Get-Date).AddDays(-30) }
[decimal]$thresholdspace2 = 20
[decimal]$thresholdspace2 = 25 
$Date9= get-date


#(Get-Date).AddDays(-60)
foreach ($objBatter in $colStats)
  {

$Name = $objBatter.Name
$Type = $objBatter.Type
$Tags = $objBatter.Tags
$UsageStart = $objBatter.UsageStart
$UsageEnd = $objBatter.UsageEnd
$BillingPeriodName = $objBatter.BillingPeriodName
$InvoiceName = $objBatter.InvoiceName
$InstanceName = $objBatter.InstanceName
$InstanceId = $objBatter.InstanceId 
$InstanceLocation = $objBatter.InstanceLocation
$Currency = $objBatter.Currency
$UsageQuantity = $objBatter.UsageQuantity
$BillableQuantity = $objBatter.BillableQuantity 
$PretaxCost = $objBatter.PretaxCost
$IsEstimated = $objBatter.IsEstimated
$MeterId  = $objBatter.MeterId 
$BillableQuantity = $BillableQuantity

#$Tipco=read-host "Enter the Tipco  $ Value"

 $TipcoValue = [Int]$BillableQuantity

# $NumCPU=read-host "Enter the CPU $ Value"
#$MemoryGB=read-host "Enter the Memory $ Value"
 $TatalM = New-Object System.Object
  $TatalM | Add-Member -type NoteProperty -name Name -value (($objBatter.Name))
  $TatalM | Add-Member -type NoteProperty -name Type -value (($objBatter.Type))
$TatalM | Add-Member -type NoteProperty -name Tags -value (($objBatter.Tags))

$TatalM | Add-Member -type NoteProperty -name UsageStart -value (($objBatter.UsageStart))
  $TatalM | Add-Member -type NoteProperty -name UsageEnd -value (($objBatter.UsageEnd))
$TatalM | Add-Member -type NoteProperty -name InvoiceName -value (($objBatter.InvoiceName))

$TatalM | Add-Member -type NoteProperty -name InstanceName -value (($objBatter.InstanceName))
  $TatalM | Add-Member -type NoteProperty -name InstanceLocation -value (($objBatter.InstanceLocation))
$TatalM | Add-Member -type NoteProperty -name Currency -value (($objBatter.Currency))
$TatalM | Add-Member -type NoteProperty -name Subscriptionid -value (($subscriptionId))

#$subscriptionId

$TatalM | Add-Member -type NoteProperty -name BillableQuantity -value (($objBatter.BillableQuantity))
  $TatalM | Add-Member -type NoteProperty -name PretaxCost -value (($objBatter.PretaxCost))
$TatalM | Add-Member -type NoteProperty -name IsEstimated -value (($objBatter.IsEstimated))
$TatalM | Add-Member -type NoteProperty -name MeterId -value (($objBatter.MeterId))

#$TatalM  | Add-Member -type NoteProperty -name TipcoCost -value (([int] $objBatter.BillableQuantity *2 ))

# ConvertFrom-String $BillableQuantity
$TatalM | Add-Member -type NoteProperty -name UsageQuantity -value (($objBatter.UsageQuantity))
$TatalM = $TatalM  | Add-Member -type NoteProperty -name TipcoCost -value (([float]$UsageQuantity * 7  )) -PassThru
#$TatalM |  Add-Member -type NoteProperty -name TipcoCost -value (( [Math]::Round($1stNum * $UsageQuantity) ))


  #$TatalM  | Add-Member -type NoteProperty -name CPUTotalprice -value (([int] $NumCPU *2 ))
#$TatalM | Add-Member -type NoteProperty -name Memory_GB -value (($objBatter.MemoryGB))
 # $TatalM  | Add-Member -type NoteProperty -name MemoryTotalprice -value (([int] $MemoryGB *2))
      

   

        $Cpuprice += $TatalM
  }




 $Cpuprice  | Sort-Object TipcoCost |Export-Csv -Path ".\Billing.csv" -NoTypeInformation -UseCulture

