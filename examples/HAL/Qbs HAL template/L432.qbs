import qbs
import qbs.File
import qbs.FileInfo
import qbs.ModUtils
import qbs.TextFile
import qbs.Probes

Product {
    id: pr

    Depends { name: "cpp" }
    type: [
        "application",
        "bin",
        "hex",
    ]

    consoleApplication: true
    cpp.positionIndependentCode: false
    cpp.executableSuffix: ".elf"
    cpp.linkerMode: "manual"
    cpp.linkerName: "g++"
    cpp.cxxFlags: [ "-std=c++11" ]
    cpp.cFlags: [ "-std=gnu99" ]
    cpp.warningLevel: "all"

    name: makefile.match(/target\s*=\s*(.+)/i)[1]

    property string makefile: {
        var origPath = FileInfo.joinPaths(pr.sourceDirectory, "MAKEFILE");
        var mfile = new TextFile(origPath, TextFile.ReadOnly);
        var s = mfile.readAll().replace(/\\\n\s*/g, '');
        mfile.close();
        return s;
    }

    property stringList myDefines:[

    ]

    property stringList myIncludes:[

    ]

    cpp.defines: {
        var arr = (makefile.match(/^(C_DEFS)\s*[:\?\+]?=\s*(.*)$/m)[2].split(/\s*-D/));
        for(var i in arr){
            if(arr[i] === "")
                arr.splice(i, 1);
        }
        return arr.concat(myDefines)
    }

    cpp.includePaths: {
        var arr = makefile.match(/^(C_INCLUDES)\s*[:\?\+]?=\s*(.*)$/m)[2].split(/\s*-I/);
        for(var i in arr){
            if(arr[i] === "")
                arr.splice(i, 1);
        }
        return arr.concat(myIncludes)
    }

    property string cpu: makefile.match(/^(CPU)\s*[:\?\+]?=\s*(.*)$/m)[2]
    property string fpu: {
        var f = makefile.match(/^(FPU)\s*[:\?\+]?=\s*(.*)$/m);
        if(f === null)
             return "";
        else 
            return f[2];
    }
    property string float_abi:{
        var f = makefile.match(/^(FLOAT-ABI)\s*[:\?\+]?=\s*(.*)$/m);
        if(f === null)
             return "-msoft-float";
        else 
            return f[2];
    }

    cpp.commonCompilerFlags: [
        cpu,
        "-mthumb",
        fpu,
        float_abi,
        "-fdata-sections",
        "-ffunction-sections"

    ];

    cpp.linkerFlags: [
        cpu,
        "-mthumb",
        fpu,
        float_abi,
        "-lm",
        "-lc",
        "-lnosys",
        "-Xlinker",
        "--gc-sections",
        "-specs=nosys.specs",
        "-specs=nano.specs",
        // "-lc++",
        // "-lsupc",
        // "-Wno-fpermissive",
        // "-specs=rdimon.specs",
        "-fdata-sections",
        "-ffunction-sections",
        "-Wall",
        "-Xlinker",
        "--print-memory-usage",

    ]

    FileTagger {
        patterns:  ["*.ld"]
        fileTags: ["linkerscript"]
    }

    files:[
        "*.ioc",
        "*_FLASH.ld",
        "**/*.c",
        "**/*.cpp",
        "**/*.h",
        "**/*.hpp",
        "**/*startup_**.s",
    ]

    excludeFiles: [

    ]

    Properties
    {
        condition: qbs.buildVariant === "debug"
        cpp.defines: outer.concat(["DEBUG=1"])
        cpp.debugInformation: true
        cpp.optimization: "none"
        destinationDirectory: path+ "/build/debug"

    }
    Properties
    {
        condition: qbs.buildVariant === "release"
        cpp.debugInformation: false
        cpp.optimization: "fast"
        destinationDirectory: path+ "/build/release"
    }
}

