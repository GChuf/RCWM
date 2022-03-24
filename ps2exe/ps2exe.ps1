param([string]$inputFile=$null, [string]$outputFile=$null, [switch]$verbose, [switch] $debug, [switch]$runtime20, [switch]$x86, [switch]$x64, [switch]$runtime30, [switch]$runtime40, [int]$lcid, [switch]$sta, [switch]$mta, [switch]$noConsole, [switch]$nested, [string]$iconFile=$null)


<################################################################################>
<##                                                                            ##>
<##      PS2EXE v0.5.0.0  -  http://ps2exe.codeplex.com                        ##>
<##          written by:                                                       ##>
<##            * Ingo Karstein (http://blog.karstein-consulting.com)           ##>
<##                                                                            ##>
<##      This script is released under Microsoft Public Licence                ##>
<##          that can be downloaded here:                                      ##>
<##          http://www.microsoft.com/opensource/licenses.mspx#Ms-PL           ##>
<##                                                                            ##>
<##      This script was created using PowerGUI (http://www.powergui.org)      ##>
<##             ... and Windows PowerShell ISE v4.0                            ##>
<##      	                        while (!me.ShouldExit && !mre.WaitOne(2))  ##>
<################################################################################>

if( !$nested ) {
    Write-Host "PS2EXE; v0.5.0.0 by Ingo Karstein (http://blog.karstein-consulting.com)"
    Write-Host ""
} else {
    write-host "PowerShell 2.0 environment started..."
    Write-Host ""
}

if( $runtime20 -eq $true -and $runtime30 -eq $true ) {
    write-host "YOU CANNOT USE SWITCHES -runtime20 AND -runtime30 AT THE SAME TIME!"
    exit -1
}

if( $sta -eq $true -and $mta -eq $true ) {
    write-host "YOU CANNOT USE SWITCHES -sta AND -eta AT THE SAME TIME!"
    exit -1
}


if( [string]::IsNullOrEmpty($inputFile) -or [string]::IsNullOrEmpty($outputFile) ) {
Write-Host "Usage:"
Write-Host ""
Write-Host "    powershell.exe -command ""&'.\ps2exe.ps1' [-inputFile] '<file_name>'"
write-host "                   [-outputFile] '<file_name>' "
write-host "                   [-verbose] [-debug] [-runtime20] [-runtime30]"""
Write-Host ""       
Write-Host "       inputFile = PowerShell script that you want to convert to EXE"       
Write-Host "      outputFile = destination EXE file name"       
Write-Host "         verbose = Output verbose informations - if any"       
Write-Host "           debug = generate debug informations for output file" 
Write-Host "           debug = generate debug informations for output file"       
Write-Host "       runtime20 = this switch forces PS2EXE to create a config file for" 
write-host "                   the generated EXE that contains the ""supported .NET"
write-host "                   Framework versions"" setting for .NET Framework 2.0"
write-host "                   for PowerShell 2.0"
Write-Host "       runtime30 = this switch forces PS2EXE to create a config file for" 
write-host "                   the generated EXE that contains the ""supported .NET"
write-host "                   Framework versions"" setting for .NET Framework 4.0"
write-host "                   for PowerShell 3.0"
Write-Host "       runtime40 = this switch forces PS2EXE to create a config file for" 
write-host "                   the generated EXE that contains the ""supported .NET"
write-host "                   Framework versions"" setting for .NET Framework 4.0"
write-host "                   for PowerShell 4.0"
Write-Host "            lcid = Location ID for the compiled EXE. Current user"
write-host "                   culture if not specified." 
Write-Host "             x86 = Compile for 32-bit runtime only"
Write-Host "             x64 = Compile for 64-bit runtime only"
Write-Host "             sta = Single Thread Apartment Mode"
Write-Host "             mta = Multi Thread Apartment Mode"
write-host "       noConsole = The resulting EXE file starts without a console window just like a Windows Forms app."
write-host ""
}

$psversion = 0

if($PSVersionTable.PSVersion.Major -eq 4) {
    $psversion = 4
    write-host "You are using PowerShell 4.0."
}

if($PSVersionTable.PSVersion.Major -eq 3) {
    $psversion = 3
    write-host "You are using PowerShell 3.0."
}

if($PSVersionTable.PSVersion.Major -eq 2) {
    $psversion = 2
    write-host "You are using PowerShell 2.0."
}

$psversion = 4

