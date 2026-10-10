using MyNamespace.MyProject;
using Xunit;

namespace MyNamespace.MyProject.Tests;

public class UnitTest1
{
    [Fact]
    public void GetMessage_ShouldReturnExpectedMessage()
    {
        Assert.Equal(
            "Hello from MyProject!",
            MyClass.GetMessage());
    }
}
