// SPDX-License-Identifier: ~~license~~
// 
// Copyright (C) __CopyrightYear__ __CopyrightOwner__
//#if (NormalizedLicense == 'GPL-2.0-only')
// 
// This file is part of MyNamespace.MyProject
// 
// This program is free software; you can redistribute it and/or modify
// it under the terms of version 2 of the GNU General Public License
// as published by the Free Software Foundation.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see
// <https://www.gnu.org/licenses/gpl-2.0.html>.
//#elseif (NormalizedLicense == 'GPL-3.0-only')
// 
// This file is part of MyNamespace.MyProject
// 
// This program is free software: you can redistribute it and/or modify
// it under the terms of version 3 of the GNU General Public License
// as published by the Free Software Foundation.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see
// <https://www.gnu.org/licenses/gpl-3.0.html>.
//#elseif (NormalizedLicense == 'LGPL-2.1-only')
// 
// This file is part of MyNamespace.MyProject
// 
// This library is free software; you can redistribute it and/or
// modify it under the terms of version 2.1 of the GNU Lesser
// General Public License as published by the Free Software Foundation.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library. If not, see
// <https://www.gnu.org/licenses/lgpl-2.1.html>.
//#elseif (NormalizedLicense == 'AGPL-3.0-only')
// 
// This file is part of MyNamespace.MyProject
// 
// This library is free software; you can redistribute it and/or
// modify it under the terms of version 2.1 of the GNU Lesser
// General Public License as published by the Free Software Foundation.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library. If not, see
// <https://www.gnu.org/licenses/agpl-3.0.html>.
//#endif

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
