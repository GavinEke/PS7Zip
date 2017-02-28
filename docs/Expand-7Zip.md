---
external help file: PS7Zip-help.xml
online version: 
schema: 2.0.0
---

# Expand-7Zip

## SYNOPSIS
Extract contents of a compressed archive file

## SYNTAX

```
Expand-7Zip [-FullName] <String> [-Remove <Boolean>]
```

## DESCRIPTION
Use Expand-7Zip to extract the contents of an archive.

## EXAMPLES

### Example 1
```
Expand-7Zip archive.zip
```

Extract contents of archive.zip in the current working folder

### Example 2
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
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Remove
If $True this will remove the compressed version of the file only leaving the uncompressed contents.

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

