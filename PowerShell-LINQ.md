# LINQ in PowerShell
LINQ (Language Integrated Query) is a .NET component that allows for data querying and filtering. Think of a combination PowerShell’s Where, Measure-Object, and Select cmdlets, but usually a lot faster than native PowerShell cmdlets, especially when dealing with large collections.

### List comparison with LINQ in PowerShell
We’re going to create a few lists and compare their contents with LINQ, including the order of the items in the lists.

$List1 = [List[string]]("one", "two", "three")
$List2 = [List[string]]("one", "two", "three")
$List3 = [List[string]]("three", "two", "one") # Same items, different order

[Linq.Enumerable]::SequenceEqual($List1, $List2);
#True

[Linq.Enumerable]::SequenceEqual($List1, $List3);
#False due to ordering being different
There is a Sort method we can use if we have lists where the items may have different ordering:

$List1.Sort()
$List2.Sort()
$List3.Sort()

[Linq.Enumerable]::SequenceEqual($List1, $List2);
#True

[Linq.Enumerable]::SequenceEqual($List1, $List3);
#True


## Getting minimum, maximum, average values from a collection
$List = [List[int]]::new()
1..100 | % {$List.Add((Get-Random -Minimum 1 -Maximum 1000))}

PS C:\> [Linq.Enumerable]::Min($List)
32

PS C:\> [Linq.Enumerable]::Max($List)
983

PS C:\> [Linq.Enumerable]::Average($List)
513.95

PS C:\> [Linq.Enumerable]::Sum($List)
51395


## As a very quick performance comparison let’s see how LINQ compares with Measure-Object for calculating the sum of one million numbers.

$List = [List[int]]::new()
1..1000000 | % {$List.Add((Get-Random -Minimum 1 -Maximum 100))}

### Measure-Object
PS C:\> 1..10 | % {Measure-Command {$List | Measure-Object -Sum}  | select -ExpandProperty TotalMilliseconds} | Measure-Object -Average
Average           : 857.56657

### Linq.Enumerable
PS C:\> 1..10 | % {Measure-Command {[Linq.Enumerable]::Sum($List)}  | select -ExpandProperty TotalMilliseconds} | Measure-Object -Average
Average           : 0.45215

In this example LINQ is ~1897 times faster

Source: https://xkln.net/blog/using-net-with-powershell/