if( [string]::IsNullOrEmpty($inputFile) -or [string]::IsNullOrEmpty($outputFile) ) {
    write-host "INPUT FILE AND OUTPUT FILE NOT SPECIFIED!"
    exit -1
}

$inputFile = (new-object System.IO.FileInfo($inputFile)).FullName

$outputFile = (new-object System.IO.FileInfo($outputFile)).FullName


if( !(Test-Path $inputFile -PathType Leaf ) ) {
	Write-Host "INPUT FILE $($inputFile) NOT FOUND!"
	exit -1
}

if( !([string]::IsNullOrEmpty($iconFile) ) ) {
	if( !(Test-Path (join-path (split-path $inputFile) $iconFile) -PathType Leaf ) ) {
		Write-Host "ICON FILE ""$($iconFile)"" NOT FOUND! IT MUST BE IN THE SAME DIRECTORY AS THE PS-SCRIPT (""$($inputFile)"")."
		exit -1
	}
}

if( !$runtime20 -and !$runtime30 -and !$runtime40 ) {
    if( $psversion -eq 4 ) {
		$runtime40 = $true
	}  elseif( $psversion -eq 3 ) {
        $runtime30 = $true
    } else {
        $runtime20 = $true
    }
}



if( $psversion -lt 3 -and $runtime30 ) {
    Write-Host "YOU NEED TO RUN PS2EXE IN AN POWERSHELL 3.0 ENVIRONMENT"
    Write-Host "  TO USE PARAMETER -runtime30"
    write-host
    exit -1
}

if( $psversion -lt 4 -and $runtime40 ) {
    Write-Host "YOU NEED TO RUN PS2EXE IN AN POWERSHELL 4.0 ENVIRONMENT"
    Write-Host "  TO USE PARAMETER -runtime40"
    write-host
    exit -1
}

write-host ""


Set-Location (Split-Path $MyInvocation.MyCommand.Path)

$type = ('System.Collections.Generic.Dictionary`2') -as "Type"
$type = $type.MakeGenericType( @( ("System.String" -as "Type"), ("system.string" -as "Type") ) )
$o = [Activator]::CreateInstance($type)

if( $psversion -eq 3 -or $psversion -eq 4 ) {
    $o.Add("CompilerVersion", "v4.0")
} else {
    $o.Add("CompilerVersion", "v2.0")
}

$referenceAssembies = @("System.dll")
$referenceAssembies += ([System.AppDomain]::CurrentDomain.GetAssemblies() | ? { $_.ManifestModule.Name -ieq "Microsoft.PowerShell.ConsoleHost" } | select -First 1).location
$referenceAssembies += ([System.AppDomain]::CurrentDomain.GetAssemblies() | ? { $_.ManifestModule.Name -ieq "System.Management.Automation.dll" } | select -First 1).location

