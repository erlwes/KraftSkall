# This is a bad example since "Get-NetNeighbor" exist, but it shows how to extract values from string based output and add them as properties to PSObjects by creating a template from an example output.

# TAKE OUTPUT FROM COMMAND/EXE AND SAVE TO FILE AND EDIT
(arp -a) | Out-File .\arp-template.txt -Force
notepad .\arp-template.txt

# HOW TO EDIT:
# 1. Where you want to extract values for properties, wrap the example value in curly brackets and start with propertyname and a semicolon
#   a) Example: {Username:VALUE}
# 3. Mark the begining of each new object with "*" after property name. In the example below we make a new object for each IPAddress, then add MAC and type to this object, and so on...
#   a) Example: {IPAddress*:10.90.90.1}
# 4. Two or three examples should be enough for "learning", the rest of the output can be removed from template.

# COMPLETE TEMPLATE EXAMPLE FOR ARP -A
#Interface: 10.100.9.29 --- 0x3
#  Internet Address      Physical Address      Type
#  {IPAddress*:10.100.0.1}            {MAC:ac-70-20-e5-f6-bd}     {Type:dynamic}   
#  {IPAddress*:10.10.200.11}           {MAC:dc-cf-60-01-15-45}     {Type:static}   
#  {IPAddress*:192.9.9.253}          {MAC:12-ab-cd-e3-30-40}     {Type:dynamic} 

# THEN USE
(arp -a) | ConvertFrom-String -TemplateFile .\arp-template.txt | Select-Object IPAddress, MAC, Type

# INSTEAD OF TEMPLATE FILE, USING A HERE-STRING ALSO WOKRS (-TemplateContent vs. -TemplateFile)
$Template = @'

Interface: 10.100.9.29 --- 0x3
  Internet Address      Physical Address      Type
  {IPAddress*:10.100.0.1}            {MAC:ac-70-20-e5-f6-bd}     {Type:dynamic}   
  {IPAddress*:10.10.200.11}           {MAC:dc-cf-60-01-15-45}     {Type:static}   
  {IPAddress*:192.9.9.253}          {MAC:12-ab-cd-e3-30-40}     {Type:dynamic}   
'@

(arp -a) | ConvertFrom-String -TemplateContent $Template | Select-Object IPAddress, MAC, Type
