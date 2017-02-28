---
external help file: PS7Zip-help.xml
online version: 
schema: 2.0.0
---

# Compress-7Zip

## SYNOPSIS
Create a compressed archive of a file or folder

## SYNTAX

```
Compress-7Zip [-FullName] <String> [-OutputFile <String>] [-ArchiveType <String>] [-Remove <Boolean>]
```

## DESCRIPTION
Use Compress-7Zip to create a 7z, gzip, zip, bzip2 or tar archive.

## EXAMPLES

### Example 1
```
Compress-7Zip c:\scripts
```

Create archive.zip in the current working folder of the folder c:\scripts

### Example 2
```
Compress-7Zip "computer inventory.csv" -OutputFile "inventory.gz" -ArchiveType GZIP -Remove $True
```

Create a gzip archive of a single file and delete the uncompressed file

### Example 3
```
Get-ChildItem E:\test | Where {$_.LastWriteTime -lt (Get-Date).AddDays(-5)} | Select -First 1 | Compress-7Zip
```

Create an archive in c:\folder based on pipeline input

## PARAMETERS

### -FullName
The full path of the file or folder you would like turn into a compressed archive.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -OutputFile
The full path of the file to be created.
Defaults to archive.zip in current working directory.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ArchiveType
The type of archive you would like.
Valid types 7Z, GZIP, ZIP, BZIP2, TAR.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Remove
If $True this will remove the uncompressed version of the file or folder only leaving the compressed archive.

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

