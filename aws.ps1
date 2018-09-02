New-Item -ItemType directory -Path "C:\aws1"
$HomeDir = "C:\aws1"
$awsAccessKey = "AKIAIPBS7BNJZ363UVRA"
$awsSecretKey = "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"
$awsIaasPayerAccountId  = "773855076067"



$accessKey = $awsAccessKey
$secretKey = $awsSecretKey
#$bucket = $awsBucket 
$iaasPAId = $awsIaasPayerAccountId



$accountname = read-host "Enter the account name"
$GroupName = read-host "Enter the Group name"


New-IAMUser -Path "/ps-created-users/" -UserName $accountname

Add-IAMUserToGroup -UserName $accountname -GroupName $GroupName

$Neworganisationaccount = read-host "Enter the New-ORGAccount email id"
$accountname = read-host "Enter the account-name name"

aws organizations create-account --email $Neworganisationaccount --account-name $accountname

$AccountId = 224866952355
$ParentId = "r-xs5j"
$ouname = read-host "Enter the Organisation unit name"

$ou = new-orgorganizationalunit -ParentId $ParentId -Name $ouname
$Destinationparentid = $ou.id
Move-ORGAccount -AccountId $AccountId -DestinationParentId $Destinationparentid -SourceParentId r-xs5j


function new-awsVDC {
    [CmdletBinding()]
    param(
        [parameter(mandatory = $true)]
        [string]
        $AccessKey,
        [parameter(mandatory = $true)]
        [string]
        $Secretkey,
        [parameter(mandatory = $true)]
        [string]
        $region,
        [parameter(mandatory = $true)]
        [string]
        $cidr,
        [parameter(mandatory = $true)]
        [string[]]
        $subnetcidr,
        [bool[]]
        $public
    )
    try{
    $vpc = New-ec2vpc -cidrblock $cidr -AccessKey $accesskey -SecretKey $secretkey -Region $region 
    if ($public -contains $true) {
        $igw = New-EC2InternetGateway -Region $region -AccessKey $accesskey -SecretKey $secretkey
        Add-EC2InternetGateway -InternetGatewayId $igw.InternetGatewayId -VpcId $vpc.VpcId -Region $region -AccessKey $accesskey -SecretKey $secretkey
    }
    for ($count = 0; $count -lt $subnetcidr.Count; $count++) {
        $subnet = New-EC2Subnet -VpcId  $vpc.VpcId -CidrBlock $subnetcidr[$count] -Region $region -AccessKey $accesskey -SecretKey $secretkey
        if ($public[$count]) {
           
            $routetable = New-EC2RouteTable -VpcId  $vpc.VpcId -Region $region -AccessKey $accesskey -SecretKey $secretkey 
            New-EC2Route -RouteTableId $routetable.RouteTableId -DestinationCidrBlock 0.0.0.0/0 -GatewayId $igw.InternetGatewayId -AccessKey $accesskey -SecretKey $secretkey -Region $region
            Register-EC2RouteTable -RouteTableId $routetable.RouteTableId -SubnetId $subnet.SubnetId -AccessKey $accesskey -SecretKey $secretkey -Region $region
        }
    }
}
catch{
    $PSCmdlet.WriteError($_)
}
} 


$awsAccessKey = "AKIAIPBS7BNJZ363UVRA"
$awsSecretKey = "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"
$awsIaasPayerAccountId  = "773855076067"

new-awsVDC -AccessKey $awsAccessKey -Secretkey $awsSecretKey -region us-east-1 -cidr 10.0.0.0/16  -subnetcidr 10.0.0.0/24,10.0.1.0/24,10.0.3.0/24,10.0.4.0/24  -public $true,$true,$false,$false

