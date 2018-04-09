---
external help file: PS7Zip-help.xml
Module Name: PS7Zip
online version: http://gavineke.com/PS7Zip/Expand-7Zip
schema: 2.0.0
---

# Expand-7Zip

## SYNOPSIS
Extract contents of a compressed archive file

## SYNTAX

```
Expand-7Zip [-FullName] <String> [-Remove]
```

## DESCRIPTION
Use Expand-7Zip to extract the contents of an archive.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Expand-7Zip archive.zip
```

Extract contents of archive.zip in the current working folder

### -------------------------- EXAMPLE 2 --------------------------
```
Expand-7Zip archive.zip -DestinationPath c:\archive
```

Extract contents of archive.zip in the c:\archive folder

### -------------------------- EXAMPLE 3 --------------------------
```
Expand-7Zip "c:\folder\files.gz"
```

Extract contents of c:\folder\files.gz into current working folder

## PARAMETERS

### -FullName
The full path of the compressed archive file.

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DestinationPath
The output directory.

```yaml
Type: String
Parameter Sets: (All)
Aliases: Destination

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Remove
If $True this will remove the compressed version of the file only leaving the uncompressed contents.

```yaml
Type: SwitchParameter
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

[http://gavineke.com/PS7Zip/Expand-7Zip](http://gavineke.com/PS7Zip/Expand-7Zip)

