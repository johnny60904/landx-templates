using BenchmarkDotNet.Attributes;
using BenchmarkDotNet.Running;

using MyNamespace.MyProject;

BenchmarkRunner.Run<MyBenchmark>();

[MemoryDiagnoser]
public class MyBenchmark
{
    [Benchmark]
    public string GetMessage()
    {
        return MyClass.GetMessage();
    }
}
