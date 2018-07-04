﻿function Export-Excel {
    <#
        .SYNOPSIS
            Export data to an Excel worksheet.
        .DESCRIPTION
            Export data to an Excel file and where possible try to convert numbers so Excel recognizes them as numbers instead of text. After all. Excel is a spreadsheet program used for number manipulation and calculations. In case the number conversion is not desired, use the parameter '-NoNumberConversion *'.
        .PARAMETER Path
            Path to a new or existing .XLSX file.
        .PARAMETER  ExcelPackage
            An object representing an Excel Package - usually this is returned by specifying -Passthru allowing multiple commands to work on the same Workbook without saving and reloading each time.
        .PARAMETER WorkSheetName
            The name of a sheet within the workbook - "Sheet1" by default.
        .PARAMETER ClearSheet
            If specified Export-Excel will remove any existing worksheet with the selected name. The Default behaviour is to overwrite cells in this sheet as needed (but leaving non-overwritten ones in place).
        .PARAMETER Append
            If specified data will be added to the end of an existing sheet, using the same column headings.
        .PARAMETER TargetData
            Data to insert onto the worksheet - this is often provided from the pipeline.
        .PARAMETER ExcludeProperty
            Specifies properties which may exist in the target data but should not be placed on the worksheet.
        .PARAMETER NoAliasOrScriptPropeties
            Some objects duplicate properties with aliases, or have Script properties which take a long time to return a value and slow the export down, if specified this removes these properties
        .PARAMETER DisplayPropertySet,
            Many (but not all) objects have a hidden property named psStandardmembers with a child property DefaultDisplayPropertySet ; this parameter reduces the properties exported to those in this set.
        .PARAMETER Title
            Text of a title to be placed in Cell A1.
        .PARAMETER TitleBold
            Sets the title in boldface type.
        .PARAMETER TitleSize
            Sets the point size for the title.
        .PARAMETER TitleBackgroundColor
            Sets the cell background color for the title cell.
        .PARAMETER TitleFillPattern
            Sets the fill pattern for the title cell.
        .PARAMETER Password
            Sets password protection on the workbook.
        .PARAMETER IncludePivotTable
            Adds a Pivot table using the data in the worksheet.
        .PARAMETER PivotRows
            Name(s) columns from the spreadhseet which will provide the row name(s) in the pivot table.
        .PARAMETER PivotColumns
            Name(s) columns from the spreadhseet which will provide the Column name(s) in the pivot table.
        .PARAMETER PivotData
            Hash table in the form ColumnName = Average|Count|CountNums|Max|Min|Product|None|StdDev|StdDevP|Sum|Var|VarP to provide the data in the Pivot table.
        .PARAMETER PivotTableDefinition,
            HashTable(s) with Sheet PivotTows, PivotColumns, PivotData, IncludePivotChart and ChartType values to make it easier to specify a definition or multiple Pivots.
        .PARAMETER IncludePivotChart,
             Include a chart with the Pivot table - implies Include Pivot Table.
        .PARAMETER NoLegend
            Exclude the legend from the pivot chart.
        .PARAMETER ShowCategory
            Add category labels to the pivot chart.
        .PARAMETER ShowPercent
            Add Percentage labels to the pivot chart.
        .PARAMETER ConditionalText
            Applies a 'Conditional formatting rule' in Excel on all the cells. When specific conditions are met a rule is triggered.
        .PARAMETER NoNumberConversion
            By default we convert all values to numbers if possible, but this isn't always desirable. NoNumberConversion allows you to add exceptions for the conversion. Wildcards (like '*') are allowed.
        .PARAMETER BoldTopRow
            Makes the top Row boldface.
        .PARAMETER NoHeader
            Does not put field names at the top of columns.
        .PARAMETER RangeName
            Makes the data in the worksheet a named range.
        .PARAMETER TableName
            Makes the data in the worksheet a table with a name applies a style to it. Name must not contain spaces.
        .PARAMETER TableStyle
            Selects the style for the named table - defaults to 'Medium6'.
        .PARAMETER ExcelChartDefinition
            A hash table containing ChartType, Title, NoLegend, ShowCategory, ShowPercent, Yrange, Xrange and SeriesHeader for one or more [non-pivot] charts.
        .PARAMETER HideSheet
            Name(s) of Sheet(s) to hide in the workbook.
        .PARAMETER MoveToStart
            If specified, the worksheet will be moved to the start of the workbook.
            MoveToStart takes precedence over MoveToEnd, Movebefore and MoveAfter if more than one is specified.
        .PARAMETER MoveToEnd
            If specified, the worksheet will be moved to the end of the workbook.
            (This is the default position for newly created sheets, but this can be used to move existing sheets.)
        .PARAMETER MoveBefore
            If specified, the worksheet will be moved before the nominated one (which can be a postion starting from 1, or a name).
            MoveBefore takes precedence over MoveAfter if both are specified.
        .PARAMETER MoveAfter
            If specified, the worksheet will be moved after the nominated one (which can be a postion starting from 1, or a name or *).
            If * is used, the worksheet names will be examined starting with the first one, and the sheet placed after the last sheet which comes before it alphabetically.
        .PARAMETER KillExcel
            Closes Excel - prevents errors writing to the file because Excel has it open.
        .PARAMETER AutoNameRange
            Makes each column a named range.
        .PARAMETER StartRow
            Row to start adding data. 1 by default. Row 1 will contain the title if any. Then headers will appear (Unless -No header is specified) then the data appears.
        .PARAMETER StartColumn
            Column to start adding data - 1 by default.
        .PARAMETER FreezeTopRow
            Freezes headers etc. in the top row.
        .PARAMETER FreezeFirstColumn
            Freezes titles etc. in the left column.
        .PARAMETER FreezeTopRowFirstColumn
             Freezes top row and left column (equivalent to Freeze pane 2,2 ).
        .PARAMETER FreezePane
             Freezes panes at specified coordinates (in the form  RowNumber , ColumnNumber).
        .PARAMETER AutoFilter
            Enables the 'Filter' in Excel on the complete header row. So users can easily sort, filter and/or search the data in the select column from within Excel.
        .PARAMETER AutoSize
            Sizes the width of the Excel column to the maximum width needed to display all the containing data in that cell.
        .PARAMETER Now
            The 'Now' switch is a shortcut that creates automatically a temporary file, enables 'AutoSize', 'AutoFiler' and 'Show', and opens the file immediately.
        .PARAMETER NumberFormat
            Formats all values that can be converted to a number to the format specified.

            Examples:
            # integer (not really needed unless you need to round numbers, Excel will use default cell properties).
            '0'

            # integer without displaying the number 0 in the cell.
            '#'

            # number with 1 decimal place.
            '0.0'

            # number with 2 decimal places.
            '0.00'

            # number with 2 decimal places and thousand separator.
            '#,##0.00'

            # number with 2 decimal places and thousand separator and money symbol.
            '€#,##0.00'

            # percentage (1 = 100%, 0.01 = 1%)
            '0%'

            # Blue color for positive numbers and a red color for negative numbers. All numbers will be proceeded by a dollar sign '$'.
            '[Blue]$#,##0.00;[Red]-$#,##0.00'

        .PARAMETER Show
            Opens the Excel file immediately after creation. Convenient for viewing the results instantly without having to search for the file first.
        .PARAMETER PassThru
            If specified, Export-Excel returns an object representing the Excel package without saving the package first. To save it you need to call the save or Saveas method or send it back to Export-Excel.

        .EXAMPLE
            Get-Process | Export-Excel .\Test.xlsx -show
            Export all the processes to the Excel file 'Test.xlsx' and open the file immediately.

        .EXAMPLE
            $ExcelParams = @{
                Path    = $env:TEMP + '\Excel.xlsx'
                Show    = $true
                Verbose = $true
            }
            Remove-Item -Path $ExcelParams.Path -Force -EA Ignore
            Write-Output -1 668 34 777 860 -0.5 119 -0.1 234 788 |
                Export-Excel @ExcelParams -NumberFormat '[Blue]$#,##0.00;[Red]-$#,##0.00'

            Exports all data to the Excel file 'Excel.xslx' and colors the negative values in 'Red' and the positive values in 'Blue'. It will also add a dollar sign '$' in front of the rounded numbers to two decimal characters behind the comma.

        .EXAMPLE
            $ExcelParams = @{
                Path    = $env:TEMP + '\Excel.xlsx'
                Show    = $true
                Verbose = $true
            }
            Remove-Item -Path $ExcelParams.Path -Force -EA Ignore
            [PSCustOmobject][Ordered]@{
                Date      = Get-Date
                Formula1  = '=SUM(F2:G2)'
                String1   = 'My String'
                String2   = 'a'
                IPAddress = '10.10.25.5'
                Number1   = '07670'
                Number2   = '0,26'
                Number3   = '1.555,83'
                Number4   = '1.2'
                Number5   = '-31'
                PhoneNr1  = '+32 44'
                PhoneNr2  = '+32 4 4444 444'
                PhoneNr3  =  '+3244444444'
            } | Export-Excel @ExcelParams -NoNumberConversion IPAddress, Number1

            Exports all data to the Excel file 'Excel.xslx' and tries to convert all values to numbers where possible except for 'IPAddress' and 'Number1'. These are stored in the sheet 'as is', without being converted to a number.

        .EXAMPLE
            $ExcelParams = @{
                Path    = $env:TEMP + '\Excel.xlsx'
                Show    = $true
                Verbose = $true
            }
            Remove-Item -Path $ExcelParams.Path -Force -EA Ignore
            [PSCustOmobject][Ordered]@{
                Date      = Get-Date
                Formula1  = '=SUM(F2:G2)'
                String1   = 'My String'
                String2   = 'a'
                IPAddress = '10.10.25.5'
                Number1   = '07670'
                Number2   = '0,26'
                Number3   = '1.555,83'
                Number4   = '1.2'
                Number5   = '-31'
                PhoneNr1  = '+32 44'
                PhoneNr2  = '+32 4 4444 444'
                PhoneNr3  =  '+3244444444'
            } | Export-Excel @ExcelParams -NoNumberConversion *

            Exports all data to the Excel file 'Excel.xslx' as is, no number conversion will take place. This means that Excel will show the exact same data that you handed over to the 'Export-Excel' function.

        .EXAMPLE
            $ExcelParams = @{
                Path    = $env:TEMP + '\Excel.xlsx'
                Show    = $true
                Verbose = $true
            }
            Remove-Item -Path $ExcelParams.Path -Force -EA Ignore
            Write-Output 489 668 299 777 860 151 119 497 234 788 |
                Export-Excel @ExcelParams -ConditionalText $(
                    New-ConditionalText -ConditionalType GreaterThan 525 -ConditionalTextColor DarkRed -BackgroundColor LightPink
                )

            Exports data that will have a 'Conditional formatting rule' in Excel on these cells that will show the background fill color in 'LightPink' and the text color in 'DarkRed' when the value is greater then '525'. In case this condition is not met the color will be the default, black text on a white background.

        .EXAMPLE
            $ExcelParams = @{
                Path    = $env:TEMP + '\Excel.xlsx'
                Show    = $true
                Verbose = $true
            }
            Remove-Item -Path $ExcelParams.Path -Force -EA Ignore
            Get-Service | Select Name, Status, DisplayName, ServiceName |
                Export-Excel @ExcelParams -ConditionalText $(
                    New-ConditionalText Stop DarkRed LightPink
                    New-ConditionalText Running Blue Cyan
                )

            Export all services to an Excel sheet where all cells have a 'Conditional formatting rule' in Excel that will show the background fill color in 'LightPink' and the text color in 'DarkRed' when the value contains the word 'Stop'. If the value contains the word 'Running' it will have a background fill color in 'Cyan' and a text color 'Blue'. In case none of these conditions are met the color will be the default, black text on a white background.

        .EXAMPLE
            $ExcelParams = @{
                Path      = $env:TEMP + '\Excel.xlsx'
                Show      = $true
                Verbose   = $true
            }
            Remove-Item -Path $ExcelParams.Path -Force -EA Ignore

            $Array = @()

            $Obj1 = [PSCustomObject]@{
                Member1   = 'First'
                Member2   = 'Second'
            }

            $Obj2 = [PSCustomObject]@{
                Member1   = 'First'
                Member2   = 'Second'
                Member3   = 'Third'
            }

            $Obj3 = [PSCustomObject]@{
                Member1   = 'First'
                Member2   = 'Second'
                Member3   = 'Third'
                Member4   = 'Fourth'
            }

            $Array = $Obj1, $Obj2, $Obj3
            $Array | Out-GridView -Title 'Not showing Member3 and Member4'
            $Array | Update-FirstObjectProperties | Export-Excel @ExcelParams -WorkSheetname Numbers

            Updates the first object of the array by adding property 'Member3' and 'Member4'. Afterwards. all objects are exported to an Excel file and all column headers are visible.

        .EXAMPLE
            Get-Process | Export-Excel .\test.xlsx -WorkSheetname Processes -IncludePivotTable -Show -PivotRows Company -PivotData PM

        .EXAMPLE
            Get-Process | Export-Excel .\test.xlsx -WorkSheetname Processes -ChartType PieExploded3D -IncludePivotChart -IncludePivotTable -Show -PivotRows Company -PivotData PM

        .EXAMPLE
            Get-Service | Export-Excel 'c:\temp\test.xlsx'  -Show -IncludePivotTable -PivotRows status -PivotData @{status='count'}

        .EXAMPLE
            $pt = [ordered]@{}
            $pt.pt1=@{ SourceWorkSheet   = 'Sheet1';
                       PivotRows         = 'Status'
                       PivotData         = @{'Status'='count'}
                       IncludePivotChart = $true
                       ChartType         = 'BarClustered3D'
            }
            $pt.pt2=@{ SourceWorkSheet   = 'Sheet2';
                       PivotRows         = 'Company'
                       PivotData         = @{'Company'='count'}
                       IncludePivotChart = $true
                       ChartType         = 'PieExploded3D'
            }
            Remove-Item  -Path .\test.xlsx
            Get-Service | Select-Object    -Property Status,Name,DisplayName,StartType | Export-Excel -Path .\test.xlsx -AutoSize
            Get-Process | Select-Object    -Property Name,Company,Handles,CPU,VM       | Export-Excel -Path .\test.xlsx -AutoSize -WorkSheetname 'sheet2'
            Export-Excel -Path .\test.xlsx -PivotTableDefinition $pt -Show

            This example defines two pivot tables. Then it puts Service data on Sheet1 with one call to Export-Excel and Process Data on sheet2 with a second call to Export-Excel.
            The thrid and final call adds the two pivot tables and opens the spreadsheet in Excel.


        .EXAMPLE
            Remove-Item  -Path .\test.xlsx
            $excel = Get-Service | Select-Object -Property Status,Name,DisplayName,StartType | Export-Excel -Path .\test.xlsx -PassThru
            $excel.Workbook.Worksheets["Sheet1"].Row(1).style.font.bold = $true
            $excel.Workbook.Worksheets["Sheet1"].Column(3 ).width = 29
            $excel.Workbook.Worksheets["Sheet1"].Column(3 ).Style.wraptext = $true
            $excel.Save()
            $excel.Dispose()
            Start-Process .\test.xlsx

            This example uses -passthrough - put service information into sheet1 of the work book and saves the excelPackageObject in $Excel.
            It then uses the package object to apply formatting, and then saves the workbook and disposes of the object before loading the document in Excel.

        .EXAMPLE
            Remove-Item -Path .\test.xlsx -ErrorAction Ignore

            $excel = Get-Process | Select-Object -Property Name,Company,Handles,CPU,PM,NPM,WS | Export-Excel -Path .\test.xlsx -ClearSheet -WorkSheetname "Processes" -PassThru
            $sheet = $excel.Workbook.Worksheets["Processes"]
            $sheet.Column(1) | Set-Format -Bold -AutoFit
            $sheet.Column(2) | Set-Format -Width 29 -WrapText
            $sheet.Column(3) | Set-Format -HorizontalAlignment Right -NFormat "#,###"
            Set-Format -Address $sheet.Cells["E1:H1048576"]  -HorizontalAlignment Right -NFormat "#,###"
            Set-Format -Address $sheet.Column(4)  -HorizontalAlignment Right -NFormat "#,##0.0" -Bold
            Set-Format -Address $sheet.Row(1) -Bold -HorizontalAlignment Center
            Add-ConditionalFormatting -WorkSheet $sheet -Range "D2:D1048576" -DataBarColor Red
            Add-ConditionalFormatting -WorkSheet $sheet -Range "G2:G1048576" -RuleType GreaterThan -ConditionValue "104857600" -ForeGroundColor Red
            foreach ($c in 5..9) {Set-Format -Address $sheet.Column($c)  -AutoFit }
            Export-Excel -ExcelPackage $excel -WorkSheetname "Processes" -IncludePivotChart -ChartType ColumnClustered -NoLegend -PivotRows company  -PivotData @{'Name'='Count'}  -Show

            This a more sophisticated version of the previous example showing different ways of using Set-Format, and also adding conditional formatting.
            In the final command a Pivot chart is added and the workbook is opened in Excel.

        .LINK
            https://github.com/dfinke/ImportExcel
    #>

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingPlainTextForPassword", "")]
    Param(
        [Parameter(ParameterSetName = "Default", Position = 0)]
        [Parameter(ParameterSetName = "Table"  , Position = 0)]
        [String]$Path,
        [Parameter(Mandatory = $true, ParameterSetName = "PackageDefault")]
        [Parameter(Mandatory = $true, ParameterSetName = "PackageTable")]
        [OfficeOpenXml.ExcelPackage]$ExcelPackage,
        [Parameter(ValueFromPipeline = $true)]
        $TargetData,
        [Switch]$Show,
        [String]$WorkSheetname = 'Sheet1',
        [String]$Password,
        [switch]$ClearSheet,
        [switch]$Append,
        [String]$Title,
        [OfficeOpenXml.Style.ExcelFillStyle]$TitleFillPattern = 'None',
        [Switch]$TitleBold,
        [Int]$TitleSize = 22,
        [System.Drawing.Color]$TitleBackgroundColor,
        [Switch]$IncludePivotTable,
		[String]$PivotTableName,
        [String[]]$PivotRows,
        [String[]]$PivotColumns,
        $PivotData,
        [String[]]$PivotFilter,
        [Switch]$PivotDataToColumn,
        [Hashtable]$PivotTableDefinition,
        [Switch]$IncludePivotChart,
        [OfficeOpenXml.Drawing.Chart.eChartType]$ChartType = 'Pie',
        [Switch]$NoLegend,
        [Switch]$ShowCategory,
        [Switch]$ShowPercent,
        [Switch]$AutoSize,
        [Switch]$NoClobber,
        [Switch]$FreezeTopRow,
        [Switch]$FreezeFirstColumn,
        [Switch]$FreezeTopRowFirstColumn,
        [Int[]]$FreezePane,
        [Parameter(ParameterSetName = 'Default')]
        [Parameter(ParameterSetName = 'PackageDefault')]
        [Switch]$AutoFilter,
        [Switch]$BoldTopRow,
        [Switch]$NoHeader,
        [ValidateScript( {
                if (-not $_) {  throw 'RangeName is null or empty.'  }
                elseif ($_[0] -notmatch '[a-z]') { throw 'RangeName starts with an invalid character.'  }
                else { $true }
            })]
        [String]$RangeName,
        [ValidateScript( {
                if (-not $_) {  throw 'Tablename is null or empty.'  }
                elseif ($_[0] -notmatch '[a-z]') { throw 'Tablename starts with an invalid character.'  }
                else { $true }
            })]
        [Parameter(ParameterSetName = 'Table'        , Mandatory = $true)]
        [Parameter(ParameterSetName = 'PackageTable' , Mandatory = $true)]
        [String]$TableName,
        [Parameter(ParameterSetName = 'Table')]
        [Parameter(ParameterSetName = 'PackageTable')]
        [OfficeOpenXml.Table.TableStyles]$TableStyle = 'Medium6',
        [Object[]]$ExcelChartDefinition,
        [String[]]$HideSheet,
        [Switch]$MoveToStart,
        [Switch]$MoveToEnd,
        $MoveBefore ,
        $MoveAfter ,
        [Switch]$KillExcel,
        [Switch]$AutoNameRange,
        [Int]$StartRow = 1,
        [Int]$StartColumn = 1,
        [Switch]$PassThru,
        [String]$Numberformat = 'General',
        [string[]]$ExcludeProperty,
        [Switch]$NoAliasOrScriptPropeties,
        [Switch]$DisplayPropertySet,
        [String[]]$NoNumberConversion,
        [Object[]]$ConditionalFormat,
        [Object[]]$ConditionalText,
        [ScriptBlock]$CellStyleSB,
        [Parameter(ParameterSetName = 'Now')]
        [Switch]$Now,
        [Switch]$ReturnRange,
        [Switch]$NoTotalsInPivot,
        [Switch]$ReZip
    )

    Begin {
        function Add-CellValue {
            <#
              .SYNOPSIS
                Save a value in an Excel cell.

              .DESCRIPTION
                DateTime objects are always converted to a short DateTime format in Excel. When Excel loads the file,
                it applies the local format for dates. And formulas are always saved as formulas. URIs are set as hyperlinks in the file.

                Numerical values will be converted to numbers as defined in the regional settings of the local
                system. In case the parameter 'NoNumberConversion' is used, we don't convert to number and leave
                the value 'as is'. In case of conversion failure, we also leave the value 'as is'.
            #>

            Param (
                [Object]$TargetCell,
                [Object]$CellValue
            )
            #The write-verbose commands have been commented out below - even if verbose is silenced they cause a significiant performance impact and if it's on they will cause a flood of messages.
            Switch ($CellValue) {
                { $_ -is [DateTime]} {
                    # Save a date with an international valid format
                    $TargetCell.Value = $_
                    $TargetCell.Style.Numberformat.Format = 'm/d/yy h:mm' # This is not a custom format, but a preset recognized as date and localized.
                    #Write-Verbose  "Cell '$Row`:$ColumnIndex' header '$Name' add value '$_' as date"
                    break

                }
                { $_ -is [System.ValueType]} {
                    # Save numerics, setting format if need be.
                    $TargetCell.Value = $_
                    if ($setNumformat) {$targetCell.Style.Numberformat.Format = $Numberformat }
                    #Write-Verbose  "Cell '$Row`:$ColumnIndex' header '$Name' add value '$_' as value"
                    break
                }

                {(($NoNumberConversion) -and ($NoNumberConversion -contains $Name)) -or
                    ($NoNumberConversion -eq '*')} {
                    #Save text without it to converting to number
                    $TargetCell.Value = $_
                    #Write-Verbose "Cell '$Row`:$ColumnIndex' header '$Name' add value '$($TargetCell.Value)' unconverted"
                    break
                }
                {($_ -is [String]) -and ($_[0] -eq '=')} {
                    #region Save an Excel formula
                    $TargetCell.Formula = $_
                    #Write-Verbose  "Cell '$Row`:$ColumnIndex' header '$Name' add value '$_' as formula"
                    break
                }
                { $_ -is [Uri] } {
                    # Save a hyperlink
                    $TargetCell.Value = $_.AbsoluteUri
                    $TargetCell.HyperLink = $_
                    $TargetCell.Style.Font.Color.SetColor([System.Drawing.Color]::Blue)
                    $TargetCell.Style.Font.UnderLine = $true
                    #Write-Verbose  "Cell '$Row`:$ColumnIndex' header '$Name' add value '$($_.AbsoluteUri)' as Hyperlink"
                    break
                }

                Default {
                    #Save a value as a number if possible
                    $number = $null
                    if ([Double]::TryParse( $_ , [ref]$number)) {
                        #was  [Double]::TryParse([String]$_, [System.Globalization.NumberStyles]::Any,[System.Globalization.NumberFormatInfo]::CurrentInfo, [Ref]$number)) {
                        $TargetCell.Value = $number
                        if ($setNumformat) {$targetCell.Style.Numberformat.Format = $Numberformat }
                        #Write-Verbose  "Cell '$Row`:$ColumnIndex' header '$Name' add value '$($TargetCell.Value)' as number converted from '$_' with format '$Numberformat'"
                    }
                    else {
                        $TargetCell.Value = $_
                        #Write-Verbose "Cell '$Row`:$ColumnIndex' header '$Name' add value '$($TargetCell.Value)' as string"
                    }
                    break
                }
            }
        }

        Try {
            $script:Header = $null
            if ($Append -and $ClearSheet) {throw "You can't use -Append AND -ClearSheet."}

            if ($PSBoundParameters.Keys.Count -eq 0 -Or $Now) {
                $Path = [System.IO.Path]::GetTempFileName() -replace '\.tmp', '.xlsx'
                $Show = $true
                $AutoSize = $true
                if (!$TableName) {
                    $AutoFilter = $true
                }
            }

            if ($ExcelPackage) {
                $pkg = $ExcelPackage
                $Path = $pkg.File
            }
            Else { $pkg = Open-ExcelPackage -Path $Path -Create -KillExcel:$KillExcel}

            $params = @{}
            if ($NoClobber) {Write-Warning -Message "-NoClobber parameter is no longer used" }
            foreach ($p in @("WorkSheetname", "ClearSheet", "MoveToStart", "MoveToEnd", "MoveBefore", "MoveAfter")) {if ($PSBoundParameters[$p]) {$params[$p] = $PSBoundParameters[$p]}}
            $ws = $pkg | Add-WorkSheet @params

            foreach ($format in $ConditionalFormat ) {
                $target = "Add$($format.Formatter)"
                $rule = ($ws.ConditionalFormatting).PSObject.Methods[$target].Invoke($format.Range, $format.IconType)
                $rule.Reverse = $format.Reverse
            }

            if ($append -and $ws.Dimension) {
                #if there is a title or anything else above the header row, append needs to be combined wih a suitable startrow parameter
                $headerRange = $ws.Dimension.Address -replace "\d+$", $StartRow
                #using a slightly odd syntax otherwise header ends up as a 2D array
                $ws.Cells[$headerRange].Value | ForEach-Object -Begin {$Script:header = @()} -Process {$Script:header += $_ }
                $row = $ws.Dimension.End.Row
                Write-Debug -Message ("Appending: headers are " + ($script:Header -join ", ") + " Start row is $row")
            }
            elseif ($Title) {
                #Can only add a title if not appending!
                $Row = $StartRow
                $ws.Cells[$Row, $StartColumn].Value = $Title
                $ws.Cells[$Row, $StartColumn].Style.Font.Size = $TitleSize

                if ($TitleBold) {
                    #Set title to Bold face font if -TitleBold was specified.
                    #Otherwise the default will be unbolded.
                    $ws.Cells[$Row, $StartColumn].Style.Font.Bold = $True
                }
                #Can only set TitleBackgroundColor if TitleFillPattern is something other than None.
                if ($TitleBackgroundColor -and ($TitleFillPattern -ne 'None')) {
                    $TitleFillPattern = [OfficeOpenXml.Style.ExcelFillStyle]::Solid
                }
                $ws.Cells[$Row, $StartColumn].Style.Fill.PatternType = $TitleFillPattern

                if ($TitleBackgroundColor ) {
                    $ws.Cells[$Row, $StartColumn].Style.Fill.BackgroundColor.SetColor($TitleBackgroundColor)
                }
                $Row ++ ; $startRow ++
            }
            else {  $Row = $StartRow }
            $ColumnIndex = $StartColumn
            $setNumformat = ($numberformat -ne $ws.Cells.Style.Numberformat.Format)

            $firstTimeThru = $true
            $isDataTypeValueType = $false
        }
        Catch {
            if ($AlreadyExists) {
                #Is this set anywhere ?
                throw "Failed exporting worksheet '$WorkSheetname' to '$Path': The worksheet '$WorkSheetname' already exists."
            }
            else {
                throw "Failed preparing to export to worksheet '$WorkSheetname' to '$Path': $_"
            }
        }
    }

    Process {
        if ($TargetData) {
            Try {
                if ($firstTimeThru) {
                    $firstTimeThru = $false
                    $isDataTypeValueType = $TargetData.GetType().name -match 'string|bool|byte|char|decimal|double|float|int|long|sbyte|short|uint|ulong|ushort'
                    Write-Debug "DataTypeName is '$($TargetData.GetType().name)' isDataTypeValueType '$isDataTypeValueType'"
                }

                if ($isDataTypeValueType) {
                    $ColumnIndex = $StartColumn

                    Add-CellValue -TargetCell $ws.Cells[$Row, $ColumnIndex] -CellValue $TargetData

                    $Row += 1
                }
                else {
                    #region Add headers
                    if (-not $script:Header) {
                        $ColumnIndex = $StartColumn
                        if ($DisplayPropertySet -and $TargetData.psStandardmembers.DefaultDisplayPropertySet.ReferencedPropertyNames) {
                            $script:Header = $TargetData.psStandardmembers.DefaultDisplayPropertySet.ReferencedPropertyNames.Where( {$_ -notin $ExcludeProperty})
                        }
                        else {
                            if ($NoAliasOrScriptPropeties) {$propType = "Property"} else {$propType = "*"}
                            $script:Header = $TargetData.PSObject.Properties.where( {$_.MemberType -like $propType -and $_.Name -notin $ExcludeProperty}).Name
                        }
                        if ($NoHeader) {
                            # Don't push the headers to the spreadsheet
                            $Row -= 1
                        }
                        else {
                            foreach ($Name in $script:Header) {
                                $ws.Cells[$Row, $ColumnIndex].Value = $Name
                                Write-Verbose "Cell '$Row`:$ColumnIndex' add header '$Name'"
                                $ColumnIndex += 1
                            }
                        }
                    }
                    #endregion

                    $Row += 1
                    $ColumnIndex = $StartColumn

                    foreach ($Name in $script:Header) {
                        #region Add non header values
                        Add-CellValue -TargetCell $ws.Cells[$Row, $ColumnIndex] -CellValue $TargetData.$Name

                        $ColumnIndex += 1
                        #endregion
                    }
                }
            }
            Catch {
                throw "Failed exporting data to worksheet '$WorkSheetname' to '$Path': $_"
            }
        }
    }

    End {
        if ($AutoNameRange) {
            Try {
                if (-not $script:header) {
                    # if there aren't any headers, use the the first row of data to name the ranges: this is the last point that headers will be used.
                    $headerRange = $ws.Dimension.Address -replace "\d+$", $StartRow
                    #using a slightly odd syntax otherwise header ends up as a 2D array
                    $ws.Cells[$headerRange].Value | ForEach-Object -Begin {$Script:header = @()} -Process {$Script:header += $_ }
                    #if there is no header start the range at $startRow
                    $targetRow = $StartRow
                }
                else {
                    #if there is a header, start the range and the next row down.
                    $targetRow = $StartRow + 1
                }

                #Dimension.start.row always seems to be one so we work out the target row
                #, but start.column is the first populated one and .Columns is the count of populated ones.
                # if we have 5 columns from 3 to 8, headers are numbered 0..4, so that is in the for loop and used for getting the name...
                # but we have to add the start column on when referencing positions
                foreach ($c in 0..($ws.Dimension.Columns - 1)) {
                    $targetRangeName = $script:Header[$c] -replace '\W' , '_'
                    $targetColumn = $c + $StartColumn
                    $theRange = $ws.Cells[$targetRow, $targetColumn, $ws.Dimension.End.Row , $targetColumn ]
                    if ($ws.names[$targetRangeName]) { $ws.names[$targetRangeName].Address = $theRange.FullAddressAbsolute }
                    else {$ws.Names.Add($targetRangeName, $theRange) | Out-Null }

                    if ([OfficeOpenXml.FormulaParsing.ExcelUtilities.ExcelAddressUtil]::IsValidAddress($targetRangeName)) {
                        Write-Warning "AutoNameRange: Property name '$targetRangeName' is also a valid Excel address and may cause issues. Consider renaming the property name."
                    }
                }
            }
            Catch {Write-Warning -Message "Failed adding named ranges to worksheet '$WorkSheetname': $_"  }
        }
        try {
            if ($Title) {
                $startAddress = $ws.Dimension.Start.address -replace "$($ws.Dimension.Start.row)`$", "$($ws.Dimension.Start.row + 1)"
            }
            else {
                $startAddress = $ws.Dimension.Start.Address
            }

            $dataRange = "{0}:{1}" -f $startAddress, $ws.Dimension.End.Address

            Write-Debug "Data Range '$dataRange'"

            if (-not [String]::IsNullOrEmpty($RangeName)) {
                if ($RangeName -match "\W") {
                    Write-Warning -Message "At least one character in $RangeName is illegal in a range name and will be replaced with '_' . "
                    $RangeName = $RangeName -replace '\W', '_'
                }
                #If named range exists, update it, else create it
                if ($ws.Names[$RangeName]) { $ws.Names[$rangename].Address = $ws.Cells[$dataRange].FullAddressAbsolute }
                else {$ws.Names.Add($RangeName, $ws.Cells[$0ange]) | Out-Null }
            }
        }
        Catch { Write-Warning -Message "Failed adding range '$RangeName' to worksheet '$WorkSheetname': $_"   }
        if (-not [String]::IsNullOrEmpty($TableName)) {
            try {
                $csr = $StartRow

                $csc = $StartColumn
                $cer = $ws.Dimension.End.Row
                $cec = $ws.Dimension.End.Column # was $script:Header.Count
                if ($TableName -match "\W") {
                    Write-Warning -Message "At least one character in $TableName is illegal in a table name and will be replaced with '_' . "
                    $TableName = $TableName -replace '\W', '_'
                }
                $targetRange = $ws.Cells[$csr, $csc, $cer, $cec]
                #if the table exists, update it.
                if ($ws.Tables[$TableName]) {
                    $ws.Tables[$TableName].TableXml.table.ref = $targetRange.Address
                    $ws.Tables[$TableName].TableStyle = $TableStyle
                }
                else {
                    $tbl = $ws.Tables.Add($targetRange, $TableName)
                    $tbl.TableStyle = $TableStyle
                }
                Write-Verbose -Message "Defined table '$TableName' at $($targetRange.Address)"
            }
            catch {Write-Warning -Message "Failed adding table '$TableName' to worksheet '$WorkSheetname': $_"}
        }
        if ($PivotTableDefinition) {
            foreach ($item in $PivotTableDefinition.GetEnumerator()) {
                $params = $item.value
                if ($params.keys -notcontains "SourceRange" -and
                    ($params.Keys -notcontains "SourceWorkSheet" -or $params.SourceWorkSheet -eq $WorkSheetname)) {$params.SourceRange = $dataRange}
                if ($params.Keys -notcontains "SourceWorkSheet") {$params.SourceWorkSheet = $ws }
                if ($params.Keys -notcontains "NoTotalsInPivot" -and $NoTotalsInPivot    ) {$params.NoTotalsInPivot = $true}
                if ($params.Keys -notcontains "PivotDataToColumn" -and $PivotDataToColumn) {$params.PivotDataToColumn = $true}

                Add-PivotTable -ExcelPackage $pkg -PivotTableName $item.key @Params
            }
        }
        if ($IncludePivotTable -or $IncludePivotChart) {
            $params = @{
                "SourceRange"    = $dataRange
            }
			if ($PivotTableName)    {$params.PivotTableName    = $PivotTableName}
			else                    {$params.PivotTableName    = $WorkSheetname + 'PivotTable'}
            if ($PivotFilter)       {$params.PivotFilter       = $PivotFilter}
            if ($PivotRows)         {$params.PivotRows         = $PivotRows}
            if ($PivotColumns)      {$Params.PivotColumns      = $PivotColumns}
            if ($PivotData)         {$Params.PivotData         = $PivotData}
            if ($NoTotalsInPivot)   {$params.NoTotalsInPivot   = $true}
            if ($PivotDataToColumn) {$params.PivotDataToColumn = $true}
            if ($IncludePivotChart) {
                $params.IncludePivotChart = $true
                $Params.ChartType =  $ChartType
                if ($ShowCategory)  {$params.ShowCategory = $true}
                if ($ShowPercent)   {$params.ShowPercent = $true}
                if ($NoLegend)      {$params.NoLegend = $true}
            }
            Add-PivotTable -ExcelPackage $pkg -SourceWorkSheet $ws   @params
        }

        if ($AutoFilter) {
            try {
                $ws.Cells[$dataRange].AutoFilter = $true
                Write-Verbose -Message "Enabeld autofilter. "
            }
            catch {Write-Warning -Message "Failed adding autofilter to worksheet '$WorkSheetname': $_"}
        }

        try {
            if ($FreezeTopRow) {
                $ws.View.FreezePanes(2, 1)
                Write-Verbose -Message "Froze top row"
            }

            if ($FreezeTopRowFirstColumn) {
                $ws.View.FreezePanes(2, 2)
                Write-Verbose -Message "Froze top row and first column"
            }

            if ($FreezeFirstColumn) {
                $ws.View.FreezePanes(1, 2)
                Write-Verbose -Message "Froze first column"
            }

            if ($FreezePane) {
                $freezeRow, $freezeColumn = $FreezePane
                if (-not $freezeColumn -or $freezeColumn -eq 0) {
                    $freezeColumn = 1
                }

                if ($freezeRow -gt 1) {
                    $ws.View.FreezePanes($freezeRow, $freezeColumn)
                    Write-Verbose -Message "Froze pandes at row $freezeRow and column $FreezeColumn"
                }
            }
        }
        catch {Write-Warning -Message "Failed adding Freezing the panes in worksheet '$WorkSheetname': $_"}

        if ($BoldTopRow) {
            try {
                if ($Title) {
                    $range = $ws.Dimension.Address -replace '\d+', ($StartRow + 1)
                }
                else {
                    $range = $ws.Dimension.Address -replace '\d+', $StartRow
                }
                $ws.Cells[$range].Style.Font.Bold = $true
                Write-Verbose -Message "Set $range font style to bold."
            }
            catch {Write-Warning -Message "Failed setting the top row to bold in worksheet '$WorkSheetname': $_"}
        }
        if ($AutoSize) {
            try {
                $ws.Cells.AutoFitColumns()
                Write-Verbose -Message "Auto-sized columns"
            }
            catch {  Write-Warning -Message "Failed autosizing columns of worksheet '$WorkSheetname': $_"}
        }

        foreach ($Sheet in $HideSheet) {
            try {
                $pkg.Workbook.WorkSheets[$Sheet].Hidden = 'Hidden'
                Write-verbose -Message "Sheet '$sheet' Hidden."
            }
            catch {Write-Warning -Message  "Failed hiding worksheet '$sheet': $_"}
        }

        foreach ($chartDef in $ExcelChartDefinition) {
            $params = @{}
            $chartDef.PSObject.Properties | ForEach-Object {if ($_.value -ne $null) {$params[$_.name] = $_.value}}
            Add-ExcelChart @params
        }

        foreach ($ct in $ConditionalText) {
            try {
                $cfParams = @{RuleType = $ct.ConditionalType; ConditionValue = $ct.text ;
                    BackgroundColor = $ct.BackgroundColor; BackgroundPattern = $ct.PatternType  ;
                    ForeGroundColor = $ct.ConditionalTextColor
                }
                if ($ct.Range) {$cfParams.range = $ct.range} else { $cfParams.Range = $ws.Dimension.Address }
                Add-ConditionalFormatting -WorkSheet $ws @cfParams
                Write-Verbose -Message "Added conditional formatting to range $($ct.range)"
            }
            catch {Write-Warning -Message "Failed adding conditional formatting to worksheet '$WorkSheetname': $_"}
        }

        if ($CellStyleSB) {
            try {
                $TotalRows  =  $ws.Dimension.Rows
                $LastColumn =  $ws.Dimension.Address -replace "^.*:(\w*)\d+$" , '$1'
                & $CellStyleSB $ws $TotalRows $LastColumn
            }
            catch {Write-Warning -Message "Failed processing CellStyleSB in worksheet '$WorkSheetname': $_"}
        }

        if ($Password) {
            try {
                $ws.Protection.SetPassword($Password)
                Write-Verbose -Message "Set password on workbook"
            }

            catch {throw "Failed setting password for worksheet '$WorkSheetname': $_"}
        }

        if ($PassThru) {       $pkg   }
        else {
            if ($ReturnRange) {$ws.Dimension.Address }

            $pkg.Save()
            Write-Verbose -Message "Saved workbook $($pkg.File)"
            if ($ReZip) {
                Write-Verbose -Message "Re-Zipping $($pkg.file) using .NET ZIP library"
                try {
                    Add-Type -AssemblyName "System.IO.Compression.Filesystem" -ErrorAction stop
                }
                catch {
                    Write-Error "The -ReZip parameter requires .NET Framework 4.5 or later to be installed. Recommend to install Powershell v4+"
                    continue
                }
                try {
                    $TempZipPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.IO.Path]::GetRandomFileName())
                    [io.compression.zipfile]::ExtractToDirectory($pkg.File, $TempZipPath)   | Out-Null
                    Remove-Item $pkg.File -Force
                    [io.compression.zipfile]::CreateFromDirectory($TempZipPath, $pkg.File) | Out-Null
                }
                catch {throw "Error resizipping $path : $_"}
            }

            $pkg.Dispose()

            if ($Show) { Invoke-Item $Path }
        }

    }
}

