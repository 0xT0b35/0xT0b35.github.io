## Purpose: Run this in a directory with a markdown file and pics folder and create a new folder with converted markdown and pics
## to be able to upload to a jekyll type blog (https://mademistakes.com/work/jekyll-themes/minimal-mistakes/). 
## It will also create a header. Basically this will make everything ready so that you can just copy over your pics/markdown blog
## post and upload with minor work.

## Created on 09/04/2023


param (

    ## Name/Path of Markdown file to process
    [Parameter(Position=0, Mandatory=$true)]
    [string]$MarkdownFile,

    ## Name/Path of Directory Containing Pictures for Markdown
    ## file, make sure you include the tailing "\"
    [Parameter(Position=0, Mandatory=$true)]
    [string]$PictureDirectory,

    ## Output file name, this will be the directory name
    ## and the new markdown file name (with date added)
    [Parameter(Position=1, Mandatory=$true)]
    [string]$FileName,

    [Parameter(Position=2, Mandatory=$true)]
    [datetime]$TimeDate,

    ## Title of blog post
    [Parameter(Position=3, Mandatory=$true)]
    [string]$Title,

    ## Caption for blog post
    [Parameter(Position=4, Mandatory=$true)]
    [string]$Excerpt,

    ## Comma separted String,
    ## Note: the first item is consider the "primary" catagory
    ## thus it is included in the file name of created md
    [Parameter(Position=5, Mandatory=$true)]
    [string]$Categories,

    ## Comma separted String
    [Parameter(Position=6, Mandatory=$true)]
    [string]$Tags,

    ## Image File Path you want displayed on your blog post (optional)
    [Parameter(Position=7, Mandatory=$false)]
    [string]$Teaser

)

## Create dir structure, if already there, ignore
## _posts, assets/images --> If these already exist, leave them
## Create your assest Dir that will contain your images
## copy over and rename markdown to _posts
## go through your coped markdown and when you hit an image, copy over from image to assests (assets/images/{PROJECT_NAME})
## replace all markdown image links with your new path (assets/images/{PROJECT_NAME})
## Create a header for your new Markdown


## TODO:

# Define the file path
# $filePath = "C:\path\to\your\textfile.txt"

# Read the content of the file
# $content = Get-Content -Path $filePath -Raw

# Define the search pattern using a generic regular expression
# $pattern = '!\[\]\(.*/([^)]+)\)'

# Define the replacement pattern
# $replacement = '![](assests/images/$1)'

# Perform the replacement using regex
# $newContent = $content -replace $pattern, $replacement

# Write the modified content back to the file
# Set-Content -Path $filePath -Value $newContent

# Output a message to confirm completion
# Write-Host "String replacement completed in $filePath"


## Main

$ErrorActionPreference = "Stop"

$postsDir = "$((Get-Location).Path)\_posts"
$assetsDir = "$((Get-Location).Path)\assets\images"
$baseName = $FileName
$postDate = $TimeDate.ToString("yyyy-MM-dd")
$imageDir = "$((Get-Location).Path)\assets\images\$baseName"
$mdImageDir = "/assets/images/$baseName"


## Header Vars
$headerTitle = $Title
$headerExcerpt = $Excerpt
$headerCategories = ($Categories -split ',' | ForEach-Object { "    - $_" }) -join "`n"
## used in the creation of filename for _posts
$topHeaderCategories = ($Categories -split ',')[0]
$headerTags = ($Tags -split ',' | ForEach-Object { "    - $_" }) -join "`n"


Write-Host "<Info>Convert Script"

## Check if Markdown file exists, if not throw

if (Test-Path -Path $MarkdownFile -PathType Leaf) {



}
else {

    throw "<ERROR>Could Not find Markdown File!"

}

## Check if Picture Dir exists, if not throw

if (Test-Path -Path $PictureDirectory -PathType Container) {



}
else {

    throw "<ERROR>Could Not Picture Directory!"

}




## Check if dir exists, this will be checked from root of script, if not, then create dir

## _posts

if (Test-Path -Path $postsDir -PathType Container) {

    Write-Host "<Info>$postsDir Already Found"

}
else {

    [void](New-Item -ItemType Directory -Path $postsDir -Force)

}

## _assets
if (Test-Path -Path $assetsDir -PathType Container) {

    Write-Host "<Info>$assetsDir Already Found"

}
else {

    [void](New-Item -ItemType Directory -Path $assetsDir -Force)

}


## Create your image dir (overwrite if it already exists)

[void](New-Item -ItemType Directory -Path $imageDir -Force)


## Teaser

if ($Teaser) {
    
    $teaserFileName = $($Teaser -split "\\" | Select-Object -Last 1)
    $teaserMoveFilePath = "${mdImageDir}/${teaserFileName}"
    $teaserHomePage = "true"

    if (Test-Path -Path $Teaser -PathType Leaf) {


        [void](Copy-Item -Path $Teaser -Destination $imageDir -Force)
    
    }
    else {
    
        throw "<ERROR>Could Not find Teaser File!"
    
    }
    

} 
else {

    $teaserHomePage = "false"

}


## Create you header

$header = "---
title: `"${headerTitle}`"
date: ${postDate}
layout: single
excerpt: `"${headerExcerpt}`"
classes: wide
header:
  teaser: `"${teaserMoveFilePath}`"
  teaser_home_page: ${teaserHomePage} 
  #icon: `"/assets/images/HTB_Laboratory`"
categories:
${headerCategories}
tags:
${headerTags}
---

"

## Take your markdown file and replace all picture paths with new path in assest

$body = (Get-Content $MarkdownFile -Raw) -replace '(!\[.*\])\(.*(/.*\.png)\)', "`$1($mdImageDir`$2)"

## Write your new Markdown file to new location

Write-Output "${header}${body}" | Set-Content -Path "${postsDir}\${postDate}-${topHeaderCategories}_${baseName}.md"


## Now copy over image files to new location

## This pulls out the ".png" files from the md that are associated with images
## Note, I have to do a "-eq 1" since all match groups return the whole regex find
## at zero and matches above zero. Since for this there is only one match I use 1.
$fileMatches = "$body" | Select-String '!\[.*\]\(.*/(.*\.png)\)' -AllMatches
$fileMatches.Matches.Groups | ForEach-Object {

    if ($_.Name -eq 1) {

        $value = $_.Value
        if (Test-Path -Path "$PictureDirectory$value" -PathType Leaf ) {

            Copy-Item -Path "$PictureDirectory$value" -Destination $imageDir

        } else {
            
            Write-Host "<Warn>Could note find $PictureDirectory$_.Name , thus did not copy"
            
        }

    }

}


Write-Host "<Info>Convert Complete!"
 

