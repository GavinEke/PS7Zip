---
external help file: PS7Zip-help.xml
online version: 
schema: 2.0.0
---

# Get-7Zip

## SYNOPSIS
List contents of a compressed archive file

## SYNTAX

```
Get-7Zip [-FullName] <String>
```

## DESCRIPTION
Use Get-7Zip to list the contents of an archive.

## EXAMPLES

### Example 1
```
Get-7Zip archive.zip
```

List contents of archive.zip in the current working folder

### Example 2
```
Get-7Zip "c:\folder\files.gz"
```

List contents of c:\folder\files.gz

## PARAMETERS

### -FullName
The full path of the compressed archive file.

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

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS

