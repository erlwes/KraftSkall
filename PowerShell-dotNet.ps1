# CUSTOM CLASSES
# Load a non-predefined .Net library - Identify Defined types (Namespace and Classes)
$dll = "C:\Users\Temp\OneDrive - Westervik\Dokumenter\PowerShell\Modules\PSStringToQRCode\1.0.1\Net.Codecrete.QrCodeGenerator\Net.Codecrete.QrCodeGenerator.dll"
$obj = [System.Reflection.Assembly]::LoadFile("$dll")
$obj.DefinedTypes | select FullName


# PREDEFINED CLASSES
# To list them:
Get-TypeData -TypeName *

# To list more namespaces avaliable
[AppDomain]::CurrentDomain.GetAssemblies() | select ManifestModule | sort ManifestModule

# To list all classes og those
[AppDomain]::CurrentDomain.GetAssemblies().GetTypes() | select FullName | sort
