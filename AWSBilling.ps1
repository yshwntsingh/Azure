$HomeDir = "/home/ec2-user"
$awsAccessKey = "AKIAILCSPFWSEVVW3QCQ"
$awsSecretKey = "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"
$awsIaasPayerAccountId  = "554256165412"
$awsBucket = "csbbackup"


$accessKey = $awsAccessKey
$secretKey = $awsSecretKey
$bucket = $awsBucket 
$localBillingPath = "$HomeDir\s3Billing"
$iaasPAId = $awsIaasPayerAccountId
get-command -module  AWSPowerShell.NetCore *s3*
#Function to append 0 to month value if the value is less than 10
Function KeyPrefixFormater($month) {
    if($month -lt 10)
    {
        $month = "0"+$month
        return $month
    }else{return $month} 
}

#Function to query AWS S3 Object from the bucket and fetch the queried files onto local
Function S3QueryAndFetch($bucket,$keyPrefix,$accessKey,$secretKey,$storageDirectory) {
    
    $s3Object = Get-S3Object -BucketName $bucket -KeyPrefix $keyPrefix -AccessKey $accessKey -SecretKey $secretKey -EndpointUrl "https://s3-ap-southeast-1.amazonaws.com" -Region ap-southeast-1

    if($s3Object -ne $null)
    {
        foreach($object in $s3Object) {
            $localFileName = $object.Key
	        if ($localFileName -ne '') {
		        $localFilePath = Join-Path $storageDirectory $localFileName
		        Copy-S3Object -BucketName $bucket -Key $object.Key -LocalFile $localFilePath -AccessKey $accessKey -SecretKey $secretKey -EndpointUrl "https://s3-ap-southeast-1.amazonaws.com" -Region ap-southeast-1
	        }
        }
    }
    else{Write-Host "No data found for Key Prefix $keyPrefix" -ForegroundColor Yellow}
}

function ZipFiles( $zipfilename, $sourcedir )
{
   Add-Type -Assembly System.IO.Compression.FileSystem
   $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
   [System.IO.Compression.ZipFile]::CreateFromDirectory($sourcedir,
        $zipfilename, $compressionLevel, $false)
}




Get-ChildItem -Recurse $localBillingPath | Remove-Item -Force
$currentMonth = (Get-Date).Month

$currentYear = (Get-Date).Year

$currentMonth = KeyPrefixFormater($currentMonth);

$billingKeyPrefix = "$iaasPAId-aws-billing-detailed-line-items-$currentYear-$currentMonth.csv"

S3QueryAndFetch $bucket $billingKeyPrefix $accessKey $secretKey $localBillingPath

$zipBillingFiles = Get-ChildItem -Path $localBillingPath  -Filter *.zip
foreach($file in $zipBillingFiles)
{
    Expand-Archive $file.FullName $localBillingPath
}
$zipBillingFiles | Remove-Item


$awsFile = import-csv -Path "$HomeDir\s3Billing\$billingKeyPrefix"
$today = Get-Date -format "yyyy-MM-dd"
$awsFile | Where {
    ($_.UsageStartDate -eq "$($today) 00:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 01:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 02:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 03:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 04:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 05:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 06:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 07:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 08:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 09:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 10:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 11:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 12:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 13:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 14:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 15:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 16:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 17:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 18:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 19:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 20:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 21:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 22:00:00") -or `
    ($_.UsageStartDate -eq "$($today) 23:00:00")
} | Export-Csv -NoTypeInformation -Path $HomeDir\s3Billing\AWSBillingData.csv
