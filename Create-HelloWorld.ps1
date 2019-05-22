Add-Type -TypeDefinition @'
public class Foo {
    public static void Main(string[] args) {
        System.Console.WriteLine("Hello, World!");
        System.Console.ReadKey();
    }
}
'@ -OutputAssembly .\HelloWorld.exe