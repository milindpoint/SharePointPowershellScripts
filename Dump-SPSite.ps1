[System.Reflection.Assembly]::Load("Microsoft.SharePoint, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c")
[System.Reflection.Assembly]::Load("Microsoft.SharePoint.Portal, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c")
[System.Reflection.Assembly]::Load("Microsoft.SharePoint.Publishing, Version=14.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c")
[System.Reflection.Assembly]::Load("System.Web, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")

function Get-DocInventory([string]$webAppUrlUrl) {

$Sites = Get-SPWebApplication $WebAppUrl | Get-SPSite -Limit All

#$site = New-Object Microsoft.SharePoint.SPSite $siteUrl
foreach($site in $Sites){

Write-Host $site.Url

if($site.Url -like "*<site collection url you want to dump>*")
{

foreach ($web in $site.AllWebs) {
foreach ($list in $web.Lists) {
if ($list.BaseType -ne “DocumentLibrary”) {
continue
}

if($list.Hidden -ne $true)
{

if($list.Title -notlike "Style Library")
{

if($Site.Url -eq "<give site collection url you want to dump. this is for root site>")
{
$path = "C:\Dump\" + $Site.Url.Replace("http://","").Replace("/","\") + "\ROOT\" + $web.Title + "\\" + $list.Title
}
else
{
$path = "C:\Dump\" + $Site.Url.Replace("http://","").Replace("/","\") + "\\" + $web.Title + "\\" + $list.Title
}


Write-Host $path

$loc = New-Item -ItemType Directory -Force -Path $path

foreach ($item in $list.Items) {
$data = @{
"Site" = $site.Url
"Web" = $web.Url
"list" = $list.Title
"Item ID" = $item.ID
"Item URL" = $item.Url
"Item Title" = $item.Title
"Item Created" = $item["Created"]
"Item Modified" = $item["Modified"]
"Created By" = $item["Author"]
"Modified By" = $item["Editor"]
"File Size" = $item.File.Length/1KB
"File Size (MB)" = $item.File.Length/1MB
}

##########Download

#$fromfile = $item.Url
$tofile   = $path + "\" + $item.Url

$file = $web.GetFile($item.Url)

 $binary = $file.OpenBinary()
        $stream = New-Object System.IO.FileStream($path + "/" + $file.Name), Create
        $writer = New-Object System.IO.BinaryWriter($stream)
        $writer.write($binary)
        $writer.Close()

New-Object PSObject -Property $data
}
}
}
$web.Dispose();
}
$site.Dispose()
}
}
}
}

#this script takes web application because with some modifications you can take dump of entire web application on file system.
Get-DocInventory "<provide web application url>" | Out-GridView
