# powershell -f perf_counter_measure_performance.ps1 -HostName DESKTOP-FH2D9SA -nSamples 5761 -nRate 15 > output_file.txt
# create table perfmon (dts datetime null, category sysname null, counter_name sysname null, instance sysname null, val numeric(38,8) null)
# bcp perfmon in output_file.txt -S DESKTOP-FH2D9SA -d dba -T -c -t"," -r "\n"
# bcp perfmon in output_file.txt -S DESKTOP-FH2D9SA -d dba -T -w -t"," -r "\n"	# IF The file is UNICODE!


param($HostName
, $nSamples
, $nRate
)

$code = '
using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace LocalCode
{
	public static class PerformanceCounterWrap
	{
        private static string machineName = "";

		//	Where key = "Category|Counter|Instance";
		//	eg:			"PhysicalDisk|Avg. Disk Queue Length|2 D:";
		private static Dictionary<string, PerformanceCounter>	dictPerformanceCounter = null;
		private static Dictionary<string, float>	dictValue = null;
		private static DateTime dtSampleTime;

		public static string[] instances(string sCategory)
		{
			PerformanceCounterCategory pcc = new PerformanceCounterCategory(sCategory);
			string[] instances = pcc.GetInstanceNames();
			return instances;
		}

		public static void init(string sMachineName = null)
		{
			if (sMachineName == null)
				machineName = System.Environment.MachineName;
			else
				machineName = sMachineName;

			dictPerformanceCounter = new Dictionary<string, PerformanceCounter>();
			dictValue = new Dictionary<string, float>();
			
			dtSampleTime = DateTime.Now;
		}
		
		public static DateTime sampletime()
		{
			return dtSampleTime;
		}

		public static void register(string sCategory, string sCounter, string sInstance)
		{
			string sKey = sCategory + "|" + sCounter + "|" + sInstance;
			dictPerformanceCounter[sKey] = new PerformanceCounter(sCategory,sCounter,sInstance,machineName);
			dictValue[sKey] = dictPerformanceCounter[sKey].NextValue();
		}

		public static void collect()
		{
			//nLastValue = pcPhysicalDisk_CDQLen.NextValue();
			dtSampleTime = DateTime.Now;
			foreach(string sKey in dictPerformanceCounter.Keys)
			{
				dictValue[sKey] = dictPerformanceCounter[sKey].NextValue();
			}
		}

		public static float get_value(string sCategory, string sCounter, string sInstance)
		{
			string sKey = sCategory + "|" + sCounter + "|" + sInstance;
			return dictValue[sKey];
		}
	}
}
'
Add-Type -ReferencedAssemblies System.Data -TypeDefinition $code -Language CSharp	

if ($nSamples -eq $null)
{
	$nSamples = 1
}
if ($nRate -eq $null)
{
	$nRate = 3
}

#iex "[LocalCode.PerformanceCounterWrap]::init()"
iex "[LocalCode.PerformanceCounterWrap]::init(""$HostName"")"
#iex "[LocalCode.PerformanceCounterWrap]::init(""DESKTOP-FH2D9SA"")"

#		//	Disk reads/sec + disk writes/sec = IOPS
#		//	Disk read bytes/sec + disk write bytes/sec = throughput
try
{
	$cnt = $nSamples
	$sleep_time = $nRate

	$counters = @()
	$counters += @([Tuple]::create("PhysicalDisk", "Disk Reads/sec"))
	$counters += @([Tuple]::create("PhysicalDisk", "Disk Writes/sec"))
	$counters += @([Tuple]::create("PhysicalDisk", "Disk Read Bytes/sec"))
	$counters += @([Tuple]::create("PhysicalDisk", "Disk Write Bytes/sec"))
	$counters += @([Tuple]::create("PhysicalDisk", "Avg. Disk sec/Read"))
	$counters += @([Tuple]::create("PhysicalDisk", "Avg. Disk sec/Write"))
	$counters += @([Tuple]::create("PhysicalDisk", "Avg. Disk Queue Length"))

	$AllDrives = iex "[LocalCode.PerformanceCounterWrap]::instances(""PhysicalDisk"")"
	foreach($drive_label in $AllDrives)
	{
		if ($drive_label -eq "_Total")
		{
			continue;
		}
		
		foreach($tup in $counters)
		{
			$category = $tup.item1
			$cntr = $tup.item2
			if ($category -eq "PhysicalDisk")	# just to be sure.
			{
				iex "[LocalCode.PerformanceCounterWrap]::register(""$category"",""$cntr"",""$drive_label"")"
			}
		}
	}  
	
	iex "[LocalCode.PerformanceCounterWrap]::collect()"
	$now = iex "[LocalCode.PerformanceCounterWrap]::sampletime()"
	#$now.ToString("yyyy/MM/dd HH:mm:ss.fffff");

	# we want to move to the 1/2 second boundary we would do a proportional sleep here.
	#	[this dodginess is about ensuring the "second" is always the sample period seperated (as there is a little error each sample that might tip over .999]
	# calculate the wait for the subsequent second + 1/2.
	$soon = $now.AddMilliseconds(1465 - [int]$now.ToString("fff"))
	$delta = $soon - $now
	#	wait for that.	
	$sleep_ms = ($delta).TotalMilliseconds;
	Start-Sleep -Milliseconds $sleep_ms
	#	re-sample.
	iex "[LocalCode.PerformanceCounterWrap]::collect()"
	$now = iex "[LocalCode.PerformanceCounterWrap]::sampletime()"
	
	$sampletime = $now
	
    while ($cnt -gt 0)
    {
		$cnt = $cnt - 1
		
		$sampletime_fmt = $sampletime.ToString("yyyy-MM-dd HH:mm:ss.fff");
		
		foreach($drive_label in $AllDrives)
		{
			if ($drive_label -eq "_Total")
			{
				continue;
			}

			foreach($tup in $counters)
			{
				$category = $tup.item1
				$cntr = $tup.item2
				$Counter = iex "[LocalCode.PerformanceCounterWrap]::get_value(""$category"",""$cntr"",""$drive_label"")"
				$CounterFmt = ($Counter).tostring("#.####")
				Write-Output "$sampletime_fmt,$category,$cntr,$drive_label,$CounterFmt`r"	# This [`r] bit is for the BCP in.  *sigh*
			}
		}
		
		# This slightly more intelligent approach will stop the "sleep creep" that happens with Sleep X seconds.
		$next_wake = $now.AddSeconds($sleep_time);
		$now = $next_wake
		
		$dur = $next_wake - $sampletime;
		$sleep_ms = ($dur).TotalMilliseconds;
		if ($sleep_ms -le 0)	# if a timeout occurs on the host, the last sampletime could be later next_wake!
		{
			$sleep_ms = 500
			$now = $sampletime.AddSeconds($sleep_time);	# not desirable, but needed in this error case.
		}
		Start-Sleep -Milliseconds $sleep_ms

		# collect and get time.
		iex "[LocalCode.PerformanceCounterWrap]::collect()"
		$sampletime = iex "[LocalCode.PerformanceCounterWrap]::sampletime()"
	}	
	exit 0
}
finally
{
    #write-host "Stopping..."
}
exit 0