if( $runtime30 -or $runtime40 ) {
    $n = new-object System.Reflection.AssemblyName("System.Core, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    [System.AppDomain]::CurrentDomain.Load($n) | Out-Null
    $referenceAssembies += ([System.AppDomain]::CurrentDomain.GetAssemblies() | ? { $_.ManifestModule.Name -ieq "System.Core.dll" } | select -First 1).location
}

if( $runtime20 -and $runtime40 ) {
	echo "2040"
    $n = new-object System.Reflection.AssemblyName("System.Core, Version=5.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
    [System.AppDomain]::CurrentDomain.Load($n) | Out-Null
    $referenceAssembies += ([System.AppDomain]::CurrentDomain.GetAssemblies() | ? { $_.ManifestModule.Name -ieq "System.Core.dll" } | select -First 1).location
}





$inputFile = [System.IO.Path]::GetFullPath($inputFile) 
$outputFile = [System.IO.Path]::GetFullPath($outputFile) 

$platform = "anycpu"
if( $x64 -and !$x86 ) { $platform = "x64" } else { if ($x86 -and !$x64) { $platform = "x86" }}

$cop = (new-object Microsoft.CSharp.CSharpCodeProvider($o))
$cp = New-Object System.CodeDom.Compiler.CompilerParameters($referenceAssembies, $outputFile)
$cp.GenerateInMemory = $false
$cp.GenerateExecutable = $true

$iconFileParam = ""
if(!([string]::IsNullOrEmpty($iconFile))) {
	$iconFileParam = "/win32icon:$($iconFile)"
}
$cp.CompilerOptions = "/platform:$($platform) /target:$( if($noConsole){'winexe'}else{'exe'}) $($iconFileParam)"

$cp.IncludeDebugInformation = $debug

if( $debug ) {
	#$cp.TempFiles.TempDir = (split-path $inputFile)
	$cp.TempFiles.KeepFiles = $true
	
}	

Write-Host "Reading input file " -NoNewline 
Write-Host $inputFile 
Write-Host ""
$content = Get-Content -LiteralPath ($inputFile) -Encoding UTF8 -ErrorAction SilentlyContinue
if( $content -eq $null ) {
	Write-Host "No data found. May be read error or file protected."
	exit -2
}
$scriptInp = [string]::Join("`r`n", $content)
$script = [System.Convert]::ToBase64String(([System.Text.Encoding]::UTF8.GetBytes($scriptInp)))


























#region program frame
    $culture = ""


	
	$forms = @"
		    internal class ReadKeyForm 
		    {
		        public KeyInfo key = new KeyInfo();
				public ReadKeyForm() {}

			}
			

"@	

		

	$programFrame = @"

	using System;
	using System.Collections.Generic;
	using System.Text;
	using System.Management.Automation;
	using System.Management.Automation.Runspaces;
	using PowerShell = System.Management.Automation.PowerShell;
	using System.Globalization;
	using System.Management.Automation.Host;

	using System.Runtime.InteropServices;

	namespace ik.PowerShell
	{
$forms
		internal class PS2EXEHostRawUI : PSHostRawUserInterface
	    {
			private const bool CONSOLE = false;

			public override ConsoleColor BackgroundColor
	        {
	            get
	            {
	                return Console.BackgroundColor;
	            }
	            set
	            {
	                Console.BackgroundColor = value;
	            }
	        }

	        public override Size BufferSize
	        {
	            get
	            {
	                if (CONSOLE)
	                    return new Size(Console.BufferWidth, Console.BufferHeight);
	                else
	                    return new Size(0, 0);
	            }
	            set
	            {
	                Console.BufferWidth = 0;
	                Console.BufferHeight = 0;
	            }
	        }

	        public override Coordinates CursorPosition
	        {
	            get
	            {
	                return new Coordinates(Console.CursorLeft, Console.CursorTop);
	            }
	            set
	            {
	                Console.CursorTop = 0;
	                Console.CursorLeft = 0;
	            }
	        }

	        public override int CursorSize
	        {
	            get
	            {
	                return Console.CursorSize;
	            }
	            set
	            {
	                Console.CursorSize = 0;
	            }
	        }

	        public override void FlushInputBuffer()
	        {
	            throw new Exception("");
	        }

	        public override ConsoleColor ForegroundColor
	        {
	            get
	            {
	                return Console.ForegroundColor;
	            }
	            set
	            {
	                Console.ForegroundColor = 0;
	            }
	        }

	        public override BufferCell[,] GetBufferContents(Rectangle rectangle)
	        {
	            throw new Exception("");
	        }

	        public override bool KeyAvailable
	        {
	            get
	            {
	                throw new Exception("");
	            }
	        }

	        public override Size MaxPhysicalWindowSize
	        {
	            get { return new Size(Console.LargestWindowWidth, Console.LargestWindowHeight); }
	        }

	        public override Size MaxWindowSize
	        {
	            get { return new Size(Console.BufferWidth, Console.BufferWidth); }
	        }

	        public override KeyInfo ReadKey(ReadKeyOptions options)
	        {

					ReadKeyForm f = new ReadKeyForm();
	                return f.key; 

	        }

	        public override void ScrollBufferContents(Rectangle source, Coordinates destination, Rectangle clip, BufferCell fill)
	        {
	            throw new Exception("");
	        }

	        public override void SetBufferContents(Rectangle rectangle, BufferCell fill)
	        {
	            throw new Exception("");
	        }

	        public override void SetBufferContents(Coordinates origin, BufferCell[,] contents)
	        {
	            throw new Exception("");
	        }

	        public override Coordinates WindowPosition
	        {
	            get
	            {
	                Coordinates s = new Coordinates();
	                s.X = 0;
	                s.Y = 0;
	                return s;
	            }
	            set
	            {
	                Console.WindowLeft = 0;
	                Console.WindowTop = 0;
	            }
	        }

	        public override Size WindowSize
	        {
	            get
	            {
	                Size s = new Size();
	                s.Height = 0;
	                s.Width = 0;
	                return s;
	            }
	            set
	            {
	                Console.WindowWidth = 0;
	                Console.WindowHeight = 0;
	            }
	        }

	        public override string WindowTitle
	        {
	            get
	            {
	                return "";
	            }
	            set
	            {
	                Console.Title = "";
	            }
	        }
	    }
	    internal class PS2EXEHostUI : PSHostUserInterface
	    {
			private const bool CONSOLE = false;

			private PS2EXEHostRawUI rawUI = null;

	        public PS2EXEHostUI()
	            : base()
	        {
	            rawUI = null;
	        }

	        public override Dictionary<string, PSObject> Prompt(string caption, string message, System.Collections.ObjectModel.Collection<FieldDescription> descriptions)
	        {

	            return new Dictionary<string, PSObject>();
	        }

	        public override int PromptForChoice(string caption, string message, System.Collections.ObjectModel.Collection<ChoiceDescription> choices, int defaultChoice)
	        {
	            return -1;
	        }

	        public override PSCredential PromptForCredential(string caption, string message, string userName, string targetName, PSCredentialTypes allowedCredentialTypes, PSCredentialUIOptions options)
	        {
	            return null;
	        }

	        public override PSCredential PromptForCredential(string caption, string message, string userName, string targetName)
	        {

	            return null;

	        }

	        public override PSHostRawUserInterface RawUI
	        {
	            get
	            {
	                return rawUI;
	            }
	        }

	        public override string ReadLine()
	        {
	            return "";
	        }

	        public override System.Security.SecureString ReadLineAsSecureString()
	        {
	            return null;
	        }

	        public override void Write(ConsoleColor foregroundColor, ConsoleColor backgroundColor, string value)
	        {

	        }

	        public override void Write(string value)
	        {


	        }

	        public override void WriteDebugLine(string message)
	        {


	        }

	        public override void WriteErrorLine(string value)
	        {


	        }

	        public override void WriteLine(string value)
	        {


	        }

	        public override void WriteProgress(long sourceId, ProgressRecord record)
	        {

	        }

	        public override void WriteVerboseLine(string message)
	        {


	        }

	        public override void WriteWarningLine(string message)
	        {


	        }
	    }



	    internal class PS2EXEHost : PSHost
	    {
			private const bool CONSOLE = false;

			private PS2EXEApp parent;
	        private PS2EXEHostUI ui = null;

	        private CultureInfo originalCultureInfo =
	            System.Threading.Thread.CurrentThread.CurrentCulture;

	        private CultureInfo originalUICultureInfo =
	            System.Threading.Thread.CurrentThread.CurrentUICulture;

	        private Guid myId = Guid.NewGuid();

	        public PS2EXEHost(PS2EXEApp app)
	        {
	            this.parent = app;
	        }

	        public override System.Globalization.CultureInfo CurrentCulture
	        {
	            get
	            {
	                return this.originalCultureInfo;
	            }
	        }

	        public override System.Globalization.CultureInfo CurrentUICulture
	        {
	            get
	            {
	                return this.originalUICultureInfo;
	            }
	        }

	        public override Guid InstanceId
	        {
	            get
	            {
	                return this.myId;
	            }
	        }

	        public override string Name
	        {
	            get
	            {
	                return "PS2EXE_Host";
	            }
	        }

	        public override PSHostUserInterface UI
	        {
	            get
	            {
	                return ui;
	            }
	        }

	        public override Version Version
	        {
	            get
	            {
	                return new Version(7, 2, 8, 6);
	            }
	        }

	        public override void EnterNestedPrompt()
	        {
	        }

	        public override void ExitNestedPrompt()
	        {
	        }

	        public override void NotifyBeginApplication()
	        {
	            return;
	        }

	        public override void NotifyEndApplication()
	        {
	            return;
	        }

	        public override void SetShouldExit(int exitCode)
	        {
	            this.parent.ShouldExit = true;

	        }
	    }



	    internal interface PS2EXEApp
	    {
	        bool ShouldExit { get; set; }
	        int ExitCode { get; set; }
	    }


	    internal class PS2EXE : PS2EXEApp
	    {
			private const bool CONSOLE = false;
			
	        private bool shouldExit;

	        private int exitCode;

	        public bool ShouldExit
	        {
	            get { return this.shouldExit; }
	            set { this.shouldExit = value; }
	        }

	        public int ExitCode
	        {
	            get { return this.exitCode; }
	            set { this.exitCode = value; }
	        }

	        $(if($sta){"[STAThread]"})$(if($mta){"[MTAThread]"})
	        private static int Main(string[] args)
	        {
                $culture

	            PS2EXE me = new PS2EXE();

	            PS2EXEHostUI ui = new PS2EXEHostUI();
	            PS2EXEHost host = new PS2EXEHost(me);
	            System.Threading.ManualResetEvent mre = new System.Threading.ManualResetEvent(false);


	            try
	            {
	                using (Runspace myRunSpace = RunspaceFactory.CreateRunspace(host))
	                {
	                    $(if($true){"myRunSpace.ApartmentState = System.Threading.ApartmentState."})$(if($true){"STA"});
	                    myRunSpace.Open();

	                    using (System.Management.Automation.PowerShell powershell = System.Management.Automation.PowerShell.Create())
	                    {

	                        powershell.Runspace = myRunSpace;


	                        PSDataCollection<PSObject> inp = new PSDataCollection<PSObject>();

	                        PSDataCollection<PSObject> outp = new PSDataCollection<PSObject>();

	                        int separator = 0;


	                        string script = System.Text.Encoding.UTF8.GetString(System.Convert.FromBase64String(@"$($script)"));

							List<string> paramList = new List<string>(args);

	                        powershell.AddScript(script);
                        	powershell.AddParameters(paramList.GetRange(0, paramList.Count));


	                        powershell.BeginInvoke<PSObject, PSObject>(inp, outp, null, new AsyncCallback(delegate(IAsyncResult ar)
	                        {
	                            if (ar.IsCompleted)
	                                mre.Set();
	                        }), null);
							
							
	                        while (!me.ShouldExit && !mre.WaitOne(10))
	                        {
	                        };

	                        powershell.Stop();
	                    }

	                    myRunSpace.Close();
	                }
					
					
					
					
					
					
					
	            }
	            catch (Exception ex)
	            {

	            }


	            return me.ExitCode;
	        }



	    }
	}
"@
#endregion







#####
#####
#####
#####
#####
#####
#####
#####
#####
##########
#####
#####
#####
##########
#####
#####
#####
##########
#####
#####
#####
##########
#####
#####
#####
#####


















#region EXE Config file
  $configFileForEXE2 = "<?xml version=""1.0"" encoding=""utf-8"" ?>`r`n<configuration><startup><supportedRuntime version=""v2.0.50727""/></startup></configuration>"
  $configFileForEXE3 = "<?xml version=""1.0"" encoding=""utf-8"" ?>`r`n<configuration><startup><supportedRuntime version=""v4.0"" sku="".NETFramework,Version=v4.0"" /></startup></configuration>"
#endregion

Write-Host "Compiling file... " -NoNewline
$cr = $cop.CompileAssemblyFromSource($cp, $programFrame)
if( $cr.Errors.Count -gt 0 ) {
	Write-Host ""
	Write-Host ""
	if( Test-Path $outputFile ) {
		Remove-Item $outputFile -Verbose:$false
	}
	Write-Host -ForegroundColor red "Could not create the PowerShell .exe file because of compilation errors. Use -verbose parameter to see details."
	$cr.Errors | % { Write-Verbose $_ -Verbose:$verbose}
} else {
	Write-Host ""
	Write-Host ""
	if( Test-Path $outputFile ) {
		Write-Host "Output file " -NoNewline 
		Write-Host $outputFile  -NoNewline
		Write-Host " written" 
		
		if( $debug) {
			$cr.TempFiles | ? { $_ -ilike "*.cs" } | select -first 1 | % {
				$dstSrc =  ([System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($outputFile), [System.IO.Path]::GetFileNameWithoutExtension($outputFile)+".cs"))
				Write-Host "Source file name for debug copied: $($dstSrc)"
				Copy-Item -Path $_ -Destination $dstSrc -Force
			}
			$cr.TempFiles | Remove-Item -Verbose:$false -Force -ErrorAction SilentlyContinue
		}
		if( $runtime20 ) {
			$configFileForEXE2 | Set-Content ($outputFile+".config")
			Write-Host "Config file for EXE created."
		}
		if( $runtime30 -or $runtime40 ) {
			$configFileForEXE3 | Set-Content ($outputFile+".config")
			Write-Host "Config file for EXE created."
		}
	} else {
		Write-Host "Output file " -NoNewline -ForegroundColor Red
		Write-Host $outputFile -ForegroundColor Red -NoNewline
		Write-Host " not written" -ForegroundColor Red
	}
}