function New-PivotTableDefinition {
    <#
      .Synopsis
        Creates Pivot table definitons for export excel
      .Description
        Export-Excel allows a single Pivot table to be defined using the parameters -IncludePivotTable, -PivotColumns -PivotRows,
        =PivotData, -PivotFilter, -NoTotalsInPivot, -PivotDataToColumn, -IncludePivotChart and -ChartType.
        Its -PivotTableDefintion paramater allows multiple pivot tables to be defined, with additional parameters.
        New-PivotTableDefinition is a convenient way to build these definitions.
      .Example
        $pt  = New-PivotTableDefinition -PivotTableName "PT1" -SourceWorkSheet "Sheet1" -PivotRows "Status"  -PivotData @{Status='Count' } -PivotFilter 'StartType' -IncludePivotChart  -ChartType BarClustered3D
        $Pt += New-PivotTableDefinition -PivotTableName "PT2" -SourceWorkSheet "Sheet2" -PivotRows "Company" -PivotData @{Company='Count'} -IncludePivotChart  -ChartType PieExploded3D  -ShowPercent -ChartTitle "Breakdown of processes by company"
        Get-Service | Select-Object    -Property Status,Name,DisplayName,StartType | Export-Excel -Path .\test.xlsx -AutoSize
        Get-Process | Select-Object    -Property Name,Company,Handles,CPU,VM       | Export-Excel -Path .\test.xlsx -AutoSize -WorkSheetname 'sheet2'
        $excel = Export-Excel -Path .\test.xlsx -PivotTableDefinition $pt -Show

        This is a re-work of one of the examples in Export-Excel - instead of writing out the pivot definition hash table it is built by calling New-PivotTableDefinition.
    #>
    param(
        [Parameter(Mandatory)]
        [Alias("PivtoTableName")]#Previous typo - use alias to avoid breaking scripts
        $PivotTableName,
        #Worksheet where the data is found
        $SourceWorkSheet,
        #Address range in the worksheet e.g "A10:F20" - the first row must be column names: if not specified the whole sheet will be used/
        $SourceRange,
        #Fields to set as rows in the Pivot table
        $PivotRows,
        #A hash table in form "FieldName"="Function", where function is one of
        #Average, Count, CountNums, Max, Min, Product, None, StdDev, StdDevP, Sum, Var, VarP
        [hashtable]$PivotData,
        #Fields to set as columns in the Pivot table
        $PivotColumns,
        #Fields to use to filter in the Pivot table
        $PivotFilter,
        [Switch]$PivotDataToColumn,
        [Switch]$NoTotalsInPivot,
        #If specified a chart Will be included.
        [Switch]$IncludePivotChart,
        #Optional title for the pivot chart, by default the title omitted.
        [String]$ChartTitle,
        #Height of the chart in Pixels (400 by default)
        [int]$ChartHeight = 400 ,
        #Width of the chart in Pixels (600 by default)
        [int]$ChartWidth = 600,
        #Cell position of the top left corner of the chart, there will be this number of rows above the top edge of the chart (default is 0, chart starts at top edge of row 1).
        [Int]$ChartRow = 0 ,
        #Cell position of the top left corner of the chart, there will be this number of cells to the left of the chart (default is 4, chart starts at left edge of column E)
        [Int]$ChartColumn = 4,
        #Vertical offset of the chart from the cell corner.
        [Int]$ChartRowOffSetPixels = 0 ,
        #Horizontal offset of the chart from the cell corner.
        [Int]$ChartColumnOffSetPixels = 0,
        #Type of chart
        [OfficeOpenXml.Drawing.Chart.eChartType]$ChartType = 'Pie',
        #If specified hides the chart legend
        [Switch]$NoLegend,
        #if specified attaches the category to slices in a pie chart : not supported on all chart types, this may give errors if applied to an unsupported type.
        [Switch]$ShowCategory,
        #If specified attaches percentages to slices in a pie chart.
        [Switch]$ShowPercent
    )
    $validDataFuntions = [system.enum]::GetNames([OfficeOpenXml.Table.PivotTable.DataFieldFunctions])

    if ($PivotData.values.Where({$_ -notin $validDataFuntions}) ) {
        Write-Warning -Message ("Pivot data functions might not be valid, they should be one of " + ($validDataFuntions -join ", ") + ".")
    }

    $parameters = @{} + $PSBoundParameters
    $parameters.Remove('PivotTableName')

    @{$PivotTableName = $parameters}
}
function Add-WorkSheet  {
    [cmdletBinding()]
    [OutputType([OfficeOpenXml.ExcelWorksheet])]
    param(
        #An object representing an Excel Package.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "Package", Position = 0)]
        [OfficeOpenXml.ExcelPackage]$ExcelPackage,
        #An Excel workbook to which the Worksheet will be added - a package contains one workbook so you can use whichever fits at the time.
        [Parameter(Mandatory = $true, ParameterSetName = "WorkBook")]
        [OfficeOpenXml.ExcelWorkbook]$ExcelWorkbook,
        #The name of the worksheet 'Sheet1' by default.
        [string]$WorkSheetname = 'Sheet1',
        #If the worksheet already exists, by default it will returned, unless -ClearSheet is specified in which case it will be deleted and re-created.
        [switch]$ClearSheet,
        #If specified, the worksheet will be moved to the start of the workbook.
        #MoveToStart takes precedence over MoveToEnd, Movebefore and MoveAfter if more than one is specified.
        [Switch]$MoveToStart,
        #If specified, the worksheet will be moved to the end of the workbook.
        #(This is the default position for newly created sheets, but this can be used to move existing sheets.)
        [Switch]$MoveToEnd,
        #If specified, the worksheet will be moved before the nominated one (which can be a postion starting from 1, or a name).
        #MoveBefore takes precedence over MoveAfter if both are specified.
        $MoveBefore ,
        # If specified, the worksheet will be moved after the nominated one (which can be a postion starting from 1, or a name or *).
        # If * is used, the worksheet names will be examined starting with the first one, and the sheet placed after the last sheet which comes before it alphabetically.
        $MoveAfter ,
        #If worksheet is provided as a copy source the new worksheet will be a copy of it. The source can be in the same workbook, or in a different file.
        [OfficeOpenXml.ExcelWorksheet]$CopySource,
        #Ignored but retained for backwards compatibility.
        [Switch] $NoClobber
    )

    if ($ExcelPackage -and -not $ExcelWorkbook) {$ExcelWorkbook = $ExcelPackage.Workbook}

    $ws = $ExcelWorkbook.Worksheets[$WorkSheetname]
    if ( $ws -and $ClearSheet) { $ExcelWorkbook.Worksheets.Delete($WorkSheetname) ; $ws = $null }
    if (!$ws -and $CopySource) {
        Write-Verbose -Message "Copying into worksheet '$WorkSheetname'."
        $ws = $ExcelWorkbook.Worksheets.Add($WorkSheetname, $CopySource)
    }
    elseif (!$ws) {
        Write-Verbose -Message "Adding worksheet '$WorkSheetname'."
        $ws = $ExcelWorkbook.Worksheets.Add($WorkSheetname)
    }
    else {Write-Verbose -Message "Worksheet '$WorkSheetname' already existed."}
    if ($MoveToStart) {$ExcelWorkbook.Worksheets.MoveToStart($worksheetName) }
    elseif ($MoveToEnd  ) {$ExcelWorkbook.Worksheets.MoveToEnd($worksheetName)   }
    elseif ($MoveBefore ) {
        if ($ExcelWorkbook.Worksheets[$MoveBefore]) {
            if ($MoveBefore -is [int]) {
                $ExcelWorkbook.Worksheets.MoveBefore($ws.Index, $MoveBefore)
            }
            else {$ExcelWorkbook.Worksheets.MoveBefore($worksheetname, $MoveBefore)}
        }
        else {Write-Warning "Can't find worksheet '$MoveBefore'; worsheet '$WorkSheetname' will not be moved."}
    }
    elseif ($MoveAfter  ) {
        if ($MoveAfter = "*") {
            if ($WorkSheetname -lt $ExcelWorkbook.Worksheets[1].Name) {$ExcelWorkbook.Worksheets.MoveToStart($worksheetName)}
            else {
                $i = 1
                While ($i -lt $ExcelWorkbook.Worksheets.Count -and ($ExcelWorkbook.Worksheets[$i + 1].Name -le $worksheetname) ) { $i++}
                $ExcelWorkbook.Worksheets.MoveAfter($ws.Index, $i)
            }
        }
        elseif ($ExcelWorkbook.Worksheets[$MoveAfter]) {
            if ($MoveAfter -is [int]) {
                $ExcelWorkbook.Worksheets.MoveAfter($ws.Index, $MoveAfter)
            }
            else {
                $ExcelWorkbook.Worksheets.MoveAfter($worksheetname, $MoveAfter)
            }
        }
        else {Write-Warning "Can't find worksheet '$MoveAfter'; worsheet '$WorkSheetname' will not be moved."}
    }
    return $ws
}
function Add-PivotTable {

    param (
        # Parameter help description
        [Parameter(Mandatory = $true)]
        $PivotTableName,
        $ExcelPackage,
        #Worksheet where the data is found
        $SourceWorkSheet,
        #Address range in the worksheet e.g "A10:F20" - the first row must be column names: if not specified the whole sheet will be used/
        $SourceRange,
        #Fields to set as rows in the Pivot table
        $PivotRows,
        #A hash table in form "FieldName"="Function", where function is one of
        #Average, Count, CountNums, Max, Min, Product, None, StdDev, StdDevP, Sum, Var, VarP
        $PivotData,
        #Fields to set as columns in the Pivot table
        $PivotColumns,
        #Fields to use to filter in the Pivot table
        $PivotFilter,
        [Switch]$PivotDataToColumn,
        [Switch]$NoTotalsInPivot,
        #If specified a chart Will be included.
        [Switch]$IncludePivotChart,
        #Optional title for the pivot chart, by default the title omitted.
        [String]$ChartTitle,
        #Height of the chart in Pixels (400 by default)
        [int]$ChartHeight = 400 ,
        #Width of the chart in Pixels (600 by default)
        [int]$ChartWidth = 600,
        #Cell position of the top left corner of the chart, there will be this number of rows above the top edge of the chart (default is 0, chart starts at top edge of row 1).
        [Int]$ChartRow = 0 ,
        #Cell position of the top left corner of the chart, there will be this number of cells to the left of the chart (default is 4, chart starts at left edge of column E)
        [Int]$ChartColumn = 4,
        #Vertical offset of the chart from the cell corner.
        [Int]$ChartRowOffSetPixels = 0 ,
        #Horizontal offset of the chart from the cell corner.
        [Int]$ChartColumnOffSetPixels = 0,
        #Type of chart
        [OfficeOpenXml.Drawing.Chart.eChartType]$ChartType = 'Pie',
        #If specified hides the chart legend
        [Switch]$NoLegend,
        #if specified attaches the category to slices in a pie chart : not supported on all chart types, this may give errors if applied to an unsupported type.
        [Switch]$ShowCategory,
        #If specified attaches percentages to slices in a pie chart.
        [Switch]$ShowPercent
    )

    $pivotTableDataName = $pivotTableName + 'PivotTableData'
    [OfficeOpenXml.ExcelWorksheet]$wsPivot = Add-WorkSheet -ExcelPackage $ExcelPackage -WorkSheetname $pivotTableName
   # $wsPivot.View.TabSelected = $true

    #if the pivot doesn't exist, create it.
    if (-not $wsPivot.PivotTables[$pivotTableDataName] ) {
        try {
            #Accept a string or a worksheet object as $Source Worksheet.
            if ($SourceWorkSheet -is [string]) {
                $SourceWorkSheet = $ExcelPackage.Workbook.Worksheets.where( {$_.name -match $SourceWorkSheet})[0]
            }
            if (-not ($SourceWorkSheet -is  [OfficeOpenXml.ExcelWorksheet])) {Write-Warning -Message "Could not find source Worksheet for pivot-table '$pivotTableName'." }
            else {
                if ($PivotFilter) {$PivotTableStartCell = "A3"} else { $PivotTableStartCell = "A1"}
                if (-not $SourceRange) { $SourceRange = $SourceWorkSheet.Dimension.Address}
                $pivotTable = $wsPivot.PivotTables.Add($wsPivot.Cells[$PivotTableStartCell], $SourceWorkSheet.Cells[ $SourceRange], $pivotTableDataName)
            }
            foreach ($Row in $PivotRows) {
                try {$null = $pivotTable.RowFields.Add($pivotTable.Fields[$Row]) }
                catch {Write-Warning -message "Could not add '$row' to Rows in PivotTable $pivotTableName." }
            }
            foreach ($Column in $PivotColumns) {
                try {$null = $pivotTable.ColumnFields.Add($pivotTable.Fields[$Column])}
                catch {Write-Warning -message "Could not add '$Column' to Columns in PivotTable $pivotTableName." }
            }
            if ($PivotData -is [HashTable] -or $PivotData -is [System.Collections.Specialized.OrderedDictionary]) {
                $PivotData.Keys | ForEach-Object {
                    try {
                        $df = $pivotTable.DataFields.Add($pivotTable.Fields[$_])
                        $df.Function = $PivotData.$_
                    }
                    catch {Write-Warning -message "Problem adding data fields to PivotTable $pivotTableName." }
                }
            }
            else {
                foreach ($field in $PivotData) {
                    try {
                        $df = $pivotTable.DataFields.Add($pivotTable.Fields[$field])
                        $df.Function = 'Count'
                    }
                    catch {Write-Warning -message "Problem adding data field '$field' to PivotTable $pivotTableName." }
                }
            }
            foreach ( $pFilter in $PivotFilter) {
                try { $null = $pivotTable.PageFields.Add($pivotTable.Fields[$pFilter])}
                catch {Write-Warning -message "Could not add '$pFilter' to Filter/Page fields in PivotTable $pivotTableName." }
            }
            if ($NoTotalsInPivot) { $pivotTable.RowGrandTotals = $false }
            if ($PivotDataToColumn ) { $pivotTable.DataOnRows = $false }
        }
        catch {Write-Warning -Message "Failed adding PivotTable '$pivotTableName': $_"}
    }
    else {
        Write-Warning -Message "Pivot table defined in $($pivotTableName) already exists, only the data range will be changed."
        $pivotTable = $wsPivot.PivotTables[$pivotTableDataName]
        $pivotTable.CacheDefinition.CacheDefinitionXml.pivotCacheDefinition.cacheSource.worksheetSource.ref = $SourceRange
    }

        #Create the chart if it doesn't exist, leave alone if it does.
    if ($IncludePivotChart -and -not $wsPivot.Drawings['PivotChart'] ) {
        try {
            [OfficeOpenXml.Drawing.Chart.ExcelChart] $chart = $wsPivot.Drawings.AddChart('PivotChart', $ChartType, $pivotTable)
            $chart.SetPosition($ChartRow  , $ChartRowOffSetPixels , $ChartColumn, $ChartColumnOffSetPixels)
            $chart.SetSize(    $ChartWidth, $ChartHeight)
            if ($chart.DataLabel) {
                $chart.DataLabel.ShowCategory = [boolean]$ShowCategory
                $chart.DataLabel.ShowPercent  = [boolean]$ShowPercent
            }
            if ($NoLegend) {  $chart.Legend.Remove()}
            if ($ChartTitle) {$chart.Title.Text = $ChartTitle}
        }
        catch {  catch {Write-Warning -Message "Failed adding chart for pivotable '$pivotTableName': $_"}
        }

    }
}
function Add-ExcelChart {
    [cmdletbinding()]
    param(
        [OfficeOpenXml.ExcelWorksheet]$Worksheet,
        [String]$Title = "Chart Title",
        #$Header,   Not used but referenced previously 
        [OfficeOpenXml.Drawing.Chart.eChartType]$ChartType = "ColumnStacked",
        $XRange,
        $YRange,
        [int]$Width = 500,
        [int]$Height = 350,
        [int]$Row = 0,
        [int]$RowOffSetPixels = 10,
        [int]$Column = 6,
        [int]$ColumnOffSetPixels = 5,
        [OfficeOpenXml.Drawing.Chart.eLegendPosition]$LegendPostion,
        $LegendSize,
        [Switch]$legendBold,
        [Switch]$NoLegend,
        [Switch]$ShowCategory,
        [Switch]$ShowPercent,
        $SeriesHeader,
        [Switch]$TitleBold,
        [Int]$TitleSize ,
        [String]$XAxisTitleText, 
        [Switch]$XAxisTitleBold,
        $XAxisTitleSize ,
        [string]$XAxisNumberformat,
        [double]$XMajorUnit, 
        [double]$XMinorUnit, 
        [double]$XMaxValue,
        [double]$XMinValue,
        [OfficeOpenXml.Drawing.Chart.eAxisPosition]$XAxisPosition        ,
        [String]$YAxisTitleText, 
        [Switch]$YAxisTitleBold,
        $YAxisTitleSize,
        [string]$YAxisNumberformat,
        [double]$YMajorUnit, 
        [double]$YMinorUnit, 
        [double]$YMaxValue,
        [double]$YMinValue,
        [OfficeOpenXml.Drawing.Chart.eAxisPosition]$YAxisPosition   )
    try {
        $ChartName = 'Chart' + (Split-Path -Leaf ([System.IO.path]::GetTempFileName())) -replace 'tmp|\.', ''
        $chart = $Worksheet.Drawings.AddChart($ChartName, $ChartType)
        $chart.Title.Text = $Title
        if ($TitleBold) {$chart.Title.Font.Bold = $true}
        if ($TitleSize) {$chart.Title.Font.Size = $TitleSize}
        
        if ($NoLegend) { $chart.Legend.Remove() }
        else {
            if ($LegendPostion) {$Chart.Legend.Position    = $LegendPostion}
            if ($LegendSize)    {$chart.Legend.Font.Size   = $LegendSize}
            if ($legendBold)    {$chart.Legend.Font.Bold   = $legendBold}
        }

        if ($XAxisTitleText) {
            $chart.XAxis.Title.Text = $XAxisTitleText
            if ($XAxisTitleBold) {$chart.XAxis.Title.Font.Bold = $true}
            if ($XAxisTitleSize) {$chart.XAxis.Title.Font.Size = $XAxisTitleSize}
        }
        if ($XAxisPosition)     {$chart.XAxis.AxisPosition = $XAxisPosition}    
        if ($XMajorUnit)        {$chart.XAxis.MajorUnit    = $XMajorUnit}         
        if ($XMinorUnit)        {$chart.XAxis.MinorUnit    = $XMinorUnit}     
        if ($XMinValue)         {$chart.XAxis.MinValue     = $XMinValue}     
        if ($XMaxValue)         {$chart.XAxis.MaxValue     = $XMaxValue}     
        if ($XAxisNumberformat) {$chart.XAxis.Format       = $XAxisNumberformat}

        if ($YAxisTitleText) {
            $chart.YAxis.Title.Text = $YAxisTitleText
            if ($YAxisTitleBold) {$chart.YAxis.Title.Font.Bold = $true}
            if ($YAxisTitleSize) {$chart.YAxis.Title.Font.Size = $YAxisTitleSize}
        }
        if ($YAxisPosition)     {$chart.YAxis.AxisPosition = $YAxisPosition}
        if ($YMajorUnit)        {$chart.YAxis.MajorUnit    = $YMajorUnit}         
        if ($YMinorUnit)        {$chart.YAxis.MinorUnit    = $YMinorUnit}     
        if ($YMinValue)         {$chart.YAxis.MinValue     = $YMinValue}      
        if ($YMaxValue)         {$chart.YAxis.MaxValue     = $YMaxValue}     
        if ($YAxisNumberformat) {$chart.YAxis.Format       = $YAxisNumberformat}
        
        if ($chart.Datalabel -ne $null) {
            $chart.Datalabel.ShowCategory = [boolean]$ShowCategory
            $chart.Datalabel.ShowPercent  = [boolean]$ShowPercent
        }

        $chart.SetPosition($Row, $RowOffsetPixels, $Column, $ColumnOffsetPixels)
        $chart.SetSize($Width, $Height)

        $chartDefCount = @($YRange).Count
        if ($chartDefCount -eq 1) {
            $Series = $chart.Series.Add($YRange, $XRange)
            if ($SeriesHeader) { $Series.Header = $SeriesHeader}
            else { $Series.Header = 'Series 1'}
        }
        else {
            for ($idx = 0; $idx -lt $chartDefCount; $idx += 1) {
                $Series = $chart.Series.Add($YRange[$idx], $XRange)
                if ($SeriesHeader.Count -gt 0) { $Series.Header = $SeriesHeader[$idx] }
                else { $Series.Header = "Series $($idx)"}
            }
        }
    }
    catch {Write-Warning -Message "Failed adding Chart to worksheet '$($WorkSheet).name': $_"}
}