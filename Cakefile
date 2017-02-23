# https://github.com/jcampbell05/xcake
# http://www.rubydoc.info/github/jcampbell05/xcake/master/file/docs/Cakefile.md

iOSdeploymentTarget = "8.0"
currentSwiftVersion = "3.0"
companyIdentifier = "khatskevich.maxim"
developmentTeamId = "UJA88X59XP"
testSuffix = "Tst"

#===

project.name = "MKHOperationFlow"
project.class_prefix = "OFL"
project.organization = "Maxim Khatskevich"

#===

project.all_configurations.each do |configuration|

    configuration.settings["SDKROOT"] = "iphoneos"
    configuration.settings["DEBUG_INFORMATION_FORMAT"] = "dwarf"
    configuration.settings["CODE_SIGN_IDENTITY[sdk=iphoneos*]"] = "iPhone Developer"
    configuration.settings["TARGETED_DEVICE_FAMILY"] = "1,2"
    configuration.settings["IPHONEOS_DEPLOYMENT_TARGET"] = iOSdeploymentTarget
    configuration.settings["VERSIONING_SYSTEM"] = "apple-generic"

    configuration.settings["GCC_NO_COMMON_BLOCKS"] = "YES"
    configuration.settings["GCC_WARN_ABOUT_RETURN_TYPE"] = "YES_ERROR"
    configuration.settings["GCC_WARN_UNINITIALIZED_AUTOS"] = "YES_AGGRESSIVE"
    configuration.settings["CLANG_WARN_DIRECT_OBJC_ISA_USAGE"] = "YES_ERROR"
    configuration.settings["CLANG_WARN_OBJC_ROOT_CLASS"] = "YES_ERROR"

    configuration.settings["SWIFT_OPTIMIZATION_LEVEL"] = "-Onone"

    configuration.settings["CURRENT_PROJECT_VERSION"] = "1" # just default non-empty value

    #=== Xcode 8:

    configuration.settings["CLANG_WARN_INFINITE_RECURSION"] = "YES"
    configuration.settings["CLANG_WARN_SUSPICIOUS_MOVE"] = "YES"
    configuration.settings["ENABLE_STRICT_OBJC_MSGSEND"] = "YES"

    configuration.settings["SWIFT_VERSION"] = currentSwiftVersion # Xcode 8

    #===

    if configuration.name == "Release"

        configuration.settings["DEBUG_INFORMATION_FORMAT"] = "dwarf-with-dsym"
        configuration.settings["SWIFT_OPTIMIZATION_LEVEL"] = "-Owholemodule" # Xcode 8

    end

end

#=== Targets

target do |target|

    target.name = project.name
    target.type = :framework
    target.language = :swift
    target.platform = :ios
    target.deployment_target = iOSdeploymentTarget

    target.all_configurations.each do |configuration|

        #=== Build Settings - Core

        configuration.product_bundle_identifier = companyIdentifier + "." + target.name

        configuration.settings["INFOPLIST_FILE"] = "Info/" + target.name + ".plist"

        configuration.settings["PRODUCT_NAME"] = "$(TARGET_NAME)"

        # Xcode 8 automati c signing support
        configuration.settings["CODE_SIGN_IDENTITY[sdk=iphoneos*]"] = "iPhone Distribution"
        configuration.settings["DEVELOPMENT_TEAM"] = developmentTeamId

        configuration.settings["SWIFT_VERSION"] = currentSwiftVersion # Xcode 8

    end

    #=== Source Files

    target.include_files = ["Src/**/*.*"]
    target.include_files << "Src-Extra/**/*.*"

    #=== Tests
    
    unit_tests_for target do |test_target|
        
        test_target.name = target.name + testSuffix
        test_target.deployment_target = iOSdeploymentTarget

        test_target.all_configurations.each do |configuration|

            configuration.product_bundle_identifier = companyIdentifier + "." + test_target.name

            configuration.settings["INFOPLIST_FILE"] = "Info/" + test_target.name + ".plist"

            configuration.settings["LD_RUNPATH_SEARCH_PATHS"] = "$(inherited) @executable_path/Frameworks @loader_path/Frameworks"

            # Xcode 8 automati c signing support
            configuration.settings["CODE_SIGN_IDENTITY[sdk=iphoneos*]"] = "iPhone Distribution"
            configuration.settings["DEVELOPMENT_TEAM"] = developmentTeamId

            configuration.settings["SWIFT_VERSION"] = currentSwiftVersion # Xcode 8

        end

        #=== Source Files

        testTargetSrcPath = testSuffix + "/**/*.*"

        test_target.include_files = [testTargetSrcPath]

    end

end
