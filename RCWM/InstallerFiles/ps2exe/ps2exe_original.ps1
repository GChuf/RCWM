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
<##                                                                            ##>
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

if($PSVersionTable.PSVersion.Major -ge 4) {
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

if( $psversion -ge 3 -and $runtime20 ) {
    write-host "To create a EXE file for PowerShell 2.0 on PowerShell 3.0/4.0 this script now launces PowerShell 2.0..."
    write-host ""

    $arguments = "-inputFile '$($inputFile)' -outputFile '$($outputFile)' -nested "

    if($verbose) { $arguments += "-verbose "}
    if($debug) { $arguments += "-debug "}
    if($runtime20) { $arguments += "-runtime20 "}
    if($x86) { $arguments += "-x86 "}
    if($x64) { $arguments += "-verbose "}
    if($lcid) { $arguments += "-lcid $lcid "}
    if($sta) { $arguments += "-sta "}
    if($mta) { $arguments += "-mta "}
    if($noconsole) { $arguments += "-noconsole "}

    $jobScript = @"
."$($PSHOME)\powershell.exe" -version 2.0 -command "&'$($MyInvocation.MyCommand.Path)' $($arguments)"
"@
    Invoke-Expression $jobScript

    exit 0
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

if( $noConsole ) {
	$n = new-object System.Reflection.AssemblyName("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
    if( $runtime30 -or $runtime40 ) {
		$n = new-object System.Reflection.AssemblyName("System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
	}
    [System.AppDomain]::CurrentDomain.Load($n) | Out-Null

	$n = new-object System.Reflection.AssemblyName("System.Drawing, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
    if( $runtime30 -or $runtime40 ) {
		$n = new-object System.Reflection.AssemblyName("System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a")
	}
    [System.AppDomain]::CurrentDomain.Load($n) | Out-Null

	
	$referenceAssembies += ([System.AppDomain]::CurrentDomain.GetAssemblies() | ? { $_.ManifestModule.Name -ieq "System.Windows.Forms.dll" } | select -First 1).location
    $referenceAssembies += ([System.AppDomain]::CurrentDomain.GetAssemblies() | ? { $_.ManifestModule.Name -ieq "System.Drawing.dll" } | select -First 1).location
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

    if( $lcid ) {
    $culture = @"
    System.Threading.Thread.CurrentThread.CurrentCulture = System.Globalization.CultureInfo.GetCultureInfo($lcid);
    System.Threading.Thread.CurrentThread.CurrentUICulture = System.Globalization.CultureInfo.GetCultureInfo($lcid);
"@
    }
	
	$forms = @"
		    internal class ReadKeyForm 
		    {
		        public KeyInfo key = new KeyInfo();
				public ReadKeyForm() {}
				public void ShowDialog() {}
			}
			

"@	
	if( $noConsole ) {
	
		$forms = @"

"@

		$forms += @"
		    internal class ReadKeyForm 
		    {
		        public KeyInfo key = new KeyInfo();
				public ReadKeyForm() {}
				public void ShowDialog() {}
			}
"@	
	

		}
		

	$programFrame = @"
	//Simple PowerShell host created by Ingo Karstein (http://blog.karstein-consulting.com)
	//   for PS2EXE (http://ps2exe.codeplex.com)


	using System;
	using System.Collections.Generic;
	using System.Text;
	using System.Management.Automation;
	using System.Management.Automation.Runspaces;
	using PowerShell = System.Management.Automation.PowerShell;
	using System.Globalization;
	using System.Management.Automation.Host;

	using System.Reflection;
	using System.Runtime.InteropServices;

	namespace ik.PowerShell
	{
$forms
		internal class PS2EXEHostRawUI : PSHostRawUserInterface
	    {
			private const bool CONSOLE = $(if($noConsole){"false"}else{"true"});

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
	                Console.BufferWidth = value.Width;
	                Console.BufferHeight = value.Height;
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
	                Console.CursorTop = value.Y;
	                Console.CursorLeft = value.X;
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
	                Console.CursorSize = value;
	            }
	        }

	        public override void FlushInputBuffer()
	        {
	            throw new Exception("Not implemented: ik.PowerShell.PS2EXEHostRawUI.FlushInputBuffer");
	        }

	        public override ConsoleColor ForegroundColor
	        {
	            get
	            {
	                return Console.ForegroundColor;
	            }
	            set
	            {
	                Console.ForegroundColor = value;
	            }
	        }

	        public override BufferCell[,] GetBufferContents(Rectangle rectangle)
	        {
	            throw new Exception("Not implemented: ik.PowerShell.PS2EXEHostRawUI.GetBufferContents");
	        }

	        public override bool KeyAvailable
	        {
	            get
	            {
	                throw new Exception("Not implemented: ik.PowerShell.PS2EXEHostRawUI.KeyAvailable/Get");
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
	                f.ShowDialog();
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
	                s.X = Console.WindowLeft;
	                s.Y = Console.WindowTop;
	                return s;
	            }
	            set
	            {
	                Console.WindowLeft = value.X;
	                Console.WindowTop = value.Y;
	            }
	        }

	        public override Size WindowSize
	        {
	            get
	            {
	                Size s = new Size();
	                s.Height = Console.WindowHeight;
	                s.Width = Console.WindowWidth;
	                return s;
	            }
	            set
	            {
	                Console.WindowWidth = value.Width;
	                Console.WindowHeight = value.Height;
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
	                Console.Title = value;
	            }
	        }
	    }
	    internal class PS2EXEHostUI : PSHostUserInterface
	    {
			private const bool CONSOLE = $(if($noConsole){"false"}else{"true"});

			private PS2EXEHostRawUI rawUI = null;

	        public PS2EXEHostUI()
	            : base()
	        {
	            rawUI = new PS2EXEHostRawUI();
	        }

	        public override Dictionary<string, PSObject> Prompt(string caption, string message, System.Collections.ObjectModel.Collection<FieldDescription> descriptions)
	        {

	            if (!string.IsNullOrEmpty(caption))
	                WriteLine(caption);
	            if (!string.IsNullOrEmpty(message))
	                WriteLine(message);
	            Dictionary<string, PSObject> ret = new Dictionary<string, PSObject>();
	            foreach (FieldDescription cd in descriptions)
	            {
	                Type t = null;
	                if (string.IsNullOrEmpty(cd.ParameterAssemblyFullName))
	                    t = typeof(string);
	                else t = Type.GetType(cd.ParameterAssemblyFullName);


	                if (t.IsArray)
	                {
	                    Type elementType = t.GetElementType();
	                    Type genericListType = Type.GetType("System.Collections.Generic.List"+((char)0x60).ToString()+"1");
	                    genericListType = genericListType.MakeGenericType(new Type[] { elementType });
	                    ConstructorInfo constructor = genericListType.GetConstructor(BindingFlags.CreateInstance | BindingFlags.Instance | BindingFlags.Public, null, Type.EmptyTypes, null);
	                    object resultList = constructor.Invoke(null);

	                    int index = 0;
	                    string data = "";
	                    do
	                    {

							if (!string.IsNullOrEmpty(cd.Name))
								Write(string.Format("{0}[{1}]: ", cd.Name, index));
							data = ReadLine();

							if (string.IsNullOrEmpty(data))
								break;
							
							object o = System.Convert.ChangeType(data, elementType);

							genericListType.InvokeMember("Add", BindingFlags.InvokeMethod | BindingFlags.Public | BindingFlags.Instance, null, resultList, new object[] { o });
						
	                        index++;
	                    } while (true);

	                    System.Array retArray = (System.Array )genericListType.InvokeMember("ToArray", BindingFlags.InvokeMethod | BindingFlags.Public | BindingFlags.Instance, null, resultList, null);
	                    ret.Add(cd.Name, new PSObject(retArray));
	                }
	                else
	                {

	                    if (!string.IsNullOrEmpty(cd.Name))
	                        Write(string.Format("{0}: ", cd.Name));
	                    object o = null;

	                    string l = null;
	                    try
	                    {
	                        l = ReadLine();

	                        if (string.IsNullOrEmpty(l))
	                            o = cd.DefaultValue;
	                        if (o == null)
	                        {
	                            o = System.Convert.ChangeType(l, t);
	                        }

	                        ret.Add(cd.Name, new PSObject(o));
	                    }
	                    catch
	                    {
	                        throw new Exception("Exception in ik.PowerShell.PS2EXEHostUI.Prompt*2");
	                    }
	                }
	            }
	            return ret;
	        }

	        public override int PromptForChoice(string caption, string message, System.Collections.ObjectModel.Collection<ChoiceDescription> choices, int defaultChoice)
	        {
					
	            if (!string.IsNullOrEmpty(caption))
	                WriteLine(caption);
	            WriteLine(message);
	            int idx = 0;
	            SortedList<string, int> res = new SortedList<string, int>();



	                string s = Console.ReadLine().ToLower();
	                if (res.ContainsKey(s))
	                {
	                    return res[s];
	                }



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
	            return Console.ReadLine();
	        }

	        public override System.Security.SecureString ReadLineAsSecureString()
	        {

	            return null;
	        }

	        public override void Write(ConsoleColor foregroundColor, ConsoleColor backgroundColor, string value)
	        {
	            Console.ForegroundColor = foregroundColor;
	            Console.BackgroundColor = backgroundColor;
	            Console.Write(value);
	        }

	        public override void Write(string value)
	        {
	            Console.ForegroundColor = ConsoleColor.White;
	            Console.BackgroundColor = ConsoleColor.Black;
	            Console.Write(value);
	        }

	        public override void WriteDebugLine(string message)
	        {
	            Console.ForegroundColor = ConsoleColor.DarkMagenta;
	            Console.BackgroundColor = ConsoleColor.Black;
	            Console.WriteLine(message);
	        }

	        public override void WriteErrorLine(string value)
	        {
	            Console.ForegroundColor = ConsoleColor.Red;
	            Console.BackgroundColor = ConsoleColor.Black;
	            Console.WriteLine(value);
	        }

	        public override void WriteLine(string value)
	        {
	            Console.ForegroundColor = ConsoleColor.White;
	            Console.BackgroundColor = ConsoleColor.Black;
	            Console.WriteLine(value);
	        }

	        public override void WriteProgress(long sourceId, ProgressRecord record)
	        {

	        }

	        public override void WriteVerboseLine(string message)
	        {
	            Console.ForegroundColor = ConsoleColor.DarkCyan;
	            Console.BackgroundColor = ConsoleColor.Black;
	            Console.WriteLine(message);
	        }

	        public override void WriteWarningLine(string message)
	        {
	            Console.ForegroundColor = ConsoleColor.Yellow;
	            Console.BackgroundColor = ConsoleColor.Black;
	            Console.WriteLine(message);
	        }
	    }



	    internal class PS2EXEHost : PSHost
	    {
			private const bool CONSOLE = $(if($noConsole){"false"}else{"true"});

			private PS2EXEApp parent;
	        private PS2EXEHostUI ui = null;

	        private CultureInfo originalCultureInfo =
	            System.Threading.Thread.CurrentThread.CurrentCulture;

	        private CultureInfo originalUICultureInfo =
	            System.Threading.Thread.CurrentThread.CurrentUICulture;

	        private Guid myId = Guid.NewGuid();

	        public PS2EXEHost(PS2EXEApp app, PS2EXEHostUI ui)
	        {
	            this.parent = app;
	            this.ui = ui;
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
	                return new Version(0, 2, 0, 0);
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
	            this.parent.ExitCode = exitCode;
	        }
	    }



	    internal interface PS2EXEApp
	    {
	        bool ShouldExit { get; set; }
	        int ExitCode { get; set; }
	    }


	    internal class PS2EXE : PS2EXEApp
	    {
			private const bool CONSOLE = true;
			
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

	            bool paramWait = false;
	            string extractFN = string.Empty;

	            PS2EXEHostUI ui = new PS2EXEHostUI();
	            PS2EXEHost host = new PS2EXEHost(me, ui);
	            System.Threading.ManualResetEvent mre = new System.Threading.ManualResetEvent(false);

	            AppDomain.CurrentDomain.UnhandledException += new UnhandledExceptionEventHandler(CurrentDomain_UnhandledException);

	                using (Runspace myRunSpace = RunspaceFactory.CreateRunspace(host))
	                {
	                    $(if($sta -or $mta) {"myRunSpace.ApartmentState = System.Threading.ApartmentState."})$(if($sta){"STA"})$(if($mta){"MTA"});
	                    myRunSpace.Open();

	                    using (System.Management.Automation.PowerShell powershell = System.Management.Automation.PowerShell.Create())
	                    {
	                        Console.CancelKeyPress += new ConsoleCancelEventHandler(delegate(object sender, ConsoleCancelEventArgs e)
	                        {

	                                powershell.BeginStop(new AsyncCallback(delegate(IAsyncResult r)
	                                {
	                                    mre.Set();
	                                    e.Cancel = true;
	                                }), null);

	                        });

	                        powershell.Runspace = myRunSpace;
	                        powershell.Streams.Progress.DataAdded += new EventHandler<DataAddedEventArgs>(delegate(object sender, DataAddedEventArgs e)
	                            {
	                                ui.WriteLine(((PSDataCollection<ProgressRecord>)sender)[e.Index].ToString());
	                            });
	                        powershell.Streams.Verbose.DataAdded += new EventHandler<DataAddedEventArgs>(delegate(object sender, DataAddedEventArgs e)
	                            {
	                                ui.WriteVerboseLine(((PSDataCollection<VerboseRecord>)sender)[e.Index].ToString());
	                            });
	                        powershell.Streams.Warning.DataAdded += new EventHandler<DataAddedEventArgs>(delegate(object sender, DataAddedEventArgs e)
	                            {
	                                ui.WriteWarningLine(((PSDataCollection<WarningRecord>)sender)[e.Index].ToString());
	                            });
	                        powershell.Streams.Error.DataAdded += new EventHandler<DataAddedEventArgs>(delegate(object sender, DataAddedEventArgs e)
	                            {
	                                ui.WriteErrorLine(((PSDataCollection<ErrorRecord>)sender)[e.Index].ToString());
	                            });

	                        PSDataCollection<PSObject> inp = new PSDataCollection<PSObject>();
	                        inp.DataAdded += new EventHandler<DataAddedEventArgs>(delegate(object sender, DataAddedEventArgs e)
	                        {
	                            ui.WriteLine(inp[e.Index].ToString());
	                        });

	                        PSDataCollection<PSObject> outp = new PSDataCollection<PSObject>();
	                        outp.DataAdded += new EventHandler<DataAddedEventArgs>(delegate(object sender, DataAddedEventArgs e)
	                        {
	                            ui.WriteLine(outp[e.Index].ToString());
	                        });

	                        int separator = 0;
	                        int idx = 0;
	                        foreach (string s in args)
	                        {
	                            if (string.Compare(s, "-wait", true) == 0)
	                                paramWait = true;
	                            else if (s.StartsWith("-extract", StringComparison.InvariantCultureIgnoreCase))
	                            {
	                                string[] s1 = s.Split(new string[] { ":" }, 2, StringSplitOptions.RemoveEmptyEntries);
	                                if (s1.Length != 2)
	                                {
	                                    return 1;
	                                }
	                                extractFN = s1[1].Trim(new char[] { '\"' });
	                            }

	                            idx++;
	                        }

	                        string script = System.Text.Encoding.UTF8.GetString(System.Convert.FromBase64String(@"$($script)"));

	                        if (!string.IsNullOrEmpty(extractFN))
	                        {
	                            System.IO.File.WriteAllText(extractFN, script);
	                            return 0;
	                        }

							List<string> paramList = new List<string>(args);

	                        powershell.AddScript(script);
                        	powershell.AddParameters(paramList.GetRange(separator, paramList.Count - separator));
                        	powershell.AddCommand("out-string");
                        	powershell.AddParameter("-stream");


	                        powershell.BeginInvoke<PSObject, PSObject>(inp, outp, null, new AsyncCallback(delegate(IAsyncResult ar)
	                        {
	                            if (ar.IsCompleted)
	                                mre.Set();
	                        }), null);

	                        while (!me.ShouldExit && !mre.WaitOne(100))
	                        {
	                        };

	                        powershell.Stop();
	                    }

	                    myRunSpace.Close();
	                }

	            return me.ExitCode;
	        }


	        static void CurrentDomain_UnhandledException(object sender, UnhandledExceptionEventArgs e)
	        {
	            throw new Exception("Unhandeled exception in PS2EXE");
	        }
	    }
	}
"@
#endregion

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